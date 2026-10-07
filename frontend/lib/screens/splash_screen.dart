// frontend/lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isInitialized) {
      Future.microtask(() {
        if (!context.mounted) return;
        if (authState.isAuthenticated && authState.user?.role == 'student') {
          context.go('/student-dashboard');
        } else if (authState.isAuthenticated &&
            authState.user?.role == 'warden') {
          context.go('/warden-dashboard');
        } else {
          context.go('/home');
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apartment, size: 80, color: Colors.white)
                  .animate()
                  .scale(duration: 600.ms),
              const SizedBox(height: 20),
              const Text(
                'HOSTEL CONNECT',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 600.ms).then().slide(),
              const SizedBox(height: 10),
              const Text(
                'Hostel Management System',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ).animate().fadeIn(duration: 800.ms),
              const SizedBox(height: 50),
              const CircularProgressIndicator(color: Colors.white)
                  .animate()
                  .fadeIn(duration: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}
