// frontend/lib/screens/auth/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const Icon(Icons.apartment, size: 100, color: Colors.white)
                    .animate()
                    .scale(duration: 600.ms),
                const SizedBox(height: 20),
                const Text(
                  'HOSTEL CONNECT',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).then().slide(),
                const SizedBox(height: 10),
                const Text(
                  'Smart Hostel Management System',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 800.ms),
                const SizedBox(height: 80),
                const Text(
                  'Select Your Role',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 1000.ms),
                const SizedBox(height: 30),
                // Student Login
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.95),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.person,
                            size: 50, color: Color(0xFF6366F1)),
                        const SizedBox(height: 12),
                        const Text(
                          'Student Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Login',
                          onPressed: () => context.go('/student-login'),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/student-register'),
                          child: const Text('New to Hostel Connect? Register'),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 1200.ms).then().slideY(begin: 0.2),
                const SizedBox(height: 20),
                // Warden Login
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.95),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.security,
                            size: 50, color: Color(0xFF6366F1)),
                        const SizedBox(height: 12),
                        const Text(
                          'Warden Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Login',
                          onPressed: () => context.go('/warden-login'),
                          width: double.infinity,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/warden-register'),
                          child: const Text('New Warden? Register'),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 1400.ms).then().slideY(begin: 0.2),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
