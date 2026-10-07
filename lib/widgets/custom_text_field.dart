import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  bool _isFocused = false;
  bool _isHovered = false;
  bool _eyeHovered = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isActive = _isFocused || _isHovered;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              0,
              isActive ? -3 : 0,
              0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(
                          alpha: _isFocused ? 0.22 : 0.12,
                        ),
                        blurRadius: _isFocused ? 14 : 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onChanged: widget.onChanged,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              maxLines: widget.maxLines,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon != null
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          widget.prefixIcon,
                          key: ValueKey(isActive),
                          color: isActive
                              ? AppTheme.primaryColor
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                        ),
                      )
                    : null,
                suffixIcon: widget.isPassword
                    ? MouseRegion(
                        onEnter: (_) => setState(() => _eyeHovered = true),
                        onExit: (_) => setState(() => _eyeHovered = false),
                        child: AnimatedScale(
                          scale: _eyeHovered ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: IconButton(
                            tooltip: _obscureText ? 'Show password' : 'Hide password',
                            icon: AnimatedOpacity(
                              duration: const Duration(milliseconds: 150),
                              opacity: _eyeHovered ? 1.0 : 0.8,
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: isActive || _eyeHovered
                                    ? AppTheme.primaryColor
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.grey[700]),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      )
                    : widget.suffixIcon,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isActive
                        ? AppTheme.primaryColor
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                    width: isActive ? 1.8 : 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
