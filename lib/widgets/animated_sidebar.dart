import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'interactive_nav_item.dart';

class AnimatedSidebar extends StatefulWidget {
  final String currentRoute;

  const AnimatedSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  State<AnimatedSidebar> createState() => _AnimatedSidebarState();
}

class _AnimatedSidebarState extends State<AnimatedSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    // 300ms staggered entrance for sidebar nav items
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  // Generate staggered animation for item index
  Animation<double> _createItemAnimation(int index, int totalItems) {
    final double start = (index / totalItems) * 0.5;
    final double end = (start + 0.5).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentUser = studentProvider.currentUser;
    final isAdmin = currentUser?.isAdmin == true;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define Navigation Items based on role
    final List<_NavItemData> navItems = [
      _NavItemData(
        title: 'Dashboard Overview',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        route: AppConstants.routeDashboard,
      ),
      _NavItemData(
        title: isAdmin ? 'Students Directory' : 'My Class Directory',
        icon: isAdmin ? Icons.people_outline : Icons.class_outlined,
        activeIcon: isAdmin ? Icons.people : Icons.class_,
        route: AppConstants.routeStudents,
      ),
      _NavItemData(
        title: isAdmin ? 'Attendance Management' : 'My Attendance Tracker',
        icon: Icons.fact_check_outlined,
        activeIcon: Icons.fact_check,
        route: AppConstants.routeAttendance,
      ),
      if (isAdmin)
        _NavItemData(
          title: 'Marks & Grades Entry',
          icon: Icons.edit_note_outlined,
          activeIcon: Icons.edit_note,
          route: AppConstants.routeMarks,
        ),
      _NavItemData(
        title: isAdmin ? 'Faculty Analytics' : 'My Marks & Grades',
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights,
        route: AppConstants.routePerformance,
      ),
      _NavItemData(
        title: isAdmin ? 'Institute Reports' : 'My Academic Reports',
        icon: Icons.assessment_outlined,
        activeIcon: Icons.assessment,
        route: AppConstants.routeReports,
      ),
      _NavItemData(
        title: 'API Integration Demo',
        icon: Icons.cloud_download_outlined,
        activeIcon: Icons.cloud_download,
        route: AppConstants.routeApiDemo,
        isApiDemo: true,
      ),
      _NavItemData(
        title: 'Settings & Preferences',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        route: AppConstants.routeSettings,
      ),
    ];

    final int totalCount = navItems.length + 1; // +1 for logout

    return Drawer(
      width: 290,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Column(
        children: [
          // 1. USER PROFILE HEADER BANNER
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAdmin
                    ? [AppTheme.primaryColor, AppTheme.primaryDark]
                    : [AppTheme.secondaryColor, const Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    currentUser?.name.isNotEmpty == true ? currentUser!.name[0] : 'U',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            accountName: Text(
              currentUser?.name ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentUser?.email ?? 'user@university.edu'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isAdmin ? 'FACULTY / ADMIN PORTAL' : 'STUDENT PORTAL',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. STAGGERED NAVIGATION ITEMS LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final bool isActive = widget.currentRoute == item.route;
                final staggerAnim = _createItemAnimation(index, totalCount);

                return InteractiveNavItem(
                  title: item.title,
                  icon: isActive ? item.activeIcon : item.icon,
                  isActive: isActive,
                  isApiDemo: item.isApiDemo,
                  staggerAnimation: staggerAnim,
                  onTap: () {
                    Navigator.pop(context); // Close drawer smoothly
                    if (!isActive) {
                      if (item.route == AppConstants.routeDashboard) {
                        Navigator.of(context).pushReplacementNamed(item.route);
                      } else {
                        Navigator.of(context).pushNamed(item.route);
                      }
                    }
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 6),

          // 3. SIGN OUT ITEM WITH SPECIAL STYLING
          InteractiveNavItem(
            title: 'Sign Out',
            icon: Icons.logout_rounded,
            isActive: false,
            isSignOut: true,
            staggerAnimation: _createItemAnimation(navItems.length, totalCount),
            onTap: () {
              Navigator.pop(context);
              studentProvider.logout();
              Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _NavItemData {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final bool isApiDemo;

  _NavItemData({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.isApiDemo = false,
  });
}
