import 'package:flutter_test/flutter_test.dart';
import 'package:student_hub/models/attendance.dart';
import 'package:student_hub/models/marks.dart';
import 'package:student_hub/models/student.dart';
import 'package:student_hub/providers/attendance_provider.dart';
import 'package:student_hub/providers/performance_provider.dart';
import 'package:student_hub/providers/student_provider.dart';
import 'package:student_hub/utils/constants.dart';

void main() {
  group('Grade & Status Calculation Tests', () {
    test('calculateGrade returns expected letter grades', () {
      expect(AppConstants.calculateGrade(95.0), 'A+');
      expect(AppConstants.calculateGrade(85.0), 'A');
      expect(AppConstants.calculateGrade(75.0), 'B');
      expect(AppConstants.calculateGrade(65.0), 'C');
      expect(AppConstants.calculateGrade(55.0), 'D');
      expect(AppConstants.calculateGrade(45.0), 'E');
      expect(AppConstants.calculateGrade(35.0), 'F');
    });

    test('AttendanceRecord calculations', () {
      final record = AttendanceRecord(
        id: '1',
        studentId: 'STU001',
        subject: 'Java',
        totalClasses: 40,
        presentClasses: 30,
      );

      expect(record.absentClasses, 10);
      expect(record.percentage, 75.0);
      expect(record.isAtRisk, false);
      expect(record.statusText, 'Good');
    });

    test('MarksRecord total score & grade calculation', () {
      final record = MarksRecord(
        id: 'm1',
        studentId: 'STU001',
        subject: 'DBMS',
        internalMarks: 18.0,
        assignmentMarks: 9.0,
        midExam: 18.0,
        finalExam: 45.0,
      );

      expect(record.totalMarks, 90.0);
      expect(record.percentage, 90.0);
      expect(record.grade, 'A+');
      expect(record.isAtRisk, false);
    });
  });

  group('StudentProvider Unit Tests', () {
    late StudentProvider studentProvider;

    setUp(() {
      studentProvider = StudentProvider();
    });

    test('Initial sample student count is 12', () {
      expect(studentProvider.totalStudents, 12);
    });

    test('Admin authentication login test', () {
      final success = studentProvider.login('admin', 'admin123');
      expect(success, true);
      expect(studentProvider.isLoggedIn, true);
      expect(studentProvider.currentUser?.role, 'admin');
    });

    test('Add and delete student state updates', () {
      final newStudent = Student(
        id: '99',
        studentId: 'STU099',
        rollNumber: '24CS099',
        name: 'Test Student',
        email: 'test@univ.edu',
        phone: '123456',
        department: 'Computer Science',
        year: '1st Year',
        section: 'A',
        dateOfBirth: '2005-01-01',
      );

      final added = studentProvider.addStudent(newStudent);
      expect(added, true);
      expect(studentProvider.totalStudents, 13);

      final deleted = studentProvider.deleteStudent('99');
      expect(deleted, true);
      expect(studentProvider.totalStudents, 12);
    });

    test('Student filter logic by search and department', () {
      studentProvider.setSearchQuery('Alex');
      expect(studentProvider.filteredStudents.length, 1);
      expect(studentProvider.filteredStudents.first.name, 'Alex Johnson');

      studentProvider.clearFilters();
      studentProvider.setDepartmentFilter('Civil Engineering');
      expect(studentProvider.filteredStudents.length, 2);
    });
  });

  group('Attendance & Performance Provider Tests', () {
    test('AttendanceProvider overall average calculation', () {
      final provider = AttendanceProvider();
      final avg = provider.getOverallAverageAttendance();
      expect(avg, greaterThan(60.0));
      expect(avg, lessThan(100.0));
    });

    test('PerformanceProvider overall average calculation', () {
      final provider = PerformanceProvider();
      final avg = provider.getOverallAverageMarks();
      expect(avg, greaterThan(50.0));
      expect(avg, lessThan(100.0));
    });
  });
}
