// frontend/lib/screens/auth/student_register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class StudentRegisterScreen extends ConsumerStatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  ConsumerState<StudentRegisterScreen> createState() =>
      _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends ConsumerState<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _hostelRegisterController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _hostelRegisterController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Registration',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your student account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Username',
                  hint: 'Choose a username',
                  controller: _usernameController,
                  icon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Username is required';
                    }
                    if ((value?.length ?? 0) < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Hostel Register Number',
                  hint: 'Your hostel register number',
                  controller: _hostelRegisterController,
                  icon: Icons.badge,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Register number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Email',
                  hint: 'your.email@example.com',
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  controller: _passwordController,
                  isPassword: true,
                  icon: Icons.lock,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Password is required';
                    }
                    if ((value?.length ?? 0) < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  icon: Icons.lock,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                if (authState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      authState.error ?? '',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Register',
                  isLoading: authState.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success =
                          await ref.read(authProvider.notifier).registerStudent(
                                username: _usernameController.text,
                                password: _passwordController.text,
                                hostelRegisterNumber:
                                    _hostelRegisterController.text,
                                email: _emailController.text,
                              );
                      if (success) {
                        _navigateTo('/student-dashboard');
                      }
                    }
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/student-login'),
                    child: const Text('Already have an account? Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(String route) {
    if (!mounted) return;
    GoRouter.of(context).go(route);
  }
}
