// frontend/lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../core/constants/app_constants.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final bool isInitialized;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final String? token;

  AuthState({
    this.isLoading = false,
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.token,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isInitialized,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
    String? token,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService = ApiService();
  final _secureStorage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final token = await _secureStorage.read(
        key: AppConstants.storageKeyToken,
      );
      if (token != null) {
        _apiService.setAuthToken(token);
        final prefs = await SharedPreferences.getInstance();
        final userJson = prefs.getString(AppConstants.storageKeyUser);
        if (userJson != null) {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          final user = UserModel.fromJson(userMap);
          state = state.copyWith(
            isInitialized: true,
            isAuthenticated: true,
            token: token,
            user: user,
          );
        } else {
          final storedRole = prefs.getString(AppConstants.storageKeyRole);
          final storedUserId = prefs.getInt(AppConstants.storageKeyUserId);

          if (storedRole != null && storedUserId != null) {
            state = state.copyWith(
              isInitialized: true,
              isAuthenticated: true,
              token: token,
              user: UserModel(
                id: storedUserId,
                username: '',
                role: storedRole,
              ),
            );
          } else {
            state = state.copyWith(
              isInitialized: true,
              isAuthenticated: true,
              token: token,
            );
          }
        }
      } else {
        state = state.copyWith(isInitialized: true, isAuthenticated: false);
      }
    } catch (_) {
      state = state.copyWith(isInitialized: true, isAuthenticated: false);
    }
  }

  Future<bool> registerStudent({
    required String username,
    required String password,
    required String hostelRegisterNumber,
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post('/auth/register/student', {
        'username': username,
        'password': password,
        'hostel_register_number': hostelRegisterNumber,
        'email': email,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);

        await _secureStorage.write(
          key: AppConstants.storageKeyToken,
          value: token,
        );
        // no biometric persistence in Flutter; face encoding is enrolled by the Python webcam service
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.storageKeyUser,
          jsonEncode(user.toJson()),
        );
        await prefs.setString(AppConstants.storageKeyRole, user.role);
        await prefs.setInt(AppConstants.storageKeyUserId, user.id);

        _apiService.setAuthToken(token);

        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          isAuthenticated: true,
          user: user,
          token: token,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isInitialized: true, error: e.toString());
    }
    return false;
  }

  Future<bool> loginStudent({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post('/auth/login/student', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);

        await _secureStorage.write(
          key: AppConstants.storageKeyToken,
          value: token,
        );
        // no biometric persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.storageKeyUser,
          jsonEncode(user.toJson()),
        );
        await prefs.setString(AppConstants.storageKeyRole, user.role);
        await prefs.setInt(AppConstants.storageKeyUserId, user.id);

        _apiService.setAuthToken(token);

        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          isAuthenticated: true,
          user: user,
          token: token,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isInitialized: true, error: e.toString());
    }
    return false;
  }

  Future<bool> loginWarden({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post('/auth/login/warden', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);

        await _secureStorage.write(
          key: AppConstants.storageKeyToken,
          value: token,
        );
        // no biometric persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.storageKeyUser,
          jsonEncode(user.toJson()),
        );
        await prefs.setString(AppConstants.storageKeyRole, user.role);
        await prefs.setInt(AppConstants.storageKeyUserId, user.id);

        _apiService.setAuthToken(token);

        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          isAuthenticated: true,
          user: user,
          token: token,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isInitialized: true, error: e.toString());
    }
    return false;
  }

  Future<bool> registerWarden({
    required String username,
    required String password,
    required String email,
    required String hostelName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post('/auth/register/warden', {
        'username': username,
        'password': password,
        'email': email,
        'hostel_name': hostelName,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);

        await _secureStorage.write(
          key: AppConstants.storageKeyToken,
          value: token,
        );
        // no biometric persistence required for warden
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.storageKeyUser,
          jsonEncode(user.toJson()),
        );
        await prefs.setString(AppConstants.storageKeyRole, user.role);
        await prefs.setInt(AppConstants.storageKeyUserId, user.id);

        _apiService.setAuthToken(token);

        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          isAuthenticated: true,
          user: user,
          token: token,
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isInitialized: true, error: e.toString());
    }
    return false;
  }

  Future<void> logout() async {
    _apiService.clearAuthToken();
    await _secureStorage.delete(key: AppConstants.storageKeyToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.storageKeyUser);
    await prefs.remove(AppConstants.storageKeyRole);
    await prefs.remove(AppConstants.storageKeyUserId);

    state = AuthState(isInitialized: true);
  }
}
