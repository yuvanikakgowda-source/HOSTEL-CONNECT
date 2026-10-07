// frontend/lib/screens/student/complaints_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/complaint_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  final _complaintController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitComplaint() async {
    if (_complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a complaint')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiService = ApiService();
      await apiService.post('/complaints/file', {
        'complaint_text': _complaintController.text,
      });
      _complaintController.clear();
      final _ = ref.refresh(complaintProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final complaintAsync = ref.watch(complaintProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Submit Complaint Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lodge a Complaint',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _complaintController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Describe your complaint here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        label: 'Submit Complaint',
                        isLoading: _isSubmitting,
                        onPressed: _submitComplaint,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Your Complaints',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              complaintAsync.when(
                data: (complaints) {
                  if (complaints.isEmpty) {
                    return const Center(
                      child: Text('No complaints yet'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            complaint.status == 'Solved'
                                ? Icons.check_circle
                                : Icons.hourglass_bottom,
                            color: complaint.status == 'Solved'
                                ? Colors.green
                                : Colors.orange,
                          ),
                          title: Text(complaint.complaintText),
                          subtitle: Text(
                              '${complaint.dateFiled} - ${complaint.status}'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }
}
