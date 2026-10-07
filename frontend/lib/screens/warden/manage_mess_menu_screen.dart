// frontend/lib/screens/warden/manage_mess_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/mess_menu_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class ManageMessMenuScreen extends ConsumerStatefulWidget {
  const ManageMessMenuScreen({super.key});

  @override
  ConsumerState<ManageMessMenuScreen> createState() =>
      _ManageMessMenuScreenState();
}

class _ManageMessMenuScreenState extends ConsumerState<ManageMessMenuScreen> {
  final Map<String, String> _menuItems = {};
  bool _isUploading = false;

  final _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final _meals = ['Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();
    for (var day in _days) {
      for (var meal in _meals) {
        _menuItems['$day-$meal'] = '';
      }
    }
  }

  Future<void> _uploadMenu() async {
    setState(() => _isUploading = true);
    try {
      final menu = <Map<String, String>>[];
      _menuItems.forEach((key, value) {
        if (value.isNotEmpty) {
          final parts = key.split('-');
          menu.add({
            'day_of_week': parts[0],
            'meal_type': parts[1],
            'menu_item': value,
          });
        }
      });

      if (menu.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add menu items')),
        );
        setState(() => _isUploading = false);
        return;
      }

      final apiService = ApiService();
      await apiService.post('/mess-menu/upload', {'menu': menu});
      final _ = ref.refresh(messMenuProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploaded Successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Mess Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/warden-dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Weekly Menu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._days.expand((day) {
                        return _meals.map((meal) {
                          final key = '$day-$meal';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextField(
                              onChanged: (value) {
                                _menuItems[key] = value;
                              },
                              decoration: InputDecoration(
                                labelText: '$day - $meal',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          );
                        });
                      }),
                      const SizedBox(height: 20),
                      CustomButton(
                        label: 'Upload Menu',
                        isLoading: _isUploading,
                        onPressed: _uploadMenu,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
