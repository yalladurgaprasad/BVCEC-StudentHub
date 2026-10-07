import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _studentIdController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  String _selectedDepartment = AppConstants.departments[0];
  String _selectedYear = AppConstants.years[0];
  String _selectedSection = AppConstants.sections[0];

  Student? _editingStudent;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Student) {
        _editingStudent = args;
        _studentIdController.text = args.studentId;
        _rollNumberController.text = args.rollNumber;
        _nameController.text = args.name;
        _emailController.text = args.email;
        _phoneController.text = args.phone;
        _dobController.text = args.dateOfBirth;

        if (AppConstants.departments.contains(args.department)) {
          _selectedDepartment = args.department;
        }
        if (AppConstants.years.contains(args.year)) {
          _selectedYear = args.year;
        }
        if (AppConstants.sections.contains(args.section)) {
          _selectedSection = args.section;
        }
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _rollNumberController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    DateTime initial = DateTime(2003, 1, 1);
    if (_dobController.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_dobController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2015),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) return;

    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    final newStudent = Student(
      id: _editingStudent?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: _studentIdController.text.trim().toUpperCase(),
      rollNumber: _rollNumberController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _selectedDepartment,
      year: _selectedYear,
      section: _selectedSection,
      dateOfBirth: _dobController.text.trim(),
    );

    if (_editingStudent != null) {
      final success = studentProvider.updateStudent(newStudent);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student ${newStudent.name} updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update student record.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      final success = studentProvider.addStudent(newStudent);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student ${newStudent.name} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Student ID or Roll Number already exists. Please check details.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = _editingStudent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student Details' : 'Add New Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing
                    ? 'Update Student Information'
                    : 'Enter New Student Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Student ID & Roll Number Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _studentIdController,
                      labelText: 'Student ID *',
                      hintText: 'e.g. STU013',
                      prefixIcon: Icons.badge_outlined,
                      readOnly: isEditing,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _rollNumberController,
                      labelText: 'Roll Number *',
                      hintText: 'e.g. 21CS013',
                      prefixIcon: Icons.numbers_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Full Name
              CustomTextField(
                controller: _nameController,
                labelText: 'Full Name *',
                hintText: 'e.g. John Smith',
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter student full name';
                  }
                  if (val.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              // Email & Phone Row
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address *',
                hintText: 'student@university.edu',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(val.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number *',
                hintText: '+1 555-0199',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),

              // Department Dropdown
              const SizedBox(height: 8),
              const Text('Department *',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: AppConstants.departments.map((dept) {
                  return DropdownMenuItem(value: dept, child: Text(dept));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDepartment = val);
                },
              ),
              const SizedBox(height: 16),

              // Year & Section Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Year *',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedYear,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          items: AppConstants.years.map((yr) {
                            return DropdownMenuItem(value: yr, child: Text(yr));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedYear = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Section *',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedSection,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.class_outlined),
                          ),
                          items: AppConstants.sections.map((sec) {
                            return DropdownMenuItem(value: sec, child: Text(sec));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSection = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date of Birth
              CustomTextField(
                controller: _dobController,
                labelText: 'Date of Birth *',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icons.cake_outlined,
                readOnly: true,
                onTap: _selectDateOfBirth,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please select date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: isEditing ? 'Update Student Record' : 'Save Student Record',
                onPressed: _saveStudent,
                icon: isEditing ? Icons.save_outlined : Icons.person_add_alt_1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
