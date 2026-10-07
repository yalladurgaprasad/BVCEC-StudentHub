class Student {
  final String id;
  final String studentId;
  final String rollNumber;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String year;
  final String section;
  final String dateOfBirth;

  Student({
    required this.id,
    required this.studentId,
    required this.rollNumber,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.year,
    required this.section,
    required this.dateOfBirth,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      department: json['department'] ?? '',
      year: json['year'] ?? '',
      section: json['section'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'rollNumber': rollNumber,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'year': year,
      'section': section,
      'dateOfBirth': dateOfBirth,
    };
  }

  Student copyWith({
    String? id,
    String? studentId,
    String? rollNumber,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? year,
    String? section,
    String? dateOfBirth,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      rollNumber: rollNumber ?? this.rollNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      year: year ?? this.year,
      section: section ?? this.section,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
