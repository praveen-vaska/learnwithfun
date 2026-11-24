import 'dart:math';
import 'package:flutter/material.dart';

/// Helper class that creates stencil paths and checkpoint dots for tracing practice.
/// Supports uppercase letters A-Z, numbers 0-9, shapes, and multi-letter words.
class TracingGuide {
  TracingGuide._();

  /// Returns normalized (0.0 to 1.0) paths for a single uppercase character
  static List<Path> getNormalizedPathsForChar(String char) {
    final c = char.toUpperCase();
    final paths = <Path>[];

    switch (c) {
      case 'A':
        // Left diagonal
        paths.add(Path()..moveTo(0.5, 0.08)..lineTo(0.12, 0.92));
        // Right diagonal
        paths.add(Path()..moveTo(0.5, 0.08)..lineTo(0.88, 0.92));
        // Crossbar
        paths.add(Path()..moveTo(0.26, 0.60)..lineTo(0.74, 0.60));
        break;

      case 'B':
        // Vertical spine
        paths.add(Path()..moveTo(0.20, 0.08)..lineTo(0.20, 0.92));
        // Top loop
        paths.add(
          Path()
            ..moveTo(0.20, 0.08)
            ..cubicTo(0.78, 0.08, 0.78, 0.50, 0.20, 0.50),
        );
        // Bottom loop
        paths.add(
          Path()
            ..moveTo(0.20, 0.50)
            ..cubicTo(0.85, 0.50, 0.85, 0.92, 0.20, 0.92),
        );
        break;

      case 'C':
        paths.add(
          Path()
            ..moveTo(0.82, 0.22)
            ..cubicTo(0.40, 0.06, 0.12, 0.30, 0.12, 0.50)
            ..cubicTo(0.12, 0.70, 0.40, 0.94, 0.82, 0.78),
        );
        break;

      case 'D':
        paths.add(Path()..moveTo(0.20, 0.08)..lineTo(0.20, 0.92));
        paths.add(
          Path()
            ..moveTo(0.20, 0.08)
            ..cubicTo(0.85, 0.08, 0.85, 0.92, 0.20, 0.92),
        );
        break;

      case 'E':
        paths.add(Path()..moveTo(0.22, 0.08)..lineTo(0.22, 0.92));
        paths.add(Path()..moveTo(0.22, 0.08)..lineTo(0.82, 0.08));
        paths.add(Path()..moveTo(0.22, 0.50)..lineTo(0.70, 0.50));
        paths.add(Path()..moveTo(0.22, 0.92)..lineTo(0.82, 0.92));
        break;

      case 'F':
        paths.add(Path()..moveTo(0.22, 0.08)..lineTo(0.22, 0.92));
        paths.add(Path()..moveTo(0.22, 0.08)..lineTo(0.82, 0.08));
        paths.add(Path()..moveTo(0.22, 0.50)..lineTo(0.68, 0.50));
        break;

      case 'G':
        paths.add(
          Path()
            ..moveTo(0.82, 0.22)
            ..cubicTo(0.40, 0.06, 0.12, 0.30, 0.12, 0.50)
            ..cubicTo(0.12, 0.70, 0.40, 0.94, 0.82, 0.78)
            ..lineTo(0.82, 0.52)
            ..lineTo(0.55, 0.52),
        );
        break;

      case 'H':
        paths.add(Path()..moveTo(0.18, 0.08)..lineTo(0.18, 0.92));
        paths.add(Path()..moveTo(0.82, 0.08)..lineTo(0.82, 0.92));
        paths.add(Path()..moveTo(0.18, 0.50)..lineTo(0.82, 0.50));
        break;

      case 'I':
        paths.add(Path()..moveTo(0.25, 0.08)..lineTo(0.75, 0.08));
        paths.add(Path()..moveTo(0.50, 0.08)..lineTo(0.50, 0.92));
        paths.add(Path()..moveTo(0.25, 0.92)..lineTo(0.75, 0.92));
        break;

      case 'J':
        paths.add(Path()..moveTo(0.30, 0.08)..lineTo(0.75, 0.08));
        paths.add(
          Path()
            ..moveTo(0.62, 0.08)
            ..lineTo(0.62, 0.70)
            ..cubicTo(0.62, 0.95, 0.20, 0.95, 0.20, 0.72),
        );
        break;

      case 'K':
        paths.add(Path()..moveTo(0.20, 0.08)..lineTo(0.20, 0.92));
        paths.add(Path()..moveTo(0.80, 0.12)..lineTo(0.20, 0.52));
        paths.add(Path()..moveTo(0.32, 0.44)..lineTo(0.82, 0.92));
        break;

      case 'L':
        paths.add(
          Path()
            ..moveTo(0.22, 0.08)
            ..lineTo(0.22, 0.92)
            ..lineTo(0.80, 0.92),
        );
        break;

      case 'M':
        paths.add(
          Path()
            ..moveTo(0.14, 0.92)
            ..lineTo(0.14, 0.08)
            ..lineTo(0.50, 0.56)
            ..lineTo(0.86, 0.08)
            ..lineTo(0.86, 0.92),
        );
        break;

      case 'N':
        paths.add(
          Path()
            ..moveTo(0.18, 0.92)
            ..lineTo(0.18, 0.08)
            ..lineTo(0.82, 0.92)
            ..lineTo(0.82, 0.08),
        );
        break;

      case 'O':
        paths.add(
          Path()
            ..addOval(
              Rect.fromCenter(
                center: const Offset(0.50, 0.50),
                width: 0.72,
                height: 0.84,
              ),
            ),
        );
        break;

      case 'P':
        paths.add(Path()..moveTo(0.20, 0.08)..lineTo(0.20, 0.92));
        paths.add(
          Path()
            ..moveTo(0.20, 0.08)
            ..cubicTo(0.82, 0.08, 0.82, 0.54, 0.20, 0.54),
        );
        break;

      case 'Q':
        paths.add(
          Path()
            ..addOval(
              Rect.fromCenter(
                center: const Offset(0.50, 0.48),
                width: 0.70,
                height: 0.80,
              ),
            ),
        );
        paths.add(Path()..moveTo(0.55, 0.65)..lineTo(0.85, 0.92));
        break;

      case 'R':
        paths.add(Path()..moveTo(0.20, 0.08)..lineTo(0.20, 0.92));
        paths.add(
          Path()
            ..moveTo(0.20, 0.08)
            ..cubicTo(0.82, 0.08, 0.82, 0.52, 0.20, 0.52),
        );
        paths.add(Path()..moveTo(0.48, 0.52)..lineTo(0.82, 0.92));
        break;

      case 'S':
        paths.add(
          Path()
            ..moveTo(0.80, 0.24)
            ..cubicTo(0.40, 0.04, 0.15, 0.28, 0.35, 0.48)
            ..cubicTo(0.65, 0.65, 0.85, 0.72, 0.55, 0.92)
            ..cubicTo(0.35, 0.98, 0.18, 0.85, 0.18, 0.76),
        );
        break;

      case 'T':
        paths.add(Path()..moveTo(0.15, 0.08)..lineTo(0.85, 0.08));
        paths.add(Path()..moveTo(0.50, 0.08)..lineTo(0.50, 0.92));
        break;

      case 'U':
        paths.add(
          Path()
            ..moveTo(0.18, 0.08)
            ..lineTo(0.18, 0.65)
            ..cubicTo(0.18, 0.96, 0.82, 0.96, 0.82, 0.65)
            ..lineTo(0.82, 0.08),
        );
        break;

      case 'V':
        paths.add(
          Path()
            ..moveTo(0.14, 0.08)
            ..lineTo(0.50, 0.92)
            ..lineTo(0.86, 0.08),
        );
        break;

      case 'W':
        paths.add(
          Path()
            ..moveTo(0.12, 0.08)
            ..lineTo(0.30, 0.92)
            ..lineTo(0.50, 0.40)
            ..lineTo(0.70, 0.92)
            ..lineTo(0.88, 0.08),
        );
        break;

      case 'X':
        paths.add(Path()..moveTo(0.16, 0.08)..lineTo(0.84, 0.92));
        paths.add(Path()..moveTo(0.84, 0.08)..lineTo(0.16, 0.92));
        break;

      case 'Y':
        paths.add(
          Path()
            ..moveTo(0.15, 0.08)
            ..lineTo(0.50, 0.50)
            ..lineTo(0.85, 0.08),
        );
        paths.add(Path()..moveTo(0.50, 0.50)..lineTo(0.50, 0.92));
        break;

      case 'Z':
        paths.add(
          Path()
            ..moveTo(0.18, 0.08)
            ..lineTo(0.82, 0.08)
            ..lineTo(0.18, 0.92)
            ..lineTo(0.82, 0.92),
        );
        break;

      // --- DIGITS 0-9 ---
      case '0':
        paths.add(
          Path()
            ..addOval(
              Rect.fromCenter(
                center: const Offset(0.50, 0.50),
                width: 0.65,
                height: 0.84,
              ),
            ),
        );
        break;

      case '1':
        paths.add(Path()..moveTo(0.32, 0.24)..lineTo(0.50, 0.08));
        paths.add(Path()..moveTo(0.50, 0.08)..lineTo(0.50, 0.92));
        paths.add(Path()..moveTo(0.24, 0.92)..lineTo(0.76, 0.92));
        break;

      case '2':
        paths.add(
          Path()
            ..moveTo(0.22, 0.28)
            ..cubicTo(0.25, 0.06, 0.78, 0.06, 0.78, 0.32)
            ..cubicTo(0.78, 0.55, 0.20, 0.75, 0.18, 0.92)
            ..lineTo(0.82, 0.92),
        );
        break;

      case '3':
        paths.add(
          Path()
            ..moveTo(0.24, 0.10)
            ..lineTo(0.78, 0.10)
            ..lineTo(0.48, 0.44)
            ..cubicTo(0.84, 0.44, 0.84, 0.92, 0.24, 0.92),
        );
        break;

      case '4':
        paths.add(
          Path()
            ..moveTo(0.72, 0.08)
            ..lineTo(0.18, 0.65)
            ..lineTo(0.84, 0.65),
        );
        paths.add(Path()..moveTo(0.70, 0.08)..lineTo(0.70, 0.92));
        break;

      case '5':
        paths.add(
          Path()
            ..moveTo(0.78, 0.08)
            ..lineTo(0.24, 0.08)
            ..lineTo(0.22, 0.44)
            ..cubicTo(0.82, 0.38, 0.82, 0.92, 0.22, 0.92),
        );
        break;

      case '6':
        paths.add(
          Path()
            ..moveTo(0.74, 0.18)
            ..cubicTo(0.40, 0.06, 0.16, 0.35, 0.16, 0.64)
            ..cubicTo(0.16, 0.94, 0.84, 0.94, 0.84, 0.64)
            ..cubicTo(0.84, 0.44, 0.40, 0.44, 0.16, 0.64),
        );
        break;

      case '7':
        paths.add(
          Path()
            ..moveTo(0.18, 0.08)
            ..lineTo(0.82, 0.08)
            ..lineTo(0.38, 0.92),
        );
        break;

      case '8':
        paths.add(
          Path()
            ..addOval(
              Rect.fromCenter(
                center: const Offset(0.50, 0.30),
                width: 0.52,
                height: 0.44,
              ),
            ),
        );
        paths.add(
          Path()
            ..addOval(
              Rect.fromCenter(
                center: const Offset(0.50, 0.70),
                width: 0.62,
                height: 0.44,
              ),
            ),
        );
        break;

      case '9':
        paths.add(
          Path()
            ..moveTo(0.84, 0.36)
            ..cubicTo(0.84, 0.06, 0.16, 0.06, 0.16, 0.36)
            ..cubicTo(0.16, 0.62, 0.84, 0.62, 0.84, 0.36)
            ..lineTo(0.84, 0.60)
            ..cubicTo(0.84, 0.94, 0.35, 0.94, 0.22, 0.82),
        );
        break;

      default:
        // Generic rounded rect fallback
        paths.add(
          Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(
                  center: const Offset(0.5, 0.5),
                  width: 0.6,
                  height: 0.8,
                ),
                const Radius.circular(0.15),
              ),
            ),
        );
        break;
    }

    return paths;
  }

  /// Returns scaled Paths and Checkpoint dots for any text / symbol across the given bounds
  static List<Path> getScaledPaths(String text, Rect bounds) {
    final clean = text.trim();
    if (clean.isEmpty) return [];

    // If single character (e.g. 'A' or '1')
    if (clean.length == 1) {
      final normPaths = getNormalizedPathsForChar(clean);
      return _scalePaths(normPaths, bounds);
    }

    // If multi-character word (e.g. 'APPLE' or 'ONE' or 'MOO')
    final word = clean.toUpperCase();
    final letterCount = word.length;
    final letterWidth = bounds.width / letterCount;
    final result = <Path>[];

    for (int i = 0; i < letterCount; i++) {
      final char = word[i];
      final charBounds = Rect.fromLTWH(
        bounds.left + (i * letterWidth),
        bounds.top,
        letterWidth,
        bounds.height,
      );
      final normPaths = getNormalizedPathsForChar(char);
      result.addAll(_scalePaths(normPaths, charBounds));
    }

    return result;
  }

  static List<Path> _scalePaths(List<Path> normPaths, Rect bounds) {
    final scaled = <Path>[];
    for (final np in normPaths) {
      final matrix = Matrix4.identity()
        ..translate(bounds.left, bounds.top)
        ..scale(bounds.width, bounds.height);
      scaled.add(np.transform(matrix.storage));
    }
    return scaled;
  }

  /// Samples evenly spaced checkpoint points along all paths
  static List<Offset> extractCheckpoints(
    List<Path> paths, {
    int pointsPerPath = 20,
  }) {
    final checkpoints = <Offset>[];

    for (final path in paths) {
      final metrics = path.computeMetrics();
      for (final metric in metrics) {
        final length = metric.length;
        if (length <= 0) continue;

        final numSteps = max(5, (length / 22).round());
        for (int i = 0; i <= numSteps; i++) {
          final distance = (i / numSteps) * length;
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            checkpoints.add(tangent.position);
          }
        }
      }
    }

    return checkpoints;
  }

  /// Calculates the fraction of checkpoints visited by the user's strokes.
  /// Tolerance hit radius is typically 36.0 - 45.0 px for toddlers.
  static TracingEvaluation evaluateTracing({
    required List<Offset> checkpoints,
    required List<List<Offset>> userStrokes,
    double hitRadius = 40.0,
  }) {
    if (checkpoints.isEmpty) {
      return TracingEvaluation(
        coverage: 1.0,
        totalPoints: 0,
        hitIndices: {},
        isSuccess: true,
      );
    }

    // Flatten all points drawn by user
    final allUserPoints = <Offset>[];
    for (final stroke in userStrokes) {
      allUserPoints.addAll(stroke);
    }

    if (allUserPoints.isEmpty) {
      return TracingEvaluation(
        coverage: 0.0,
        totalPoints: 0,
        hitIndices: {},
        isSuccess: false,
      );
    }

    final hitIndices = <int>{};
    final hitRadiusSquared = hitRadius * hitRadius;

    for (int i = 0; i < checkpoints.length; i++) {
      final cp = checkpoints[i];
      for (final up in allUserPoints) {
        final dx = cp.dx - up.dx;
        final dy = cp.dy - up.dy;
        if ((dx * dx + dy * dy) <= hitRadiusSquared) {
          hitIndices.add(i);
          break;
        }
      }
    }

    final coverage = hitIndices.length / checkpoints.length;

    // Must trace at least 60% of the dots to succeed
    final isSuccess = coverage >= 0.60;

    return TracingEvaluation(
      coverage: coverage,
      totalPoints: allUserPoints.length,
      hitIndices: hitIndices,
      isSuccess: isSuccess,
    );
  }
}

class TracingEvaluation {
  final double coverage;
  final int totalPoints;
  final Set<int> hitIndices;
  final bool isSuccess;

  TracingEvaluation({
    required this.coverage,
    required this.totalPoints,
    required this.hitIndices,
    required this.isSuccess,
  });
}
