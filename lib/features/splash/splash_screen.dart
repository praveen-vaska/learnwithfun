import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/illustrations/kid_scenes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/animations/floating_stars.dart';
import '../../core/animations/fade_slide_in.dart';
import '../../core/animations/kid_animations.dart';
import '../../blocs/auth_cubit.dart';
import '../auth/screens/login_screen.dart';
import '../main_nav/main_nav_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _start(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final Widget destination = (authState is Authenticated || authState is GuestExplorer)
        ? const MainNavScreen()
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, anim, secAnim) => destination,
        transitionsBuilder: (context, anim, secAnim, child) {
          // Circular "magic portal" reveal from the button area.
          return AnimatedBuilder(
            animation: anim,
            child: child,
            builder: (context, child) {
              final size = MediaQuery.sizeOf(context);
              final maxR = sqrt(
                size.width * size.width + size.height * size.height,
              );
              return ClipPath(
                clipper: _CircleRevealClipper(
                  center: Offset(size.width / 2, size.height * 0.88),
                  radius: maxR * Curves.easeInOutCubic.transform(anim.value),
                ),
                child: child,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF9B7BFF), Color(0xFF7952F5), Color(0xFF6236E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DriftingClouds(count: 5, color: Color(0x26FFFFFF)),
            ),
            // Soft glowing floor ellipse under the mascot
            Positioned(
              left: -60,
              right: -60,
              bottom: -120,
              height: 360,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withAlpha(70),
                      Colors.white.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: FloatingStars(
                count: 14,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      // Title: two lines, letters bounce in one by one
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Semantics(
                            label: 'Learn With Fun!',
                            header: true,
                            child: ExcludeSemantics(
                              child: Column(
                                children: [
                                  _BouncyTitle(
                                    text: 'Learn',
                                    startDelay: 300,
                                    fontSize: 52,
                                  ),
                                  _BouncyTitle(
                                    text: 'With Fun!',
                                    startDelay: 600,
                                    fontSize: 46,
                                    color: AppColors.yellow,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: -26,
                            top: -6,
                            child: PopIn(
                              delay: const Duration(milliseconds: 1300),
                              fromRotation: -1.5,
                              curve: Curves.elasticOut,
                              child: Wiggle(
                                autoEvery: const Duration(seconds: 3),
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.yellow,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 1100),
                        child: Text(
                          'Kids Smart Learning App',
                          style: AppTextStyles.bodyLarge(
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                      ),
                      // Mascot (boy reading + panda), floating
                      Expanded(
                        child: Center(
                          child: PopIn(
                            delay: const Duration(milliseconds: 500),
                            duration: const Duration(milliseconds: 1000),
                            child: const ReadingHeroScene(size: 360),
                          ),
                        ),
                      ),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 1400),
                        offset: const Offset(0, 0.6),
                        child: PulseGlow(
                          glowColor: const Color(0x80FFFFFF),
                          child: AppButton(
                            label: 'Start Learning',
                            variant: AppButtonVariant.white,
                            width: double.infinity,
                            height: 58,
                            icon: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: AppColors.primaryPurple,
                              size: 26,
                            ),
                            onPressed: () => _start(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Each letter drops in with an elastic bounce, staggered left to right.
class _BouncyTitle extends StatefulWidget {
  final String text;
  final int startDelay;
  final double fontSize;
  final Color color;

  const _BouncyTitle({
    required this.text,
    required this.startDelay,
    required this.fontSize,
    this.color = Colors.white,
  });

  @override
  State<_BouncyTitle> createState() => _BouncyTitleState();
}

class _BouncyTitleState extends State<_BouncyTitle>
    with SingleTickerProviderStateMixin {
  static const _perLetterMs = 70;
  static const _letterMs = 650;

  late final int _totalMs =
      widget.startDelay + widget.text.length * _perLetterMs + _letterMs;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _totalMs),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.baloo2(
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w800,
      color: widget.color,
      height: 1.05,
      shadows: const [
        Shadow(color: Color(0x553B0764), offset: Offset(0, 4), blurRadius: 8),
      ],
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final ms = _c.value * _totalMs;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.text.length; i++)
              Builder(
                builder: (context) {
                  final start = widget.startDelay + i * _perLetterMs;
                  final t = ((ms - start) / _letterMs).clamp(0.0, 1.0);
                  final y = (1 - Curves.elasticOut.transform(t)) * -40;
                  return Opacity(
                    opacity: (t * 4).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, y),
                      child: Text(widget.text[i], style: style),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _CircleRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(covariant _CircleRevealClipper old) =>
      old.radius != radius || old.center != center;
}
