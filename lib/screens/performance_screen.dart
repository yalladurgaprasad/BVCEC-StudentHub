import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/performance_provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/performance_card.dart';
import '../widgets/section_header.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String _selectedSubjectFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final performanceProvider = Provider.of<PerformanceProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentUser = studentProvider.currentUser;
    final isAdmin = currentUser?.isAdmin == true;
    final currentStudent = studentProvider.currentStudent;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allMarks = performanceProvider.allMarks;

    // Filter displayed marks: Students see their own marks; Faculty sees all/filtered.
    final displayedMarks = allMarks.where((m) {
      if (!isAdmin && currentStudent != null) {
        if (m.studentId != currentStudent.studentId) return false;
      }
      if (_selectedSubjectFilter == 'All') return true;
      return m.subject == _selectedSubjectFilter;
    }).toList();

    double overallScore = isAdmin
        ? performanceProvider.getOverallAverageMarks()
        : (currentStudent != null
            ? performanceProvider.getAverageMarksForStudent(currentStudent.studentId)
            : 0.0);

    String overallGrade = AppConstants.calculateGrade(overallScore);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Faculty Performance Analytics' : 'My Grades & Transcript'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_chart),
              tooltip: 'Enter Marks',
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.routeMarks);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Header Banner depending on Role
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isAdmin ? Icons.insights : Icons.grade_rounded,
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
                              ? 'Faculty Assessment & Grading Control'
                              : 'Personal Academic Transcript (${currentStudent?.name ?? "Student"})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAdmin
                              ? 'Overall System Average: ${overallScore.toStringAsFixed(1)}% (Grade: $overallGrade)'
                              : 'My Overall Score: ${overallScore.toStringAsFixed(1)}% (Grade: $overallGrade)',
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
            const SizedBox(height: 16),

            // Analytics Summary Banner Card
            Card(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAdmin ? 'Overall System Average' : 'My Cumulative Average',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${overallScore.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('Grade', style: TextStyle(fontSize: 10)),
                              Text(
                                overallGrade,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Overall Grade distribution / Progress
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: overallScore / 100.0,
                        minHeight: 10,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subject High/Low Overview Indicators (Faculty view)
            if (isAdmin) ...[
              const SectionHeader(title: 'Subject Performance Statistics'),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.subjects.length,
                  itemBuilder: (context, index) {
                    final subj = AppConstants.subjects[index];
                    final highest = performanceProvider.getHighestMarksForSubject(subj);
                    final lowest = performanceProvider.getLowestMarksForSubject(subj);

                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 12),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                subj,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Highest:', style: TextStyle(fontSize: 11)),
                                      Text('${highest.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Lowest:', style: TextStyle(fontSize: 11)),
                                      Text('${lowest.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Filter Subject dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SectionHeader(
                  title: isAdmin ? 'Student Assessment Records' : 'My Subject Grades',
                ),
                DropdownButton<String>(
                  value: _selectedSubjectFilter,
                  underline: const SizedBox(),
                  items: ['All', ...AppConstants.subjects].map((subj) {
                    return DropdownMenuItem(value: subj, child: Text('Filter: $subj'));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSubjectFilter = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Performance Cards List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedMarks.length,
              itemBuilder: (context, index) {
                final record = displayedMarks[index];
                final student = studentProvider.getStudentById(record.studentId);
                final studentName = student?.name ?? record.studentId;

                return PerformanceCard(
                  record: record,
                  studentName: studentName,
                  showEdit: isAdmin,
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
}
