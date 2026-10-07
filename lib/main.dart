import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/attendance_provider.dart';
import 'providers/performance_provider.dart';
import 'providers/student_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/add_student_screen.dart';
import 'screens/api_demo_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/marks_screen.dart';
import 'screens/performance_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/student_details_screen.dart';
import 'screens/student_list_screen.dart';

import 'theme/app_theme.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentHubApp());
}

class StudentHubApp extends StatelessWidget {
  const StudentHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => PerformanceProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppConstants.routeSplash,
            routes: {
              AppConstants.routeSplash: (context) => const SplashScreen(),
              AppConstants.routeLogin: (context) => const LoginScreen(),
              AppConstants.routeDashboard: (context) => const DashboardScreen(),
              AppConstants.routeStudents: (context) => const StudentListScreen(),
              AppConstants.routeAddStudent: (context) => const AddStudentScreen(),
              AppConstants.routeStudentDetails: (context) => const StudentDetailsScreen(),
              AppConstants.routeAttendance: (context) => const AttendanceScreen(),
              AppConstants.routeMarks: (context) => const MarksScreen(),
              AppConstants.routePerformance: (context) => const PerformanceScreen(),
              AppConstants.routeReports: (context) => const ReportsScreen(),
              AppConstants.routeApiDemo: (context) => const ApiDemoScreen(),
              AppConstants.routeSettings: (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
