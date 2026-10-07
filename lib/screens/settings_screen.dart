import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentUser = studentProvider.currentUser;

    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current User Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                      child: Text(
                        currentUser?.name.isNotEmpty == true ? currentUser!.name[0] : 'U',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.name ?? 'Guest User',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentUser?.email ?? 'user@university.edu',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Role: ${currentUser?.role.toUpperCase() ?? "GUEST"}',
                              style: const TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Appearance Section
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text('Dark Mode Theme'),
                    subtitle: Text(
                      isDark ? 'Dark theme is enabled' : 'Light theme is enabled',
                    ),
                    value: isDark,
                    onChanged: (bool value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Application Information Section
            const Text(
              'System Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                    title: const Text('Application Name'),
                    subtitle: const Text(AppConstants.appName),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: AppTheme.primaryColor),
                    title: const Text('Subtitle'),
                    subtitle: const Text(AppConstants.appSubtitle),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.vibration_outlined, color: AppTheme.primaryColor),
                    title: const Text('Version'),
                    subtitle: const Text('v1.0.0 (Build 2026.10)'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code_outlined, color: AppTheme.primaryColor),
                    title: const Text('Framework'),
                    subtitle: const Text('Flutter 3.47.6 with Dart & Material 3'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () {
                  studentProvider.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppConstants.routeLogin,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out of StudentHub'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
