// frontend/lib/models/user_model.dart
class UserModel {
  final int id;
  final String username;
  final String role;
  final String? email;
  final String? phone;
  final String? hostelRegisterNumber;
  final String? roomNumber;
  final int? floor;
  final String? hostelName;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    this.email,
    this.phone,
    this.hostelRegisterNumber,
    this.roomNumber,
    this.floor,
    this.hostelName,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? 'student',
      email: json['email'],
      phone: json['phone'],
      hostelRegisterNumber: json['hostel_register_number'],
      roomNumber: json['room_number'],
      floor: json['floor'],
      hostelName: json['hostel_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'email': email,
      'phone': phone,
      'hostel_register_number': hostelRegisterNumber,
      'room_number': roomNumber,
      'floor': floor,
      'hostel_name': hostelName,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
