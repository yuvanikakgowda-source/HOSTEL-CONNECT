// frontend/lib/models/complaint_model.dart
class ComplaintModel {
  final int id;
  final int studentId;
  final String complaintText;
  final String status;
  final String dateFiled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ComplaintModel({
    required this.id,
    required this.studentId,
    required this.complaintText,
    required this.status,
    required this.dateFiled,
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      complaintText: json['complaint_text'] ?? '',
      status: json['status'] ?? 'Processing',
      dateFiled: json['date_filed'] ?? '',
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
      'student_id': studentId,
      'complaint_text': complaintText,
      'status': status,
      'date_filed': dateFiled,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
