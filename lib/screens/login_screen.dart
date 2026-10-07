import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Selected Demo Role ('admin' or 'student' or null)
  String? _selectedRole;

  // Hover states for logo & card
  bool _logoHovered = false;
  bool _cardHovered = false;
  bool _forgotHovered = false;

  // Animation Controllers
  late AnimationController _entranceController;
  late AnimationController _blobController;

  // Entrance Staggered Animations
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _headerSlide;
  late Animation<double> _rolesSlide;
  late Animation<double> _formSlide;
  late Animation<double> _actionSlide;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Staggered Controller (800ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _headerSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _rolesSlide = Tween<double>(begin: 35.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _formSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _actionSlide = Tween<double>(begin: 45.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Slow Ambient Background Blob Animation (10s repeat reverse)
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _blobController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectRole(String role, String username, String password) {
    setState(() {
      _selectedRole = role;
      _usernameController.text = username;
      _passwordController.text = password;
      _errorMessage = null;
    });
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final success = studentProvider.login(
      _usernameController.text,
      _passwordController.text,
      remember: _rememberMe,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppConstants.routeDashboard);
    } else {
      setState(() {
        _errorMessage =
            'Invalid credentials. Please select Faculty/Admin or Student demo roles above.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. MODERN BACKGROUND WITH SUBTLE FLOATING GRADIENT BLOBS
          _buildModernBackground(isDark),

          // 2. MAIN LOGIN SCROLL CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _cardHovered = true),
                    onExit: (_) => setState(() => _cardHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      transform: Matrix4.translationValues(
                        0,
                        _cardHovered ? -4 : 0,
                        0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 36.0,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(
                              alpha: _cardHovered ? 0.18 : 0.10,
                            ),
                            blurRadius: _cardHovered ? 40 : 28,
                            spreadRadius: _cardHovered ? 0 : -4,
                            offset: Offset(0, _cardHovered ? 20 : 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 3. LOGO ANIMATION (Point 3)
                          _buildInteractiveLogo(isDark),
                          const SizedBox(height: 16),

                          // 4. STUDENTHUB TITLE & SUBTITLE (Point 5)
                          _buildStaggeredWidget(
                            animation: _headerSlide,
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      Color(0xFF06B6D4),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: const Text(
                                    AppConstants.appName,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppConstants.appSubtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 5. QUICK DEMO LOGIN ROLE SELECTOR (Point 6)
                          _buildStaggeredWidget(
                            animation: _rolesSlide,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.touch_app_outlined,
                                      size: 15,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SELECT DEMO ACCOUNT ROLE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _RoleSelectCard(
                                        title: 'Faculty / Admin',
                                        subtitle: 'admin / admin123',
                                        icon: Icons.admin_panel_settings_rounded,
                                        isSelected: _selectedRole == 'admin',
                                        isDark: isDark,
                                        onTap: () => _selectRole(
                                          'admin',
                                          AppConstants.adminUsername,
                                          AppConstants.adminPassword,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _RoleSelectCard(
                                        title: 'Student',
                                        subtitle: 'student / student123',
                                        icon: Icons.person_rounded,
                                        isSelected: _selectedRole == 'student',
                                        isDark: isDark,
                                        onTap: () => _selectRole(
                                          'student',
                                          AppConstants.studentUsername,
                                          AppConstants.studentPassword,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 6. LOGIN FORM INPUTS & ACTIONS (Points 7, 8, 9, 10, 11)
                          _buildStaggeredWidget(
                            animation: _formSlide,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_errorMessage != null) ...[
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.statusRed.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppTheme.statusRed.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline_rounded,
                                            color: AppTheme.statusRed,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                color: AppTheme.statusRed,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Username Input
                                  CustomTextField(
                                    controller: _usernameController,
                                    labelText: 'Username or Email',
                                    hintText: 'e.g. admin or student',
                                    prefixIcon: Icons.person_outline_rounded,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter username or email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 4),

                                  // Password Input
                                  CustomTextField(
                                    controller: _passwordController,
                                    labelText: 'Password',
                                    hintText: 'Enter password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter password';
                                      }
                                      if (value.trim().length < 4) {
                                        return 'Password must be at least 4 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),

                                  // Remember Me & Forgot Password Row
                                  _buildStaggeredWidget(
                                    animation: _actionSlide,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Custom Animated Checkbox (Point 9)
                                            Flexible(
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _rememberMe = !_rememberMe;
                                                  });
                                                },
                                                borderRadius: BorderRadius.circular(8),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                    vertical: 4.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      _CustomCheckboxWidget(
                                                        checked: _rememberMe,
                                                        isDark: isDark,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Flexible(
                                                        child: Text(
                                                          'Remember me',
                                                          style: TextStyle(
                                                            fontSize: 13.0,
                                                            fontWeight: FontWeight.w500,
                                                            color: isDark
                                                                ? const Color(0xFFCBD5E1)
                                                                : const Color(0xFF475569),
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Forgot Password Animated Link (Point 10)
                                            MouseRegion(
                                              onEnter: (_) =>
                                                  setState(() => _forgotHovered = true),
                                              onExit: (_) =>
                                                  setState(() => _forgotHovered = false),
                                              child: InkWell(
                                                onTap: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Select Faculty/Admin or Student role above for quick access.',
                                                      ),
                                                      duration: Duration(seconds: 2),
                                                    ),
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(6),
                                                child: AnimatedDefaultTextStyle(
                                                  duration:
                                                      const Duration(milliseconds: 150),
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: _forgotHovered
                                                        ? AppTheme.primaryLight
                                                        : AppTheme.primaryColor,
                                                    decoration: _forgotHovered
                                                        ? TextDecoration.underline
                                                        : TextDecoration.none,
                                                  ),
                                                  child: const Text('Forgot Password?'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),

                                        // 7. SIGN IN BUTTON CTA (Point 11)
                                        CustomButton(
                                          text: 'Sign In to StudentHub',
                                          isLoading: _isLoading,
                                          onPressed: _handleLogin,
                                          icon: Icons.login_rounded,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // HELPER WIDGETS FOR MODERN LOGIN UI
  // -------------------------------------------------------------

  // 1. MODERN BACKGROUND WITH FLOATING BLOBS (Point 1)
  Widget _buildModernBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, child) {
        final val = _blobController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                    ]
                  : [
                      const Color(0xFFF8FAFC),
                      const Color(0xFFEFF6FF),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Radial Glow behind card
              Center(
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(
                          alpha: isDark ? 0.12 : 0.08,
                        ),
                        Colors.transparent,
                      ],
                      radius: 0.85,
                    ),
                  ),
                ),
              ),

              // Animated Blob 1 (Top Right)
              Positioned(
                top: -50 + (math.sin(val * math.pi * 2) * 25),
                right: -40 + (math.cos(val * math.pi * 2) * 20),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF06B6D4).withValues(
                          alpha: isDark ? 0.15 : 0.12,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Animated Blob 2 (Bottom Left)
              Positioned(
                bottom: -60 + (math.cos(val * math.pi * 2) * 25),
                left: -50 + (math.sin(val * math.pi * 2) * 20),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(
                          alpha: isDark ? 0.15 : 0.10,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. INTERACTIVE LOGO ANIMATION (Point 3)
  Widget _buildInteractiveLogo(bool isDark) {
    return FadeTransition(
      opacity: _logoFade,
      child: ScaleTransition(
        scale: _logoScale,
        child: Center(
          child: MouseRegion(
            onEnter: (_) => setState(() => _logoHovered = true),
            onExit: (_) => setState(() => _logoHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              transform: Matrix4.diagonal3Values(
                _logoHovered ? 1.08 : 1.0,
                _logoHovered ? 1.08 : 1.0,
                1.0,
              )..rotateZ(_logoHovered ? -0.05 : 0.0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _logoHovered
                      ? [
                          AppTheme.primaryColor,
                          const Color(0xFF06B6D4),
                        ]
                      : [
                          AppTheme.primaryColor.withValues(alpha: 0.12),
                          AppTheme.primaryColor.withValues(alpha: 0.05),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(
                    alpha: _logoHovered ? 0.8 : 0.25,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(
                      alpha: _logoHovered ? 0.35 : 0.10,
                    ),
                    blurRadius: _logoHovered ? 24 : 12,
                    spreadRadius: _logoHovered ? 2 : 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.school_rounded,
                size: 44,
                color: _logoHovered ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 3. STAGGERED ENTRANCE WRAPPER (Point 4)
  Widget _buildStaggeredWidget({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Opacity(
            opacity: (1.0 - (animation.value / 45.0)).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// INTERACTIVE ROLE SELECTOR CARD WIDGET (Point 6)
// -------------------------------------------------------------
class _RoleSelectCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleSelectCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_RoleSelectCard> createState() => _RoleSelectCardState();
}

class _RoleSelectCardState extends State<_RoleSelectCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            0,
            _isPressed ? 1 : (_isHovered ? -2 : 0),
            0,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppTheme.primaryColor.withValues(alpha: 0.25)
                    : const Color(0xFFEFF6FF))
                : (_isHovered
                    ? (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9))
                    : (isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC))),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : (_isHovered
                      ? AppTheme.primaryColor.withValues(alpha: 0.5)
                      : (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0))),
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: [
              if (isSelected || _isHovered)
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(
                    alpha: isSelected ? 0.18 : 0.08,
                  ),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedScale(
                    scale: _isHovered || isSelected ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : (_isHovered
                              ? AppTheme.primaryColor
                              : (isDark ? Colors.white70 : const Color(0xFF64748B))),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.white : const Color(0xFF1E293B)),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// CUSTOM ANIMATED CHECKBOX WIDGET (Point 9)
// -------------------------------------------------------------
class _CustomCheckboxWidget extends StatelessWidget {
  final bool checked;
  final bool isDark;

  const _CustomCheckboxWidget({
    required this.checked,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked
            ? AppTheme.primaryColor
            : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked
              ? AppTheme.primaryColor
              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          width: 1.8,
        ),
        boxShadow: checked
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: checked
          ? const Icon(
              Icons.check_rounded,
              size: 14,
              color: Colors.white,
            )
          : null,
    );
  }
}
