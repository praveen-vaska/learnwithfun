import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../theme/app_colors.dart';

class ConfettiCelebration extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const ConfettiCelebration({
    super.key,
    required this.child,
    this.trigger = false,
  });

  @override
  State<ConfettiCelebration> createState() => ConfettiCelebrationState();
}

class ConfettiCelebrationState extends State<ConfettiCelebration> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    if (widget.trigger) {
      _confettiController.play();
    }
  }

  void play() {
    _confettiController.play();
  }

  @override
  void didUpdateWidget(covariant ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primaryPurple,
              AppColors.yellow,
              AppColors.lime,
              AppColors.pink,
              AppColors.skyBlue,
              Colors.orange,
            ],
            numberOfParticles: 25,
            gravity: 0.25,
            emissionFrequency: 0.05,
          ),
        ),
      ],
    );
  }
}
