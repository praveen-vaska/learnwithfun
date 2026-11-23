import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  bool _hasError = false;
  bool _isPlaying = true;

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
              }
              // Clean YouTube branding, "More videos", cards, watermark, while keeping navigation controls
              controller.runJavaScript('''
                (function setupKidPlayer() {
                  var css = `
                    /* 1. Remove YouTube watermark logo and Watch on YouTube button */
                    html body .html5-video-player .ytp-youtube-button,
                    html body .ytp-chrome-bottom .ytp-right-controls .ytp-youtube-button,
                    html body a.ytp-youtube-button,
                    html body a[class*="ytp-youtube-button"],
                    html body [class*="ytp-watermark"],
                    html body .ytp-watermark,
                    html body .ytp-impression-link,
                    html body a.ytp-title-link,
                    html body a[href*="youtube.com/watch"],
                    html body [aria-label*="Watch on YouTube" i],
                    html body [title*="Watch on YouTube" i],

                    /* 2. Remove 'More videos' overlay and drawer */
                    html body [class*="ytp-pause-overlay"],
                    html body .ytp-pause-overlay,
                    html body .ytp-pause-overlay-container,
                    html body .ytp-expand-pause-overlay,
                    html body .ytp-show-tiles,
                    html body .ytp-scroll-min,
                    html body [aria-label*="More videos" i],
                    html body [title*="More videos" i],

                    /* 3. Remove end-screen suggested videos, cards, popups and teasers */
                    html body [class*="ytp-ce-"],
                    html body .ytp-ce-element,
                    html body .ytp-ce-video,
                    html body .ytp-ce-channel,
                    html body .ytp-ce-covering-overlay,
                    html body .ytp-ce-element-show,
                    html body [class*="ytp-cards-"],
                    html body .ytp-cards-teaser,
                    html body .ytp-cards-button,
                    html body .ytp-upnext,
                    html body [class*="ytp-endscreen-"],
                    html body .ytp-endscreen-content,
                    html body .ytp-autonav-endscreen-countdown-container,
                    html body .ytp-suggested-action-badge,

                    /* 4. Remove copy link / share buttons */
                    html body .ytp-button--link,
                    html body a.ytp-share-button,
                    html body .ytp-copylink-button,
                    html body [aria-label*="Copy link" i],
                    html body [aria-label*="Share" i],

                    /* 5. Remove large center play button and bezel */
                    html body [class*="ytp-large-play-button"],
                    html body .ytp-large-play-button,
                    html body .ytp-large-play-button-bg {
                      display: none !important;
                      visibility: hidden !important;
                      opacity: 0 !important;
                      pointer-events: none !important;
                      width: 0 !important;
                      height: 0 !important;
                      min-width: 0 !important;
                      min-height: 0 !important;
                      max-width: 0 !important;
                      max-height: 0 !important;
                      position: absolute !important;
                      top: -9999px !important;
                      left: -9999px !important;
                      clip: rect(0,0,0,0) !important;
                      transform: scale(0) !important;
                      z-index: -9999 !important;
                    }

                    /* 6. KEEP navigation and playback controls visible and interactive */
                    .ytp-chrome-bottom {
                      display: block !important;
                      visibility: visible !important;
                      opacity: 1 !important;
                    }
                    .ytp-chrome-controls {
                      display: flex !important;
                      visibility: visible !important;
                      opacity: 1 !important;
                    }
                    .ytp-play-button,
                    .ytp-progress-bar-container,
                    .ytp-time-display,
                    .ytp-fullscreen-button {
                      display: inline-block !important;
                      visibility: visible !important;
                      opacity: 1 !important;
                      pointer-events: auto !important;
                    }

                    body, html, #player, .html5-video-player {
                      background-color: #000 !important;
                      overflow: hidden !important;
                    }
                  `;

                  function injectStyle() {
                    try {
                      var style = document.getElementById('kid-clean-styles');
                      if (!style) {
                        style = document.createElement('style');
                        style.id = 'kid-clean-styles';
                        style.type = 'text/css';
                        (document.head || document.documentElement).appendChild(style);
                      }
                      if (style.textContent !== css) {
                        style.textContent = css;
                      }
                    } catch(e) {}
                  }

                  function purgeUnwanted() {
                    injectStyle();

                    var selectors = [
                      '.ytp-youtube-button',
                      'a.ytp-youtube-button',
                      'a[class*="ytp-youtube-button"]',
                      '.ytp-watermark',
                      '[class*="ytp-watermark"]',
                      '.ytp-impression-link',
                      'a.ytp-title-link',
                      '.ytp-button--link',
                      'a.ytp-share-button',
                      '.ytp-copylink-button',
                      '[aria-label*="More videos" i]',
                      '[title*="More videos" i]',
                      '[aria-label*="Watch on YouTube" i]',
                      '[title*="Watch on YouTube" i]',
                      '[aria-label*="Copy link" i]',
                      '[aria-label*="Share" i]',
                      '.ytp-pause-overlay',
                      '.ytp-pause-overlay-container',
                      '.ytp-expand-pause-overlay',
                      '[class*="ytp-pause-overlay"]',
                      '.ytp-show-tiles',
                      '.ytp-scroll-min',
                      '.ytp-ce-element',
                      '.ytp-ce-video',
                      '.ytp-ce-channel',
                      '.ytp-ce-covering-overlay',
                      '.ytp-ce-element-show',
                      '[class*="ytp-ce-"]',
                      '[class*="ytp-cards-"]',
                      '.ytp-cards-teaser',
                      '.ytp-cards-button',
                      '.ytp-upnext',
                      '.ytp-endscreen-content',
                      '[class*="ytp-endscreen-"]',
                      '.ytp-large-play-button',
                      '.ytp-large-play-button-bg',
                      '[class*="ytp-large-play-button"]'
                    ];

                    for (var s = 0; s < selectors.length; s++) {
                      try {
                        var elements = document.querySelectorAll(selectors[s]);
                        for (var i = 0; i < elements.length; i++) {
                          var el = elements[i];
                          try {
                            el.remove();
                          } catch(err) {
                            el.style.setProperty('display', 'none', 'important');
                            el.style.setProperty('visibility', 'hidden', 'important');
                            el.style.setProperty('opacity', '0', 'important');
                            el.style.setProperty('pointer-events', 'none', 'important');
                          }
                        }
                      } catch(e) {}
                    }
                  }

                  injectStyle();
                  purgeUnwanted();

                  try {
                    var observer = new MutationObserver(function() {
                      purgeUnwanted();
                    });
                    observer.observe(document.body || document.documentElement, {
                      childList: true,
                      subtree: true
                    });
                  } catch(e) {}

                  setInterval(purgeUnwanted, 400);

                  var vAttempts = 0;
                  var vTimer = setInterval(function() {
                    vAttempts++;
                    var v = document.querySelector('video');
                    if (v) {
                      if (v.paused) {
                        v.play().catch(function() {});
                      }
                      v.addEventListener('play', function() {
                        purgeUnwanted();
                        try { KidVideoBridge.postMessage('PLAYING'); } catch(e) {}
                      });
                      v.addEventListener('pause', function() {
                        purgeUnwanted();
                        try { KidVideoBridge.postMessage('PAUSED'); } catch(e) {}
                      });
                      v.addEventListener('ended', function() {
                        purgeUnwanted();
                        try { KidVideoBridge.postMessage('ENDED'); } catch(e) {}
                      });
                      v.addEventListener('timeupdate', function() {
                        purgeUnwanted();
                      });
                      if (!v.paused) {
                        clearInterval(vTimer);
                      }
                    }
                    if (vAttempts > 25) {
                      clearInterval(vTimer);
                    }
                  }, 250);
                })();
              ''');
            },
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url.toLowerCase();
              // Prevent opening standard YouTube watch pages or external links
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
              // Only fail if main frame genuinely failed to connect
              if (error.isForMainFrame == true &&
                  error.description != 'net::ERR_CONNECTION_REFUSED' &&
                  error.errorCode != -102) {
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
            if (message.message == 'PLAYING') {
              if (mounted && !_isPlaying) setState(() => _isPlaying = true);
            } else if (message.message == 'PAUSED') {
              if (mounted && _isPlaying) setState(() => _isPlaying = false);
            } else if (message.message == 'ENDED') {
              _confettiKey.currentState?.play();
              _playNextVideo(auto: true);
            }
          },
        );

      if (controller.platform is AndroidWebViewController) {
        final androidController =
            controller.platform as AndroidWebViewController;
        androidController.setMediaPlaybackRequiresUserGesture(false);
        androidController.setCustomWidgetCallbacks(
          onShowCustomWidget:
              (Widget customWidget, void Function() onCustomWidgetHidden) {
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: true,
                    builder: (BuildContext context) => PopScope(
                      onPopInvokedWithResult: (didPop, result) {
                        if (didPop) {
                          onCustomWidgetHidden();
                        }
                      },
                      child: Scaffold(
                        backgroundColor: Colors.black,
                        body: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(child: customWidget),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: SafeArea(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    onPressed: () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                      onCustomWidgetHidden();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
          onHideCustomWidget: () {
            if (mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        );
      }

      _webViewController = controller;
      _loadVideo(_currentStory.youtubeVideoId ?? 'yCjJyiqpAuU');
    } catch (e) {
      debugPrint('Error initializing WebViewController: $e');
      _webViewController = null;
    }
  }

  void _loadVideo(String videoId) {
    if (_webViewController == null) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isPlaying = true;
    });

    final embedUri = Uri.parse(
      'https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&controls=1&rel=0&iv_load_policy=3&modestbranding=1&enablejsapi=1&fs=1',
    );

    _webViewController!.loadRequest(
      embedUri,
      headers: const {'Referer': 'https://www.youtube.com'},
    );
  }

  void _seekRelative(int seconds) {
    if (_webViewController != null) {
      _webViewController!.runJavaScript('''
        (function() {
          var v = document.querySelector('video');
          if (v) {
            v.currentTime = Math.max(0, Math.min(v.duration || 999999, v.currentTime + ($seconds)));
          }
        })();
      ''');
    }
  }

  void _togglePlayPause() {
    if (_webViewController == null) return;
    if (_isPlaying) {
      _webViewController!.runJavaScript(
        'var v = document.querySelector("video"); if(v) v.pause();',
      );
      setState(() => _isPlaying = false);
    } else {
      _webViewController!.runJavaScript(
        'var v = document.querySelector("video"); if(v) v.play();',
      );
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
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
    if (_webViewController != null) {
      _webViewController!.runJavaScript('''
        (function() {
          var v = document.querySelector('video');
          if (v) {
            v.currentTime = 0;
            v.play();
          }
        })();
      ''');
    }
    setState(() => _isPlaying = true);
    _confettiKey.currentState?.play();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _currentStory.youtubeVideoId ?? 'yCjJyiqpAuU';
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
              // 1. Solid Kid-Friendly Top Navigation Bar (NO transparent overlap)
              _buildTopBar(context),

              // 2. High-Definition 16:9 Video Player Stage (Pinned at the top!)
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
                    child: (_isWebViewSupported && _webViewController != null)
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              WebViewWidget(controller: _webViewController!),
                              if (_hasError)
                                _buildErrorFallback(videoId)
                              else if (_isLoading)
                                _buildVideoThumbnailFallback(videoId),
                            ],
                          )
                        : _buildVideoThumbnailFallback(videoId),
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
                                // Soft Purple Child Music / Story Icon
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
        // Real Video Thumbnail
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
        // Dark translucent overlay with friendly loading spinner
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
