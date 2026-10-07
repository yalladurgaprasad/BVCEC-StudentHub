class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String role; // 'admin' or 'student'
  final String? studentId;
  final String? department;
  final String? phone;
  final String? website;
  final String? companyName;
  final String? cityName;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.department,
    this.phone,
    this.website,
    this.companyName,
    this.cityName,
  });

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String compName = '';
    if (json['company'] != null && json['company'] is Map) {
      compName = json['company']['name'] ?? '';
    } else if (json['companyName'] != null) {
      compName = json['companyName'];
    }

    String city = '';
    if (json['address'] != null && json['address'] is Map) {
      city = json['address']['city'] ?? '';
    } else if (json['cityName'] != null) {
      city = json['cityName'];
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? json['name'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      studentId: json['studentId'],
      department: json['department'],
      phone: json['phone']?.toString(),
      website: json['website']?.toString(),
      companyName: compName.isNotEmpty ? compName : null,
      cityName: city.isNotEmpty ? city : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'role': role,
      'studentId': studentId,
      'department': department,
      'phone': phone,
      'website': website,
      'companyName': companyName,
      'cityName': cityName,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? role,
    String? studentId,
    String? department,
    String? phone,
    String? website,
    String? companyName,
    String? cityName,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      companyName: companyName ?? this.companyName,
      cityName: cityName ?? this.cityName,
    );
  }
}
