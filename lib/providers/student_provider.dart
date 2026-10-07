import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class StudentProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _rememberMe = false;

  String _searchQuery = '';
  String _selectedDepartment = 'All';
  String _selectedYear = 'All';
  String _selectedSection = 'All';

  final List<Student> _students = [
    Student(
      id: '1',
      studentId: 'STU001',
      rollNumber: '21CS001',
      name: 'Alex Johnson',
      email: 'alex.j@university.edu',
      phone: '+1 555-0101',
      department: 'Computer Science',
      year: '3rd Year',
      section: 'A',
      dateOfBirth: '2002-05-14',
    ),
    Student(
      id: '2',
      studentId: 'STU002',
      rollNumber: '21CS002',
      name: 'Sophia Chen',
      email: 'sophia.c@university.edu',
      phone: '+1 555-0102',
      department: 'Computer Science',
      year: '3rd Year',
      section: 'A',
      dateOfBirth: '2002-08-22',
    ),
    Student(
      id: '3',
      studentId: 'STU003',
      rollNumber: '22IT015',
      name: 'Marcus Vance',
      email: 'marcus.v@university.edu',
      phone: '+1 555-0103',
      department: 'Information Technology',
      year: '2nd Year',
      section: 'B',
      dateOfBirth: '2003-01-10',
    ),
    Student(
      id: '4',
      studentId: 'STU004',
      rollNumber: '21EE040',
      name: 'Emily Davis',
      email: 'emily.d@university.edu',
      phone: '+1 555-0104',
      department: 'Electrical Engineering',
      year: '3rd Year',
      section: 'B',
      dateOfBirth: '2002-11-03',
    ),
    Student(
      id: '5',
      studentId: 'STU005',
      rollNumber: '23ME008',
      name: 'Liam Wilson',
      email: 'liam.w@university.edu',
      phone: '+1 555-0105',
      department: 'Mechanical Engineering',
      year: '1st Year',
      section: 'A',
      dateOfBirth: '2004-03-17',
    ),
    Student(
      id: '6',
      studentId: 'STU006',
      rollNumber: '20CE022',
      name: 'Olivia Martinez',
      email: 'olivia.m@university.edu',
      phone: '+1 555-0106',
      department: 'Civil Engineering',
      year: '4th Year',
      section: 'C',
      dateOfBirth: '2001-09-30',
    ),
    Student(
      id: '7',
      studentId: 'STU007',
      rollNumber: '21CS045',
      name: 'Daniel Kim',
      email: 'daniel.k@university.edu',
      phone: '+1 555-0107',
      department: 'Computer Science',
      year: '3rd Year',
      section: 'B',
      dateOfBirth: '2002-12-05',
    ),
    Student(
      id: '8',
      studentId: 'STU008',
      rollNumber: '22IT033',
      name: 'Ava Taylor',
      email: 'ava.t@university.edu',
      phone: '+1 555-0108',
      department: 'Information Technology',
      year: '2nd Year',
      section: 'A',
      dateOfBirth: '2003-07-19',
    ),
    Student(
      id: '9',
      studentId: 'STU009',
      rollNumber: '23CS012',
      name: 'Ethan Brown',
      email: 'ethan.b@university.edu',
      phone: '+1 555-0109',
      department: 'Computer Science',
      year: '1st Year',
      section: 'C',
      dateOfBirth: '2004-04-12',
    ),
    Student(
      id: '10',
      studentId: 'STU010',
      rollNumber: '20EE019',
      name: 'Isabella Garcia',
      email: 'isabella.g@university.edu',
      phone: '+1 555-0110',
      department: 'Electrical Engineering',
      year: '4th Year',
      section: 'A',
      dateOfBirth: '2001-02-28',
    ),
    Student(
      id: '11',
      studentId: 'STU011',
      rollNumber: '21ME055',
      name: 'Noah Anderson',
      email: 'noah.a@university.edu',
      phone: '+1 555-0111',
      department: 'Mechanical Engineering',
      year: '3rd Year',
      section: 'C',
      dateOfBirth: '2002-06-11',
    ),
    Student(
      id: '12',
      studentId: 'STU012',
      rollNumber: '22CE004',
      name: 'Mia Thomas',
      email: 'mia.t@university.edu',
      phone: '+1 555-0112',
      department: 'Civil Engineering',
      year: '2nd Year',
      section: 'B',
      dateOfBirth: '2003-10-15',
    ),
  ];

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get rememberMe => _rememberMe;

  Student? get currentStudent {
    if (_currentUser?.isStudent == true && _currentUser?.studentId != null) {
      return getStudentById(_currentUser!.studentId!);
    }
    return _students.isNotEmpty ? _students.first : null;
  }

  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;
  String get selectedYear => _selectedYear;
  String get selectedSection => _selectedSection;

  List<Student> get students => List.unmodifiable(_students);

  int get totalStudents => _students.length;

  List<Student> get filteredStudents {
    return _students.where((student) {
      final matchesSearch = _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.studentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDept = _selectedDepartment == 'All' ||
          student.department == _selectedDepartment;

      final matchesYear = _selectedYear == 'All' || student.year == _selectedYear;

      final matchesSection = _selectedSection == 'All' || student.section == _selectedSection;

      return matchesSearch && matchesDept && matchesYear && matchesSection;
    }).toList();
  }

  // Authentication logic
  bool login(String username, String password, {bool remember = false}) {
    if (username.trim() == AppConstants.adminUsername &&
        password.trim() == AppConstants.adminPassword) {
      _currentUser = UserModel(
        id: 'usr_admin',
        username: 'admin',
        name: 'Dr. Robert Vance (Admin)',
        email: 'admin@university.edu',
        role: AppConstants.roleAdmin,
        department: 'Academic Affairs',
      );
      _isLoggedIn = true;
      _rememberMe = remember;
      notifyListeners();
      return true;
    } else if (username.trim() == AppConstants.studentUsername &&
        password.trim() == AppConstants.studentPassword) {
      _currentUser = UserModel(
        id: 'usr_student',
        username: 'student',
        name: 'Alex Johnson',
        email: 'alex.j@university.edu',
        role: AppConstants.roleStudent,
        studentId: 'STU001',
        department: 'Computer Science',
      );
      _isLoggedIn = true;
      _rememberMe = remember;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  // Search & Filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDepartmentFilter(String dept) {
    _selectedDepartment = dept;
    notifyListeners();
  }

  void setYearFilter(String year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setSectionFilter(String sec) {
    _selectedSection = sec;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = 'All';
    _selectedYear = 'All';
    _selectedSection = 'All';
    notifyListeners();
  }

  // Student Operations
  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id || s.studentId == id);
    } catch (_) {
      return null;
    }
  }

  bool addStudent(Student student) {
    // Check for duplicate Student ID or Roll Number
    bool exists = _students.any((s) =>
        s.studentId.toUpperCase() == student.studentId.toUpperCase() ||
        s.rollNumber.toUpperCase() == student.rollNumber.toUpperCase());
    if (exists) return false;

    _students.add(student);
    notifyListeners();
    return true;
  }

  bool updateStudent(Student student) {
    int index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool deleteStudent(String id) {
    int initialLength = _students.length;
    _students.removeWhere((s) => s.id == id || s.studentId == id);
    if (_students.length < initialLength) {
      notifyListeners();
      return true;
    }
    return false;
  }
}
