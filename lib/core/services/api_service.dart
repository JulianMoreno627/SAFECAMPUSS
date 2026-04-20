import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // En desarrollo local usamos 10.0.2.2 para el emulador de Android
  // o localhost para iOS/Web. En producción será la URL de Render.
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000/api';

  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // --- AUTH ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _token = data['token'];
      return data;
    } else {
      throw Exception(data['error'] ?? 'Error al iniciar sesión');
    }
  }

  Future<Map<String, dynamic>> register({
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

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      _token = data['token'];
      return data;
    } else {
      throw Exception(data['error'] ?? 'Error al registrar usuario');
    }
  }

  // --- REPORTES ---

  Future<List<dynamic>> getReportesCercanos(double lat, double lng, {double radio = 5000}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reportes/cercanos?lat=$lat&lng=$lng&radio=$radio'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener reportes');
    }
  }

  Future<Map<String, dynamic>> crearReporte({
    required String tipo,
    required String descripcion,
    required String nivelUrgencia,
    required double lat,
    required double lng,
    required String userId,
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
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear el reporte');
    }
  }
}
