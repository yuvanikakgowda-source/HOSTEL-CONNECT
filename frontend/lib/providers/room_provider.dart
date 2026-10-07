// frontend/lib/providers/room_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';

final studentRoomProvider = StreamProvider.autoDispose((ref) async* {
  final apiService = ApiService();
  // Poll every 5 seconds for updates to student's room
  while (true) {
    try {
      final response = await apiService.get('/rooms/my-room');
      if (response.statusCode == 200) {
        yield response.data['data'];
      } else {
        yield null;
      }
    } catch (e) {
      yield null;
    }

    await Future.delayed(const Duration(seconds: 5));
  }
});

final allRoomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  final apiService = ApiService();
  try {
    final response = await apiService.get('/rooms/all');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => RoomModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch rooms: $e');
  }
});
