import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/performance_provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/empty_state_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedDepartment = 'All';
  String _selectedYear = 'All';
  final double _attendanceThreshold = 75.0;
  final double _marksThreshold = 40.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final performanceProvider = Provider.of<PerformanceProvider>(context);
    final currentUser = studentProvider.currentUser;
    final isAdmin = currentUser?.isAdmin == true;
    final currentStudent = studentProvider.currentStudent;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter base student list: Faculty sees all filtered; Student sees only self.
    final filteredStudents = studentProvider.students.where((s) {
      if (!isAdmin && currentStudent != null) {
        return s.studentId == currentStudent.studentId;
      }
      bool matchDept = _selectedDepartment == 'All' || s.department == _selectedDepartment;
      bool matchYear = _selectedYear == 'All' || s.year == _selectedYear;
      return matchDept && matchYear;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Institute Academic Reports' : 'My Academic Progress Report'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(icon: Icon(Icons.fact_check_outlined), text: 'Attendance'),
            const Tab(icon: Icon(Icons.grade_outlined), text: 'Performance'),
            Tab(
              icon: const Icon(Icons.warning_amber_rounded),
              text: isAdmin ? 'At-Risk Alert' : 'My Standing',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner header depending on role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            child: Row(
              children: [
                Icon(
                  isAdmin ? Icons.assessment : Icons.picture_as_pdf_outlined,
                  color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAdmin
                        ? 'Institute-Wide Analytics & Risk Monitoring Report'
                        : 'Personal Academic Standing & Transcript Report for ${currentStudent?.name ?? "Student"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Faculty Filter Controls Container
          if (isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: theme.cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedDepartment,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['All', ...AppConstants.departments].map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text('Dept: $dept', style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDepartment = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['All', ...AppConstants.years].map((yr) {
                        return DropdownMenuItem(
                          value: yr,
                          child: Text('Year: $yr', style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedYear = val);
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Attendance Report Tab
                _buildAttendanceReport(context, filteredStudents, attendanceProvider),

                // 2. Performance Report Tab
                _buildPerformanceReport(context, filteredStudents, performanceProvider),

                // 3. At-Risk Report Tab
                _buildAtRiskReport(
                  context,
                  filteredStudents,
                  attendanceProvider,
                  performanceProvider,
                  isAdmin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Attendance Report Table View
  Widget _buildAttendanceReport(
      BuildContext context, List students, AttendanceProvider attendanceProvider) {
    if (students.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Students Found',
        message: 'No student records match the selected department/year filter.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final records = attendanceProvider.getAttendanceForStudent(student.studentId);
        final avgAttendance =
            attendanceProvider.getAverageAttendanceForStudent(student.studentId);
        final isAtRisk = avgAttendance < _attendanceThreshold;

        return Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: CircleAvatar(
              backgroundColor: (isAtRisk ? Colors.red : Colors.green).withValues(alpha: 0.15),
              child: Icon(
                isAtRisk ? Icons.warning_amber : Icons.check_circle_outline,
                color: isAtRisk ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${student.studentId} • ${student.department} • Avg Attendance: ${avgAttendance.toStringAsFixed(1)}%',
              style: TextStyle(
                color: isAtRisk ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: records.map((r) {
              return ListTile(
                dense: true,
                title: Text(r.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(
                  '${r.presentClasses}/${r.totalClasses} (${r.percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: r.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // 2. Performance Report Table View
  Widget _buildPerformanceReport(
      BuildContext context, List students, PerformanceProvider performanceProvider) {
    if (students.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Students Found',
        message: 'No student records match the selected department/year filter.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final records = performanceProvider.getMarksForStudent(student.studentId);
        final avgMarks = performanceProvider.getAverageMarksForStudent(student.studentId);
        final grade = AppConstants.calculateGrade(avgMarks);

        return Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
              child: Text(
                grade,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${student.studentId} • ${student.department} • Overall Score: ${avgMarks.toStringAsFixed(1)}%',
            ),
            children: records.map((m) {
              return ListTile(
                dense: true,
                title: Text(m.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Int: ${m.internalMarks} | Ass: ${m.assignmentMarks} | Mid: ${m.midExam} | Fin: ${m.finalExam}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: m.gradeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${m.totalMarks.toStringAsFixed(0)}% (${m.grade})',
                    style: TextStyle(
                      color: m.gradeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // 3. At-Risk Alert Report Tab
  Widget _buildAtRiskReport(
    BuildContext context,
    List students,
    AttendanceProvider attendanceProvider,
    PerformanceProvider performanceProvider,
    bool isAdmin,
  ) {
    final atRiskStudents = students.where((s) {
      double avgAtt = attendanceProvider.getAverageAttendanceForStudent(s.studentId);
      double avgMarks = performanceProvider.getAverageMarksForStudent(s.studentId);
      return avgAtt < _attendanceThreshold || avgMarks < _marksThreshold;
    }).toList();

    if (atRiskStudents.isEmpty) {
      return const EmptyStateWidget(
        title: 'All Clear!',
        message: 'No student records currently trigger the at-risk criteria.',
        icon: Icons.verified_user_outlined,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isAdmin
                      ? 'Risk Criteria: Attendance < ${_attendanceThreshold.toInt()}% OR Marks < ${_marksThreshold.toInt()}%'
                      : 'Personal Risk Alert: Attendance < 75% or Score < 40%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.statusRed,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: atRiskStudents.length,
            itemBuilder: (context, index) {
              final student = atRiskStudents[index];
              final avgAtt =
                  attendanceProvider.getAverageAttendanceForStudent(student.studentId);
              final avgMarks =
                  performanceProvider.getAverageMarksForStudent(student.studentId);

              bool attRisk = avgAtt < _attendanceThreshold;
              bool marksRisk = avgMarks < _marksThreshold;

              return Card(
                color: AppTheme.statusRed.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.statusRed, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.statusRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'AT-RISK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${student.studentId} • Roll: ${student.rollNumber} • ${student.department} (${student.year})',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (attRisk) ...[
                            Chip(
                              avatar: const Icon(Icons.event_busy,
                                  size: 14, color: Colors.red),
                              label: Text(
                                  'Low Attendance: ${avgAtt.toStringAsFixed(1)}%'),
                              backgroundColor: Colors.red.withValues(alpha: 0.1),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (marksRisk) ...[
                            Chip(
                              avatar:
                                  const Icon(Icons.grade, size: 14, color: Colors.red),
                              label: Text(
                                  'Low Marks: ${avgMarks.toStringAsFixed(1)}%'),
                              backgroundColor: Colors.red.withValues(alpha: 0.1),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
