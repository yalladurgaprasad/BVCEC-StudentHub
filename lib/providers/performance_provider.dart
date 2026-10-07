import 'package:flutter/material.dart';
import '../models/marks.dart';
import '../utils/constants.dart';

class PerformanceProvider extends ChangeNotifier {
  final List<MarksRecord> _marks = [
    // STU001 - Alex Johnson (High Performer)
    MarksRecord(id: 'mk_1', studentId: 'STU001', subject: 'Java Programming', internalMarks: 18.5, assignmentMarks: 9.5, midExam: 18.0, finalExam: 46.0), // 92% A+
    MarksRecord(id: 'mk_2', studentId: 'STU001', subject: 'DBMS', internalMarks: 17.0, assignmentMarks: 9.0, midExam: 17.5, finalExam: 42.0), // 85.5% A
    MarksRecord(id: 'mk_3', studentId: 'STU001', subject: 'Computer Networks', internalMarks: 19.0, assignmentMarks: 10.0, midExam: 19.0, finalExam: 47.0), // 95% A+
    MarksRecord(id: 'mk_4', studentId: 'STU001', subject: 'Operating Systems', internalMarks: 16.0, assignmentMarks: 8.5, midExam: 16.0, finalExam: 40.0), // 80.5% A

    // STU002 - Sophia Chen (Top Performer)
    MarksRecord(id: 'mk_5', studentId: 'STU002', subject: 'Java Programming', internalMarks: 19.5, assignmentMarks: 10.0, midExam: 19.5, finalExam: 49.0), // 98% A+
    MarksRecord(id: 'mk_6', studentId: 'STU002', subject: 'DBMS', internalMarks: 19.0, assignmentMarks: 9.5, midExam: 18.5, finalExam: 46.5), // 93.5% A+
    MarksRecord(id: 'mk_7', studentId: 'STU002', subject: 'Computer Networks', internalMarks: 18.5, assignmentMarks: 9.5, midExam: 18.0, finalExam: 45.0), // 91% A+

    // STU003 - Marcus Vance (Average)
    MarksRecord(id: 'mk_8', studentId: 'STU003', subject: 'Java Programming', internalMarks: 13.0, assignmentMarks: 7.0, midExam: 12.0, finalExam: 30.0), // 62% C
    MarksRecord(id: 'mk_9', studentId: 'STU003', subject: 'DBMS', internalMarks: 14.0, assignmentMarks: 6.5, midExam: 13.0, finalExam: 32.0), // 65.5% C
    MarksRecord(id: 'mk_10', studentId: 'STU003', subject: 'Web Development', internalMarks: 12.0, assignmentMarks: 6.0, midExam: 11.0, finalExam: 28.0), // 57% D

    // STU004 - Emily Davis
    MarksRecord(id: 'mk_11', studentId: 'STU004', subject: 'Python Programming', internalMarks: 16.5, assignmentMarks: 8.5, midExam: 16.0, finalExam: 41.0), // 82% A
    MarksRecord(id: 'mk_12', studentId: 'STU004', subject: 'Computer Networks', internalMarks: 15.0, assignmentMarks: 8.0, midExam: 15.5, finalExam: 38.0), // 76.5% B

    // STU005 - Liam Wilson (At Risk Marks)
    MarksRecord(id: 'mk_13', studentId: 'STU005', subject: 'Java Programming', internalMarks: 8.0, assignmentMarks: 4.0, midExam: 8.0, finalExam: 18.0), // 38% F (At Risk)
    MarksRecord(id: 'mk_14', studentId: 'STU005', subject: 'Operating Systems', internalMarks: 9.0, assignmentMarks: 5.0, midExam: 7.0, finalExam: 16.0), // 37% F (At Risk)

    // STU006 - Olivia Martinez
    MarksRecord(id: 'mk_15', studentId: 'STU006', subject: 'DBMS', internalMarks: 17.5, assignmentMarks: 9.0, midExam: 18.0, finalExam: 44.0), // 88.5% A
    MarksRecord(id: 'mk_16', studentId: 'STU006', subject: 'Web Development', internalMarks: 16.0, assignmentMarks: 8.5, midExam: 17.0, finalExam: 40.0), // 81.5% A

    // STU007 - Daniel Kim
    MarksRecord(id: 'mk_17', studentId: 'STU007', subject: 'Java Programming', internalMarks: 14.0, assignmentMarks: 7.5, midExam: 14.5, finalExam: 35.0), // 71% B
    MarksRecord(id: 'mk_18', studentId: 'STU007', subject: 'DBMS', internalMarks: 15.0, assignmentMarks: 8.0, midExam: 15.0, finalExam: 36.0), // 74% B

    // STU008 - Ava Taylor
    MarksRecord(id: 'mk_19', studentId: 'STU008', subject: 'Python Programming', internalMarks: 18.0, assignmentMarks: 9.0, midExam: 17.5, finalExam: 44.5), // 89% A
    MarksRecord(id: 'mk_20', studentId: 'STU008', subject: 'Web Development', internalMarks: 17.0, assignmentMarks: 8.5, midExam: 16.5, finalExam: 42.0), // 84% A

    // STU009 - Ethan Brown (Critical Risk)
    MarksRecord(id: 'mk_21', studentId: 'STU009', subject: 'Java Programming', internalMarks: 7.0, assignmentMarks: 3.5, midExam: 6.0, finalExam: 15.0), // 31.5% F
    MarksRecord(id: 'mk_22', studentId: 'STU009', subject: 'Operating Systems', internalMarks: 8.5, assignmentMarks: 4.0, midExam: 7.5, finalExam: 17.0), // 37% F

    // STU010 - Isabella Garcia
    MarksRecord(id: 'mk_23', studentId: 'STU010', subject: 'Computer Networks', internalMarks: 17.0, assignmentMarks: 9.0, midExam: 16.5, finalExam: 42.5), // 85% A
    MarksRecord(id: 'mk_24', studentId: 'STU010', subject: 'Python Programming', internalMarks: 18.0, assignmentMarks: 9.5, midExam: 17.0, finalExam: 44.0), // 88.5% A

    // STU011 - Noah Anderson
    MarksRecord(id: 'mk_25', studentId: 'STU011', subject: 'DBMS', internalMarks: 15.0, assignmentMarks: 7.5, midExam: 14.0, finalExam: 36.5), // 73% B
    MarksRecord(id: 'mk_26', studentId: 'STU011', subject: 'Operating Systems', internalMarks: 13.5, assignmentMarks: 7.0, midExam: 13.0, finalExam: 32.5), // 66% C

    // STU012 - Mia Thomas
    MarksRecord(id: 'mk_27', studentId: 'STU012', subject: 'Web Development', internalMarks: 16.0, assignmentMarks: 8.0, midExam: 15.5, finalExam: 39.5), // 79% B
    MarksRecord(id: 'mk_28', studentId: 'STU012', subject: 'Python Programming', internalMarks: 15.5, assignmentMarks: 8.0, midExam: 16.0, finalExam: 38.5), // 78% B
  ];

  List<MarksRecord> get allMarks => List.unmodifiable(_marks);

  List<MarksRecord> getMarksForStudent(String studentId) {
    return _marks.where((m) => m.studentId == studentId).toList();
  }

  double getAverageMarksForStudent(String studentId) {
    final studentMarks = getMarksForStudent(studentId);
    if (studentMarks.isEmpty) return 0.0;
    double sum = studentMarks.fold(0.0, (acc, m) => acc + m.percentage);
    return sum / studentMarks.length;
  }

  double getOverallAverageMarks() {
    if (_marks.isEmpty) return 0.0;
    double sum = _marks.fold(0.0, (acc, m) => acc + m.percentage);
    return sum / _marks.length;
  }

  double getHighestMarksForSubject(String subject) {
    final subjectMarks = _marks.where((m) => m.subject == subject).toList();
    if (subjectMarks.isEmpty) return 0.0;
    return subjectMarks.map((m) => m.percentage).reduce((a, b) => a > b ? a : b);
  }

  double getLowestMarksForSubject(String subject) {
    final subjectMarks = _marks.where((m) => m.subject == subject).toList();
    if (subjectMarks.isEmpty) return 0.0;
    return subjectMarks.map((m) => m.percentage).reduce((a, b) => a < b ? a : b);
  }

  String getOverallGradeForStudent(String studentId) {
    double avg = getAverageMarksForStudent(studentId);
    return AppConstants.calculateGrade(avg);
  }

  String getPerformanceStatusForStudent(String studentId) {
    double avg = getAverageMarksForStudent(studentId);
    return AppConstants.getPerformanceStatus(avg);
  }

  List<String> getAtRiskStudentIds({double threshold = AppConstants.marksAtRiskThreshold}) {
    final studentIds = _marks.map((m) => m.studentId).toSet();
    List<String> atRisk = [];
    for (var sid in studentIds) {
      if (getAverageMarksForStudent(sid) < threshold) {
        atRisk.add(sid);
      }
    }
    return atRisk;
  }

  void addOrUpdateMarks(MarksRecord record) {
    final index = _marks.indexWhere(
      (m) => m.studentId == record.studentId && m.subject == record.subject,
    );
    if (index != -1) {
      _marks[index] = record;
    } else {
      _marks.add(record);
    }
    notifyListeners();
  }
}
