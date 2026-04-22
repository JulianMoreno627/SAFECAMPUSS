import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/usuario.dart';
import '../models/reporte.dart';

class ApiService {
  String get baseUrl {
    try {
      final url = dotenv.maybeGet('API_URL');
      if (url != null && url.isNotEmpty) return url;

      // Fallback para Web vs Mobile
      const isWeb = bool.fromEnvironment('dart.library.js_util');
      return isWeb
          ? 'http://localhost:3000/api'
          : 'http://10.0.2.2:3000/api';
    } catch (_) {
      return 'https://safecampus-backend-xdbe.onrender.com/api';
    }
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<({Usuario usuario, String token})> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      _token = data['token'] as String;
      return (
        usuario: Usuario.fromMap(data['user'] as Map<String, dynamic>),
        token: _token!,
      );
    }
    throw Exception(data['error'] ?? 'Error al iniciar sesión');
  }

  Future<bool> loginWithGoogle({
    required String idToken,
    required String email,
    required String nombre,
    required String apellido,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: _headers,
        body: jsonEncode({
          'id_token': idToken,
          'email': email,
          'nombre': nombre,
          'apellido': apellido,
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        _token = data['token'] as String;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<({Usuario usuario, String token})> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201) {
      _token = data['token'] as String;
      return (
        usuario: Usuario.fromMap(data['user'] as Map<String, dynamic>),
        token: _token!,
      );
    }
    throw Exception(data['error'] ?? 'Error al registrar usuario');
  }

  // ── Reportes ──────────────────────────────────────────────────────────────

  Future<List<Reporte>> getReportesCercanos(double lat, double lng,
      {double radio = 5000}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reportes/cercanos?lat=$lat&lng=$lng&radio=$radio'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Reporte.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener reportes');
  }

  Future<List<Reporte>> getReportesDelUsuario(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reportes/usuario/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Reporte.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    // Si el endpoint no existe aún, retornamos lista vacía sin romper la app
    if (response.statusCode == 404) return [];
    throw Exception('Error al obtener mis reportes');
  }

  Future<Reporte> crearReporte({
    required String tipo,
    required String descripcion,
    required String nivelUrgencia,
    required double lat,
    required double lng,
    required String userId,
    int testigos = 0,
    String? fotoUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reportes'),
      headers: _headers,
      body: jsonEncode({
        'tipo': tipo,
        'descripcion': descripcion,
        'nivel_urgencia': nivelUrgencia,
        'lat': lat,
        'lng': lng,
        'user_id': userId,
        'testigos': testigos,
        if (fotoUrl != null) 'foto_url': fotoUrl,
      }),
    );
    if (response.statusCode == 201) {
      return Reporte.fromMap(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Error al crear el reporte');
  }

  // ── Notificaciones ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNotificaciones(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notificaciones/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al obtener notificaciones');
  }

  Future<void> marcarNotificacionLeida(String notificacionId) async {
    await http.patch(
      Uri.parse('$baseUrl/notificaciones/$notificacionId/leer'),
      headers: _headers,
    );
  }
}
