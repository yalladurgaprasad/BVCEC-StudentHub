import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../utils/constants.dart';

class AttendanceProvider extends ChangeNotifier {
  final List<AttendanceRecord> _records = [
    // STU001 - Alex Johnson
    AttendanceRecord(id: 'att_1', studentId: 'STU001', subject: 'Java Programming', totalClasses: 40, presentClasses: 36), // 90%
    AttendanceRecord(id: 'att_2', studentId: 'STU001', subject: 'DBMS', totalClasses: 35, presentClasses: 30), // 85.7%
    AttendanceRecord(id: 'att_3', studentId: 'STU001', subject: 'Computer Networks', totalClasses: 30, presentClasses: 27), // 90%
    AttendanceRecord(id: 'att_4', studentId: 'STU001', subject: 'Operating Systems', totalClasses: 40, presentClasses: 32), // 80%

    // STU002 - Sophia Chen
    AttendanceRecord(id: 'att_5', studentId: 'STU002', subject: 'Java Programming', totalClasses: 40, presentClasses: 38), // 95%
    AttendanceRecord(id: 'att_6', studentId: 'STU002', subject: 'DBMS', totalClasses: 35, presentClasses: 33), // 94.2%
    AttendanceRecord(id: 'att_7', studentId: 'STU002', subject: 'Computer Networks', totalClasses: 30, presentClasses: 28), // 93.3%

    // STU003 - Marcus Vance (At Risk)
    AttendanceRecord(id: 'att_8', studentId: 'STU003', subject: 'Java Programming', totalClasses: 40, presentClasses: 24), // 60%
    AttendanceRecord(id: 'att_9', studentId: 'STU003', subject: 'DBMS', totalClasses: 35, presentClasses: 20), // 57.1%
    AttendanceRecord(id: 'att_10', studentId: 'STU003', subject: 'Web Development', totalClasses: 30, presentClasses: 18), // 60%

    // STU004 - Emily Davis
    AttendanceRecord(id: 'att_11', studentId: 'STU004', subject: 'Python Programming', totalClasses: 40, presentClasses: 34), // 85%
    AttendanceRecord(id: 'att_12', studentId: 'STU004', subject: 'Computer Networks', totalClasses: 35, presentClasses: 29), // 82.8%

    // STU005 - Liam Wilson (At Risk)
    AttendanceRecord(id: 'att_13', studentId: 'STU005', subject: 'Java Programming', totalClasses: 40, presentClasses: 26), // 65%
    AttendanceRecord(id: 'att_14', studentId: 'STU005', subject: 'Operating Systems', totalClasses: 30, presentClasses: 17), // 56.6%

    // STU006 - Olivia Martinez
    AttendanceRecord(id: 'att_15', studentId: 'STU006', subject: 'DBMS', totalClasses: 40, presentClasses: 37), // 92.5%
    AttendanceRecord(id: 'att_16', studentId: 'STU006', subject: 'Web Development', totalClasses: 35, presentClasses: 31), // 88.5%

    // STU007 - Daniel Kim
    AttendanceRecord(id: 'att_17', studentId: 'STU007', subject: 'Java Programming', totalClasses: 40, presentClasses: 31), // 77.5%
    AttendanceRecord(id: 'att_18', studentId: 'STU007', subject: 'DBMS', totalClasses: 35, presentClasses: 28), // 80%

    // STU008 - Ava Taylor
    AttendanceRecord(id: 'att_19', studentId: 'STU008', subject: 'Python Programming', totalClasses: 40, presentClasses: 36), // 90%
    AttendanceRecord(id: 'att_20', studentId: 'STU008', subject: 'Web Development', totalClasses: 30, presentClasses: 27), // 90%

    // STU009 - Ethan Brown (Critical Risk)
    AttendanceRecord(id: 'att_21', studentId: 'STU009', subject: 'Java Programming', totalClasses: 40, presentClasses: 18), // 45%
    AttendanceRecord(id: 'att_22', studentId: 'STU009', subject: 'Operating Systems', totalClasses: 35, presentClasses: 19), // 54.2%

    // STU010 - Isabella Garcia
    AttendanceRecord(id: 'att_23', studentId: 'STU010', subject: 'Computer Networks', totalClasses: 40, presentClasses: 35), // 87.5%
    AttendanceRecord(id: 'att_24', studentId: 'STU010', subject: 'Python Programming', totalClasses: 35, presentClasses: 32), // 91.4%

    // STU011 - Noah Anderson
    AttendanceRecord(id: 'att_25', studentId: 'STU011', subject: 'DBMS', totalClasses: 40, presentClasses: 32), // 80%
    AttendanceRecord(id: 'att_26', studentId: 'STU011', subject: 'Operating Systems', totalClasses: 35, presentClasses: 27), // 77.1%

    // STU012 - Mia Thomas
    AttendanceRecord(id: 'att_27', studentId: 'STU012', subject: 'Web Development', totalClasses: 40, presentClasses: 33), // 82.5%
    AttendanceRecord(id: 'att_28', studentId: 'STU012', subject: 'Python Programming', totalClasses: 30, presentClasses: 25), // 83.3%
  ];

  List<AttendanceRecord> get allRecords => List.unmodifiable(_records);

  List<AttendanceRecord> getAttendanceForStudent(String studentId) {
    return _records.where((r) => r.studentId == studentId).toList();
  }

  double getAverageAttendanceForStudent(String studentId) {
    final studentRecs = getAttendanceForStudent(studentId);
    if (studentRecs.isEmpty) return 0.0;
    double sum = studentRecs.fold(0.0, (acc, r) => acc + r.percentage);
    return sum / studentRecs.length;
  }

  double getOverallAverageAttendance() {
    if (_records.isEmpty) return 0.0;
    double sum = _records.fold(0.0, (acc, r) => acc + r.percentage);
    return sum / _records.length;
  }

  int getPresentCountToday() {
    // Calculates total present student sessions / count of active students present
    int totalPresent = _records.fold(0, (acc, r) => acc + r.presentClasses);
    int totalClasses = _records.fold(0, (acc, r) => acc + r.totalClasses);
    if (totalClasses == 0) return 0;
    // Estimated count based on active student ratio
    return (12 * (totalPresent / totalClasses)).round();
  }

  List<String> getAtRiskStudentIds({double threshold = AppConstants.attendanceAtRiskThreshold}) {
    // Group by studentId and check average attendance < threshold
    final studentIds = _records.map((r) => r.studentId).toSet();
    List<String> atRisk = [];
    for (var sid in studentIds) {
      if (getAverageAttendanceForStudent(sid) < threshold) {
        atRisk.add(sid);
      }
    }
    return atRisk;
  }

  void markAttendance(String recordId, bool isPresent) {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      final old = _records[index];
      int newPresent = isPresent ? old.presentClasses + 1 : old.presentClasses;
      int newTotal = old.totalClasses + 1;
      _records[index] = old.copyWith(
        presentClasses: newPresent,
        totalClasses: newTotal,
      );
      notifyListeners();
    }
  }

  void addOrUpdateRecord(AttendanceRecord record) {
    final index = _records.indexWhere(
      (r) => r.studentId == record.studentId && r.subject == record.subject,
    );
    if (index != -1) {
      _records[index] = record;
    } else {
      _records.add(record);
    }
    notifyListeners();
  }
}
