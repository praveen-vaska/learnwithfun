import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Gentle idle "floating" motion: bobs up/down with a slight sway.
/// Used for mascots, trophies and hero illustrations.
class FloatBob extends StatefulWidget {
  final Widget child;
  final double distance;
  final double rotation;
  final Duration period;
  final double phase;

  const FloatBob({
    super.key,
    required this.child,
    this.distance = 8,
    this.rotation = 0.02,
    this.period = const Duration(milliseconds: 2600),
    this.phase = 0,
  });

  @override
  State<FloatBob> createState() => _FloatBobState();
}

class _FloatBobState extends State<FloatBob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = (_c.value + widget.phase) * 2 * pi;
        return Transform.translate(
          offset: Offset(0, sin(t) * widget.distance),
          child: Transform.rotate(
            angle: sin(t + pi / 3) * widget.rotation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Soft breathing pulse (scale + glow) to draw a child's eye to a CTA.
class PulseGlow extends StatefulWidget {
  final Widget child;
  final double scale;
  final Color glowColor;
  final double borderRadius;
  final bool enabled;

  const PulseGlow({
    super.key,
    required this.child,
    this.scale = 1.035,
    this.glowColor = const Color(0x667952F5),
    this.borderRadius = 30,
    this.enabled = true,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = Curves.easeInOut.transform(_c.value);
        return Transform.scale(
          scale: 1 + (widget.scale - 1) * v,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(
                    alpha: widget.glowColor.a * (0.35 + 0.65 * v),
                  ),
                  blurRadius: 10 + 14 * v,
                  spreadRadius: 1 + 2 * v,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Springy pop-in: scales from 0 with an elastic overshoot after [delay].
class PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double fromRotation;
  final Curve curve;

  const PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.fromRotation = 0,
    this.curve = Curves.easeOutBack,
  });

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final s = widget.curve.transform(_c.value);
        final o = Curves.easeOut.transform((_c.value * 3).clamp(0.0, 1.0));
        return Opacity(
          opacity: o,
          child: Transform.rotate(
            angle:
                widget.fromRotation *
                (1 - Curves.easeOutBack.transform(_c.value)),
            child: Transform.scale(scale: s, child: child),
          ),
        );
      },
    );
  }
}

/// Plays a playful wiggle every time [trigger] changes, and optionally
/// every [autoEvery] while idle (to invite taps).
class Wiggle extends StatefulWidget {
  final Widget child;
  final Object? trigger;
  final Duration? autoEvery;
  final double angle;

  const Wiggle({
    super.key,
    required this.child,
    this.trigger,
    this.autoEvery,
    this.angle = 0.12,
  });

  @override
  State<Wiggle> createState() => _WiggleState();
}

class _WiggleState extends State<Wiggle> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoEvery != null) {
      _timer = Timer.periodic(widget.autoEvery!, (_) {
        if (mounted) _c.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(covariant Wiggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        final damp = 1 - t;
        return Transform.rotate(
          angle: sin(t * pi * 6) * widget.angle * damp,
          child: Transform.scale(scale: 1 + sin(t * pi) * 0.08, child: child),
        );
      },
    );
  }
}

/// Horizontal "no-no" shake, fired whenever [trigger] changes.
class ShakeX extends StatefulWidget {
  final Widget child;
  final Object? trigger;
  final double distance;

  const ShakeX({
    super.key,
    required this.child,
    this.trigger,
    this.distance = 10,
  });

  @override
  State<ShakeX> createState() => _ShakeXState();
}

class _ShakeXState extends State<ShakeX> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void didUpdateWidget(covariant ShakeX oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          sin(_c.value * pi * 5) * widget.distance * (1 - _c.value),
          0,
        ),
        child: child,
      ),
    );
  }
}

/// Number that counts up from [from] to [value] with an ease-out.
class CountUp extends StatelessWidget {
  final int value;
  final int from;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const CountUp({
    super.key,
    required this.value,
    this.from = 0,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from.toDouble(), end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text('$prefix${v.round()}$suffix', style: style),
    );
  }
}

/// Rounded progress bar that fills smoothly from 0 to [value] on first build
/// and animates between values afterwards.
class AnimatedFillBar extends StatelessWidget {
  final double value;
  final double height;
  final Color color;
  final Color trackColor;
  final Gradient? gradient;
  final Duration duration;
  final Duration delay;

  const AnimatedFillBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color = const Color(0xFF7952F5),
    this.trackColor = const Color(0xFFEDE9FE),
    this.gradient,
    this.duration = const Duration(milliseconds: 1100),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final total = duration + delay;
    final startFrac = total.inMilliseconds == 0
        ? 0.0
        : delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: total,
      curve: Interval(startFrac, 1, curve: Curves.easeOutCubic),
      builder: (context, v, _) => Container(
        height: height,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(height),
        ),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              color: gradient == null ? color : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft white clouds drifting slowly across their area. Purely decorative.
class DriftingClouds extends StatefulWidget {
  final int count;
  final Color color;

  const DriftingClouds({
    super.key,
    this.count = 4,
    this.color = const Color(0xCCFFFFFF),
  });

  @override
  State<DriftingClouds> createState() => _DriftingCloudsState();
}

class _DriftingCloudsState extends State<DriftingClouds>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _CloudPainter(_c.value, widget.count, widget.color),
        ),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double t;
  final int count;
  final Color color;

  _CloudPainter(this.t, this.count, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var i = 0; i < count; i++) {
      final speed = 0.6 + (i % 3) * 0.25;
      final scale = 0.6 + ((i * 37) % 5) / 8;
      final w = 90 * scale;
      final span = size.width + w * 2;
      final x = ((t * speed + i / count) % 1.0) * span - w;
      final y = size.height * (0.08 + ((i * 53) % 7) / 10 * 0.8);
      final h = 26 * scale;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(h / 2),
      );
      canvas.drawRRect(r, paint);
      canvas.drawCircle(Offset(x + w * 0.35, y), h * 0.62, paint);
      canvas.drawCircle(Offset(x + w * 0.62, y + 2), h * 0.48, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter old) => old.t != t;
}

/// Small colourful confetti bits that gently sparkle around a hero element
/// (static positions, animated twinkle). Lighter than a full confetti burst.
class SparkleBits extends StatefulWidget {
  final int count;
  final double radius;
  final Widget child;

  const SparkleBits({
    super.key,
    required this.child,
    this.count = 10,
    this.radius = 110,
  });

  @override
  State<SparkleBits> createState() => _SparkleBitsState();
}

class _SparkleBitsState extends State<SparkleBits>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  static const _colors = [
    Color(0xFFFFC94D),
    Color(0xFFFF7EB3),
    Color(0xFF6FD3FF),
    Color(0xFF9EE35D),
    Color(0xFFA68BFF),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _SparklePainter(_c.value, widget.count, widget.radius),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double t;
  final int count;
  final double radius;

  _SparklePainter(this.t, this.count, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < count; i++) {
      final a = i / count * 2 * pi + 0.4;
      final rr = radius * (0.85 + ((i * 29) % 5) / 14);
      final drift = sin((t + i / count) * 2 * pi) * 6;
      final p = c + Offset(cos(a) * (rr + drift), sin(a) * (rr + drift));
      final tw = (0.5 + 0.5 * sin((t * 2 + i * 0.37) * 2 * pi)).clamp(0.2, 1.0);
      final paint = Paint()
        ..color = _SparkleBitsState._colors[i % 5].withValues(alpha: tw);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(t * 2 * pi * (i.isEven ? 1 : -1) + i);
      if (i % 3 == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-5, -2, 10, 4),
            const Radius.circular(2),
          ),
          paint,
        );
      } else if (i % 3 == 1) {
        canvas.drawCircle(Offset.zero, 3.2, paint);
      } else {
        final s = 6.0 * tw;
        final path = Path()
          ..moveTo(0, -s)
          ..quadraticBezierTo(0, 0, s, 0)
          ..quadraticBezierTo(0, 0, 0, s)
          ..quadraticBezierTo(0, 0, -s, 0)
          ..quadraticBezierTo(0, 0, 0, -s);
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.t != t;
}

/// Global page transition: the new page rises in with a soft fade and a
/// slight springy scale; the old page eases back. Applied to all
/// MaterialPageRoutes via the theme.
class KidPageTransitionsBuilder extends PageTransitionsBuilder {
  const KidPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 480);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final inCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    final fade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    final out = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: out,
      child: child,
      builder: (context, child) => Transform.scale(
        scale: 1 - 0.05 * out.value,
        child: Opacity(opacity: 1 - 0.4 * out.value, child: child),
      ),
    ).let(
      (outWrapped) => FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(inCurve),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(inCurve),
            child: outWrapped,
          ),
        ),
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

/// Shows a "+N XP" star badge that pops up from [anchor] (or screen centre),
/// floats upward and fades away. Fire-and-forget.
void showXpBurst(BuildContext context, int xp, {Offset? anchor}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  final size = MediaQuery.sizeOf(context);
  final start = anchor ?? Offset(size.width / 2, size.height * 0.55);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) =>
        _XpBurst(xp: xp, start: start, onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _XpBurst extends StatefulWidget {
  final int xp;
  final Offset start;
  final VoidCallback onDone;

  const _XpBurst({required this.xp, required this.start, required this.onDone});

  @override
  State<_XpBurst> createState() => _XpBurstState();
}

class _XpBurstState extends State<_XpBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward().whenComplete(() => widget.onDone());

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final pop = Curves.elasticOut.transform((t / 0.45).clamp(0.0, 1.0));
          final rise = Curves.easeIn.transform(
            ((t - 0.35) / 0.65).clamp(0.0, 1.0),
          );
          final fade =
              1 - Curves.easeIn.transform(((t - 0.6) / 0.4).clamp(0.0, 1.0));
          return Stack(
            children: [
              Positioned(
                left: widget.start.dx - 60,
                top: widget.start.dy - 24 - rise * 120,
                width: 120,
                child: Opacity(
                  opacity: fade,
                  child: Transform.scale(
                    scale: pop,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD54F), Color(0xFFF59E0B)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x55F59E0B),
                              blurRadius: 14,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${widget.xp} XP',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
