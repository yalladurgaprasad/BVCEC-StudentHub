import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/marks.dart';
import '../providers/performance_provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({super.key});

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedStudentId = '';
  String _selectedSubject = AppConstants.subjects[0];

  final _internalController = TextEditingController(text: '18');
  final _assignmentController = TextEditingController(text: '9');
  final _midController = TextEditingController(text: '17');
  final _finalController = TextEditingController(text: '42');

  MarksRecord? _editingRecord;
  bool _isInitialized = false;

  double _calculatedTotal = 86.0;
  String _calculatedGrade = 'A';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      if (studentProvider.students.isNotEmpty) {
        _selectedStudentId = studentProvider.students.first.studentId;
      }

      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is MarksRecord) {
        _editingRecord = args;
        _selectedStudentId = args.studentId;
        _selectedSubject = args.subject;
        _internalController.text = args.internalMarks.toString();
        _assignmentController.text = args.assignmentMarks.toString();
        _midController.text = args.midExam.toString();
        _finalController.text = args.finalExam.toString();
      }

      _recalculateScores();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    _assignmentController.dispose();
    _midController.dispose();
    _finalController.dispose();
    super.dispose();
  }

  void _recalculateScores() {
    double internal = double.tryParse(_internalController.text) ?? 0.0;
    double assign = double.tryParse(_assignmentController.text) ?? 0.0;
    double mid = double.tryParse(_midController.text) ?? 0.0;
    double finalEx = double.tryParse(_finalController.text) ?? 0.0;

    double total = internal + assign + mid + finalEx;
    if (total > 100) total = 100;

    setState(() {
      _calculatedTotal = total;
      _calculatedGrade = AppConstants.calculateGrade(total);
    });
  }

  void _saveMarks() {
    if (!_formKey.currentState!.validate()) return;

    final performanceProvider =
        Provider.of<PerformanceProvider>(context, listen: false);

    double internal = double.parse(_internalController.text.trim());
    double assign = double.parse(_assignmentController.text.trim());
    double mid = double.parse(_midController.text.trim());
    double finalEx = double.parse(_finalController.text.trim());

    final record = MarksRecord(
      id: _editingRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: _selectedStudentId,
      subject: _selectedSubject,
      internalMarks: internal,
      assignmentMarks: assign,
      midExam: mid,
      finalExam: finalEx,
    );

    performanceProvider.addOrUpdateMarks(record);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Marks saved for $_selectedStudentId ($_selectedSubject) - Total: ${record.totalMarks} (${record.grade})'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingRecord != null ? 'Edit Marks Entry' : 'Marks Entry Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Academic Assessment Entry',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Student Selection Dropdown
              const Text('Select Student *',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedStudentId.isNotEmpty
                    ? _selectedStudentId
                    : studentProvider.students.first.studentId,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: studentProvider.students.map((s) {
                  return DropdownMenuItem(
                    value: s.studentId,
                    child: Text('${s.name} (${s.studentId} - ${s.department})'),
                  );
                }).toList(),
                onChanged: _editingRecord != null
                    ? null
                    : (val) {
                        if (val != null) setState(() => _selectedStudentId = val);
                      },
              ),
              const SizedBox(height: 16),

              // Subject Selection Dropdown
              const Text('Select Subject *',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.book_outlined),
                ),
                items: AppConstants.subjects.map((subj) {
                  return DropdownMenuItem(value: subj, child: Text(subj));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSubject = val);
                },
              ),
              const SizedBox(height: 20),

              // Auto-calculated Live Score Preview Card
              Card(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calculated Total Score',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_calculatedTotal.toStringAsFixed(1)} / 100',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.secondaryColor, width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text('Grade', style: TextStyle(fontSize: 11)),
                            Text(
                              _calculatedGrade,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
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

              // Exam Component Input Fields
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _internalController,
                      labelText: 'Internal Marks (Max 20) *',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.edit_note_outlined,
                      onChanged: (_) => _recalculateScores(),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final num = double.tryParse(val);
                        if (num == null || num < 0 || num > 20) {
                          return '0 - 20';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _assignmentController,
                      labelText: 'Assignment (Max 10) *',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.assignment_outlined,
                      onChanged: (_) => _recalculateScores(),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final num = double.tryParse(val);
                        if (num == null || num < 0 || num > 10) {
                          return '0 - 10';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _midController,
                      labelText: 'Mid Exam (Max 20) *',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.quiz_outlined,
                      onChanged: (_) => _recalculateScores(),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final num = double.tryParse(val);
                        if (num == null || num < 0 || num > 20) {
                          return '0 - 20';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _finalController,
                      labelText: 'Final Exam (Max 50) *',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.description_outlined,
                      onChanged: (_) => _recalculateScores(),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        final num = double.tryParse(val);
                        if (num == null || num < 0 || num > 50) {
                          return '0 - 50';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: 'Save Marks Record',
                onPressed: _saveMarks,
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
