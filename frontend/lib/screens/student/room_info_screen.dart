import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/room_provider.dart';

class RoomInfoScreen extends ConsumerWidget {
  const RoomInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(studentRoomProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Room Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: roomAsync.when(
        data: (roomData) {
          if (roomData == null) {
            return const Center(child: Text('No room allocated'));
          }

          final occupants = roomData['students'] as List? ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Room Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow('Floor', roomData['floor']),
                        _infoRow('Room Number', roomData['room_number']),
                        _infoRow('Room Type', roomData['room_type']),
                        _infoRow('Room Capacity', roomData['capacity']),
                        _infoRow('Current Occupants', occupants.length),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Occupants',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (occupants.isEmpty)
                  const Text('No occupants found')
                else
                  ...occupants.map((occupant) {
                    final item = Map<String, dynamic>.from(occupant as Map);
                    final name = item['username'] ?? 'Unknown';
                    final userId = item['hostel_register_number'] ?? 'N/A';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(name),
                        subtitle: Text(userId),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading room information: $error'),
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? 'N/A')),
        ],
      ),
    );
  }
}
