import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/student_card.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final currentUser = studentProvider.currentUser;
    final isAdmin = currentUser?.isAdmin == true;
    final filteredStudents = studentProvider.filteredStudents;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Students Directory' : 'Classmates Directory'),
        actions: [
          if (studentProvider.searchQuery.isNotEmpty ||
              studentProvider.selectedDepartment != 'All' ||
              studentProvider.selectedYear != 'All' ||
              studentProvider.selectedSection != 'All')
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: 'Clear Filters',
              onPressed: () {
                _searchController.clear();
                studentProvider.clearFilters();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Banner Banner header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            child: Row(
              children: [
                Icon(
                  isAdmin ? Icons.supervisor_account : Icons.people_alt_outlined,
                  color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdmin
                            ? 'Faculty Control: Student Roster'
                            : 'Student View: Peer & Class Roster',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isAdmin ? AppTheme.primaryColor : AppTheme.secondaryColor,
                        ),
                      ),
                      Text(
                        isAdmin
                            ? 'Search, filter, edit, or register new students.'
                            : 'View classmate profiles across departments and sections.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter Header Container
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    studentProvider.setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: isAdmin
                        ? 'Search student by name, ID, roll no, or email...'
                        : 'Search classmate by name or ID...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              studentProvider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Dropdowns Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Department Filter
                      DropdownButton<String>(
                        value: studentProvider.selectedDepartment,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: ['All', ...AppConstants.departments].map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text('Dept: $dept', style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) studentProvider.setDepartmentFilter(val);
                        },
                      ),
                      const SizedBox(width: 16),

                      // Year Filter
                      DropdownButton<String>(
                        value: studentProvider.selectedYear,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: ['All', ...AppConstants.years].map((yr) {
                          return DropdownMenuItem(
                            value: yr,
                            child: Text('Year: $yr', style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) studentProvider.setYearFilter(val);
                        },
                      ),
                      const SizedBox(width: 16),

                      // Section Filter
                      DropdownButton<String>(
                        value: studentProvider.selectedSection,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: ['All', ...AppConstants.sections].map((sec) {
                          return DropdownMenuItem(
                            value: sec,
                            child: Text('Sec: $sec', style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) studentProvider.setSectionFilter(val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Student Count Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredStudents.length} of ${studentProvider.totalStudents} Students',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: filteredStudents.isEmpty
                ? EmptyStateWidget(
                    title: 'No Student Records Found',
                    message:
                        'No student records match your active search query or filters.',
                    icon: Icons.person_search_outlined,
                    actionText: 'Reset Filters',
                    onActionPressed: () {
                      _searchController.clear();
                      studentProvider.clearFilters();
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return StudentCard(
                        student: student,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppConstants.routeStudentDetails,
                            arguments: student.id,
                          );
                        },
                        showActions: isAdmin,
                        onEdit: () {
                          Navigator.of(context).pushNamed(
                            AppConstants.routeAddStudent,
                            arguments: student,
                          );
                        },
                        onDelete: () {
                          _showDeleteConfirmDialog(context, student);
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
                Navigator.of(context).pushNamed(AppConstants.routeAddStudent);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Student'),
            )
          : null,
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student Record'),
        content: Text(
            'Are you sure you want to delete ${student.name} (${student.studentId})? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<StudentProvider>(context, listen: false)
                  .deleteStudent(student.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully deleted ${student.name}')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
