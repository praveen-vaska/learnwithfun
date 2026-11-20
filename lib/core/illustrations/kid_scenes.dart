import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'scene_kit.dart';

// ===========================================================================
// 1. Splash: boy reading a book with his panda friend
//    - pages flip, magic letters float out of the book
//    - boy blinks, bobs his head, glances up at the viewer
//    - panda blinks, wiggles ears and waves
// ===========================================================================

class ReadingHeroScene extends StatelessWidget {
  final double size;
  const ReadingHeroScene({super.key, this.size = 320});

  @override
  Widget build(BuildContext context) =>
      LoopScene(painter: _paintReading, width: size, height: size);
}

const _letterColors = [
  Color(0xFFFF5C8A),
  Color(0xFFFFC21A),
  Color(0xFF38BDF8),
  Color(0xFF84CC16),
  Color(0xFFFF8A3D),
  Color(0xFFA78BFA),
];

void _paintReading(Canvas c, double t) {
  // Soft magic glow
  c.drawCircle(
    const Offset(150, 165),
    135,
    radialP(const Offset(150, 165), 135, const [
      Color(0x55FFFFFF),
      Color(0x00FFFFFF),
    ]),
  );

  // Floating cloud seat
  final bob = math.sin(t * 1.3) * 3;
  c.save();
  c.translate(0, bob);
  final cloudPaint = linearP(const Offset(0, 230), const Offset(0, 290), const [
    Color(0xFFFFFFFF),
    Color(0xFFE4DBFF),
  ]);
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(38, 248, 230, 36),
      const Radius.circular(18),
    ),
    cloudPaint,
  );
  for (final (x, y, r) in const [
    (60.0, 252.0, 22.0),
    (95.0, 240.0, 30.0),
    (150.0, 236.0, 32.0),
    (205.0, 240.0, 30.0),
    (245.0, 252.0, 22.0),
  ]) {
    c.drawCircle(Offset(x, y), r, cloudPaint);
  }
  c.restore();

  // ---- Panda (right) ----
  final waveEnv = pulseEnv(t, 5.0, 1.8, 1.2);
  final armAngle = 0.7 - waveEnv * 2.3 + waveEnv * math.sin(t * 15) * 0.4;
  drawPanda(
    c,
    Offset(232, 206 + bob),
    0.62,
    open: blinkOpen(t, period: 4.4, offset: 1.6),
    armAngle: armAngle,
    earWiggle: math.sin(t * 9) * 0.06 * pulseEnv(t, 3.2, 1.0, 0.4),
    headTilt: math.sin(t * 1.1) * 0.08 + waveEnv * 0.1,
  );

  // ---- Boy (left) ----
  const blue = Color(0xFF4C6FE0);
  const blueDark = Color(0xFF3651B8);
  final by = bob + math.sin(t * 1.6) * 1.2;
  c.save();
  c.translate(0, by);
  // Crossed legs
  c.drawLine(
    const Offset(102, 238),
    const Offset(62, 258),
    strokeP(blueDark, 26),
  );
  c.drawLine(const Offset(140, 238), const Offset(178, 258), strokeP(blue, 26));
  for (final (x, flip) in const [(56.0, -1.0), (184.0, 1.0)]) {
    c.drawOval(
      Rect.fromCenter(center: Offset(x, 262), width: 34, height: 20),
      fillP(Colors.white),
    );
    c.drawArc(
      Rect.fromCenter(center: Offset(x, 262), width: 34, height: 20),
      math.pi,
      math.pi,
      false,
      strokeP(const Color(0xFFFF5C8A), 5),
    );
    c.drawCircle(
      Offset(x + flip * 8, 258),
      2.5,
      fillP(const Color(0xFFFF5C8A)),
    );
  }
  // Hoodie torso
  final torso = Path()
    ..moveTo(92, 160)
    ..quadraticBezierTo(121, 150, 150, 160)
    ..quadraticBezierTo(166, 200, 162, 246)
    ..quadraticBezierTo(121, 256, 80, 246)
    ..quadraticBezierTo(76, 200, 92, 160)
    ..close();
  c.drawPath(
    torso,
    linearP(const Offset(80, 160), const Offset(165, 250), const [
      Color(0xFFFFE066),
      Color(0xFFFFC21A),
      Color(0xFFF5A00A),
    ]),
  );
  // Hood collar + strings
  c.drawPath(
    Path()
      ..moveTo(98, 162)
      ..quadraticBezierTo(121, 182, 144, 162),
    strokeP(const Color(0xFFE59A0A), 7),
  );
  c.drawLine(
    const Offset(114, 172),
    const Offset(112, 188),
    strokeP(Colors.white, 2.5),
  );
  c.drawLine(
    const Offset(128, 172),
    const Offset(130, 188),
    strokeP(Colors.white, 2.5),
  );

  // Head (bobs gently, looks down at the book, sometimes up at you)
  final lookUp = pulseEnv(t, 7.0, 1.6, 3.0);
  final tilt = math.sin(t * 0.9) * 0.05 - lookUp * 0.04;
  c.save();
  c.translate(121, 158);
  c.rotate(tilt);
  c.translate(-121, -158);
  drawBoyHead(
    c,
    const Offset(121, 116),
    44,
    open: blinkOpen(t, period: 3.6),
    look: Offset(0.2, 1 - lookUp * 1.8),
    smile: 0.8 + lookUp * 0.3,
  );
  c.restore();

  // Glow over the open book
  c.drawCircle(
    const Offset(121, 196),
    44,
    radialP(const Offset(121, 196), 44, const [
      Color(0x99FFF3B0),
      Color(0x00FFF3B0),
    ]),
  );
  // Book held in front
  drawOpenBook(c, const Offset(121, 196), 46, 40, t, flipPeriod: 3.2);
  // Hands
  c.drawLine(
    const Offset(92, 176),
    const Offset(78, 214),
    strokeP(const Color(0xFFF5A00A), 16),
  );
  c.drawLine(
    const Offset(150, 176),
    const Offset(164, 214),
    strokeP(const Color(0xFFF5A00A), 16),
  );
  c.drawCircle(const Offset(77, 216), 9, fillP(const Color(0xFFFFD6B5)));
  c.drawCircle(const Offset(165, 216), 9, fillP(const Color(0xFFFFD6B5)));
  c.restore();

  // ---- Magic letters rising out of the book ----
  const letters = ['A', 'B', 'C', '1', '2', '★'];
  for (var i = 0; i < letters.length; i++) {
    final p = phase(t, 3.6, i * 0.6);
    final ease = Curves.easeOut.transform(p);
    final side = i.isEven ? -1.0 : 1.0;
    final x = 121 + side * (38 + ease * 72) + math.sin(p * math.pi * 2 + i) * 6;
    final y = 196 + by - ease * 130;
    final op = math.sin(p * math.pi).clamp(0.0, 1.0);
    drawLabel(
      c,
      letters[i],
      Offset(x, y),
      14 + 12 * ease,
      _letterColors[i % _letterColors.length],
      rotation: math.sin(t * 2 + i) * 0.3,
      opacity: op,
    );
  }

  // Twinkles
  for (var i = 0; i < 7; i++) {
    final a = i * 0.9 + 0.4;
    final pos = Offset(150 + math.cos(a) * 125, 140 + math.sin(a) * 105);
    final tw = (0.5 + 0.5 * math.sin(t * 3 + i * 1.3)).clamp(0.0, 1.0);
    drawSparkle(c, pos, 4 + 4 * tw, Colors.white.withValues(alpha: tw * 0.9));
  }
}

// ===========================================================================
// 2. Onboarding 1: boy riding a rocket through space
//    - rocket swoops, flame flickers, smoke puffs trail away
//    - scarf and hair flutter, boy waves; stars streak past
// ===========================================================================

class RocketBoyScene extends StatelessWidget {
  final double size;
  const RocketBoyScene({super.key, this.size = 260});

  @override
  Widget build(BuildContext context) =>
      LoopScene(painter: _paintRocket, width: size, height: size);
}

void _paintRocket(Canvas c, double t) {
  const ang = 0.72; // pointing up-right
  final dir = Offset(math.sin(ang), -math.cos(ang));

  // Little planet & twinkling stars
  c.drawCircle(
    const Offset(52, 64),
    17,
    linearP(const Offset(35, 50), const Offset(70, 80), const [
      Color(0xFFFFB7CB),
      Color(0xFFF472B6),
    ]),
  );
  c.save();
  c.translate(52, 64);
  c.rotate(-0.35);
  c.drawOval(
    Rect.fromCenter(center: Offset.zero, width: 54, height: 12),
    strokeP(const Color(0xFFFFE16A), 3.5),
  );
  c.restore();
  for (var i = 0; i < 9; i++) {
    final pos = Offset((i * 71 % 290) + 6.0, (i * 113 % 280) + 8.0);
    final tw = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 2.6 + i * 2.1));
    drawSparkle(
      c,
      pos,
      3 + 3 * tw,
      const Color(0xFFFFE16A).withValues(alpha: tw),
    );
  }

  // Speed streaks flying past (opposite to travel)
  for (var i = 0; i < 8; i++) {
    final p = phase(t, 0.9, i * 0.31);
    final perp = Offset(-dir.dy, dir.dx);
    final start = const Offset(150, 150) + perp * ((i - 3.5) * 32) + dir * 170;
    final pos = start - dir * (p * 360);
    final a = math.sin(p * math.pi) * 0.7;
    c.drawLine(
      pos,
      pos + dir * 26,
      strokeP(Colors.white.withValues(alpha: a), 3),
    );
  }

  // Rocket transform (gentle swoop)
  final center = Offset(
    150 + math.sin(t * 1.3) * 10,
    156 + math.cos(t * 1.7) * 9,
  );
  final a = ang + math.sin(t * 2.0) * 0.05;
  Offset toWorld(Offset local) => center + rot(local, a);

  c.save();
  c.translate(center.dx, center.dy);
  c.rotate(a);

  // Smoke puffs trailing behind
  for (var i = 0; i < 10; i++) {
    final p = phase(t, 1.3, i * 0.13);
    final pos = Offset(
      math.sin(i * 2.3 + t * 2) * 7 * p + (i.isEven ? 1 : -1) * p * 16,
      82 + p * 150,
    );
    c.drawCircle(
      pos,
      7 + p * 20,
      fillP(
        Color.lerp(
          Colors.white,
          const Color(0xFFD9CCFF),
          p,
        )!.withValues(alpha: (1 - p) * 0.85),
      ),
    );
  }

  // Flame (layered, flickering)
  final l = 50 + 9 * math.sin(t * 28) + 5 * math.sin(t * 41 + 1);
  final w = 16 + 3 * math.sin(t * 33);
  Path flame(double len, double wid) => Path()
    ..moveTo(-wid, 66)
    ..quadraticBezierTo(-wid * 0.95, 66 + len * 0.55, 0, 66 + len)
    ..quadraticBezierTo(wid * 0.95, 66 + len * 0.55, wid, 66)
    ..close();
  c.drawCircle(const Offset(0, 86), 30, glowP(const Color(0x88FF8A3D), 14));
  c.drawPath(
    flame(l, w),
    linearP(const Offset(0, 66), Offset(0, 66 + l), const [
      Color(0xFFFF6B35),
      Color(0x00FF3D00),
    ]),
  );
  c.drawPath(flame(l * 0.72, w * 0.7), fillP(const Color(0xFFFFB627)));
  c.drawPath(flame(l * 0.42, w * 0.42), fillP(const Color(0xFFFFF6C2)));

  // Fins
  for (final s in [-1.0, 1.0]) {
    final fin = Path()
      ..moveTo(s * 28, 22)
      ..quadraticBezierTo(s * 56, 44, s * 52, 74)
      ..quadraticBezierTo(s * 40, 64, s * 26, 60)
      ..close();
    c.drawPath(
      fin,
      linearP(Offset(s * 26, 22), Offset(s * 52, 74), const [
        Color(0xFFFF6B81),
        Color(0xFFE11D48),
      ]),
    );
  }
  // Body
  final body = Path()
    ..moveTo(0, -96)
    ..cubicTo(26, -82, 32, -50, 32, -20)
    ..lineTo(30, 54)
    ..quadraticBezierTo(0, 64, -30, 54)
    ..lineTo(-32, -20)
    ..cubicTo(-32, -50, -26, -82, 0, -96)
    ..close();
  c.drawPath(
    body,
    linearP(
      const Offset(-32, 0),
      const Offset(32, 0),
      const [Color(0xFFFFFFFF), Color(0xFFF5F2FF), Color(0xFFC9BCF2)],
      const [0, 0.45, 1],
    ),
  );
  c.save();
  c.clipPath(body);
  c.drawRect(
    const Rect.fromLTRB(-40, -100, 40, -56),
    linearP(const Offset(-32, 0), const Offset(32, 0), const [
      Color(0xFFFF7A8F),
      Color(0xFFE11D48),
    ]),
  );
  c.drawRect(
    const Rect.fromLTRB(-40, 28, 40, 38),
    fillP(const Color(0xFF8B5CF6)),
  );
  c.restore();
  // Window
  c.drawCircle(const Offset(0, -20), 17, fillP(const Color(0xFFB8B0DE)));
  c.drawCircle(
    const Offset(0, -20),
    12.5,
    radialP(const Offset(-4, -24), 18, const [
      Color(0xFFBFF0FF),
      Color(0xFF38BDF8),
      Color(0xFF2563EB),
    ]),
  );
  c.drawArc(
    Rect.fromCircle(center: const Offset(0, -20), radius: 8),
    3.6,
    1.3,
    false,
    strokeP(Colors.white.withAlpha(220), 2.6),
  );
  // Nozzle + centre fin
  c.drawPath(
    Path()
      ..moveTo(-18, 54)
      ..lineTo(18, 54)
      ..lineTo(14, 68)
      ..lineTo(-14, 68)
      ..close(),
    linearP(const Offset(-18, 0), const Offset(18, 0), const [
      Color(0xFF9CA3AF),
      Color(0xFF6B7280),
    ]),
  );
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTRB(-4, 30, 4, 72),
      const Radius.circular(4),
    ),
    fillP(const Color(0xFFE11D48)),
  );
  c.restore();

  // ---- Boy riding on the rocket's back ----
  final seat = toWorld(const Offset(-30, 20));
  final lean = a * 0.18;
  c.save();
  c.translate(seat.dx, seat.dy);
  c.rotate(lean);
  // Scarf fluttering behind
  final scarf = Path()..moveTo(2, -40);
  for (var k = 1; k <= 6; k++) {
    scarf.lineTo(
      -k * 10.0,
      -40 + k * 6.0 + math.sin(t * 10 - k * 0.9) * (2 + k * 0.9),
    );
  }
  c.drawPath(scarf, strokeP(const Color(0xFFE11D48), 9));
  // Torso
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTRB(-15, -44, 17, 2),
      const Radius.circular(13),
    ),
    linearP(const Offset(-15, -44), const Offset(17, 2), const [
      Color(0xFFFFE066),
      Color(0xFFF5A00A),
    ]),
  );
  // Waving arm (raised)
  final waveA = -0.75 + math.sin(t * 7) * 0.3;
  final sh = const Offset(11, -34);
  final hand = sh + rot(const Offset(26, 0), waveA);
  c.drawLine(sh, hand, strokeP(const Color(0xFFF5A00A), 10));
  c.drawCircle(hand, 6.5, fillP(const Color(0xFFFFD6B5)));
  // Holding arm
  c.drawLine(
    const Offset(-11, -32),
    const Offset(-6, -6),
    strokeP(const Color(0xFFF5A00A), 10),
  );
  c.drawCircle(const Offset(-5, -4), 6, fillP(const Color(0xFFFFD6B5)));
  // Head
  drawBoyHead(
    c,
    const Offset(2, -66),
    25,
    open: blinkOpen(t, period: 3.2, offset: 0.8),
    look: const Offset(1, -0.4),
    hairWind: math.sin(t * 12),
  );
  // Leg draped over the rocket
  c.drawLine(
    const Offset(6, -2),
    const Offset(24, 22),
    strokeP(const Color(0xFF4C6FE0), 13),
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(28, 27), width: 20, height: 12),
    fillP(Colors.white),
  );
  c.drawArc(
    Rect.fromCenter(center: const Offset(28, 27), width: 20, height: 12),
    0,
    math.pi,
    false,
    strokeP(const Color(0xFFFF5C8A), 3.5),
  );
  c.restore();
}

// ===========================================================================
// 3. Golden trophy: rotating rays, shine sweep, orbiting stars, confetti
// ===========================================================================

class TrophyScene extends StatelessWidget {
  final double size;
  final bool rays;
  final bool confetti;
  final bool bob;

  const TrophyScene({
    super.key,
    this.size = 240,
    this.rays = true,
    this.confetti = true,
    this.bob = true,
  });

  @override
  Widget build(BuildContext context) => LoopScene(
    painter: rays && confetti && bob
        ? _paintTrophyFull
        : (rays
              ? (bob ? _paintTrophyRaysBob : _paintTrophyRays)
              : (bob ? _paintTrophyBob : _paintTrophyPlain)),
    width: size,
    height: size,
  );
}

void _paintTrophyFull(Canvas c, double t) =>
    _paintTrophy(c, t, rays: true, confetti: true, bob: true);
void _paintTrophyRaysBob(Canvas c, double t) =>
    _paintTrophy(c, t, rays: true, confetti: false, bob: true);
void _paintTrophyRays(Canvas c, double t) =>
    _paintTrophy(c, t, rays: true, confetti: false, bob: false);
void _paintTrophyBob(Canvas c, double t) =>
    _paintTrophy(c, t, rays: false, confetti: false, bob: true);
void _paintTrophyPlain(Canvas c, double t) =>
    _paintTrophy(c, t, rays: false, confetti: false, bob: false);

const _confettiColors = [
  Color(0xFFFF5C8A),
  Color(0xFF38BDF8),
  Color(0xFF84CC16),
  Color(0xFFA78BFA),
  Color(0xFFFFC21A),
];

void _paintTrophy(
  Canvas c,
  double t, {
  required bool rays,
  required bool confetti,
  required bool bob,
}) {
  const cx = 150.0;
  final cy = 140.0 + (bob ? math.sin(t * 1.6) * 5 : 0);

  if (rays) {
    c.save();
    c.translate(cx, 130);
    c.rotate(t * 0.25);
    final rayPaint = radialP(Offset.zero, 145, const [
      Color(0x66FFE16A),
      Color(0x00FFE16A),
    ]);
    for (var i = 0; i < 12; i++) {
      c.save();
      c.rotate(i * math.pi / 6);
      c.drawPath(
        Path()
          ..moveTo(0, 0)
          ..lineTo(-12, -145)
          ..lineTo(12, -145)
          ..close(),
        rayPaint,
      );
      c.restore();
    }
    c.restore();
  }
  c.drawCircle(
    Offset(cx, cy - 20),
    92,
    radialP(Offset(cx, cy - 20), 92, const [
      Color(0x88FFF3B0),
      Color(0x00FFF3B0),
    ]),
  );

  c.save();
  c.translate(cx, cy);
  const gold = [
    Color(0xFFFFE680),
    Color(0xFFFFC93C),
    Color(0xFFF29F05),
    Color(0xFFFFD45C),
  ];
  const goldStops = [0.0, 0.35, 0.75, 1.0];
  // Handles
  for (final s in [-1.0, 1.0]) {
    c.drawPath(
      Path()
        ..moveTo(s * 50, -58)
        ..cubicTo(s * 98, -62, s * 92, 2, s * 28, 6),
      strokeP(const Color(0xFFE39B0B), 12),
    );
    c.drawPath(
      Path()
        ..moveTo(s * 50, -58)
        ..cubicTo(s * 98, -62, s * 92, 2, s * 28, 6),
      strokeP(const Color(0xFFFFD45C), 5),
    );
  }
  // Cup
  final cup = Path()
    ..moveTo(-56, -70)
    ..lineTo(56, -70)
    ..cubicTo(56, -8, 30, 20, 12, 28)
    ..lineTo(-12, 28)
    ..cubicTo(-30, 20, -56, -8, -56, -70)
    ..close();
  c.drawPath(
    cup,
    linearP(const Offset(-56, 0), const Offset(56, 0), gold, goldStops),
  );
  // Shine sweep across the cup
  final sp = phase(t, 3.2);
  if (sp < 0.45) {
    final x = -100 + (sp / 0.45) * 220;
    c.save();
    c.clipPath(cup);
    c.drawPath(
      Path()
        ..moveTo(x, -80)
        ..lineTo(x + 20, -80)
        ..lineTo(x - 12, 40)
        ..lineTo(x - 32, 40)
        ..close(),
      fillP(Colors.white.withAlpha(150)),
    );
    c.restore();
  }
  // Static highlight
  c.drawPath(
    Path()
      ..moveTo(-40, -58)
      ..quadraticBezierTo(-42, -20, -22, 8),
    strokeP(Colors.white.withAlpha(120), 6),
  );
  // Rim
  c.drawOval(
    Rect.fromCenter(center: const Offset(0, -70), width: 114, height: 18),
    fillP(const Color(0xFFFFE680)),
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(0, -69), width: 96, height: 11),
    fillP(const Color(0xFFD98E04)),
  );
  // Star emblem (gently pulsing)
  final pulse = 1 + math.sin(t * 3) * 0.06;
  drawStar(
    c,
    const Offset(0, -28),
    20 * pulse,
    linearP(const Offset(0, -48), const Offset(0, -8), const [
      Colors.white,
      Color(0xFFFFF1A6),
    ]),
  );
  drawStar(
    c,
    const Offset(0, -28),
    20 * pulse,
    strokeP(const Color(0xFFE0A100), 2),
  );
  // Stem & base
  c.drawRect(
    const Rect.fromLTRB(-9, 28, 9, 52),
    linearP(const Offset(-9, 0), const Offset(9, 0), gold, goldStops),
  );
  c.drawOval(
    Rect.fromCenter(center: const Offset(0, 40), width: 32, height: 10),
    fillP(const Color(0xFFFFD45C)),
  );
  c.drawPath(
    Path()
      ..moveTo(-30, 52)
      ..lineTo(30, 52)
      ..lineTo(38, 74)
      ..lineTo(-38, 74)
      ..close(),
    linearP(const Offset(-38, 0), const Offset(38, 0), gold, goldStops),
  );
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTRB(-48, 74, 48, 94),
      const Radius.circular(6),
    ),
    linearP(const Offset(0, 74), const Offset(0, 94), const [
      Color(0xFF6D4AE0),
      Color(0xFF4C2CB0),
    ]),
  );
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTRB(-24, 79, 24, 89),
      const Radius.circular(3),
    ),
    fillP(const Color(0xFFFFE16A)),
  );
  c.restore();

  // Orbiting popping stars
  for (var i = 0; i < 5; i++) {
    final ang = i * 2 * math.pi / 5 + t * 0.35;
    final pos = Offset(cx + math.cos(ang) * 118, 135 + math.sin(ang) * 92);
    final s = 0.65 + 0.35 * math.sin(t * 3 + i * 1.3);
    drawShinyStar(c, pos, 13 * s, rotation: t * 0.8 + i);
  }
  for (var i = 0; i < 6; i++) {
    final tw = (0.5 + 0.5 * math.sin(t * 3.4 + i * 2)).clamp(0.0, 1.0);
    final a = i * 1.1;
    drawSparkle(
      c,
      Offset(cx + math.cos(a) * 80, 120 + math.sin(a) * 70),
      3 + 5 * tw,
      Colors.white.withValues(alpha: tw),
    );
  }

  if (confetti) {
    for (var i = 0; i < 16; i++) {
      final p = phase(t, 3.5 + (i % 3) * 0.7, i * 0.37);
      final x = (i * 41 % 280) + 10 + math.sin(t * 2 + i) * 10;
      final y = -10 + p * 320;
      c.save();
      c.translate(x, y);
      c.rotate(t * 3 + i);
      c.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-5, -2.5, 10, 5),
          const Radius.circular(2),
        ),
        fillP(
          _confettiColors[i % _confettiColors.length].withValues(
            alpha: math.sin(p * math.pi),
          ),
        ),
      );
      c.restore();
    }
  }
}

// ===========================================================================
// 4. Onboarding 3: fairytale castle rising from a storybook
//    - flags wave, trees sway, birds flap across, pages flutter
// ===========================================================================

class StoryCastleScene extends StatelessWidget {
  final double size;
  const StoryCastleScene({super.key, this.size = 260});

  @override
  Widget build(BuildContext context) =>
      LoopScene(painter: _paintCastle, width: size, height: size);
}

void _paintCastle(Canvas c, double t) {
  // Rainbow
  const rainbow = [
    Color(0x55FF7A8A),
    Color(0x55FFC21A),
    Color(0x5584CC16),
    Color(0x5538BDF8),
    Color(0x55A78BFA),
  ];
  for (var i = 0; i < rainbow.length; i++) {
    c.drawArc(
      Rect.fromCircle(center: const Offset(150, 205), radius: 128.0 - i * 9),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = rainbow[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
  }
  // Drifting clouds
  drawCloud(
    c,
    Offset(60 + math.sin(t * 0.5) * 10, 58),
    60,
    Colors.white.withAlpha(230),
  );
  drawCloud(
    c,
    Offset(240 + math.cos(t * 0.4) * 10, 78),
    50,
    Colors.white.withAlpha(210),
  );

  // Birds
  for (var i = 0; i < 3; i++) {
    final p = phase(t, 9, i * 3.1);
    final x = -20 + p * 340;
    final y = 40 + i * 16 + math.sin(t * 2 + i) * 6;
    final flap = math.sin(t * 12 + i * 2) * 5;
    c.drawPath(
      Path()
        ..moveTo(x - 8, y - flap)
        ..quadraticBezierTo(x - 4, y - 3, x, y)
        ..quadraticBezierTo(x + 4, y - 3, x + 8, y - flap),
      strokeP(const Color(0xFF5B4B8A), 2.4),
    );
  }

  // Trees swaying
  void tree(Offset base, double s, double sway) {
    c.save();
    c.translate(base.dx, base.dy);
    c.rotate(sway);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-5 * s, -40 * s, 10 * s, 40 * s),
        Radius.circular(4 * s),
      ),
      fillP(const Color(0xFF9A5B34)),
    );
    final leaf = linearP(Offset(0, -95 * s), Offset(0, -30 * s), const [
      Color(0xFF86EFAC),
      Color(0xFF22C55E),
    ]);
    c.drawCircle(Offset(0, -62 * s), 26 * s, leaf);
    c.drawCircle(Offset(-18 * s, -48 * s), 18 * s, leaf);
    c.drawCircle(Offset(18 * s, -48 * s), 18 * s, leaf);
    c.drawCircle(
      Offset(-8 * s, -72 * s),
      6 * s,
      fillP(Colors.white.withAlpha(90)),
    );
    c.restore();
  }

  tree(const Offset(42, 218), 0.9, math.sin(t * 1.5) * 0.06);
  tree(const Offset(258, 218), 0.8, math.sin(t * 1.5 + 1) * 0.06);

  // Book
  drawOpenBook(
    c,
    const Offset(150, 205),
    118,
    52,
    t,
    flipPeriod: 5.0,
    flipOffset: 1.5,
    lines: false,
  );

  // Castle
  final breathe = 1 + math.sin(t * 1.4) * 0.012;
  c.save();
  c.translate(150, 214);
  c.scale(breathe);
  c.translate(-150, -214);
  const wall = [Color(0xFFFFD1E6), Color(0xFFFF9EC7)];
  Paint wallP(double x0, double x1) =>
      linearP(Offset(x0, 0), Offset(x1, 0), wall);
  // Main wall with crenellations
  c.drawRect(const Rect.fromLTRB(102, 150, 198, 214), wallP(102, 198));
  for (var i = 0; i < 6; i++) {
    c.drawRect(Rect.fromLTWH(104.0 + i * 16, 142, 10, 10), wallP(102, 198));
  }
  // Side towers
  c.drawRect(const Rect.fromLTRB(78, 122, 108, 214), wallP(78, 108));
  c.drawRect(const Rect.fromLTRB(192, 122, 222, 214), wallP(192, 222));
  // Centre tower
  c.drawRect(const Rect.fromLTRB(132, 96, 168, 152), wallP(132, 168));
  // Roofs
  const roof = [Color(0xFFB79CFF), Color(0xFF7C3AED)];
  void cone(double x0, double x1, double base, double tip) {
    c.drawPath(
      Path()
        ..moveTo(x0, base)
        ..lineTo((x0 + x1) / 2, tip)
        ..lineTo(x1, base)
        ..close(),
      linearP(Offset(x0, 0), Offset(x1, 0), roof),
    );
  }

  cone(72, 114, 124, 80);
  cone(186, 228, 124, 80);
  cone(126, 174, 98, 46);
  // Flags waving
  void flag(Offset tip, Color color, double ph) {
    final top = tip - const Offset(0, 18);
    c.drawLine(tip, top, strokeP(const Color(0xFF6B7280), 2));
    final f = Path()..moveTo(top.dx, top.dy);
    for (var k = 1; k <= 4; k++) {
      f.lineTo(top.dx + k * 4.5, top.dy + 2 + math.sin(t * 7 + ph - k) * 2);
    }
    for (var k = 4; k >= 0; k--) {
      f.lineTo(top.dx + k * 4.5, top.dy + 10 + math.sin(t * 7 + ph - k) * 2);
    }
    f.close();
    c.drawPath(f, fillP(color));
  }

  flag(const Offset(93, 80), const Color(0xFFFFC21A), 0);
  flag(const Offset(207, 80), const Color(0xFF38BDF8), 1.4);
  flag(const Offset(150, 46), const Color(0xFFFF5C8A), 0.7);
  // Windows (glowing softly)
  final glow = 0.75 + 0.25 * math.sin(t * 2.2);
  final win = fillP(
    Color.lerp(const Color(0xFF6D28D9), const Color(0xFFFFE16A), glow * 0.35)!,
  );
  void arch(Rect r) => c.drawRRect(
    RRect.fromRectAndCorners(
      r,
      topLeft: Radius.circular(r.width / 2),
      topRight: Radius.circular(r.width / 2),
    ),
    win,
  );
  arch(const Rect.fromLTWH(87, 140, 12, 18));
  arch(const Rect.fromLTWH(201, 140, 12, 18));
  arch(const Rect.fromLTWH(144, 110, 12, 18));
  arch(const Rect.fromLTWH(116, 162, 12, 16));
  arch(const Rect.fromLTWH(172, 162, 12, 16));
  // Door
  c.drawRRect(
    RRect.fromRectAndCorners(
      const Rect.fromLTWH(138, 180, 24, 34),
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
    ),
    fillP(const Color(0xFF9A5B34)),
  );
  c.drawCircle(const Offset(156, 198), 2, fillP(const Color(0xFFFFE16A)));
  c.restore();

  // Magic sparkles over the castle
  for (var i = 0; i < 8; i++) {
    final p = phase(t, 2.6, i * 0.33);
    final x = 90 + (i * 23 % 120).toDouble();
    final y = 200 - p * 150;
    final a = math.sin(p * math.pi);
    drawSparkle(
      c,
      Offset(x, y),
      3 + 4 * a,
      const Color(0xFFFFE16A).withValues(alpha: a),
    );
  }
}
