import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InteractiveNavItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isSignOut;
  final bool isApiDemo;
  final Animation<double>? staggerAnimation;

  const InteractiveNavItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.isSignOut = false,
    this.isApiDemo = false,
    this.staggerAnimation,
  });

  @override
  State<InteractiveNavItem> createState() => _InteractiveNavItemState();
}

class _InteractiveNavItemState extends State<InteractiveNavItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // Build the core interactive item
    Widget navItem = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: disableAnimations ? 0 : 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          transform: Matrix4.identity()
            ..scale(_isPressed && !disableAnimations ? 0.97 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _getBackgroundColor(isDark),
            border: Border.all(
              color: _getBorderColor(isDark),
              width: (widget.isActive || _isHovered) ? 1.2 : 1.0,
            ),
            boxShadow: _getShadows(isDark),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  // 1. ACTIVE LEFT INDICATOR BAR (Animates in on select)
                  AnimatedContainer(
                    duration: Duration(milliseconds: disableAnimations ? 0 : 220),
                    curve: Curves.easeOutCubic,
                    width: widget.isActive ? 4.0 : 0.0,
                    height: 22.0,
                    margin: EdgeInsets.only(right: widget.isActive ? 10.0 : 0.0),
                    decoration: BoxDecoration(
                      color: widget.isSignOut
                          ? AppTheme.statusRed
                          : (widget.isApiDemo ? AppTheme.primaryLight : AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: (widget.isApiDemo ? AppTheme.primaryLight : AppTheme.primaryColor)
                                    .withValues(alpha: 0.4),
                                blurRadius: 6,
                              )
                            ]
                          : [],
                    ),
                  ),

                  // 2. INTERACTIVE ICON (Scale, TranslateX, Rotation per item type)
                  Transform.translate(
                    offset: Offset(_isHovered && !disableAnimations ? 3.0 : 0.0, 0.0),
                    child: Transform.rotate(
                      angle: _getIconRotation(),
                      child: AnimatedScale(
                        duration: Duration(milliseconds: disableAnimations ? 0 : 180),
                        scale: (_isHovered || widget.isActive) ? 1.10 : 1.0,
                        child: Icon(
                          widget.icon,
                          size: 21,
                          color: _getIconColor(isDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // 3. TITLE TEXT WITH HIGHLIGHT STYLING
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: disableAnimations ? 0 : 180),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.isActive
                            ? FontWeight.bold
                            : (_isHovered ? FontWeight.w600 : FontWeight.w500),
                        color: _getTextColor(isDark),
                        letterSpacing: widget.isActive ? 0.2 : 0.0,
                      ),
                      child: Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // 4. API DEMO BADGE / SIGN OUT CHEVRON / ACTIVE DOT
                  if (widget.isApiDemo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'REST',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  else if (widget.isActive)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // If stagger animation is provided, wrap in FadeTransition + SlideTransition
    if (widget.staggerAnimation != null && !disableAnimations) {
      return AnimatedBuilder(
        animation: widget.staggerAnimation!,
        builder: (context, child) {
          final val = widget.staggerAnimation!.value;
          return Transform.translate(
            offset: Offset(-20.0 * (1.0 - val), 0.0),
            child: Opacity(
              opacity: val.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: navItem,
      );
    }

    return navItem;
  }

  // Determine icon rotation for settings/analytics
  double _getIconRotation() {
    if (!_isHovered) return 0.0;
    if (widget.icon == Icons.settings_outlined || widget.icon == Icons.settings) {
      return 0.14; // Subtle gear turn on hover
    }
    return 0.0;
  }

  // Get background color based on state
  Color _getBackgroundColor(bool isDark) {
    if (widget.isSignOut) {
      return _isHovered
          ? AppTheme.statusRed.withValues(alpha: 0.12)
          : Colors.transparent;
    }
    if (widget.isApiDemo) {
      if (widget.isActive) {
        return AppTheme.primaryLight.withValues(alpha: 0.18);
      }
      return _isHovered
          ? AppTheme.primaryLight.withValues(alpha: 0.12)
          : AppTheme.primaryLight.withValues(alpha: 0.04);
    }
    if (widget.isActive) {
      return isDark
          ? AppTheme.primaryColor.withValues(alpha: 0.25)
          : AppTheme.primaryColor.withValues(alpha: 0.10);
    }
    if (_isHovered) {
      return isDark
          ? const Color(0xFF334155).withValues(alpha: 0.6)
          : const Color(0xFFF1F5F9);
    }
    return Colors.transparent;
  }

  // Get border color based on state
  Color _getBorderColor(bool isDark) {
    if (widget.isSignOut) {
      return _isHovered ? AppTheme.statusRed.withValues(alpha: 0.4) : Colors.transparent;
    }
    if (widget.isApiDemo) {
      return (_isHovered || widget.isActive)
          ? AppTheme.primaryLight.withValues(alpha: 0.5)
          : AppTheme.primaryLight.withValues(alpha: 0.2);
    }
    if (widget.isActive) {
      return AppTheme.primaryColor.withValues(alpha: 0.4);
    }
    if (_isHovered) {
      return isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    }
    return Colors.transparent;
  }

  // Get icon color based on state
  Color _getIconColor(bool isDark) {
    if (widget.isSignOut) {
      return AppTheme.statusRed;
    }
    if (widget.isApiDemo) {
      return AppTheme.primaryLight;
    }
    if (widget.isActive || _isHovered) {
      return isDark ? AppTheme.primaryLight : AppTheme.primaryColor;
    }
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  }

  // Get text color based on state
  Color _getTextColor(bool isDark) {
    if (widget.isSignOut) {
      return AppTheme.statusRed;
    }
    if (widget.isApiDemo) {
      return AppTheme.primaryLight;
    }
    if (widget.isActive) {
      return isDark ? AppTheme.primaryLight : AppTheme.primaryColor;
    }
    if (_isHovered) {
      return isDark ? Colors.white : const Color(0xFF0F172A);
    }
    return isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
  }

  // Get shadows based on state
  List<BoxShadow> _getShadows(bool isDark) {
    if (_isHovered || widget.isActive) {
      final glowColor = widget.isSignOut
          ? AppTheme.statusRed
          : (widget.isApiDemo ? AppTheme.primaryLight : AppTheme.primaryColor);
      return [
        BoxShadow(
          color: glowColor.withValues(alpha: _isHovered ? 0.16 : 0.08),
          blurRadius: _isHovered ? 10 : 6,
          offset: const Offset(0, 3),
        ),
      ];
    }
    return [];
  }
}
