import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../models/reporte.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  final Logger _logger = Logger();
  GenerativeModel? _model;

  bool get isReady => _model != null;

  void init() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty && apiKey != 'pending') {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1000,
        ),
      );
    }
  }

  // ── 1. Clasificar reporte automáticamente ─────────────────────────────────

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
    if (_model == null) return fallback;

    final prompt = '''
Eres un sistema de seguridad universitaria. Analiza este reporte de incidente y responde SOLO en JSON sin explicaciones:

Tipo: $tipo
Descripción: $descripcion

Responde exactamente en este formato JSON:
{
  "nivel_riesgo": "bajo|medio|alto|critico",
  "confianza": 0.95,
  "categoria": "robo|acoso|iluminacion|sospechoso|pelea|vandalismo|otro",
  "alertar_zona": true,
  "radio_alerta_metros": 300,
  "recomendacion": "texto corto de recomendación"
}
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return _parseJson(response.text ?? '') ?? fallback;
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
    if (_model == null) return fallback;

    final reportesStr = reportesCercanos.isEmpty
        ? 'Sin reportes recientes'
        : reportesCercanos
            .take(5)
            .map((r) =>
                '- ${r.tipo.label}: ${r.descripcion} (${r.nivelUrgencia.label})')
            .join('\n');

    final prompt = '''
Eres un sistema de seguridad universitaria. Analiza la seguridad de esta ruta y responde SOLO en JSON:

Origen: $origen
Destino: $destino
Hora actual: $hora
Reportes recientes en la zona:
$reportesStr

Responde exactamente en este formato JSON:
{
  "score_seguridad": 75,
  "nivel_riesgo": "bajo|medio|alto|critico",
  "recomendacion": "texto de recomendación",
  "ruta_alternativa": true,
  "motivo": "explicación breve",
  "tips": ["tip 1", "tip 2", "tip 3"]
}
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return _parseJson(response.text ?? '') ?? fallback;
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
    if (_model == null) return fallback;

    final prompt = '''
Eres un sistema de seguridad universitaria. Analiza el perfil de riesgo de este estudiante y responde SOLO en JSON:

Ruta más frecuente: $rutaFrecuente
Horario habitual: $horarioHabitual
Zonas visitadas: ${zonasVisitadas.join(', ')}

Responde exactamente en este formato JSON:
{
  "nivel_exposicion": "bajo|moderado|alto",
  "zona_mas_riesgosa": "nombre de zona",
  "dia_vulnerable": "día de la semana",
  "score_riesgo": 45,
  "recomendacion_principal": "texto",
  "acciones": ["acción 1", "acción 2", "acción 3"]
}
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return _parseJson(response.text ?? '') ?? fallback;
    } catch (e) {
      _logger.e('GeminiService.analizarRiesgoPersonal error: $e');
      return fallback;
    }
  }

  // ── 4. Chat de seguridad (respuesta única, no multi-turn) ────────────────

  Future<String> chatSeguridad({
    required String pregunta,
    required String zonaActual,
    required String nivelRiesgo,
  }) async {
    if (_model == null) {
      return 'Error al conectar con la IA. Verifica tu conexión.';
    }

    final prompt = '''
Eres SafeBot, un asistente de seguridad universitaria.
El estudiante está en: $zonaActual
Nivel de riesgo actual: $nivelRiesgo

Responde de forma concisa y útil a esta pregunta de seguridad:
$pregunta

Máximo 3 oraciones. Sé directo y práctico. Responde en español.
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim() ??
          'No pude procesar tu consulta. Intenta de nuevo.';
    } catch (e) {
      _logger.e('GeminiService.chatSeguridad error: $e');
      return 'Error al conectar con la IA. Verifica tu conexión.';
    }
  }

  // ── 5. Tips de seguridad personalizados ──────────────────────────────────

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
    if (_model == null) return fallback;

    final prompt = '''
Eres un sistema de seguridad universitaria. Genera tips de seguridad personalizados y responde SOLO en JSON:

Zona: $zona
Hora: $hora
Nivel de riesgo: $nivelRiesgo

Responde exactamente en este formato JSON:
{
  "tips": ["tip 1", "tip 2", "tip 3", "tip 4", "tip 5"]
}
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final data = _parseJson(response.text ?? '');
      if (data == null) return fallback;
      final tips = data['tips'];
      if (tips is List) return tips.map((t) => t.toString()).toList();
      return fallback;
    } catch (e) {
      _logger.e('GeminiService.generarTipsSeguridad error: $e');
      return fallback;
    }
  }

  // ── Helper: parse JSON with jsonDecode first, manual fallback ────────────

  Map<String, dynamic>? _parseJson(String raw) {
    if (raw.isEmpty) return null;

    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();

    // Intento 1: jsonDecode estándar
    try {
      final decoded = jsonDecode(clean);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}

    // Intento 2: extraer el bloque {} y reintentar
    try {
      final start = clean.indexOf('{');
      final end = clean.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final block = clean.substring(start, end + 1);
        final decoded = jsonDecode(block);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}

    return null;
  }
}

final geminiService = GeminiService();
