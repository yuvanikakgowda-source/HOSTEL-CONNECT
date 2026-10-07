// frontend/lib/providers/mess_menu_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mess_menu_model.dart';
import '../services/api_service.dart';

final messMenuProvider = FutureProvider<List<MessMenuModel>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/mess-menu/view');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => MessMenuModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch mess menu: $e');
  }
});
