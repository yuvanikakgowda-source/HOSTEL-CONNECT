// frontend/lib/screens/warden/warden_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_card.dart';

class WardenDashboardScreen extends ConsumerWidget {
  const WardenDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: const Text('Hostel Connect - Warden'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              context.go('/home');
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
                      colors: [Color(0xFF1F2937), Color(0xFF374151)],
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
                          'Warden Control Panel',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage: ${authState.user?.username ?? 'Hostel'}',
                          style: const TextStyle(
                            fontSize: 16,
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
                'Management Tools',
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
                    subtitle: 'View & Manage',
                    icon: Icons.calendar_today,
                    color: const Color(0xFF10B981),
                    onTap: () => context.go('/warden-attendance'),
                  ),
                  DashboardCard(
                    title: 'Complaints',
                    subtitle: 'Review Status',
                    icon: Icons.feedback,
                    color: const Color(0xFFF59E0B),
                    onTap: () => context.go('/warden-complaints'),
                  ),
                  DashboardCard(
                    title: 'Notices',
                    subtitle: 'Post & Manage',
                    icon: Icons.notifications,
                    color: const Color(0xFF3B82F6),
                    onTap: () => context.go('/warden-notices'),
                  ),
                  DashboardCard(
                    title: 'Mess Menu',
                    subtitle: 'Update Menu',
                    icon: Icons.restaurant,
                    color: const Color(0xFFEC4899),
                    onTap: () => context.go('/warden-mess-menu'),
                  ),
                  DashboardCard(
                    title: 'Rooms',
                    subtitle: 'Allocate Rooms',
                    icon: Icons.room,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.go('/warden-rooms'),
                  ),
                  DashboardCard(
                    title: 'Search',
                    subtitle: 'Find Students',
                    icon: Icons.search,
                    color: const Color(0xFF06B6D4),
                    onTap: () => context.go('/warden-search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
