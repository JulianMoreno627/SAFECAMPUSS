import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class AuthState {
  final Usuario? usuario;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.usuario,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    Usuario? usuario,
    String? token,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      usuario: usuario ?? this.usuario,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  bool get isAuthenticated => usuario != null && token != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api = ApiService();

  AuthNotifier() : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _api.login(email, password);
      _api.setToken(result.token);
      state = state.copyWith(
        usuario: result.usuario,
        token: result.token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _api.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );
      _api.setToken(result.token);
      state = state.copyWith(
        usuario: result.usuario,
        token: result.token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
