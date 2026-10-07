// frontend/lib/screens/student/mess_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/mess_menu_model.dart';
import '../../providers/mess_menu_provider.dart';

class MessMenuScreen extends ConsumerWidget {
  const MessMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(messMenuProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Mess Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard'),
        ),
      ),
      body: menuAsync.when(
        data: (menu) {
          if (menu.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Menu not available yet'),
                ],
              ),
            );
          }

          final days = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ];
          final meals = ['Breakfast', 'Lunch', 'Dinner'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: List.generate(
                        days.length + 1,
                        (index) => DataColumn(
                          label: index == 0
                              ? const Text('Meal')
                              : Text(days[index - 1]),
                        ),
                      ),
                      rows: List.generate(
                        meals.length,
                        (mealIndex) => DataRow(
                          cells: [
                            DataCell(Text(meals[mealIndex])),
                            ...List.generate(
                              days.length,
                              (dayIndex) {
                                final item = menu.firstWhere(
                                  (m) =>
                                      m.dayOfWeek == days[dayIndex] &&
                                      m.mealType == meals[mealIndex],
                                  orElse: () => MessMenuModel(
                                    id: 0,
                                    dayOfWeek: '',
                                    mealType: '',
                                    menuItem: '',
                                  ),
                                );
                                return DataCell(
                                  Text(item.menuItem.isNotEmpty
                                      ? item.menuItem
                                      : '-'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
