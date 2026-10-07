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

class StudentDetailsScreen extends StatelessWidget {
  const StudentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? studentId =
        ModalRoute.of(context)?.settings.arguments as String?;

    final studentProvider = Provider.of<StudentProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final performanceProvider = Provider.of<PerformanceProvider>(context);
    final currentUser = studentProvider.currentUser;

    final Student? student = studentId != null
        ? studentProvider.getStudentById(studentId)
        : studentProvider.students.firstOrNull;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Profile')),
        body: const Center(child: Text('Student Record Not Found.')),
      );
    }

    final attendanceRecords = attendanceProvider.getAttendanceForStudent(student.studentId);
    final marksRecords = performanceProvider.getMarksForStudent(student.studentId);

    final avgAttendance = attendanceProvider.getAverageAttendanceForStudent(student.studentId);
    final avgMarks = performanceProvider.getAverageMarksForStudent(student.studentId);
    final overallGrade = AppConstants.calculateGrade(avgMarks);
    final perfStatus = AppConstants.getPerformanceStatus(avgMarks);

    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
        actions: [
          if (currentUser?.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppConstants.routeAddStudent,
                  arguments: student,
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                      child: Text(
                        student.name.isNotEmpty ? student.name[0] : 'S',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${student.studentId} • Roll: ${student.rollNumber}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${student.department} • ${student.year} (${student.section})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Academic Summary Cards Grid
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: (avgAttendance >= 75 ? AppTheme.statusGreen : AppTheme.statusRed)
                        .withOpacity(0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${avgAttendance.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: avgAttendance >= 75
                                  ? AppTheme.statusGreen
                                  : AppTheme.statusRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Avg Attendance', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    color: AppTheme.primaryLight.withOpacity(0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${avgMarks.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Avg Score', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    color: AppTheme.secondaryColor.withOpacity(0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            overallGrade,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(perfStatus,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Personal Information Details
            const SectionHeader(title: 'Personal Details'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(context, Icons.email_outlined, 'Email', student.email),
                    const Divider(),
                    _buildDetailRow(context, Icons.phone_outlined, 'Phone', student.phone),
                    const Divider(),
                    _buildDetailRow(
                        context, Icons.cake_outlined, 'Date of Birth', student.dateOfBirth),
                    const Divider(),
                    _buildDetailRow(
                        context, Icons.school_outlined, 'Department', student.department),
                    const Divider(),
                    _buildDetailRow(context, Icons.class_outlined, 'Year & Section',
                        '${student.year} - Section ${student.section}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subject Attendance Breakdown
            SectionHeader(
              title: 'Attendance Breakdown (${attendanceRecords.length} Subjects)',
            ),
            if (attendanceRecords.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No attendance records logged for this student.')),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = attendanceRecords[index];
                  return AttendanceCard(
                    record: record,
                    studentName: student.name,
                    isFaculty: currentUser?.isAdmin == true,
                    onMarkPresent: () {
                      attendanceProvider.markAttendance(record.id, true);
                    },
                    onMarkAbsent: () {
                      attendanceProvider.markAttendance(record.id, false);
                    },
                  );
                },
              ),
            const SizedBox(height: 20),

            // Subject Marks Breakdown
            SectionHeader(
              title: 'Academic Marks & Grades (${marksRecords.length} Subjects)',
            ),
            if (marksRecords.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No marks entries recorded for this student.')),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: marksRecords.length,
                itemBuilder: (context, index) {
                  final record = marksRecords[index];
                  return PerformanceCard(
                    record: record,
                    studentName: student.name,
                    showEdit: currentUser?.isAdmin == true,
                    onEdit: () {
                      Navigator.of(context).pushNamed(
                        AppConstants.routeMarks,
                        arguments: record,
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
