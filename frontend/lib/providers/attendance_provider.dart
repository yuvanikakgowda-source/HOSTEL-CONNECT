// frontend/lib/providers/attendance_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';

final attendanceProvider = FutureProvider<List<AttendanceModel>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/attendance/my-attendance');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch attendance: $e');
  }
});

final allAttendanceProvider = FutureProvider<List<AttendanceModel>>((
  ref,
) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/attendance/all');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch attendance: $e');
  }
});

final attendanceStatsProvider = FutureProvider((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/attendance/statistics');
    if (response.statusCode == 200) {
      return response.data['data'];
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch statistics: $e');
  }
});
