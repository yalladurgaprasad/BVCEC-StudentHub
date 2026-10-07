import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attendance.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/attendance_card.dart';
import '../widgets/empty_state_widget.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedSubjectFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentUser = studentProvider.currentUser;
    final isAdmin = currentUser?.isAdmin == true;
    final currentStudent = studentProvider.currentStudent;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allRecords = attendanceProvider.allRecords;

    // Filter records: Students see their own attendance records; Faculty sees all/filtered records.
    final displayedRecords = allRecords.where((r) {
      if (!isAdmin && currentStudent != null) {
        if (r.studentId != currentStudent.studentId) return false;
      }
      if (_selectedSubjectFilter == 'All') return true;
      return r.subject == _selectedSubjectFilter;
    }).toList();

    double studentOverallAvg = 0.0;
    if (!isAdmin && currentStudent != null) {
      studentOverallAvg =
          attendanceProvider.getAverageAttendanceForStudent(currentStudent.studentId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Attendance Management' : 'My Attendance Tracker'),
      ),
      body: Column(
        children: [
          // Dynamic Header Banner depending on Role
          Container(
            padding: const EdgeInsets.all(16.0),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            child: Row(
              children: [
                Icon(
                  isAdmin ? Icons.supervisor_account : Icons.event_available_rounded,
                  color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin
                            ? 'Faculty Attendance Control & Log'
                            : 'Personal Attendance Tracker (${currentStudent?.name ?? "Student"})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAdmin
                            ? 'Mark present/absent classes and monitor at-risk thresholds.'
                            : 'Overall Standing: ${studentOverallAvg.toStringAsFixed(1)}% (Target ≥75%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subject Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            color: theme.cardColor,
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                const Text('Subject:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedSubjectFilter,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: ['All', ...AppConstants.subjects].map((subj) {
                      return DropdownMenuItem(value: subj, child: Text(subj));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSubjectFilter = val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Attendance Records Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${displayedRecords.length} Attendance Records',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isAdmin
                      ? 'System Avg: ${attendanceProvider.getOverallAverageAttendance().toStringAsFixed(1)}%'
                      : 'My Avg: ${studentOverallAvg.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (isAdmin
                            ? attendanceProvider.getOverallAverageAttendance() >= 75
                            : studentOverallAvg >= 75)
                        ? Colors.teal
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Attendance Records List
          Expanded(
            child: displayedRecords.isEmpty
                ? EmptyStateWidget(
                    title: 'No Attendance Records',
                    message: 'No records found for the selected subject filter.',
                    icon: Icons.event_busy,
                    actionText: 'Reset Filter',
                    onActionPressed: () {
                      setState(() => _selectedSubjectFilter = 'All');
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: displayedRecords.length,
                    itemBuilder: (context, index) {
                      final record = displayedRecords[index];
                      final student = studentProvider.getStudentById(record.studentId);
                      final studentName = student?.name ?? record.studentId;

                      return AttendanceCard(
                        record: record,
                        studentName: studentName,
                        isFaculty: isAdmin,
                        onMarkPresent: () {
                          attendanceProvider.markAttendance(record.id, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Marked Present for $studentName (${record.subject})'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onMarkAbsent: () {
                          attendanceProvider.markAttendance(record.id, false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Marked Absent for $studentName (${record.subject})'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                _showAddAttendanceDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Log Attendance'),
            )
          : null,
    );
  }

  void _showAddAttendanceDialog(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    String selectedStudentId = studentProvider.students.first.studentId;
    String selectedSubject = AppConstants.subjects[0];
    final totalController = TextEditingController(text: '40');
    final presentController = TextEditingController(text: '35');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log Subject Attendance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Student:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedStudentId,
                  isExpanded: true,
                  items: studentProvider.students.map((s) {
                    return DropdownMenuItem(
                      value: s.studentId,
                      child: Text('${s.name} (${s.studentId})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedStudentId = val);
                  },
                ),
                const SizedBox(height: 12),

                const Text('Select Subject:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedSubject,
                  isExpanded: true,
                  items: AppConstants.subjects.map((subj) {
                    return DropdownMenuItem(value: subj, child: Text(subj));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedSubject = val);
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Classes'),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: presentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Present Classes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                int total = int.tryParse(totalController.text) ?? 40;
                int present = int.tryParse(presentController.text) ?? 35;
                if (present > total) present = total;

                attendanceProvider.addOrUpdateRecord(
                  AttendanceRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    studentId: selectedStudentId,
                    subject: selectedSubject,
                    totalClasses: total,
                    presentClasses: present,
                  ),
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance log saved successfully!')),
                );
              },
              child: const Text('Save Log'),
            ),
          ],
        ),
      ),
    );
  }
}
