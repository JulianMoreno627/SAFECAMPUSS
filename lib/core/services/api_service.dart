import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/usuario.dart';
import '../models/reporte.dart';
import '../models/categoria_incidente.dart';

class ApiService {
  String get baseUrl {
    try {
      final url = dotenv.maybeGet('API_URL');
      if (url != null && url.isNotEmpty) return url;
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

  static const _timeout = Duration(seconds: 20);

  // Decodifica JSON de forma segura: si la respuesta es HTML lanza un error
  // claro (ej. servidor dormido en Render free tier).
  dynamic _decodeJson(http.Response response) {
    final body = response.body.trimLeft();
    if (body.startsWith('<')) {
      if (response.statusCode >= 500) {
        throw Exception('El servidor no está disponible (${response.statusCode}). Intenta en unos segundos.');
      }
      throw Exception('Respuesta inesperada del servidor (${response.statusCode}).');
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      throw Exception('Respuesta inválida del servidor (${response.statusCode}).');
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<({Usuario usuario, String token})> login(
      String email, String password) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);
    final data = _decodeJson(response) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      _token = data['token'] as String;
      return (
        usuario: Usuario.fromMap(data['user'] as Map<String, dynamic>),
        token: _token!,
      );
    }
    throw Exception(data['error'] ?? 'Error al iniciar sesión');
  }

  Future<({Usuario usuario, String token})?> loginWithGoogle({
    required String idToken,
    required String email,
    required String nombre,
    required String apellido,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/google'),
            headers: _headers,
            body: jsonEncode({
              'id_token': idToken,
              'email': email,
              'nombre': nombre,
              'apellido': apellido,
            }),
          )
          .timeout(_timeout);
      final data = _decodeJson(response) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        _token = data['token'] as String;
        final usuario =
            Usuario.fromMap(data['user'] as Map<String, dynamic>);
        return (usuario: usuario, token: _token!);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<({Usuario usuario, String token})> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/register'),
          headers: _headers,
          body: jsonEncode({
            'email': email,
            'password': password,
            'nombre': nombre,
            'apellido': apellido,
            'telefono': telefono,
          }),
        )
        .timeout(_timeout);
    final data = _decodeJson(response) as Map<String, dynamic>;
    if (response.statusCode == 201) {
      _token = data['token'] as String;
      return (
        usuario: Usuario.fromMap(data['user'] as Map<String, dynamic>),
        token: _token!,
      );
    }
    throw Exception(data['error'] ?? 'Error al registrar usuario');
  }

  // ── Perfil ────────────────────────────────────────────────────────────────

  Future<Usuario> actualizarFotoPerfil(String userId, String fotoUrl) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/perfil/foto'),
          headers: _headers,
          body: jsonEncode({'user_id': userId, 'foto_url': fotoUrl}),
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      return Usuario.fromMap(
          _decodeJson(response) as Map<String, dynamic>);
    }
    throw Exception('Error al actualizar foto de perfil');
  }

  // ── Reportes ──────────────────────────────────────────────────────────────

  Future<List<Reporte>> getReportesCercanos(double lat, double lng,
      {double radio = 5000, bool mapa = false}) async {
    final response = await http
        .get(
          Uri.parse(
              '$baseUrl/reportes/cercanos?lat=$lat&lng=$lng&radio=$radio&mapa=$mapa'),
          headers: _headers,
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final list = _decodeJson(response) as List<dynamic>;
      return list
          .map((e) => Reporte.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener reportes');
  }

  Future<void> eliminarTodosLosReportes() async {
    final response = await http
        .delete(Uri.parse('$baseUrl/reportes'), headers: _headers)
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar reportes');
    }
  }

  // ── Categorías ────────────────────────────────────────────────────────────

  Future<List<CategoriaIncidente>> getCategorias() async {
    final response = await http
        .get(Uri.parse('$baseUrl/categorias'), headers: _headers)
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final list = _decodeJson(response) as List<dynamic>;
      return list
          .map((e) => CategoriaIncidente.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al obtener categorías');
  }

  Future<CategoriaIncidente> crearCategoria(String nombre) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/categorias'),
          headers: _headers,
          body: jsonEncode({'nombre': nombre}),
        )
        .timeout(_timeout);
    if (response.statusCode == 201) {
      return CategoriaIncidente.fromMap(
          _decodeJson(response) as Map<String, dynamic>);
    }
    throw Exception('Error al crear categoría');
  }

  Future<List<Reporte>> getReportesDelUsuario(String userId) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/reportes/usuario/$userId'),
          headers: _headers,
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      final list = _decodeJson(response) as List<dynamic>;
      return list
          .map((e) => Reporte.fromMap(e as Map<String, dynamic>))
          .toList();
    }
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
    final response = await http
        .post(
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
        )
        .timeout(_timeout);
    if (response.statusCode == 201) {
      return Reporte.fromMap(_decodeJson(response) as Map<String, dynamic>);
    }
    final data = _decodeJson(response) as Map<String, dynamic>;
    throw Exception(
        data['detail'] ?? data['error'] ?? 'Error al crear el reporte (${response.statusCode})');
  }

  // ── Notificaciones ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNotificaciones(String userId) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/notificaciones/$userId'),
          headers: _headers,
        )
        .timeout(_timeout);
    if (response.statusCode == 200) {
      return (_decodeJson(response) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    if (response.statusCode == 404) return [];
    throw Exception('Error al obtener notificaciones');
  }

  Future<void> marcarNotificacionLeida(String notificacionId) async {
    await http
        .patch(
          Uri.parse('$baseUrl/notificaciones/$notificacionId/leer'),
          headers: _headers,
        )
        .timeout(_timeout);
  }
}
