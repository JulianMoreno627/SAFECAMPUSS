import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/reporte.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  final Logger _logger = Logger();
  String? _apiKey;
  static const _model = 'llama-3.3-70b-versatile';
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  bool get isReady => _apiKey != null;

  void init() {
    final key = dotenv.maybeGet('GROQ_API_KEY');
    if (key != null && key.isNotEmpty && key != 'pending') {
      _apiKey = key;
    }
  }

  // ── HTTP helper ───────────────────────────────────────────────────────────

  Future<String?> _complete(
    List<Map<String, String>> messages, {
    int maxTokens = 500,
    double temperature = 0.7,
  }) async {
    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['choices'] as List).first['message']['content'] as String?;
    }
    if (res.statusCode == 429) throw Exception('RESOURCE_EXHAUSTED: ${res.body}');
    throw Exception('${res.statusCode}: ${res.body}');
  }

  Map<String, dynamic>? _parseJson(String raw) {
    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    try {
      final decoded = jsonDecode(clean);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    try {
      final start = clean.indexOf('{');
      final end = clean.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final decoded = jsonDecode(clean.substring(start, end + 1));
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}
    return null;
  }

  // ── 1. Clasificar reporte ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> clasificarReporte({
    required String descripcion,
    required String tipo,
  }) async {
    const fallback = {
      'nivel_riesgo': 'medio',
      'confianza': 0.5,
      'categoria': 'otro',
      'alertar_zona': true,
      'radio_alerta_metros': 200,
      'recomendacion': 'Mantente alerta en esta zona',
    };
    if (_apiKey == null) return fallback;

    try {
      final text = await _complete([
        {
          'role': 'system',
          'content':
              'Sistema de seguridad universitaria. Responde ÚNICAMENTE con JSON válido sin markdown.',
        },
        {
          'role': 'user',
          'content':
              'Tipo: $tipo\nDescripción: $descripcion\n\n'
              '{"nivel_riesgo":"bajo|medio|alto|critico","confianza":0.95,"categoria":"robo|acoso|iluminacion|sospechoso|pelea|vandalismo|otro","alertar_zona":true,"radio_alerta_metros":300,"recomendacion":"texto corto"}',
        },
      ], maxTokens: 150, temperature: 0.2);
      return _parseJson(text ?? '') ?? fallback;
    } catch (e) {
      _logger.e('GeminiService.clasificarReporte error: $e');
      return {...fallback, 'categoria': tipo.toLowerCase()};
    }
  }

  // ── 2. Recomendar ruta segura ─────────────────────────────────────────────

  Future<Map<String, dynamic>> recomendarRuta({
    required String origen,
    required String destino,
    required String hora,
    required List<Reporte> reportesCercanos,
  }) async {
    const fallback = {
      'score_seguridad': 60,
      'nivel_riesgo': 'medio',
      'recomendacion': 'Toma precauciones en esta ruta',
      'ruta_alternativa': false,
      'motivo': 'Sin datos suficientes',
      'tips': ['Mantente en zonas iluminadas', 'Comparte tu ubicación'],
    };
    if (_apiKey == null) return fallback;

    final reportesStr = reportesCercanos.isEmpty
        ? 'Sin reportes recientes'
        : reportesCercanos
            .take(5)
            .map((r) => '- ${r.tipo.label}: ${r.descripcion} (${r.nivelUrgencia.label})')
            .join('\n');

    try {
      final text = await _complete([
        {
          'role': 'system',
          'content':
              'Sistema de seguridad universitaria. Responde ÚNICAMENTE con JSON válido sin markdown.',
        },
        {
          'role': 'user',
          'content':
              'Origen: $origen\nDestino: $destino\nHora: $hora\nReportes:\n$reportesStr\n\n'
              '{"score_seguridad":75,"nivel_riesgo":"bajo|medio|alto|critico","recomendacion":"texto","ruta_alternativa":true,"motivo":"breve","tips":["tip1","tip2","tip3"]}',
        },
      ], maxTokens: 200, temperature: 0.3);
      return _parseJson(text ?? '') ?? fallback;
    } catch (e) {
      _logger.e('GeminiService.recomendarRuta error: $e');
      return fallback;
    }
  }

  // ── 3. Análisis de riesgo personal ───────────────────────────────────────

  Future<Map<String, dynamic>> analizarRiesgoPersonal({
    required String rutaFrecuente,
    required String horarioHabitual,
    required List<String> zonasVisitadas,
  }) async {
    const fallback = {
      'nivel_exposicion': 'moderado',
      'zona_mas_riesgosa': 'Parqueadero',
      'dia_vulnerable': 'Viernes',
      'score_riesgo': 50,
      'recomendacion_principal': 'Evita zonas oscuras en horario nocturno',
      'acciones': [
        'Comparte tu ubicación con un contacto',
        'Activa el modo acompañamiento',
        'Evita salir solo después de las 9 PM',
      ],
    };
    if (_apiKey == null) return fallback;

    try {
      final text = await _complete([
        {
          'role': 'system',
          'content':
              'Sistema de seguridad universitaria. Responde ÚNICAMENTE con JSON válido sin markdown.',
        },
        {
          'role': 'user',
          'content':
              'Ruta frecuente: $rutaFrecuente\nHorario: $horarioHabitual\nZonas: ${zonasVisitadas.join(", ")}\n\n'
              '{"nivel_exposicion":"bajo|moderado|alto","zona_mas_riesgosa":"nombre","dia_vulnerable":"día","score_riesgo":45,"recomendacion_principal":"texto","acciones":["acción1","acción2","acción3"]}',
        },
      ], maxTokens: 200, temperature: 0.3);
      return _parseJson(text ?? '') ?? fallback;
    } catch (e) {
      _logger.e('GeminiService.analizarRiesgoPersonal error: $e');
      return fallback;
    }
  }

  // ── 4. Chat de seguridad ──────────────────────────────────────────────────

  Future<String> chatSeguridad({
    required String pregunta,
    required String zonaActual,
    required String nivelRiesgo,
  }) async {
    if (_apiKey == null) return 'Error al conectar con la IA. Verifica tu conexión.';
    try {
      final text = await _complete([
        {
          'role': 'system',
          'content':
              'Eres SafeBot, asistente de seguridad universitaria. '
              'Zona actual: $zonaActual. Nivel de riesgo: $nivelRiesgo. '
              'Responde de forma concisa (máximo 3 oraciones), directo y práctico. En español.',
        },
        {'role': 'user', 'content': pregunta},
      ], maxTokens: 150);
      return text?.trim() ?? 'No pude procesar tu consulta. Intenta de nuevo.';
    } catch (e) {
      _logger.e('GeminiService.chatSeguridad error: $e');
      return 'Error al conectar con la IA. Verifica tu conexión.';
    }
  }

  // ── 5. Tips de seguridad ──────────────────────────────────────────────────

  Future<List<String>> generarTipsSeguridad({
    required String zona,
    required String hora,
    required String nivelRiesgo,
  }) async {
    const fallback = [
      'Mantente en zonas bien iluminadas',
      'Comparte tu ubicación con alguien de confianza',
      'Ten a mano el número de seguridad del campus',
      'Evita usar audífonos en ambos oídos',
      'Camina por el centro del andén',
    ];
    if (_apiKey == null) return fallback;

    try {
      final text = await _complete([
        {
          'role': 'system',
          'content':
              'Sistema de seguridad universitaria. Responde ÚNICAMENTE con JSON válido sin markdown.',
        },
        {
          'role': 'user',
          'content':
              'Zona: $zona\nHora: $hora\nNivel de riesgo: $nivelRiesgo\n\n'
              '{"tips":["tip1","tip2","tip3","tip4","tip5"]}',
        },
      ], maxTokens: 150, temperature: 0.5);
      if (text == null) return fallback;
      final data = _parseJson(text);
      if (data == null) return fallback;
      final tips = data['tips'];
      if (tips is List) return tips.map((t) => t.toString()).toList();
      return fallback;
    } catch (e) {
      _logger.e('GeminiService.generarTipsSeguridad error: $e');
      return fallback;
    }
  }
}

final geminiService = GeminiService();
