// frontend/lib/screens/student/student_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/dashboard_card.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      Future.microtask(() {
        if (!context.mounted) return;
        context.go('/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Connect'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/student-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme toggle')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          authState.user?.username ?? 'Student',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Register: ${authState.user?.hostelRegisterNumber ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  DashboardCard(
                    title: 'Attendance',
                    subtitle: 'Mark & View',
                    icon: Icons.check_circle,
                    color: const Color(0xFF10B981),
                    onTap: () => context.go('/student-attendance'),
                  ),
                  DashboardCard(
                    title: 'Complaints',
                    subtitle: 'Lodge & Track',
                    icon: Icons.feedback,
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.go('/student-complaints'),
                  ),
                  DashboardCard(
                    title: 'Notices',
                    subtitle: 'View Updates',
                    icon: Icons.notifications,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.go('/student-notices'),
                  ),
                  DashboardCard(
                    title: 'Mess Menu',
                    subtitle: 'Weekly Menu',
                    icon: Icons.restaurant,
                    color: const Color(0xFFEC4899),
                    onTap: () => context.go('/student-mess-menu'),
                  ),
                  DashboardCard(
                    title: 'Room Info',
                    subtitle: 'My Room',
                    icon: Icons.room,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.go('/student-room-info'),
                  ),
                  DashboardCard(
                    title: 'Profile',
                    subtitle: 'Account Settings',
                    icon: Icons.settings,
                    color: const Color(0xFF06B6D4),
                    onTap: () => context.go('/student-profile'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Attendance History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ref.watch(attendanceProvider).when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No attendance history available.'),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Day')),
                            DataColumn(label: Text('Month')),
                            DataColumn(label: Text('Year')),
                            DataColumn(label: Text('Time')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: records.take(10).map((record) {
                            return DataRow(
                              cells: [
                                DataCell(Text(record.date)),
                                DataCell(Text(record.day)),
                                DataCell(Text(record.month ?? '')),
                                DataCell(Text(record.year?.toString() ?? '')),
                                DataCell(Text(
                                    record.time ?? record.timeMarked ?? '')),
                                DataCell(Text(record.status)),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading attendance history: $error'),
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
