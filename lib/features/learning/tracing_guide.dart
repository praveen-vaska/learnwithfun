import 'dart:math';
import 'package:flutter/material.dart';

/// Helper class that creates stencil paths and checkpoint dots for tracing practice.
/// Supports uppercase letters A-Z, numbers 0-9, shapes, and multi-letter words with clear letter gaps.
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

  /// Returns scaled Paths for text / symbol across the given bounds with generous letter gaps.
  static List<Path> getScaledPaths(String text, Rect bounds) {
    final clean = text.trim();
    if (clean.isEmpty) return [];

    // Single character (e.g. 'A' or '1')
    if (clean.length == 1) {
      // Keep proper character aspect ratio (width ~ 0.75 of height)
      final charHeight = bounds.height * 0.85;
      final charWidth = min(bounds.width * 0.75, charHeight * 0.75);
      final charBounds = Rect.fromCenter(
        center: bounds.center,
        width: charWidth,
        height: charHeight,
      );
      final normPaths = getNormalizedPathsForChar(clean);
      return _scalePaths(normPaths, charBounds);
    }

    // Multi-character word (e.g. 'APPLE', 'ONE', 'MOO')
    final word = clean.toUpperCase();
    final letterCount = word.length;

    // Generous spacing between letters so children can trace each letter cleanly
    final maxAvailableWidth = bounds.width * 0.92;
    final maxAvailableHeight = bounds.height * 0.75;

    // Proportional letter width and gap
    // Ideal ratio: letterWidth = 0.65 * height, gap = 0.30 * letterWidth
    double letterHeight = maxAvailableHeight;
    double letterWidth = letterHeight * 0.60;
    double gap = letterWidth * 0.28;

    double totalWordWidth = (letterCount * letterWidth) + ((letterCount - 1) * gap);

    // If total width exceeds canvas bounds, scale down proportionally
    if (totalWordWidth > maxAvailableWidth) {
      final scale = maxAvailableWidth / totalWordWidth;
      letterHeight *= scale;
      letterWidth *= scale;
      gap *= scale;
      totalWordWidth = maxAvailableWidth;
    }

    final startX = bounds.left + (bounds.width - totalWordWidth) / 2;
    final startY = bounds.top + (bounds.height - letterHeight) / 2;

    final result = <Path>[];

    for (int i = 0; i < letterCount; i++) {
      final char = word[i];
      final charLeft = startX + (i * (letterWidth + gap));
      final charBounds = Rect.fromLTWH(charLeft, startY, letterWidth, letterHeight);
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

        final numSteps = max(5, (length / 20).round());
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

  /// Extracts structured target data with component-level checkpoint segmentation
  /// (e.g. each stroke of a letter, or each character in a word).
  static TracingTargetData getTargetData(String text, Rect bounds) {
    final clean = text.trim();
    if (clean.isEmpty) {
      return TracingTargetData(
        allPaths: [],
        componentCheckpoints: [],
        flatCheckpoints: [],
        componentLabels: [],
      );
    }

    final allPaths = <Path>[];
    final componentCheckpoints = <List<Offset>>[];
    final flatCheckpoints = <Offset>[];
    final componentLabels = <String>[];

    if (clean.length == 1) {
      // Single character (e.g. 'A', '1')
      final charHeight = bounds.height * 0.85;
      final charWidth = min(bounds.width * 0.75, charHeight * 0.75);
      final charBounds = Rect.fromCenter(
        center: bounds.center,
        width: charWidth,
        height: charHeight,
      );

      final normPaths = getNormalizedPathsForChar(clean);
      final scaled = _scalePaths(normPaths, charBounds);
      allPaths.addAll(scaled);

      for (int i = 0; i < scaled.length; i++) {
        final pts = extractCheckpoints([scaled[i]], pointsPerPath: 16);
        if (pts.isNotEmpty) {
          componentCheckpoints.add(pts);
          flatCheckpoints.addAll(pts);
          componentLabels.add('${clean.toUpperCase()} part ${i + 1}');
        }
      }
    } else {
      // Multi-character word (e.g. 'APPLE', 'ONE', 'MOO')
      final word = clean.toUpperCase();
      final letterCount = word.length;

      final maxAvailableWidth = bounds.width * 0.92;
      final maxAvailableHeight = bounds.height * 0.75;

      double letterHeight = maxAvailableHeight;
      double letterWidth = letterHeight * 0.60;
      double gap = letterWidth * 0.28;

      double totalWordWidth = (letterCount * letterWidth) + ((letterCount - 1) * gap);
      if (totalWordWidth > maxAvailableWidth) {
        final scale = maxAvailableWidth / totalWordWidth;
        letterHeight *= scale;
        letterWidth *= scale;
        gap *= scale;
        totalWordWidth = maxAvailableWidth;
      }

      final startX = bounds.left + (bounds.width - totalWordWidth) / 2;
      final startY = bounds.top + (bounds.height - letterHeight) / 2;

      for (int i = 0; i < letterCount; i++) {
        final char = word[i];
        final charLeft = startX + (i * (letterWidth + gap));
        final charBounds = Rect.fromLTWH(charLeft, startY, letterWidth, letterHeight);
        final normPaths = getNormalizedPathsForChar(char);
        final scaledCharPaths = _scalePaths(normPaths, charBounds);
        allPaths.addAll(scaledCharPaths);

        final charPts = extractCheckpoints(scaledCharPaths, pointsPerPath: 14);
        if (charPts.isNotEmpty) {
          componentCheckpoints.add(charPts);
          flatCheckpoints.addAll(charPts);
          componentLabels.add(char);
        }
      }
    }

    return TracingTargetData(
      allPaths: allPaths,
      componentCheckpoints: componentCheckpoints,
      flatCheckpoints: flatCheckpoints,
      componentLabels: componentLabels,
    );
  }

  /// Calculates the fraction of checkpoints visited by the user's strokes,
  /// strictly enforcing:
  /// 1. Overall checkpoint coverage (>= 68%).
  /// 2. Every single component / stroke / character has adequate coverage (>= 45%),
  ///    preventing half-drawn letters (e.g. drawing 1 leg of 'A') or skipped letters in words.
  /// 3. Off-target scribble rejection (at least 50% of user points must be on the stencil).
  static TracingEvaluation evaluateTracing({
    required List<Offset> checkpoints,
    required List<List<Offset>> userStrokes,
    List<List<Offset>>? componentCheckpoints,
    double hitRadius = 26.0,
    double minOverallCoverage = 0.68,
    double minComponentCoverage = 0.45,
    double minAccuracyRatio = 0.50,
    String targetName = '',
  }) {
    if (checkpoints.isEmpty) {
      return TracingEvaluation(
        coverage: 1.0,
        accuracyRatio: 1.0,
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
        accuracyRatio: 0.0,
        totalPoints: 0,
        hitIndices: {},
        isSuccess: false,
        rejectionReason: 'Trace on the dotted lines to begin!',
      );
    }

    // Minimum stroke points required to avoid passing accidental taps
    if (allUserPoints.length < 4) {
      return TracingEvaluation(
        coverage: 0.0,
        accuracyRatio: 0.0,
        totalPoints: allUserPoints.length,
        hitIndices: {},
        isSuccess: false,
        rejectionReason: 'Keep tracing along the dotted lines! 👆',
      );
    }

    final hitIndices = <int>{};
    final hitRadiusSquared = hitRadius * hitRadius;
    final onTargetThresholdSquared = (hitRadius * 1.35) * (hitRadius * 1.35);

    // 1. Calculate checkpoints hit
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

    // 2. Calculate on-target points ratio (detects off-target scribbles)
    int onTargetUserPoints = 0;
    for (final up in allUserPoints) {
      bool isNear = false;
      for (final cp in checkpoints) {
        final dx = cp.dx - up.dx;
        final dy = cp.dy - up.dy;
        if ((dx * dx + dy * dy) <= onTargetThresholdSquared) {
          isNear = true;
          break;
        }
      }
      if (isNear) {
        onTargetUserPoints++;
      }
    }

    final accuracyRatio = onTargetUserPoints / allUserPoints.length;
    final coverage = hitIndices.length / checkpoints.length;

    // 3. Verify each component (each stroke of letter, or each letter in word)
    bool allComponentsSatisfied = true;
    if (componentCheckpoints != null && componentCheckpoints.isNotEmpty) {
      int offsetTracker = 0;
      for (int c = 0; c < componentCheckpoints.length; c++) {
        final compList = componentCheckpoints[c];
        int compHits = 0;
        for (int p = 0; p < compList.length; p++) {
          final globalIndex = offsetTracker + p;
          if (hitIndices.contains(globalIndex)) {
            compHits++;
          }
        }
        offsetTracker += compList.length;

        final compCoverage = compList.isEmpty ? 1.0 : (compHits / compList.length);
        if (compCoverage < minComponentCoverage) {
          allComponentsSatisfied = false;
          break;
        }
      }
    }

    // Determine rejection reason if not successful
    String? rejectionReason;
    bool isSuccess = false;

    if (accuracyRatio < minAccuracyRatio) {
      rejectionReason = 'Trace carefully on the dotted stencil! ✏️';
    } else if (!allComponentsSatisfied) {
      if (targetName.length > 1) {
        rejectionReason = 'Trace all letters in "$targetName"! You missed some letters! 🔤';
      } else {
        rejectionReason = 'Trace all parts of "$targetName"! Don\'t miss any lines! ✏️';
      }
    } else if (coverage < minOverallCoverage) {
      final pct = (coverage * 100).toInt();
      rejectionReason = 'Almost there! You traced $pct% of "$targetName". Trace the rest of the lines! ✨';
    } else {
      isSuccess = true;
    }

    return TracingEvaluation(
      coverage: coverage,
      accuracyRatio: accuracyRatio,
      totalPoints: allUserPoints.length,
      hitIndices: hitIndices,
      isSuccess: isSuccess,
      rejectionReason: rejectionReason,
    );
  }
}

/// Structured target data for a tracing exercise
class TracingTargetData {
  final List<Path> allPaths;
  final List<List<Offset>> componentCheckpoints;
  final List<Offset> flatCheckpoints;
  final List<String> componentLabels;

  TracingTargetData({
    required this.allPaths,
    required this.componentCheckpoints,
    required this.flatCheckpoints,
    required this.componentLabels,
  });
}

class TracingEvaluation {
  final double coverage;
  final double accuracyRatio;
  final int totalPoints;
  final Set<int> hitIndices;
  final bool isSuccess;
  final String? rejectionReason;

  TracingEvaluation({
    required this.coverage,
    this.accuracyRatio = 1.0,
    required this.totalPoints,
    required this.hitIndices,
    required this.isSuccess,
    this.rejectionReason,
  });
}
