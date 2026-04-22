import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
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
  static const _boxName = 'settings';
  static const _tokenKey = 'session_token';
  static const _userKey = 'session_user';

  AuthNotifier() : super(const AuthState());

  /// Inicializa la sesión si hay datos guardados
  Future<void> init() async {
    final box = Hive.box(_boxName);
    final token = box.get(_tokenKey) as String?;
    final userJson = box.get(_userKey) as String?;

    print('DEBUG: AuthNotifier.init() - token: ${token != null ? 'encontrado' : 'null'}, userJson: ${userJson != null ? 'encontrado' : 'null'}');

    if (token != null && userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        final usuario = Usuario.fromMap(userData);
        _api.setToken(token);
        state = state.copyWith(usuario: usuario, token: token);
        print('DEBUG: Sesión recuperada para ${usuario.email}');
      } catch (e) {
        print('DEBUG: Error al decodificar sesión: $e');
        await box.delete(_tokenKey);
        await box.delete(_userKey);
      }
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _api.login(email, password);
      _api.setToken(result.token);

      if (rememberMe) {
        final box = Hive.box(_boxName);
        await box.put(_tokenKey, result.token);
        await box.put(_userKey, jsonEncode(result.usuario.toMap()));
      }

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
    bool rememberMe = false,
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

      if (rememberMe) {
        final box = Hive.box(_boxName);
        await box.put(_tokenKey, result.token);
        await box.put(_userKey, jsonEncode(result.usuario.toMap()));
      }

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

  Future<void> logout() async {
    final box = Hive.box(_boxName);
    await box.delete(_tokenKey);
    await box.delete(_userKey);
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
