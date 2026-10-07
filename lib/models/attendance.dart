import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AttendanceRecord {
  final String id;
  final String studentId;
  final String subject;
  final int totalClasses;
  final int presentClasses;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.totalClasses,
    required this.presentClasses,
  });

  int get absentClasses => totalClasses - presentClasses;

  double get percentage =>
      totalClasses > 0 ? (presentClasses / totalClasses) * 100.0 : 0.0;

  bool get isAtRisk => percentage < 75.0;

  Color get statusColor {
    if (percentage >= 75.0) {
      return AppTheme.statusGreen;
    } else if (percentage >= 60.0) {
      return AppTheme.statusYellow;
    } else {
      return AppTheme.statusRed;
    }
  }

  String get statusText {
    if (percentage >= 75.0) {
      return 'Good';
    } else if (percentage >= 60.0) {
      return 'Warning';
    } else {
      return 'Critical';
    }
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      subject: json['subject'] ?? '',
      totalClasses: json['totalClasses'] ?? 0,
      presentClasses: json['presentClasses'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'subject': subject,
      'totalClasses': totalClasses,
      'presentClasses': presentClasses,
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? subject,
    int? totalClasses,
    int? presentClasses,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      totalClasses: totalClasses ?? this.totalClasses,
      presentClasses: presentClasses ?? this.presentClasses,
    );
  }
}
