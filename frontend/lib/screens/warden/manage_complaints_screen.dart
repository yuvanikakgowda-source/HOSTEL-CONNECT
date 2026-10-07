// frontend/lib/screens/warden/manage_complaints_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/complaint_provider.dart';
import '../../services/api_service.dart';

class ManageComplaintsScreen extends ConsumerWidget {
  const ManageComplaintsScreen({super.key});

  Future<void> _updateStatus(
      int complaintId, String newStatus, WidgetRef ref) async {
    try {
      final apiService = ApiService();
      await apiService.put('/complaints/status/$complaintId', {
        'status': newStatus,
      });
      final _ = ref.refresh(allComplaintsProvider);
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(allComplaintsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Complaints'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/warden-dashboard'),
        ),
      ),
      body: complaintsAsync.when(
        data: (complaints) {
          if (complaints.isEmpty) {
            return const Center(
              child: Text('No complaints'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Icon(
                    complaint.status == 'Solved'
                        ? Icons.check_circle
                        : Icons.hourglass_bottom,
                    color: complaint.status == 'Solved'
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Text(complaint.complaintText),
                  subtitle: Text(complaint.dateFiled),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Status: ${complaint.status}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                  label: Text('Processing'),
                                  value: 'Processing'),
                              ButtonSegment(
                                  label: Text('Solved'), value: 'Solved'),
                            ],
                            selected: {complaint.status},
                            onSelectionChanged: (selected) {
                              _updateStatus(complaint.id, selected.first, ref);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
