// frontend/lib/providers/notice_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notice_model.dart';
import '../services/api_service.dart';

final noticeProvider = FutureProvider<List<NoticeModel>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/notices/view');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => NoticeModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch notices: $e');
  }
});

final wardenNoticeProvider = FutureProvider<List<NoticeModel>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/notices/my-notices');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => NoticeModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch notices: $e');
  }
});
