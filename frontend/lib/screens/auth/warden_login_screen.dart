// frontend/lib/screens/auth/warden_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class WardenLoginScreen extends ConsumerStatefulWidget {
  const WardenLoginScreen({super.key});

  @override
  ConsumerState<WardenLoginScreen> createState() => _WardenLoginScreenState();
}

class _WardenLoginScreenState extends ConsumerState<WardenLoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
                  'Warden Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your warden account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Username',
                  hint: 'Enter your username',
                  controller: _usernameController,
                  icon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  icon: Icons.lock,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Password is required';
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
                  label: 'Login',
                  isLoading: authState.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success =
                          await ref.read(authProvider.notifier).loginWarden(
                                username: _usernameController.text,
                                password: _passwordController.text,
                              );
                      if (success) {
                        _navigateTo('/warden-dashboard');
                      }
                    }
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/warden-register'),
                    child: const Text('New to system? Register'),
                  ),
                ),
                const SizedBox(height: 20),
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
