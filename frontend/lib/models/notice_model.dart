// frontend/lib/models/notice_model.dart
class NoticeModel {
  final int id;
  final int wardenId;
  final String title;
  final String content;
  final String datePosted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? username;

  NoticeModel({
    required this.id,
    required this.wardenId,
    required this.title,
    required this.content,
    required this.datePosted,
    this.createdAt,
    this.updatedAt,
    this.username,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? 0,
      wardenId: json['warden_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      datePosted: json['date_posted'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warden_id': wardenId,
      'title': title,
      'content': content,
      'date_posted': datePosted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
