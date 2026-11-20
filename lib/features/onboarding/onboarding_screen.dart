import 'package:flutter/material.dart';

import '../../core/illustrations/kid_scenes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/app_button.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/floating_stars.dart';
import '../../core/animations/kid_animations.dart';
import 'age_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final int initialPage;

  const OnboardingScreen({super.key, this.initialPage = 0});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialPage,
  );
  late int _currentPage = widget.initialPage;

  static const List<_Slide> _slides = [
    _Slide(
      title: 'Fun Learning\nfor Curious Kids!',
      subtitle: 'Learn, play, and grow with interactive lessons and games.',
      image: AssetPaths.boyRocket,
      sky: [Color(0xFFE9E1FF), Color(0xFFD3C4FF)],
    ),
    _Slide(
      title: 'Play, Learn\nand Earn!',
      subtitle: 'Complete challenges, win stars and unlock exciting rewards.',
      image: AssetPaths.goldenTrophy,
      sky: [Color(0xFFFFF3D6), Color(0xFFE6DAFF)],
    ),
    _Slide(
      title: 'Stories, Games\n& More!',
      subtitle: 'Enjoy stories, rhymes and fun activities every day.',
      image: AssetPaths.fairytaleCastle,
      sky: [Color(0xFFDDF5FF), Color(0xFFE2D8FF)],
    ),
  ];

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToAgeSelection();
    }
  }

  void _goToAgeSelection() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AgeSelectionScreen()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: skip
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LearnWithFun',
                    style: AppTextStyles.heading3(
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: isLast ? 0 : 1,
                    child: TextButton(
                      onPressed: isLast ? null : _goToAgeSelection,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.buttonSmall(
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, _) {
                      // Distance of this page from the viewport centre (-1..1)
                      double delta = 0;
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        delta = (_pageController.page ?? 0) - index;
                      }
                      return _SlideView(
                        slide: slide,
                        delta: delta,
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primaryPurple
                              : AppColors.lavender.withAlpha(110),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  PulseGlow(
                    enabled: isLast,
                    child: AppButton(
                      label: isLast ? 'Get Started' : 'Next',
                      width: double.infinity,
                      icon: Icon(
                        isLast
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: _onNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final String title;
  final String subtitle;
  final String image;
  final List<Color> sky;

  const _Slide({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.sky,
  });
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  final double delta;
  final int index;

  const _SlideView({
    required this.slide,
    required this.delta,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final fade = (1 - delta.abs()).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Sky panel with clouds, stars and parallax illustration
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: slide.sky,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Transform.translate(
                        offset: Offset(delta * 60, 0),
                        child: const DriftingClouds(count: 4),
                      ),
                    ),
                    const Positioned.fill(child: FloatingStars(count: 7)),
                    // Ground hill
                    Positioned(
                      left: -40,
                      right: -40,
                      bottom: -90,
                      height: 170,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(150),
                          borderRadius: const BorderRadius.all(
                            Radius.elliptical(400, 170),
                          ),
                        ),
                      ),
                    ),
                    // Illustration — moves faster than the page (parallax)
                    Center(
                      child: Transform.translate(
                        offset: Offset(delta * -140, 0),
                        child: Transform.scale(
                          scale: 0.8 + 0.2 * fade,
                          child: Transform.rotate(
                            angle: delta * -0.25,
                            child: _sceneFor(index),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Expanded(
            flex: 3,
            child: Opacity(
              opacity: fade,
              child: Transform.translate(
                offset: Offset(delta * -40, 0),
                child: Column(
                  children: [
                    FadeSlideIn(
                      key: ValueKey('t$index'),
                      delay: const Duration(milliseconds: 150),
                      child: Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading1(
                          color: AppColors.darkPurple,
                        ).copyWith(fontSize: 30),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideIn(
                      key: ValueKey('s$index'),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge(
                          color: AppColors.textMedium,
                        ),
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
}

Widget _sceneFor(int index) {
  switch (index) {
    case 0:
      return const RocketBoyScene(size: 310);
    case 1:
      return const TrophyScene(size: 300);
    default:
      return const StoryCastleScene(size: 320);
  }
}
