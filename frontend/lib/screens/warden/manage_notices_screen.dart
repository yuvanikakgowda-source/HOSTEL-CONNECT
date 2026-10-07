// frontend/lib/screens/warden/manage_notices_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notice_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class ManageNoticesScreen extends ConsumerStatefulWidget {
  const ManageNoticesScreen({super.key});

  @override
  ConsumerState<ManageNoticesScreen> createState() =>
      _ManageNoticesScreenState();
}

class _ManageNoticesScreenState extends ConsumerState<ManageNoticesScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _createNotice() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiService = ApiService();
      await apiService.post('/notices/create', {
        'title': _titleController.text,
        'content': _contentController.text,
      });
      _titleController.clear();
      _contentController.clear();
      final _ = ref.refresh(wardenNoticeProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice created successfully')),
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
    final noticesAsync = ref.watch(wardenNoticeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/warden-dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Notice',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        label: 'Create Notice',
                        isLoading: _isSubmitting,
                        onPressed: _createNotice,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Your Notices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              noticesAsync.when(
                data: (notices) {
                  if (notices.isEmpty) {
                    return const Center(
                      child: Text('No notices created yet'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      final notice = notices[index];
                      return Card(
                        child: ExpansionTile(
                          title: Text(notice.title),
                          subtitle: Text(notice.datePosted),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(notice.content),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Edit'),
                                        onPressed: () {
                                          _titleController.text = notice.title;
                                          _contentController.text =
                                              notice.content;
                                        },
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Delete'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          try {
                                            final apiService = ApiService();
                                            await apiService.delete(
                                                '/notices/delete/${notice.id}');
                                            final _ = ref
                                                .refresh(wardenNoticeProvider);
                                          } catch (e) {
                                            debugPrint('Error: $e');
                                          }
                                        },
                                      ),
                                    ],
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
