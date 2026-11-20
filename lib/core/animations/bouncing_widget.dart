import 'package:flutter/material.dart';

/// Squish-on-press, springy-release tap feedback used across the app.
class BouncingWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const BouncingWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.92,
  });

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget>
    with SingleTickerProviderStateMixin {
  // 0 = resting, 1 = fully pressed. Release uses a spring (elastic) curve so
  // the widget overshoots slightly — a "jelly" feel kids enjoy.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _press = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.elasticIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _enabled ? (_) => _controller.forward() : null,
      onTapUp: _enabled
          ? (_) {
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: _enabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _press,
        child: widget.child,
        builder: (context, child) {
          final p = _press.value;
          // Squash slightly wider than tall for a cartoony press.
          final sy = 1 - (1 - widget.scaleFactor) * p;
          final sx = 1 - (1 - widget.scaleFactor) * p * 0.7;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(sx, sy, 1),
            child: child,
          );
        },
      ),
    );
  }
}
