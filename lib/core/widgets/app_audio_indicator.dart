import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../animations/bouncing_widget.dart';

class AppAudioIndicator extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onToggle;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const AppAudioIndicator({
    super.key,
    required this.isPlaying,
    required this.onToggle,
    this.size = 44,
    this.backgroundColor = AppColors.softPurple,
    this.iconColor = AppColors.primaryPurple,
  });

  @override
  State<AppAudioIndicator> createState() => _AppAudioIndicatorState();
}

class _AppAudioIndicatorState extends State<AppAudioIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isPlaying) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AppAudioIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animController.repeat(reverse: true);
      } else {
        _animController.stop();
        _animController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      onTap: widget.onToggle,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.isPlaying ? AppColors.yellow : widget.backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.isPlaying
                  ? AppColors.yellowDark.withAlpha(80)
                  : AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Center(
              child: Icon(
                widget.isPlaying
                    ? Icons.volume_up_rounded
                    : Icons.volume_up_outlined,
                color: widget.isPlaying ? AppColors.textDark : widget.iconColor,
                size: widget.size * 0.55 + (_animController.value * 3),
              ),
            );
          },
        ),
      ),
    );
  }
}
