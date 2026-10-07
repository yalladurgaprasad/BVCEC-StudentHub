import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HoverIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;
  final double iconSize;

  const HoverIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.iconSize = 22.0,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: Duration(milliseconds: disableAnimations ? 0 : 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            padding: const EdgeInsets.all(9),
            transform: Matrix4.identity()
              ..scale(_isPressed && !disableAnimations ? 0.95 : 1.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isHovered
                  ? Colors.white.withValues(alpha: isDark ? 0.20 : 0.25)
                  : Colors.transparent,
              boxShadow: _isHovered && !disableAnimations
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: AnimatedScale(
                duration: Duration(milliseconds: disableAnimations ? 0 : 180),
                scale: _isHovered && !disableAnimations ? 1.15 : 1.0,
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: widget.color ?? Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
