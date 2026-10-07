class AppConstants {
  static const String appName = 'BVCEC STUDENTHUB';
  static const String appSubtitle = 'Attendance & Performance Management System';
  static const String appVersion = '1.0.0';

  // Named Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeDashboard = '/dashboard';
  static const String routeStudents = '/students';
  static const String routeAddStudent = '/add-student';
  static const String routeStudentDetails = '/student-details';
  static const String routeAttendance = '/attendance';
  static const String routeMarks = '/marks';
  static const String routePerformance = '/performance';
  static const String routeReports = '/reports';
  static const String routeApiDemo = '/api-demo';
  static const String routeSettings = '/settings';

  // Demo User Credentials
  static const String adminUsername = 'admin';
  static const String adminPassword = 'admin123';
  static const String studentUsername = 'student';
  static const String studentPassword = 'student123';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleStudent = 'student';

  // Academic Dropdown Options
  static const List<String> departments = [
    'Computer Science',
    'Information Technology',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
  ];

  static const List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  static const List<String> sections = [
    'A',
    'B',
    'C',
    'D',
  ];

  static const List<String> subjects = [
    'Java Programming',
    'DBMS',
    'Computer Networks',
    'Operating Systems',
    'Python Programming',
    'Web Development',
  ];

  // Thresholds
  static const double attendanceAtRiskThreshold = 75.0;
  static const double marksAtRiskThreshold = 40.0;

  // Grade Calculation Helper
  static String calculateGrade(double percentage) {
    if (percentage >= 90.0) return 'A+';
    if (percentage >= 80.0) return 'A';
    if (percentage >= 70.0) return 'B';
    if (percentage >= 60.0) return 'C';
    if (percentage >= 50.0) return 'D';
    if (percentage >= 40.0) return 'E';
    return 'F';
  }

  // Performance Status Helper
  static String getPerformanceStatus(double percentage) {
    if (percentage >= 80.0) return 'Excellent';
    if (percentage >= 70.0) return 'Good';
    if (percentage >= 50.0) return 'Average';
    return 'Needs Improvement';
  }
}
