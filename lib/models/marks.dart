import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class MarksRecord {
  final String id;
  final String studentId;
  final String subject;
  final double internalMarks; // Max 20
  final double assignmentMarks; // Max 10
  final double midExam; // Max 20
  final double finalExam; // Max 50

  MarksRecord({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.internalMarks,
    required this.assignmentMarks,
    required this.midExam,
    required this.finalExam,
  });

  double get totalMarks =>
      internalMarks + assignmentMarks + midExam + finalExam;

  double get percentage => totalMarks; // Since max is 100

  String get grade => AppConstants.calculateGrade(percentage);

  String get performanceStatus => AppConstants.getPerformanceStatus(percentage);

  bool get isAtRisk => percentage < 40.0;

  Color get gradeColor {
    if (percentage >= 80.0) return AppTheme.statusGreen;
    if (percentage >= 60.0) return AppTheme.primaryLight;
    if (percentage >= 40.0) return AppTheme.statusYellow;
    return AppTheme.statusRed;
  }

  factory MarksRecord.fromJson(Map<String, dynamic> json) {
    return MarksRecord(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      subject: json['subject'] ?? '',
      internalMarks: (json['internalMarks'] ?? 0.0).toDouble(),
      assignmentMarks: (json['assignmentMarks'] ?? 0.0).toDouble(),
      midExam: (json['midExam'] ?? 0.0).toDouble(),
      finalExam: (json['finalExam'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'subject': subject,
      'internalMarks': internalMarks,
      'assignmentMarks': assignmentMarks,
      'midExam': midExam,
      'finalExam': finalExam,
    };
  }

  MarksRecord copyWith({
    String? id,
    String? studentId,
    String? subject,
    double? internalMarks,
    double? assignmentMarks,
    double? midExam,
    double? finalExam,
  }) {
    return MarksRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      internalMarks: internalMarks ?? this.internalMarks,
      assignmentMarks: assignmentMarks ?? this.assignmentMarks,
      midExam: midExam ?? this.midExam,
      finalExam: finalExam ?? this.finalExam,
    );
  }
}
