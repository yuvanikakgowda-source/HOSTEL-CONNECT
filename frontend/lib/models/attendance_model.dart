// frontend/lib/models/attendance_model.dart
class AttendanceModel {
  final int id;
  final int studentId;
  final String date;
  final String day;
  final String? timeMarked;
  final String status;
  final double? latitude;
  final double? longitude;
  final int isMorning;
  final int isEvening;
  final String? username;
  final String? hostelRegisterNumber;
  final String? userId;
  final String? studentName;
  final int? year;
  final String? month;
  final String? time;
  final String? timestamp;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.day,
    this.timeMarked,
    required this.status,
    this.latitude,
    this.longitude,
    required this.isMorning,
    required this.isEvening,
    this.username,
    this.hostelRegisterNumber,
    this.userId,
    this.studentName,
    this.year,
    this.month,
    this.time,
    this.timestamp,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      timeMarked: json['time_marked'] ?? json['time'],
      status: json['status'] ?? 'Absent',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isMorning: json['is_morning'] ?? 0,
      isEvening: json['is_evening'] ?? 0,
      username: json['username'],
      hostelRegisterNumber: json['hostel_register_number'],
      userId: json['userId'] ?? json['user_id'] ?? json['hostel_register_number'],
      studentName: json['studentName'] ?? json['student_name'] ?? json['username'],
      year: json['year'],
      month: json['month'],
      time: json['time'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'date': date,
      'day': day,
      'time_marked': timeMarked,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'is_morning': isMorning,
      'is_evening': isEvening,
      'userId': userId,
      'studentName': studentName,
      'year': year,
      'month': month,
      'time': time,
      'timestamp': timestamp,
    };
  }
}
