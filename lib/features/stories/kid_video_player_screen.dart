import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  WebViewController? _webViewController;
  late Story _currentStory;
  bool _isLoading = true;
  bool _isBuffering = false;
  bool _hasError = false;
  bool _isPlaying = true;
  bool _isFullscreen = false;

  // On-video overlay controls state
  bool _showControls = true;
  Timer? _hideControlsTimer;
  double _currentTime = 0.0;
  double _duration = 0.0;
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

  void _initWebViewController() {
    if (!_isWebViewSupported) return;

    try {
      late final WebViewController controller;
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = false;
                });
                _startHideControlsTimer();
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url.toLowerCase();
              if (url.startsWith('https://www.youtube.com/watch') ||
                  url.startsWith('https://m.youtube.com/watch') ||
                  url.contains('/channel/') ||
                  url.contains('/user/')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onWebResourceError: (error) {
              debugPrint(
                'WebView resource error [code: ${error.errorCode}, isMainFrame: ${error.isForMainFrame}]: ${error.description}',
              );
              // Only fail on critical main frame failures
              if (error.isForMainFrame == true &&
                  error.description != 'net::ERR_CONNECTION_REFUSED' &&
                  error.errorCode != -102 &&
                  error.errorCode != -6) {
                if (mounted && _isLoading) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
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
            final dur = (payload['duration'] as num?)?.toDouble() ?? 0.0;
            if (dur > 0) _duration = dur;
          });
          _startHideControlsTimer();
        }
      } else if (type == 'STATE_CHANGE') {
        final state = payload['state'] as String?;
        final cur = (payload['currentTime'] as num?)?.toDouble() ?? 0.0;
        final dur = (payload['duration'] as num?)?.toDouble() ?? 0.0;

        if (mounted) {
          setState(() {
            if (dur > 0) _duration = dur;
            if (!_isDraggingSlider) _currentTime = cur;

            if (state == 'PLAYING') {
              _isPlaying = true;
              _isLoading = false;
              _isBuffering = false;
              _startHideControlsTimer();
            } else if (state == 'PAUSED') {
              _isPlaying = false;
              _isBuffering = false;
              _showControls = true;
              _hideControlsTimer?.cancel();
            } else if (state == 'BUFFERING') {
              _isBuffering = true;
            } else if (state == 'ENDED') {
              _isPlaying = false;
              _isBuffering = false;
              _showControls = true;
              _confettiKey.currentState?.play();
              _playNextVideo(auto: true);
            }
          });
        }
      } else if (type == 'TIME_UPDATE') {
        final cur = (payload['currentTime'] as num?)?.toDouble() ?? 0.0;
        final dur = (payload['duration'] as num?)?.toDouble() ?? 0.0;
        if (mounted && !_isDraggingSlider) {
          setState(() {
            _currentTime = cur;
            if (dur > 0) _duration = dur;
          });
        }
      } else if (type == 'ERROR') {
        final code = payload['code'];
        debugPrint('YouTube player error event: $code');
        // Only set error if critical (100, 101, 150)
        if (code == 100 || code == 101 || code == 150) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing KidVideoBridge message: $e');
    }
  }

  String _buildPlayerHtml(String videoId) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; background: #000; overflow: hidden; }
    #player { width: 100%; height: 100%; position: absolute; top: 0; left: 0; }
  </style>
</head>
<body>
  <div id="player"></div>
  <script>
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    var player = null;
    var timeInterval = null;

    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        height: '100%',
        width: '100%',
        videoId: '$videoId',
        host: 'https://www.youtube-nocookie.com',
        playerVars: {
          'autoplay': 1,
          'playsinline': 1,
          'controls': 0,
          'rel': 0,
          'modestbranding': 1,
          'iv_load_policy': 3,
          'disablekb': 1,
          'fs': 0,
          'origin': 'https://www.youtube-nocookie.com',
          'widget_referrer': 'https://www.youtube-nocookie.com'
        },
        events: {
          'onReady': onPlayerReady,
          'onStateChange': onPlayerStateChange,
          'onError': onPlayerError
        }
      });
    }

    function notifyFlutter(type, data) {
      try {
        if (window.KidVideoBridge) {
          window.KidVideoBridge.postMessage(JSON.stringify({ type: type, data: data }));
        }
      } catch (e) {}
    }

    function onPlayerReady(event) {
      try {
        event.target.playVideo();
      } catch (e) {}
      var dur = 0;
      try { dur = player.getDuration(); } catch (e) {}
      notifyFlutter('READY', { duration: dur });
    }

    function onPlayerStateChange(event) {
      var stateMap = { '-1': 'UNSTARTED', '0': 'ENDED', '1': 'PLAYING', '2': 'PAUSED', '3': 'BUFFERING', '5': 'CUED' };
      var stateName = stateMap[event.data] || 'UNKNOWN';
      var cur = 0;
      var dur = 0;
      try { cur = player.getCurrentTime(); } catch (e) {}
      try { dur = player.getDuration(); } catch (e) {}
      notifyFlutter('STATE_CHANGE', { state: stateName, currentTime: cur, duration: dur });

      if (event.data === 1) {
        startTimeUpdater();
      } else {
        stopTimeUpdater();
      }
    }

    function startTimeUpdater() {
      stopTimeUpdater();
      timeInterval = setInterval(function() {
        if (player && typeof player.getCurrentTime === 'function') {
          var cur = player.getCurrentTime() || 0;
          var dur = player.getDuration() || 0;
          notifyFlutter('TIME_UPDATE', { currentTime: cur, duration: dur });
        }
      }, 500);
    }

    function stopTimeUpdater() {
      if (timeInterval) {
        clearInterval(timeInterval);
        timeInterval = null;
      }
    }

    function onPlayerError(event) {
      notifyFlutter('ERROR', { code: event.data });
    }

    function playerPlay() {
      if (player && player.playVideo) player.playVideo();
    }

    function playerPause() {
      if (player && player.pauseVideo) player.pauseVideo();
    }

    function playerSeekTo(sec) {
      if (player && player.seekTo) player.seekTo(sec, true);
    }

    function playerSeekRelative(delta) {
      if (player && player.getCurrentTime && player.seekTo) {
        var nextTime = Math.max(0, (player.getCurrentTime() || 0) + delta);
        player.seekTo(nextTime, true);
      }
    }

    function playerReplay() {
      if (player && player.seekTo && player.playVideo) {
        player.seekTo(0, true);
        player.playVideo();
      }
    }
  </script>
</body>
</html>
''';
  }

  void _loadVideo(String videoId) {
    if (_webViewController == null) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isPlaying = true;
      _isBuffering = false;
      _currentTime = 0.0;
      _duration = 0.0;
      _showControls = true;
    });

    _webViewController!.loadHtmlString(
      _buildPlayerHtml(videoId),
      baseUrl: 'https://www.youtube-nocookie.com',
    );
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _isPlaying) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startHideControlsTimer();
      }
    });
  }

  void _seekRelative(int seconds) {
    _webViewController?.runJavaScript('playerSeekRelative($seconds);');
    _startHideControlsTimer();
  }

  void _seekTo(double seconds) {
    _webViewController?.runJavaScript('playerSeekTo($seconds);');
  }

  void _togglePlayPause() {
    if (_webViewController == null) return;
    if (_isPlaying) {
      _webViewController!.runJavaScript('playerPause();');
      setState(() {
        _isPlaying = false;
        _showControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      _webViewController!.runJavaScript('playerPlay();');
      setState(() => _isPlaying = true);
      _startHideControlsTimer();
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  String _formatDuration(double seconds) {
    if (seconds.isNaN || seconds.isInfinite || seconds <= 0) return '0:00';
    final totalSecs = seconds.toInt();
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
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
    _webViewController?.runJavaScript('playerReplay();');
    setState(() => _isPlaying = true);
    _startHideControlsTimer();
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
      child: _isFullscreen
          ? _buildFullscreenPlayer(videoId)
          : _buildPortraitLayout(context, videoId),
    );
  }

  Widget _buildFullscreenPlayer(String videoId) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildVideoPlayerSurface(videoId),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, String videoId) {
    final channelName = _currentStory.youtubeChannel ?? 'LearnWithFun';
    final storiesState = context.watch<StoriesCubit>().state;
    final otherVideos = storiesState.stories
        .where((s) => s.id != _currentStory.id && s.hasVideo)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConfettiCelebration(
        key: _confettiKey,
        child: SafeArea(
          child: Column(
            children: [
              // 1. Solid Kid-Friendly Top Navigation Bar
              _buildTopBar(context),

              // 2. High-Definition 16:9 Video Player Stage with In-Video Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
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
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildVideoPlayerSurface(videoId),
                  ),
                ),
              ),

              // 3. Scrollable Below Stage: Controls, Metadata, Lyrics, & Other Songs
              Expanded(
                child: SingleChildScrollView(
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

                            // Big Kid-Friendly Navigation Action Buttons
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerSurface(String videoId) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. YouTube WebView (Underneath, pointer events ignored so child cannot click external links)
        if (_isWebViewSupported && _webViewController != null)
          IgnorePointer(
            ignoring: true,
            child: WebViewWidget(controller: _webViewController!),
          )
        else
          _buildVideoThumbnailFallback(videoId),

        // 2. Loading / Buffering / Error Overlays
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

        // 3. Interactive Kid-Friendly Video Controls Overlay (Play, Forward, Seek, Fullscreen)
        if (!_hasError && !_isLoading) _buildVideoControlsOverlay(),
      ],
    );
  }

  Widget _buildVideoControlsOverlay() {
    final current = _isDraggingSlider ? _dragValue : _currentTime;
    final displayTime = _formatDuration(current);
    final displayDuration = _formatDuration(_duration);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControlsVisibility,
      child: AnimatedOpacity(
        opacity: (_showControls || !_isPlaying) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: !_showControls && _isPlaying,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.45),
                  Colors.transparent,
                  Colors.black.withOpacity(0.65),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentStory.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Action Row: -10s, Play/Pause, +10s
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // -10s button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _seekRelative(-10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),

                    // Big Center Play / Pause button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(36),
                        onTap: _togglePlayPause,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple.withOpacity(0.5),
                                blurRadius: 16,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),

                    // +10s button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _seekRelative(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.forward_10_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Bar: Time elapsed, Seek slider, Duration, Fullscreen
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 8, 6),
                  child: Row(
                    children: [
                      Text(
                        displayTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.5,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12.0,
                            ),
                            activeTrackColor: AppColors.primaryPurple,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.white,
                            overlayColor: AppColors.primaryPurple.withOpacity(
                              0.3,
                            ),
                          ),
                          child: Slider(
                            value: current.clamp(
                              0.0,
                              _duration > 0 ? _duration : 1.0,
                            ),
                            max: _duration > 0 ? _duration : 1.0,
                            onChanged: (val) {
                              setState(() {
                                _isDraggingSlider = true;
                                _dragValue = val;
                              });
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
                      Text(
                        displayDuration,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          _isFullscreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: _toggleFullscreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 40),
            const SizedBox(height: 8),
            const Text(
              'Could not load video. Please check your internet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _loadVideo(videoId),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
