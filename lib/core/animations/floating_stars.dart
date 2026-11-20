import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FloatingStars extends StatefulWidget {
  final int count;
  final Widget? child;

  const FloatingStars({super.key, this.count = 8, this.child});

  @override
  State<FloatingStars> createState() => _FloatingStarsState();
}

class _FloatingStarsState extends State<FloatingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_StarParticle> _stars = [];
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    for (int i = 0; i < widget.count; i++) {
      _stars.add(
        _StarParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: 10 + _random.nextDouble() * 14,
          speed: 0.5 + _random.nextDouble() * 0.8,
          color: i % 2 == 0 ? AppColors.yellow : AppColors.pink,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarsPainter(stars: _stars, progress: _controller.value),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class _StarParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;

  _StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

class _StarsPainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double progress;

  _StarsPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final yOffset = sin((progress * 2 * pi * star.speed) + star.x * 5) * 8;
      final px = star.x * size.width;
      final py = star.y * size.height + yOffset;
      final opacity = (0.4 + 0.5 * sin(progress * 2 * pi + star.y * 3)).clamp(
        0.2,
        1.0,
      );

      final paint = Paint()
        ..color = star.color.withAlpha((opacity * 255).toInt())
        ..style = PaintingStyle.fill;

      // Draw cute 4-point star
      final path = Path();
      final r = star.size / 2;
      path.moveTo(px, py - r);
      path.quadraticBezierTo(px, py, px + r, py);
      path.quadraticBezierTo(px, py, px, py + r);
      path.quadraticBezierTo(px, py, px - r, py);
      path.quadraticBezierTo(px, py, px, py - r);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => true;
}
