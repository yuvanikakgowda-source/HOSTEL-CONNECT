// frontend/lib/providers/complaint_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import '../services/api_service.dart';

final complaintProvider = FutureProvider<List<ComplaintModel>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/complaints/my-complaints');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => ComplaintModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch complaints: $e');
  }
});

final allComplaintsProvider = FutureProvider<List<ComplaintModel>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/complaints/all');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => ComplaintModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch complaints: $e');
  }
});
