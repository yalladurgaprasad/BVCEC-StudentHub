import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/attendance_provider.dart';
import '../providers/performance_provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/attendance_card.dart';
import '../widgets/performance_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/student_card.dart';
import '../widgets/animated_sidebar.dart';
import '../widgets/hover_icon_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentBottomNavIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == _currentBottomNavIndex) return;

    switch (index) {
      case 0:
        // Dashboard
        break;
      case 1:
        Navigator.of(context).pushNamed(AppConstants.routeStudents);
        break;
      case 2:
        Navigator.of(context).pushNamed(AppConstants.routeAttendance);
        break;
      case 3:
        Navigator.of(context).pushNamed(AppConstants.routePerformance);
        break;
      case 4:
        Navigator.of(context).pushNamed(AppConstants.routeReports);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final performanceProvider = Provider.of<PerformanceProvider>(context);

    final currentUser = studentProvider.currentUser;
    final isAdmin = currentUser?.isAdmin == true;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAdmin ? Icons.admin_panel_settings_rounded : Icons.school_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isAdmin ? 'BVCEC Faculty Command Center' : 'BVCEC Student Portal',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          HoverIconButton(
            icon: Icons.api_rounded,
            tooltip: 'REST API Demo',
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeApiDemo);
            },
          ),
          HoverIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings & Theme',
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeSettings);
            },
          ),
        ],
      ),

      // Custom Animated Sidebar with Staggered Navigation Items
      drawer: const AnimatedSidebar(
        currentRoute: AppConstants.routeDashboard,
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: isAdmin
              ? _buildFacultyDashboard(
                  context,
                  studentProvider,
                  attendanceProvider,
                  performanceProvider,
                  isDark,
                )
              : _buildStudentDashboard(
                  context,
                  studentProvider,
                  attendanceProvider,
                  performanceProvider,
                  isDark,
                ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(isAdmin ? Icons.people_outline : Icons.class_outlined),
            activeIcon: Icon(isAdmin ? Icons.people : Icons.class_),
            label: isAdmin ? 'Students' : 'Classmates',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'Attendance',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Performance',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),

      // FAB only for Faculty/Admin
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeAddStudent);
              },
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Student'),
            )
          : null,
    );
  }

  // ==========================================
  // 1. FACULTY / ADMIN DASHBOARD VIEW (ULTRA MODERN SaaS)
  // ==========================================
  Widget _buildFacultyDashboard(
    BuildContext context,
    StudentProvider studentProvider,
    AttendanceProvider attendanceProvider,
    PerformanceProvider performanceProvider,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final currentUser = studentProvider.currentUser;

    final totalStudents = studentProvider.totalStudents;
    final presentToday = attendanceProvider.getPresentCountToday();
    final avgAttendance = attendanceProvider.getOverallAverageAttendance();
    final avgMarks = performanceProvider.getOverallAverageMarks();

    final atRiskAttendanceIds = attendanceProvider.getAtRiskStudentIds();
    final atRiskMarksIds = performanceProvider.getAtRiskStudentIds();
    final allAtRiskIds = {...atRiskAttendanceIds, ...atRiskMarksIds};

    final atRiskStudents = studentProvider.students
        .where((s) => allAtRiskIds.contains(s.studentId))
        .toList();

    // Calculate Department Breakdown
    final cseCount = studentProvider.students.where((s) => s.department == 'CSE').length;
    final eceCount = studentProvider.students.where((s) => s.department == 'ECE').length;
    final eeeCount = studentProvider.students.where((s) => s.department == 'EEE').length;
    final mechCount = studentProvider.students.where((s) => s.department == 'MECH').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------
        // A. FACULTY HERO BANNER WITH AMBIENT GRAPHICS
        // ------------------------------------
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [AppTheme.primaryColor, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Live Status Ribbon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_rounded, size: 14, color: Colors.greenAccent),
                              SizedBox(width: 6),
                              Text(
                                'SYSTEM STATUS: ONLINE • LIVE ACADEMIC SESSION',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white70),
                              SizedBox(width: 6),
                              Text(
                                'AY 2026',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Faculty User Info & Welcome Title
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Text(
                                  currentUser?.name.isNotEmpty == true ? currentUser!.name[0] : 'F',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
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
                                  border: Border.all(color: AppTheme.primaryColor, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, ${currentUser?.name ?? "Faculty Admin"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Head of Academic Operations & Student Governance',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Mini Metric Badges inside Hero Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHeroMetricPill(
                            icon: Icons.people_rounded,
                            label: 'Enrolled',
                            value: '$totalStudents Students',
                          ),
                          Container(width: 1, height: 24, color: Colors.white24),
                          _buildHeroMetricPill(
                            icon: Icons.check_circle_rounded,
                            label: 'Today Present',
                            value: '$presentToday Present',
                          ),
                          Container(width: 1, height: 24, color: Colors.white24),
                          _buildHeroMetricPill(
                            icon: Icons.warning_amber_rounded,
                            label: 'At Risk',
                            value: '${atRiskStudents.length} Students',
                            valueColor: atRiskStudents.isNotEmpty ? Colors.amberAccent : Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Decorative ambient circles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ------------------------------------
        // B. FACULTY QUICK ACTION COMMAND CENTER
        // ------------------------------------
        const SectionHeader(title: 'Faculty Quick Actions'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FacultyQuickActionButton(
                icon: Icons.person_add_rounded,
                label: 'Add Student',
                subtitle: 'Register new student',
                color: const Color(0xFF2563EB),
                onTap: () => Navigator.of(context).pushNamed(AppConstants.routeAddStudent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FacultyQuickActionButton(
                icon: Icons.fact_check_rounded,
                label: 'Attendance',
                subtitle: 'Mark daily attendance',
                color: const Color(0xFF059669),
                onTap: () => Navigator.of(context).pushNamed(AppConstants.routeAttendance),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FacultyQuickActionButton(
                icon: Icons.edit_note_rounded,
                label: 'Enter Marks',
                subtitle: 'Update test scores',
                color: const Color(0xFFD97706),
                onTap: () => Navigator.of(context).pushNamed(AppConstants.routeMarks),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FacultyQuickActionButton(
                icon: Icons.assessment_rounded,
                label: 'Reports & CSV',
                subtitle: 'Generate analytics',
                color: const Color(0xFF7C3AED),
                onTap: () => Navigator.of(context).pushNamed(AppConstants.routeReports),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ------------------------------------
        // C. INSTITUTE KEY METRICS GRID
        // ------------------------------------
        const SectionHeader(title: 'Institute Key Metrics'),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth > 500 ? 1.5 : 1.3,
              children: [
                StatCard(
                  title: 'Total Enrolled',
                  value: '$totalStudents',
                  subtitle: 'Active Students',
                  icon: Icons.people_outline_rounded,
                  iconBgColor: Colors.blue.withValues(alpha: 0.15),
                  iconColor: Colors.blue,
                  onTap: () => Navigator.of(context).pushNamed(AppConstants.routeStudents),
                ),
                StatCard(
                  title: 'Present Today',
                  value: '$presentToday',
                  subtitle: 'Daily Attendance',
                  icon: Icons.check_circle_outline_rounded,
                  iconBgColor: Colors.green.withValues(alpha: 0.15),
                  iconColor: Colors.green,
                  onTap: () => Navigator.of(context).pushNamed(AppConstants.routeAttendance),
                ),
                StatCard(
                  title: 'Avg Attendance',
                  value: '${avgAttendance.toStringAsFixed(1)}%',
                  subtitle: 'Target ≥ 75%',
                  icon: Icons.pie_chart_outline_rounded,
                  iconBgColor: (avgAttendance >= 75 ? Colors.teal : Colors.orange)
                      .withValues(alpha: 0.15),
                  iconColor: avgAttendance >= 75 ? Colors.teal : Colors.orange,
                  onTap: () => Navigator.of(context).pushNamed(AppConstants.routeAttendance),
                ),
                StatCard(
                  title: 'Academic Avg',
                  value: '${avgMarks.toStringAsFixed(1)}%',
                  subtitle: 'Overall Score',
                  icon: Icons.trending_up_rounded,
                  iconBgColor: Colors.indigo.withValues(alpha: 0.15),
                  iconColor: Colors.indigo,
                  onTap: () => Navigator.of(context).pushNamed(AppConstants.routePerformance),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // ------------------------------------
        // D. DEPARTMENT ENROLLMENT & ACADEMIC BREAKDOWN CARD
        // ------------------------------------
        const SectionHeader(title: 'Departmental & Academic Breakdown'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
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
                  const Text(
                    'Department Distribution',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '100% Allocated',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Department Progress Bars
              _buildDepartmentProgressBar(
                context,
                deptName: 'Computer Science (CSE)',
                count: cseCount,
                total: totalStudents,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 10),
              _buildDepartmentProgressBar(
                context,
                deptName: 'Electronics (ECE)',
                count: eceCount,
                total: totalStudents,
                color: const Color(0xFF059669),
              ),
              const SizedBox(height: 10),
              _buildDepartmentProgressBar(
                context,
                deptName: 'Electrical (EEE)',
                count: eeeCount,
                total: totalStudents,
                color: const Color(0xFFD97706),
              ),
              const SizedBox(height: 10),
              _buildDepartmentProgressBar(
                context,
                deptName: 'Mechanical (MECH)',
                count: mechCount,
                total: totalStudents,
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ------------------------------------
        // E. AT-RISK ALERT CENTER WIDGET
        // ------------------------------------
        if (atRiskStudents.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.statusRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.statusRed.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.statusRed.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.statusRed.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.statusRed,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'At-Risk Students Requiring Action (${atRiskStudents.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.statusRed,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Low attendance (<75%) or failing grades (<40%)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[300] : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.statusRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppConstants.routeReports);
                      },
                      child: const Text('Review List', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Horizontal list of at-risk student chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: atRiskStudents.take(5).map((student) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppConstants.routeStudentDetails,
                          arguments: student.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.statusRed.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: AppTheme.statusRed.withValues(alpha: 0.2),
                              child: Text(
                                student.name[0],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.statusRed,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ------------------------------------
        // F. RECENT STUDENTS DIRECTORY TABLE
        // ------------------------------------
        SectionHeader(
          title: 'Recent Students Directory',
          actionText: 'View All ($totalStudents)',
          onActionTap: () => Navigator.of(context).pushNamed(AppConstants.routeStudents),
        ),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: studentProvider.students.take(4).length,
          itemBuilder: (context, index) {
            final student = studentProvider.students[index];
            return StudentCard(
              student: student,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeStudentDetails,
                  arguments: student.id,
                );
              },
              showActions: true,
              onEdit: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeAddStudent,
                  arguments: student,
                );
              },
              onDelete: () {
                _showDeleteDialog(context, studentProvider, student);
              },
            );
          },
        ),
      ],
    );
  }

  // Mini metric pill inside hero banner
  Widget _buildHeroMetricPill({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: valueColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Department progress bar item
  Widget _buildDepartmentProgressBar(
    BuildContext context, {
    required String deptName,
    required int count,
    required int total,
    required Color color,
  }) {
    final double pct = total > 0 ? (count / total) : 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              deptName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count Students (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. STUDENT PORTAL DASHBOARD VIEW
  // ==========================================
  Widget _buildStudentDashboard(
    BuildContext context,
    StudentProvider studentProvider,
    AttendanceProvider attendanceProvider,
    PerformanceProvider performanceProvider,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final Student? currentStudent = studentProvider.currentStudent;

    if (currentStudent == null) {
      return const Center(child: Text('Student profile data unavailable.'));
    }

    final myAttendanceRecords =
        attendanceProvider.getAttendanceForStudent(currentStudent.studentId);
    final myMarksRecords =
        performanceProvider.getMarksForStudent(currentStudent.studentId);

    final myAvgAttendance =
        attendanceProvider.getAverageAttendanceForStudent(currentStudent.studentId);
    final myAvgMarks =
        performanceProvider.getAverageMarksForStudent(currentStudent.studentId);

    final myGrade = AppConstants.calculateGrade(myAvgMarks);
    final myStatus = AppConstants.getPerformanceStatus(myAvgMarks);

    bool isAttendanceAtRisk = myAvgAttendance < 75.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personalized Student Card Header Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                  : [AppTheme.secondaryColor, const Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_pin, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'MY STUDENT PROFILE PORTAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ID: ${currentStudent.studentId}',
                      style: const TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      currentStudent.name[0],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentStudent.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Roll: ${currentStudent.rollNumber} • ${currentStudent.department}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentStudent.year} (${currentStudent.section}) • ${currentStudent.email}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Personalized Student Academic KPI Summary Cards
        const SectionHeader(title: 'My Academic Performance Overview'),
        Row(
          children: [
            Expanded(
              child: Card(
                color: (isAttendanceAtRisk ? Colors.red : Colors.green).withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAttendanceAtRisk
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline,
                            color: isAttendanceAtRisk ? Colors.red : Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${myAvgAttendance.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isAttendanceAtRisk ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'My Attendance',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: AppTheme.primaryLight.withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.grade_outlined, color: AppTheme.primaryLight, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${myAvgMarks.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'My Average Score',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        myGrade,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myStatus,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Attendance Safety Calculator & Goals Banner for Student
        Card(
          color: isAttendanceAtRisk
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.teal.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isAttendanceAtRisk ? Colors.red : Colors.teal,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  isAttendanceAtRisk
                      ? Icons.report_problem_outlined
                      : Icons.verified_user_outlined,
                  color: isAttendanceAtRisk ? Colors.red : Colors.teal,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAttendanceAtRisk
                            ? 'Attendance Alert: Action Required'
                            : 'Attendance Standing: Excellent',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isAttendanceAtRisk ? Colors.red : Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAttendanceAtRisk
                            ? 'Your current overall attendance is below 75%. Please attend upcoming lectures to maintain safe academic standing.'
                            : 'Your attendance is above the 75% threshold. Keep up the consistent performance!',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // My Subject Attendance Breakdown
        SectionHeader(
          title: 'My Course Attendance Breakdown (${myAttendanceRecords.length} Subjects)',
          actionText: 'View Details',
          onActionTap: () => Navigator.of(context).pushNamed(AppConstants.routeAttendance),
        ),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: myAttendanceRecords.length,
          itemBuilder: (context, index) {
            final record = myAttendanceRecords[index];
            return AttendanceCard(
              record: record,
              studentName: currentStudent.name,
              isFaculty: false,
            );
          },
        ),
        const SizedBox(height: 20),

        // My Academic Marks Breakdown
        SectionHeader(
          title: 'My Subject Grades & Marks Breakdown (${myMarksRecords.length} Subjects)',
          actionText: 'View Details',
          onActionTap: () => Navigator.of(context).pushNamed(AppConstants.routePerformance),
        ),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: myMarksRecords.length,
          itemBuilder: (context, index) {
            final record = myMarksRecords[index];
            return PerformanceCard(
              record: record,
              studentName: currentStudent.name,
              showEdit: false,
            );
          },
        ),
      ],
    );
  }

  void _showDeleteDialog(
      BuildContext context, StudentProvider provider, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student Record'),
        content: Text('Are you sure you want to delete ${student.name} (${student.studentId})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteStudent(student.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Student ${student.name} deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Stateful Quick Action Button with -3px hover translation lift & blue glow ring
class _FacultyQuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FacultyQuickActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FacultyQuickActionButton> createState() => _FacultyQuickActionButtonState();
}

class _FacultyQuickActionButtonState extends State<_FacultyQuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.color
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 14 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: _isHovered ? 0.22 : 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isHovered ? widget.color : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: _isHovered ? widget.color : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
