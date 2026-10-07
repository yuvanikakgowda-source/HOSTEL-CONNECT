import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/room_model.dart';
import '../../providers/room_provider.dart';
import '../../services/api_service.dart';

class ManageRoomsScreen extends ConsumerStatefulWidget {
  const ManageRoomsScreen({super.key});

  @override
  ConsumerState<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends ConsumerState<ManageRoomsScreen> {
  Future<void> _saveRoom({
    RoomModel? room,
    required String floor,
    required String roomType,
    required String roomNumber,
    required String capacity,
  }) async {
    final payload = {
      'floor': floor.trim(),
      'room_type': roomType.trim(),
      'room_number': roomNumber.trim(),
      'capacity': int.tryParse(capacity.trim()) ?? 0,
    };

    try {
      final api = ApiService();
      if (room == null) {
        await api.post('/rooms/create', payload);
      } else {
        await api.put('/rooms/${room.id}', payload);
      }
      final _ = ref.refresh(allRoomsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(room == null ? 'Room added' : 'Room updated')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _allocateStudent(RoomModel room, String userId) async {
    if (userId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student User ID is required')),
      );
      return;
    }

    try {
      await ApiService().put(
        '/rooms/allocate/${userId.trim()}',
        {'room_id': room.id},
      );
      final _ = ref.refresh(allRoomsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student allocated')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _removeStudent(String userId) async {
    try {
      await ApiService().put('/rooms/remove/$userId', {});
      final _ = ref.refresh(allRoomsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student removed from room')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _showRoomDialog({RoomModel? room}) {
    final floorController =
        TextEditingController(text: room?.floor.toString() ?? '');
    final roomTypeController =
        TextEditingController(text: room?.roomType ?? 'Boys');
    final roomNumberController =
        TextEditingController(text: room?.roomNumber ?? '');
    final capacityController =
        TextEditingController(text: room?.capacity.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(room == null ? 'Add Room' : 'Update Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(floorController, 'Floor'),
              _dialogField(roomTypeController, 'Room Type'),
              _dialogField(roomNumberController, 'Room Number'),
              _dialogField(
                capacityController,
                'Capacity',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _saveRoom(
              room: room,
              floor: floorController.text,
              roomType: roomTypeController.text,
              roomNumber: roomNumberController.text,
              capacity: capacityController.text,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _showAllocateDialog(RoomModel room) {
    final userIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Allocate Student to ${room.roomNumber}'),
        content: TextField(
          controller: userIdController,
          decoration: const InputDecoration(
            labelText: 'Student User ID',
            hintText: 'STU001',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _allocateStudent(room, userIdController.text),
            child: const Text('Allocate'),
          ),
        ],
      ),
    );
  }

  void _showOccupantsDialog(RoomModel room) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Room ${room.roomNumber} Occupants'),
        content: SizedBox(
          width: double.maxFinite,
          child: room.studentDetails.isEmpty
              ? const Text('No students allocated')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: room.studentDetails.length,
                  itemBuilder: (context, index) {
                    final student = room.studentDetails[index];
                    return ListTile(
                      title: Text(student.username),
                      subtitle: Text(student.hostelRegisterNumber ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_remove),
                        onPressed: () => _removeStudent(
                          student.hostelRegisterNumber ?? student.id.toString(),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(allRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Allocation Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/warden-dashboard'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoomDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
      ),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(child: Text('No rooms available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Floor')),
                  DataColumn(label: Text('Room Type')),
                  DataColumn(label: Text('Room Number')),
                  DataColumn(label: Text('No. of Students')),
                  DataColumn(label: Text('Student Names (User IDs)')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: rooms.map((room) {
                  final occupants = room.students.join(', ');
                  return DataRow(
                    cells: [
                      DataCell(Text(room.floor.toString())),
                      DataCell(Text(room.roomType)),
                      DataCell(Text(room.roomNumber)),
                      DataCell(Text(room.currentOccupancy.toString())),
                      DataCell(
                        SizedBox(
                          width: 320,
                          child: Text(occupants.isEmpty ? '-' : occupants),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Update Room',
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showRoomDialog(room: room),
                            ),
                            IconButton(
                              tooltip: 'Allocate Student',
                              icon: const Icon(Icons.person_add),
                              onPressed: () => _showAllocateDialog(room),
                            ),
                            IconButton(
                              tooltip: 'Occupants',
                              icon: const Icon(Icons.group),
                              onPressed: () => _showOccupantsDialog(room),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
