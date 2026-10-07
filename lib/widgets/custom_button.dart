import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppTheme.primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            0,
            _isPressed ? 1 : (_isHovered ? -3 : 0),
            0,
          ),
          width: widget.width,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: !widget.isOutlined
                ? LinearGradient(
                    colors: _isHovered
                        ? [
                            AppTheme.primaryLight,
                            AppTheme.primaryColor,
                          ]
                        : [
                            bgColor,
                            AppTheme.primaryDark,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            border: Border.all(
              color: _isHovered ? AppTheme.primaryLight : (widget.isOutlined ? bgColor : AppTheme.primaryDark),
              width: _isHovered ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(
                  alpha: _isPressed ? 0.20 : (_isHovered ? 0.45 : 0.25),
                ),
                blurRadius: _isHovered ? 18 : 10,
                spreadRadius: _isHovered ? 1 : 0,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.05),
              child: Center(
                child: _buildChild(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.4,
      color: widget.textColor ??
          (widget.isOutlined
              ? (_isHovered ? AppTheme.primaryLight : AppTheme.primaryColor)
              : Colors.white),
    );

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: _isHovered ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.textColor ??
                  (widget.isOutlined ? AppTheme.primaryColor : Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Text(widget.text, style: textStyle),
        ],
      );
    }

    return Text(widget.text, style: textStyle);
  }
}
