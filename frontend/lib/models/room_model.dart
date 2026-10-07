// frontend/lib/models/room_model.dart

class StudentInfo {
  final int id;
  final String username;
  final String? hostelRegisterNumber;
  final String? email;
  final String? phone;

  StudentInfo({
    required this.id,
    required this.username,
    this.hostelRegisterNumber,
    this.email,
    this.phone,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      hostelRegisterNumber: json['hostel_register_number'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'hostel_register_number': hostelRegisterNumber,
      'email': email,
      'phone': phone,
    };
  }

  String get displayName =>
      hostelRegisterNumber == null || hostelRegisterNumber!.isEmpty
          ? username
          : '$username($hostelRegisterNumber)';
}

class RoomModel {
  final int id;
  final String? roomId;
  final int floor;
  final String roomNumber;
  final String roomType;
  final int capacity;
  final int currentOccupancy;
  final List<String> students;
  final List<StudentInfo> studentDetails;
  final int studentCount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoomModel({
    required this.id,
    this.roomId,
    required this.floor,
    required this.roomNumber,
    this.roomType = 'Double',
    required this.capacity,
    required this.currentOccupancy,
    this.students = const [],
    this.studentDetails = const [],
    this.studentCount = 0,
    this.status = 'Vacant',
    this.createdAt,
    this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    final studentDetailsFromJson = (json['students'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((s) => StudentInfo.fromJson(s))
            .toList() ??
        [];
    final studentList = (json['students'] as List?)?.map((s) {
          if (s is String) return s;
          if (s is Map<String, dynamic>) {
            return StudentInfo.fromJson(s).displayName;
          }
          if (s is Map) {
            return StudentInfo.fromJson(Map<String, dynamic>.from(s))
                .displayName;
          }
          return '';
        }).where((s) => s.isNotEmpty).toList() ??
        [];

    return RoomModel(
      id: json['id'] ?? 0,
      roomId: json['roomId'] ?? json['room_id'],
      floor: json['floor'] is int
          ? json['floor']
          : int.tryParse(json['floor']?.toString() ?? '') ?? 0,
      roomNumber: json['room_number'] ?? '',
      roomType: json['room_type'] ?? 'Double',
      capacity: json['capacity'] ?? 0,
      currentOccupancy:
          json['occupied'] ??
              json['current_occupancy'] ??
              json['currentOccupancy'] ??
              0,
      students: studentList,
      studentDetails: studentDetailsFromJson,
      studentCount:
          json['occupied'] ?? json['student_count'] ?? json['studentCount'] ?? 0,
      status: json['status'] ??
          (json['current_occupancy'] ?? 0 > 0 ? 'Occupied' : 'Vacant'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'floor': floor,
      'room_number': roomNumber,
      'room_type': roomType,
      'capacity': capacity,
      'current_occupancy': currentOccupancy,
      'students': students,
      'student_count': studentCount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
