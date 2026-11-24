import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../core/services/audio_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_vector_graphic.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../blocs/stories_cubit.dart';
import '../../data/models/story.dart';

class KidVideoPlayerScreen extends StatefulWidget {
  final Story story;

  const KidVideoPlayerScreen({super.key, required this.story});

  @override
  State<KidVideoPlayerScreen> createState() => _KidVideoPlayerScreenState();
}

class _KidVideoPlayerScreenState extends State<KidVideoPlayerScreen> {
  final GlobalKey<ConfettiCelebrationState> _confettiKey =
      GlobalKey<ConfettiCelebrationState>();
  final GlobalKey _webViewKey = GlobalKey();

  WebViewController? _webViewController;
  late Story _currentStory;
  bool _isLoading = true;
  bool _isBuffering = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isPlaying = true;
  bool _isFullscreen = false;
  Timer? _controlsTimer;
  bool _showFullscreenControls = true;
  double _currentTime = 0.0;
  double _totalDuration = 0.0;
  bool _isDraggingSlider = false;
  double _dragValue = 0.0;

  bool get _isWebViewSupported {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _currentStory = widget.story;
    _initWebViewController();
  }

  Future<void> _launchYouTubeExternal([String? customUrl]) async {
    final videoId = _currentStory.youtubeVideoId ?? 'yCjJyiqpAuU';
    final targetUrl = customUrl != null && customUrl.isNotEmpty
        ? customUrl
        : 'https://www.youtube.com/watch?v=$videoId';
    final uri = Uri.parse(targetUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching external YouTube app: $e');
    }
  }

  void _initWebViewController() {
    if (!_isWebViewSupported) return;

    try {
      late final WebViewController controller;
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                _injectVideoCleanScript();
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url.toLowerCase();
              if (url.contains('watch?v=') || url.contains('youtu.be/')) {
                _launchYouTubeExternal(request.url);
                return NavigationDecision.prevent;
              }
              if (url.contains('/embed/') ||
                  url.contains('googlevideo.com') ||
                  url.contains('youtube.com') ||
                  url.contains('youtube-nocookie.com') ||
                  url.contains('learnwithfun.kids')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
            onWebResourceError: (error) {
              debugPrint(
                'WebView resource error [code: ${error.errorCode}, isMainFrame: ${error.isForMainFrame}]: ${error.description}',
              );
              if (error.isForMainFrame == true &&
                  error.description != 'net::ERR_CONNECTION_REFUSED' &&
                  error.errorCode != -102 &&
                  error.errorCode != -6) {
                if (mounted && _isLoading) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _errorMessage = error.description;
                  });
                }
              }
            },
          ),
        )
        ..addJavaScriptChannel(
          'KidVideoBridge',
          onMessageReceived: (JavaScriptMessage message) {
            _handleJsBridgeMessage(message.message);
          },
        );

      if (controller.platform is AndroidWebViewController) {
        final androidController =
            controller.platform as AndroidWebViewController;
        androidController.setMediaPlaybackRequiresUserGesture(false);
      }

      _webViewController = controller;
      _loadVideo(_currentStory.youtubeVideoId ?? 'yCjJyiqpAuU');
    } catch (e) {
      debugPrint('Error initializing WebViewController: $e');
      _webViewController = null;
    }
  }

  void _handleJsBridgeMessage(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final payload = data['data'] as Map<String, dynamic>? ?? {};

      if (type == 'READY') {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
        }
      } else if (type == 'STATE_CHANGE') {
        final state = payload['state'] as String?;

        if (mounted) {
          setState(() {
            if (state == 'PLAYING') {
              _isPlaying = true;
              _isLoading = false;
              _isBuffering = false;
            } else if (state == 'PAUSED') {
              _isPlaying = false;
              _isBuffering = false;
            } else if (state == 'BUFFERING') {
              _isBuffering = true;
            } else if (state == 'ENDED') {
              _isPlaying = false;
              _isBuffering = false;
              _confettiKey.currentState?.play();
              _playNextVideo(auto: true);
            }
          });
        }
      } else if (type == 'TIME_UPDATE') {
        final current = (payload['current'] as num?)?.toDouble() ?? 0.0;
        final duration = (payload['duration'] as num?)?.toDouble() ?? 0.0;
        if (mounted && !_isDraggingSlider) {
          setState(() {
            _currentTime = current;
            if (duration > 0) _totalDuration = duration;
          });
        }
      } else if (type == 'ERROR_SCREEN') {
        final msg = payload['message'] as String? ?? '';
        debugPrint('YouTube error screen detected in DOM: $msg');
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = msg;
          });
        }
      } else if (type == 'ERROR') {
        final code = payload['code'];
        debugPrint('YouTube player error event: $code');
        if (code == 100 || code == 101 || code == 150) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _isLoading = false;
              _errorMessage = 'Playback error (Code $code)';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing KidVideoBridge message: $e');
    }
  }

  void _injectVideoCleanScript() {
    if (_webViewController == null) return;
    const script = '''
      (function() {
        var style = document.getElementById('kid-clean-style');
        if (!style) {
          style = document.createElement('style');
          style.id = 'kid-clean-style';
          style.innerHTML = `
            .ytp-chrome-top, 
            .ytp-chrome-bottom, 
            .ytp-show-cards-title, 
            .ytp-pause-overlay, 
            .ytp-scroll-min, 
            .ytp-watermark,
            .ytp-youtube-button,
            .ytp-title,
            .ytp-share-button,
            .ytp-more-videos-view,
            .ytp-contextmenu {
              display: none !important;
            }
          `;
          document.head.appendChild(style);
        }

        function checkErrors() {
          var err = document.querySelector('.ytp-error, .player-error-screen, .ytp-error-content, .ytp-chrome-top-buttons');
          if (err && err.innerText && err.innerText.trim().length > 0) {
            var text = err.innerText.trim();
            if (text.includes('unavailable') || text.includes('152') || text.includes('disabled') || text.includes('Error')) {
              if (window.KidVideoBridge) {
                window.KidVideoBridge.postMessage(JSON.stringify({
                  type: 'ERROR_SCREEN',
                  data: { message: text }
                }));
              }
            }
          }
        }
        setInterval(checkErrors, 1000);

        function setupVideoListener() {
          var v = document.querySelector('video');
          if (v) {
            v.play().catch(function() {});
            v.ontimeupdate = function() {
              if (window.KidVideoBridge) {
                window.KidVideoBridge.postMessage(JSON.stringify({
                  type: 'TIME_UPDATE',
                  data: { current: v.currentTime, duration: v.duration || 0 }
                }));
              }
            };
            v.onended = function() {
              if (window.KidVideoBridge) {
                window.KidVideoBridge.postMessage(JSON.stringify({
                  type: 'STATE_CHANGE',
                  data: { state: 'ENDED' }
                }));
              }
            };
            v.onplay = function() {
              if (window.KidVideoBridge) {
                window.KidVideoBridge.postMessage(JSON.stringify({
                  type: 'STATE_CHANGE',
                  data: { state: 'PLAYING' }
                }));
              }
            };
            v.onpause = function() {
              if (window.KidVideoBridge) {
                window.KidVideoBridge.postMessage(JSON.stringify({
                  type: 'STATE_CHANGE',
                  data: { state: 'PAUSED' }
                }));
              }
            };
          } else {
            setTimeout(setupVideoListener, 300);
          }
        }
        setupVideoListener();
      })();
    ''';
    _webViewController!.runJavaScript(script);
  }

  void _loadVideo(String videoId) {
    if (_webViewController == null) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isPlaying = true;
      _isBuffering = false;
      _currentTime = 0.0;
      _totalDuration = 0.0;
      _isDraggingSlider = false;
    });

    final embedUrl = Uri.parse(
      'https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&controls=0&rel=0&modestbranding=1&enablejsapi=1&iv_load_policy=3&fs=0&disablekb=1&origin=https://learnwithfun.kids',
    );
    _webViewController!.loadRequest(
      embedUrl,
      headers: const {
        'Referer': 'https://learnwithfun.kids/',
      },
    );
  }

  String _formatTime(double seconds) {
    if (seconds.isNaN || seconds.isInfinite || seconds < 0) return '00:00';
    final int totalSec = seconds.toInt();
    final int min = totalSec ~/ 60;
    final int sec = totalSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _startHideControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showFullscreenControls && !_isDraggingSlider) {
        setState(() {
          _showFullscreenControls = false;
        });
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showFullscreenControls = !_showFullscreenControls;
    });
    if (_showFullscreenControls) {
      _startHideControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _seekTo(double seconds) {
    _webViewController?.runJavaScript(
      "var v = document.querySelector('video'); if (v) v.currentTime = $seconds;",
    );
  }

  void _seekRelative(int seconds) {
    _webViewController?.runJavaScript(
      "var v = document.querySelector('video'); if (v) v.currentTime = Math.max(0, v.currentTime + $seconds);",
    );
  }

  void _togglePlayPause() {
    if (_webViewController == null) return;
    if (_isPlaying) {
      _webViewController!.runJavaScript(
        "var v = document.querySelector('video'); if (v) v.pause();",
      );
      setState(() => _isPlaying = false);
    } else {
      _webViewController!.runJavaScript(
        "var v = document.querySelector('video'); if (v) v.play();",
      );
      setState(() => _isPlaying = true);
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      _showFullscreenControls = true;
      if (_isFullscreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        _startHideControlsTimer();
      } else {
        _controlsTimer?.cancel();
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });

    if (_isPlaying) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _isPlaying) {
          _webViewController?.runJavaScript('playerPlay();');
        }
      });
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    AppAudioService.instance.stop();
    super.dispose();
  }

  void _switchStory(Story newStory) {
    setState(() {
      _currentStory = newStory;
      final videoId = newStory.youtubeVideoId ?? 'yCjJyiqpAuU';
      _loadVideo(videoId);
    });
  }

  void _playNextVideo({bool auto = false}) {
    final stories = context
        .read<StoriesCubit>()
        .state
        .stories
        .where((s) => s.hasVideo)
        .toList();
    if (stories.isEmpty) return;

    final currentIndex = stories.indexWhere((s) => s.id == _currentStory.id);
    final nextIndex = (currentIndex + 1) % stories.length;
    final nextStory = stories[nextIndex];

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auto
                ? 'Up Next: ${nextStory.title} 🎵'
                : 'Playing: ${nextStory.title} 🎵',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.primaryPurple,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
    _switchStory(nextStory);
  }

  void _playPreviousVideo() {
    final stories = context
        .read<StoriesCubit>()
        .state
        .stories
        .where((s) => s.hasVideo)
        .toList();
    if (stories.isEmpty) return;

    final currentIndex = stories.indexWhere((s) => s.id == _currentStory.id);
    final prevIndex = (currentIndex - 1 + stories.length) % stories.length;
    final prevStory = stories[prevIndex];

    _switchStory(prevStory);
  }

  void _replayVideo() {
    _webViewController?.runJavaScript(
      "var v = document.querySelector('video'); if (v) { v.currentTime = 0; v.play(); }",
    );
    setState(() => _isPlaying = true);
    _confettiKey.currentState?.play();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _currentStory.youtubeVideoId ?? 'yCjJyiqpAuU';

    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isFullscreen) {
          _toggleFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: _isFullscreen ? Colors.black : AppColors.background,
        body: ConfettiCelebration(
          key: _confettiKey,
          child: SafeArea(
            top: !_isFullscreen,
            bottom: !_isFullscreen,
            left: false,
            right: false,
            child: Column(
              children: [
                // 1. Top Bar (Only visible in Portrait mode)
                if (!_isFullscreen) _buildTopBar(context),

                // 2. Video Stage: Sits in the EXACT SAME place in the widget tree across portrait & landscape!
                // This ensures the native Android WebView SurfaceView is NEVER destroyed or reparented.
                Expanded(
                  flex: _isFullscreen ? 1 : 0,
                  child: Container(
                    width: double.infinity,
                    margin: _isFullscreen
                        ? EdgeInsets.zero
                        : const EdgeInsets.fromLTRB(16, 2, 16, 10),
                    decoration: _isFullscreen
                        ? const BoxDecoration(color: Colors.black)
                        : BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                    clipBehavior: _isFullscreen ? Clip.none : Clip.antiAlias,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildVideoPlayerSurface(videoId),
                      ),
                    ),
                  ),
                ),

                // 3. Scrollable Portrait Content (Only visible in Portrait mode)
                if (!_isFullscreen)
                  Expanded(
                    child: _buildPortraitContent(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenControlsOverlay() {
    final effectiveTime = _isDraggingSlider ? _dragValue : _currentTime;
    final maxDuration = _totalDuration > 0 ? _totalDuration : 1.0;
    final currentSliderVal = effectiveTime.clamp(0.0, maxDuration);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControlsVisibility,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.75),
              Colors.black.withOpacity(0.15),
              Colors.black.withOpacity(0.15),
              Colors.black.withOpacity(0.85),
            ],
            stops: const [0.0, 0.25, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back to Portrait, Title, and Replay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: _toggleFullscreen,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _currentStory.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 6, color: Colors.black87),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _replayVideo();
                        _startHideControlsTimer();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.replay_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center Area: -10s, Big Play/Pause, +10s
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // -10s Rewind Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          _seekRelative(-10);
                          _startHideControlsTimer();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),

                    // Big Play/Pause Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () {
                          _togglePlayPause();
                          _startHideControlsTimer();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),

                    // +10s Fast Forward Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          _seekRelative(10);
                          _startHideControlsTimer();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.forward_10_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Area: Scrubber Bar, Time Labels, and Fullscreen Exit Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  // Current Time
                  Text(
                    _formatTime(effectiveTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Draggable Video Bar Slider
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 18,
                        ),
                        activeTrackColor: AppColors.primaryPurple,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        overlayColor: AppColors.primaryPurple.withOpacity(0.3),
                      ),
                      child: Slider(
                        min: 0.0,
                        max: maxDuration,
                        value: currentSliderVal,
                        onChanged: (val) {
                          setState(() {
                            _isDraggingSlider = true;
                            _dragValue = val;
                          });
                          _startHideControlsTimer();
                        },
                        onChangeEnd: (val) {
                          _seekTo(val);
                          setState(() {
                            _isDraggingSlider = false;
                            _currentTime = val;
                          });
                          _startHideControlsTimer();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Total Duration
                  Text(
                    _formatTime(_totalDuration),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Exit Fullscreen Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _toggleFullscreen,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fullscreen_exit_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildPortraitContent(BuildContext context) {
    final channelName = _currentStory.youtubeChannel ?? 'LearnWithFun';
    final storiesState = context.watch<StoriesCubit>().state;
    final otherVideos = storiesState.stories
        .where((s) => s.id != _currentStory.id && s.hasVideo)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      // Kid-Friendly Navigation & Player Control Bar
                      AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.softPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _currentStory.isRhyme
                                        ? Icons.music_note_rounded
                                        : Icons.auto_stories_rounded,
                                    color: AppColors.primaryPurple,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _currentStory.title,
                                        style: AppTextStyles.heading2()
                                            .copyWith(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            channelName,
                                            style:
                                                AppTextStyles.bodySmall(
                                                  color:
                                                      AppColors.primaryPurple,
                                                ).copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 14,
                                            color: AppColors.primaryPurple,
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: () => _launchYouTubeExternal(),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.08,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.red.withOpacity(
                                                    0.3,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.play_arrow_rounded,
                                                    color: Colors.red,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    'YouTube 📺',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Badges: Language & Duration & Type
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildPill(
                                  icon: Icons.language_rounded,
                                  label: _currentStory.language == 'Telugu'
                                      ? '🇮🇳 Telugu (తెలుగు)'
                                      : _currentStory.language == 'Hindi'
                                      ? '🇮🇳 Hindi (हिंदी)'
                                      : '🇬🇧 English',
                                  color: AppColors.primaryPurple,
                                  bgColor: AppColors.softPurple,
                                ),
                                _buildPill(
                                  icon: Icons.schedule_rounded,
                                  label: _currentStory.durationText
                                      .split('•')
                                      .first
                                      .trim(),
                                  color: AppColors.textMedium,
                                  bgColor: AppColors.background,
                                ),
                                _buildPill(
                                  icon: _currentStory.isRhyme
                                      ? Icons.audiotrack_rounded
                                      : Icons.menu_book_rounded,
                                  label: _currentStory.isRhyme
                                      ? 'Kids Rhyme'
                                      : 'Moral Story',
                                  color: const Color(0xFFE97D00),
                                  bgColor: const Color(0xFFFFF3E0),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Big Kid-Friendly Navigation Action Buttons (Primary Controls)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Row 1: Main Playback (Previous, Large Play/Pause, Next)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildControlButton(
                                          icon: Icons.skip_previous_rounded,
                                          label: 'Previous',
                                          onTap: _playPreviousVideo,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildControlButton(
                                          icon: _isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          label: _isPlaying ? 'Pause' : 'Play',
                                          isPrimary: true,
                                          onTap: _togglePlayPause,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildControlButton(
                                          icon: Icons.skip_next_rounded,
                                          label: 'Next Song',
                                          onTap: () =>
                                              _playNextVideo(auto: false),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(
                                    height: 1,
                                    color: AppColors.borderLight,
                                  ),
                                  const SizedBox(height: 8),
                                  // Row 2: Seeking & Fun (-10s, +10s, Replay, Yay!)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildControlButton(
                                          icon: Icons.replay_10_rounded,
                                          label: '-10s',
                                          onTap: () => _seekRelative(-10),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildControlButton(
                                          icon: Icons.forward_10_rounded,
                                          label: '+10s',
                                          onTap: () => _seekRelative(10),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildControlButton(
                                          icon: Icons.replay_rounded,
                                          label: 'Replay',
                                          onTap: _replayVideo,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildControlButton(
                                          icon: Icons.celebration_rounded,
                                          label: 'Yay!',
                                          color: AppColors.pinkDark,
                                          onTap: () =>
                                              _confettiKey.currentState?.play(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Sing-Along Lyrics or Moral Lesson Card
                      if (_currentStory.lyrics.isNotEmpty) ...[
                        _buildLyricsSection(),
                        const SizedBox(height: 14),
                      ] else ...[
                        _buildMoralStorySection(),
                        const SizedBox(height: 14),
                      ],

                      // "More Songs & Stories For You" Carousel
                      if (otherVideos.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'More Songs for You 🎵',
                              style: AppTextStyles.heading2().copyWith(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${otherVideos.length} songs',
                              style: AppTextStyles.bodySmall(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: otherVideos.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final item = otherVideos[index];
                              final itemVideoId = item.youtubeVideoId ?? '';

                              return GestureDetector(
                                onTap: () => _switchStory(item),
                                child: Container(
                                  width: 145,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadow,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: itemVideoId.isNotEmpty
                                            ? Image.network(
                                                'https://img.youtube.com/vi/$itemVideoId/mqdefault.jpg',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => AppVectorGraphic(
                                                      assetPath:
                                                          item.coverAsset,
                                                      fit: BoxFit.cover,
                                                    ),
                                              )
                                            : AppVectorGraphic(
                                                assetPath: item.coverAsset,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.heading3()
                                              .copyWith(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                );
  }

  Widget _buildVideoPlayerSurface(
    String videoId, {
    bool showCornerToggle = true,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. YouTube WebView (stays permanently mounted in the same tree branch)
        if (_isWebViewSupported && _webViewController != null)
          WebViewWidget(
            key: _webViewKey,
            controller: _webViewController!,
          )
        else
          _buildVideoThumbnailFallback(videoId),

        // 2. Full Surface Tap Detector Layer
        // In Portrait: Tapping video toggles play/pause cleanly
        // In Fullscreen: Tapping video toggles the full navigation overlay on/off
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_isFullscreen) {
                _toggleControlsVisibility();
              } else {
                _togglePlayPause();
              }
            },
            child: const ColoredBox(
              color: Colors.transparent,
              child: SizedBox.expand(),
            ),
          ),
        ),

        // 3. Loading / Buffering / Error Overlays
        if (_hasError)
          _buildErrorFallback(videoId)
        else if (_isLoading)
          _buildVideoThumbnailFallback(videoId)
        else if (_isBuffering)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryPurple,
              strokeWidth: 3.5,
            ),
          ),

        // 4. Portrait Corner Fullscreen Toggle Button (bottom-right)
        if (!_isFullscreen && showCornerToggle)
          Positioned(
            right: 10,
            bottom: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _toggleFullscreen,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

        // 5. Fullscreen Navigation & Scrubber Overlay (Tap screen to show/hide)
        if (_isFullscreen)
          AnimatedOpacity(
            opacity: _showFullscreenControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_showFullscreenControls,
              child: _buildFullscreenControlsOverlay(),
            ),
          ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textDark,
              ),
              onPressed: () {
                AppAudioService.instance.stop();
                Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentStory.title,
              style: AppTextStyles.heading2().copyWith(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _currentStory.isRhyme ? '🎵 Rhyme' : '📖 Story',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _toggleFullscreen,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Fullscreen',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    Color? color,
  }) {
    final activeColor =
        color ?? (isPrimary ? AppColors.primaryPurple : AppColors.textMedium);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppColors.primaryPurple
                    : AppColors.softPurple.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : activeColor,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                  color: activeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnailFallback(String videoId) {
    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return AppVectorGraphic(
              assetPath: _currentStory.coverAsset,
              fit: BoxFit.cover,
            );
          },
        ),
        Container(
          color: Colors.black45,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryPurple,
                    strokeWidth: 3.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Loading Fun Video... 🎵',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorFallback(String videoId) {
    final is152 = _errorMessage.contains('152') || _errorMessage.contains('ad');
    final isOwnerDisabled =
        _errorMessage.contains('disabled by the video owner') ||
        _errorMessage.contains('150') ||
        _errorMessage.contains('101');

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_display_rounded,
                  color: AppColors.primaryPurple,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                is152
                    ? 'Private DNS / Ad-Blocker Alert'
                    : (isOwnerDisabled
                        ? 'Playback Restricted by Owner'
                        : 'Video Unavailable in Embed'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                is152
                    ? 'If your phone uses AdGuard Private DNS, YouTube embed checks may be blocked. You can turn off Private DNS in phone settings or watch directly on YouTube.'
                    : (isOwnerDisabled
                        ? 'The channel owner has disabled in-app embedding for this video. You can still watch it directly on YouTube!'
                        : 'You can watch this rhyme safely on YouTube or try refreshing.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _launchYouTubeExternal(),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Watch on YouTube'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _loadVideo(videoId),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsSection() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.music_note_rounded,
                color: AppColors.primaryPurple,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Sing Along Lyrics 🎤',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._currentStory.lyrics.map(
            (line) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐ ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      line,
                      style: AppTextStyles.bodyMedium().copyWith(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoralStorySection() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.softPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Moral of the Story',
                style: AppTextStyles.heading2().copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentStory.moral,
            style: AppTextStyles.bodyMedium().copyWith(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _currentStory.pages.first,
            style: AppTextStyles.bodySmall(color: AppColors.textMedium)
                .copyWith(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
