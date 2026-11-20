import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

/// Draws a scene into a fixed 300x300 design space. [t] is elapsed seconds.
typedef ScenePainter = void Function(Canvas canvas, double t);

/// Hosts a continuously animated vector scene. Everything is drawn with
/// vectors at the device pixel ratio, so it stays crisp on any screen.
class LoopScene extends StatefulWidget {
  final ScenePainter painter;
  final double width;
  final double height;

  const LoopScene({
    super.key,
    required this.painter,
    required this.width,
    required this.height,
  });

  @override
  State<LoopScene> createState() => _LoopSceneState();
}

class _LoopSceneState extends State<LoopScene>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _time = ValueNotifier(0);
  late final Ticker _ticker = createTicker(
    (elapsed) => _time.value = elapsed.inMicroseconds / 1e6,
  )..start();

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ticker; // ensure started
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _ScenePainter(_time, widget.painter),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final ValueListenable<double> time;
  final ScenePainter scene;

  _ScenePainter(this.time, this.scene) : super(repaint: time);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 300;
    canvas.save();
    canvas.translate((size.width - 300 * s) / 2, (size.height - 300 * s) / 2);
    canvas.scale(s);
    scene(canvas, time.value);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.scene != scene;
}

// ---------------------------------------------------------------------------
// Paint helpers
// ---------------------------------------------------------------------------

Paint fillP(Color c) => Paint()..color = c;

Paint linearP(Offset a, Offset b, List<Color> colors, [List<double>? stops]) =>
    Paint()
      ..shader = ui.Gradient.linear(a, b, colors, stops ?? _evenStops(colors));

Paint radialP(Offset c, double r, List<Color> colors, [List<double>? stops]) =>
    Paint()
      ..shader = ui.Gradient.radial(c, r, colors, stops ?? _evenStops(colors));

List<double>? _evenStops(List<Color> colors) => colors.length <= 2
    ? null
    : List.generate(colors.length, (i) => i / (colors.length - 1));

Paint strokeP(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint glowP(Color c, double blur) => Paint()
  ..color = c
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

/// 0..1 position within a repeating period.
double phase(double t, double period, [double offset = 0]) =>
    ((t + offset) % period) / period;

/// Eye openness 0..1 with a quick blink once per [period] seconds.
double blinkOpen(double t, {double period = 3.8, double offset = 0}) {
  final p = (t + offset) % period;
  const d = 0.18;
  if (p > d) return 1;
  return (1 - math.sin(p / d * math.pi)).clamp(0.0, 1.0);
}

/// Smooth 0→1→0 envelope over the first [active] seconds of each [period].
double pulseEnv(double t, double period, double active, [double offset = 0]) {
  final p = (t + offset) % period;
  if (p > active) return 0;
  return math.sin(p / active * math.pi);
}

Offset rot(Offset p, double a) => Offset(
  p.dx * math.cos(a) - p.dy * math.sin(a),
  p.dx * math.sin(a) + p.dy * math.cos(a),
);

void drawStar(
  Canvas c,
  Offset o,
  double r,
  Paint p, {
  double rotation = 0,
  double inner = 0.48,
}) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final rr = i.isEven ? r : r * inner;
    final a = -math.pi / 2 + i * math.pi / 5 + rotation;
    final pt = o + Offset(math.cos(a) * rr, math.sin(a) * rr);
    i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
  }
  path.close();
  c.drawPath(path, p);
}

/// Shiny cartoon star (gold gradient + soft outline).
void drawShinyStar(Canvas c, Offset o, double r, {double rotation = 0}) {
  drawStar(
    c,
    o,
    r,
    linearP(o - Offset(0, r), o + Offset(0, r), const [
      Color(0xFFFFF1A6),
      Color(0xFFFFC21A),
      Color(0xFFF59E0B),
    ]),
    rotation: rotation,
  );
  drawStar(
    c,
    o,
    r,
    strokeP(const Color(0x66C27100), r * 0.08),
    rotation: rotation,
  );
  c.drawCircle(
    o + Offset(-r * 0.22, -r * 0.25),
    r * 0.13,
    fillP(Colors.white.withAlpha(200)),
  );
}

void drawSparkle(Canvas c, Offset o, double r, Color color) {
  final p = Path()
    ..moveTo(o.dx, o.dy - r)
    ..quadraticBezierTo(o.dx, o.dy, o.dx + r, o.dy)
    ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r)
    ..quadraticBezierTo(o.dx, o.dy, o.dx - r, o.dy)
    ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r);
  c.drawPath(p, fillP(color));
}

void drawCloud(Canvas c, Offset o, double w, Color color) {
  final p = fillP(color);
  c.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: o, width: w, height: w * 0.32),
      Radius.circular(w * 0.16),
    ),
    p,
  );
  c.drawCircle(o + Offset(-w * 0.15, -w * 0.12), w * 0.2, p);
  c.drawCircle(o + Offset(w * 0.12, -w * 0.16), w * 0.24, p);
}

void drawLabel(
  Canvas c,
  String text,
  Offset center,
  double size,
  Color color, {
  double rotation = 0,
  double opacity = 1,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: GoogleFonts.baloo2().fontFamily,
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color.withValues(alpha: color.a * opacity),
        shadows: [
          Shadow(
            color: Colors.white.withValues(alpha: 0.8 * opacity),
            blurRadius: 0,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  c.save();
  c.translate(center.dx, center.dy);
  c.rotate(rotation);
  tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  c.restore();
}

// ---------------------------------------------------------------------------
// Characters
// ---------------------------------------------------------------------------

const _skin = Color(0xFFFFD6B5);
const _skinLight = Color(0xFFFFE8D4);
const _skinShade = Color(0xFFF0B088);
const _hair = Color(0xFF6B3A1E);
const _hairLight = Color(0xFF94562F);
const _hairDark = Color(0xFF45220F);

/// Cartoon boy head centred at [o] with radius [r].
/// [open] eye openness, [look] -1..1 gaze offset, [hairWind] tuft flutter.
void drawBoyHead(
  Canvas c,
  Offset o,
  double r, {
  double open = 1,
  Offset look = Offset.zero,
  double smile = 1,
  double hairWind = 0,
}) {
  // Ears
  for (final s in [-1.0, 1.0]) {
    final e = o + Offset(s * r * 0.95, r * 0.12);
    c.drawCircle(e, r * 0.22, fillP(_skinShade));
    c.drawCircle(e, r * 0.11, fillP(const Color(0xFFE59A72)));
  }
  // Face
  c.drawCircle(
    o,
    r,
    radialP(
      o + Offset(-r * 0.3, -r * 0.35),
      r * 1.5,
      const [_skinLight, _skin, _skinShade],
      const [0, 0.55, 1],
    ),
  );
  // Hair cap with fringe
  final h = Path()
    ..moveTo(o.dx - r * 1.02, o.dy + r * 0.1)
    ..cubicTo(
      o.dx - r * 1.18,
      o.dy - r * 0.95,
      o.dx - r * 0.4,
      o.dy - r * 1.28,
      o.dx + r * 0.15,
      o.dy - r * 1.14,
    )
    ..cubicTo(
      o.dx + r * 0.85,
      o.dy - r * 1.05,
      o.dx + r * 1.18,
      o.dy - r * 0.6,
      o.dx + r * 1.02,
      o.dy + r * 0.1,
    )
    ..quadraticBezierTo(
      o.dx + r * 0.88,
      o.dy - r * 0.32,
      o.dx + r * 0.58,
      o.dy - r * 0.36,
    )
    ..quadraticBezierTo(
      o.dx + r * 0.42,
      o.dy - r * 0.16,
      o.dx + r * 0.2,
      o.dy - r * 0.4,
    )
    ..quadraticBezierTo(
      o.dx + r * 0.0,
      o.dy - r * 0.18,
      o.dx - r * 0.22,
      o.dy - r * 0.44,
    )
    ..quadraticBezierTo(
      o.dx - r * 0.46,
      o.dy - r * 0.22,
      o.dx - r * 0.62,
      o.dy - r * 0.4,
    )
    ..quadraticBezierTo(
      o.dx - r * 0.88,
      o.dy - r * 0.28,
      o.dx - r * 1.02,
      o.dy + r * 0.1,
    )
    ..close();
  c.drawPath(
    h,
    linearP(o - Offset(0, r * 1.2), o + Offset(0, r * 0.1), const [
      _hairLight,
      _hair,
      _hairDark,
    ]),
  );
  // Fluttering tuft
  final tuft = Path()
    ..moveTo(o.dx - r * 0.1, o.dy - r * 1.08)
    ..quadraticBezierTo(
      o.dx + r * (0.0 + hairWind * 0.15),
      o.dy - r * 1.6,
      o.dx + r * (0.42 + hairWind * 0.25),
      o.dy - r * (1.45 - hairWind * 0.1),
    )
    ..quadraticBezierTo(
      o.dx + r * 0.18,
      o.dy - r * 1.32,
      o.dx + r * 0.25,
      o.dy - r * 1.08,
    )
    ..close();
  c.drawPath(tuft, fillP(_hair));
  // Hair shine
  c.drawPath(
    Path()
      ..moveTo(o.dx - r * 0.62, o.dy - r * 0.78)
      ..quadraticBezierTo(
        o.dx - r * 0.3,
        o.dy - r * 1.04,
        o.dx + r * 0.12,
        o.dy - r * 1.0,
      ),
    strokeP(Colors.white.withAlpha(70), r * 0.08),
  );
  // Eyebrows
  for (final s in [-1.0, 1.0]) {
    c.drawPath(
      Path()
        ..moveTo(o.dx + s * r * 0.22, o.dy - r * 0.18)
        ..quadraticBezierTo(
          o.dx + s * r * 0.38,
          o.dy - r * 0.28,
          o.dx + s * r * 0.54,
          o.dy - r * 0.18,
        ),
      strokeP(_hairDark, r * 0.07),
    );
  }
  // Eyes
  for (final s in [-1.0, 1.0]) {
    final e = o + Offset(s * r * 0.38 + look.dx * r * 0.05, r * 0.06);
    if (open < 0.2) {
      c.drawPath(
        Path()
          ..moveTo(e.dx - r * 0.13, e.dy)
          ..quadraticBezierTo(e.dx, e.dy + r * 0.1, e.dx + r * 0.13, e.dy),
        strokeP(const Color(0xFF2B1A12), r * 0.06),
      );
    } else {
      final eh = r * 0.32 * open;
      final ec = e + Offset(0, look.dy * r * 0.05);
      c.drawOval(
        Rect.fromCenter(center: ec, width: r * 0.25, height: eh),
        fillP(const Color(0xFF2B1A12)),
      );
      c.drawCircle(
        ec + Offset(-r * 0.04, -eh * 0.2),
        r * 0.06,
        fillP(Colors.white),
      );
      c.drawCircle(
        ec + Offset(r * 0.05, eh * 0.18),
        r * 0.027,
        fillP(Colors.white.withAlpha(210)),
      );
    }
  }
  // Cheeks
  for (final s in [-1.0, 1.0]) {
    c.drawCircle(
      o + Offset(s * r * 0.6, r * 0.36),
      r * 0.16,
      fillP(const Color(0x66FF6F86)),
    );
  }
  // Nose
  c.drawPath(
    Path()
      ..moveTo(o.dx - r * 0.06, o.dy + r * 0.24)
      ..quadraticBezierTo(
        o.dx,
        o.dy + r * 0.3,
        o.dx + r * 0.06,
        o.dy + r * 0.24,
      ),
    strokeP(const Color(0xFFD88B63), r * 0.05),
  );
  // Open happy mouth
  final mw = r * 0.27;
  final my = o.dy + r * 0.44;
  final mh = r * (0.16 + 0.1 * smile);
  final mouth = Path()
    ..moveTo(o.dx - mw, my)
    ..quadraticBezierTo(o.dx, my + mh * 2, o.dx + mw, my)
    ..quadraticBezierTo(o.dx, my + mh * 0.3, o.dx - mw, my)
    ..close();
  c.drawPath(mouth, fillP(const Color(0xFF9C2F3A)));
  c.save();
  c.clipPath(mouth);
  c.drawCircle(
    Offset(o.dx, my + mh * 1.55),
    mw * 0.62,
    fillP(const Color(0xFFFF7A8A)),
  );
  c.drawRect(
    Rect.fromLTWH(o.dx - mw, my - 2, mw * 2, mh * 0.45),
    fillP(Colors.white),
  );
  c.restore();
}

/// Cute panda. [o] is the body centre, [s] a scale factor.
void drawPanda(
  Canvas c,
  Offset o,
  double s, {
  double open = 1,
  double armAngle = 0.6,
  double earWiggle = 0,
  double headTilt = 0,
}) {
  const black = Color(0xFF26233A);
  c.save();
  c.translate(o.dx, o.dy);
  c.scale(s);

  // Ground shadow
  c.drawOval(
    Rect.fromCenter(center: const Offset(0, 58), width: 110, height: 16),
    fillP(const Color(0x22311B92)),
  );
  // Legs
  for (final x in [-30.0, 30.0]) {
    c.drawOval(
      Rect.fromCenter(center: Offset(x, 44), width: 38, height: 30),
      fillP(black),
    );
    c.drawCircle(Offset(x, 46), 7, fillP(const Color(0xFFFFB7CB)));
  }
  // Body
  c.drawOval(
    Rect.fromCenter(center: const Offset(0, 10), width: 100, height: 92),
    radialP(
      const Offset(-15, -10),
      80,
      const [Colors.white, Color(0xFFF1EDFA), Color(0xFFD9D1F0)],
      const [0, 0.6, 1],
    ),
  );
  // Left arm (resting on belly)
  c.drawLine(const Offset(-36, -6), const Offset(-16, 24), strokeP(black, 22));
  // Right arm (waves)
  final shoulder = const Offset(34, -6);
  final hand = shoulder + rot(const Offset(30, 0), armAngle);
  c.drawLine(shoulder, hand, strokeP(black, 22));

  // Head
  c.save();
  c.translate(0, -48);
  c.rotate(headTilt);
  for (final sx in [-1.0, 1.0]) {
    c.save();
    c.rotate(sx * earWiggle);
    c.drawCircle(Offset(sx * 33, -32), 16, fillP(black));
    c.drawCircle(Offset(sx * 33, -32), 7, fillP(const Color(0xFF4A4560)));
    c.restore();
  }
  c.drawCircle(
    Offset.zero,
    44,
    radialP(
      const Offset(-14, -16),
      70,
      const [Colors.white, Color(0xFFF3F0FB), Color(0xFFDCD5F0)],
      const [0, 0.65, 1],
    ),
  );
  for (final sx in [-1.0, 1.0]) {
    c.save();
    c.translate(sx * 17, -2);
    c.rotate(sx * -0.5);
    c.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 23, height: 31),
      fillP(black),
    );
    c.restore();
    final e = Offset(sx * 16, -4);
    if (open < 0.2) {
      c.drawPath(
        Path()
          ..moveTo(e.dx - 6, e.dy)
          ..quadraticBezierTo(e.dx, e.dy + 5, e.dx + 6, e.dy),
        strokeP(Colors.white, 2.4),
      );
    } else {
      c.drawOval(
        Rect.fromCenter(center: e, width: 13, height: 13 * open),
        fillP(Colors.white),
      );
      c.drawOval(
        Rect.fromCenter(
          center: e + const Offset(0.8, 0.5),
          width: 8,
          height: 8 * open,
        ),
        fillP(black),
      );
      c.drawCircle(e + const Offset(-1.2, -1.6), 1.8, fillP(Colors.white));
    }
    c.drawCircle(Offset(sx * 28, 14), 6.5, fillP(const Color(0x77FF8FAB)));
  }
  c.drawOval(
    Rect.fromCenter(center: const Offset(0, 11), width: 13, height: 9),
    fillP(black),
  );
  c.drawPath(
    Path()
      ..moveTo(-7, 18)
      ..quadraticBezierTo(-3.5, 23, 0, 18.5)
      ..quadraticBezierTo(3.5, 23, 7, 18),
    strokeP(black, 2.2),
  );
  c.restore();
  c.restore();
}

/// Open book with an optional page flipping. [spine] is the top of the spine.
void drawOpenBook(
  Canvas c,
  Offset spine,
  double w,
  double h,
  double t, {
  double flipPeriod = 3.0,
  double flipOffset = 0,
  Color cover = const Color(0xFF7952F5),
  bool lines = true,
}) {
  Path page(double sign, double width, double lift) {
    return Path()
      ..moveTo(spine.dx, spine.dy)
      ..quadraticBezierTo(
        spine.dx + sign * width * 0.5,
        spine.dy - 12 - lift,
        spine.dx + sign * width,
        spine.dy - 4 - lift * 0.6,
      )
      ..lineTo(spine.dx + sign * width, spine.dy + h - 4 - lift * 0.6)
      ..quadraticBezierTo(
        spine.dx + sign * width * 0.5,
        spine.dy + h - 12 - lift * 0.3,
        spine.dx,
        spine.dy + h,
      )
      ..close();
  }

  // Cover (slightly bigger, below pages)
  for (final s in [-1.0, 1.0]) {
    final p = Path()
      ..moveTo(spine.dx, spine.dy + 6)
      ..quadraticBezierTo(
        spine.dx + s * (w + 6) * 0.5,
        spine.dy - 6,
        spine.dx + s * (w + 7),
        spine.dy + 2,
      )
      ..lineTo(spine.dx + s * (w + 7), spine.dy + h + 4)
      ..quadraticBezierTo(
        spine.dx + s * (w + 6) * 0.5,
        spine.dy + h - 4,
        spine.dx,
        spine.dy + h + 8,
      )
      ..close();
    c.drawPath(
      p,
      linearP(spine, spine + Offset(s * w, h), [
        cover,
        Color.lerp(cover, Colors.black, 0.3)!,
      ]),
    );
  }
  // Pages
  for (final s in [-1.0, 1.0]) {
    final p = page(s, w, 0);
    c.drawPath(
      p,
      linearP(
        spine,
        spine + Offset(s * w, 0),
        const [Color(0xFFE9DFC8), Color(0xFFFFFAEE), Color(0xFFFFF6E0)],
        const [0, 0.25, 1],
      ),
    );
    if (lines) {
      for (var i = 0; i < 4; i++) {
        final y = spine.dy + h * (0.25 + i * 0.17);
        final x0 = spine.dx + s * w * 0.18;
        final x1 = spine.dx + s * w * (i == 3 ? 0.55 : 0.82);
        c.drawLine(
          Offset(x0, y - 6),
          Offset(x1, y - 7),
          strokeP(const Color(0x55A68BFF), 2.6),
        );
      }
    }
  }
  // Flipping page (right → left)
  final p = phase(t, flipPeriod, flipOffset);
  if (p < 0.32) {
    final f = Curves.easeInOut.transform(p / 0.32);
    final theta = f * math.pi;
    final x = math.cos(theta) * w;
    final lift = math.sin(theta) * 26;
    final path = Path()
      ..moveTo(spine.dx, spine.dy)
      ..quadraticBezierTo(
        spine.dx + x * 0.5,
        spine.dy - 12 - lift,
        spine.dx + x,
        spine.dy - 4 - lift * 0.7,
      )
      ..lineTo(spine.dx + x, spine.dy + h - 4 - lift * 0.7)
      ..quadraticBezierTo(
        spine.dx + x * 0.5,
        spine.dy + h - 12 - lift * 0.35,
        spine.dx,
        spine.dy + h,
      )
      ..close();
    c.drawPath(
      path,
      fillP(x >= 0 ? const Color(0xFFFFFCF4) : const Color(0xFFF2E8D2)),
    );
    c.drawPath(path, strokeP(const Color(0x22000000), 0.8));
  }
  // Spine shadow
  c.drawLine(
    spine,
    spine + Offset(0, h),
    strokeP(const Color(0x33000000), 1.6),
  );
}
