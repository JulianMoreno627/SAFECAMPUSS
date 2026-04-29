import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/reporte.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final _logger = Logger();
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

  String? _extractJson(String raw) {
    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return clean.substring(start, end + 1);
  }

  // ── Chat multi-turn ───────────────────────────────────────────────────────

  List<Map<String, String>> buildChatHistory({List<Reporte>? reportesCercanos}) {
    final resumen = (reportesCercanos != null && reportesCercanos.isNotEmpty)
        ? reportesCercanos
            .take(6)
            .map((r) => '${r.tipo.label} (${r.nivelUrgencia.label})')
            .join(', ')
        : 'ninguno por el momento';

    return [
      {
        'role': 'system',
        'content':
            'Eres SafeBot, el asistente inteligente de seguridad de SafeCampus AI. '
            'Ayudas a estudiantes universitarios con consejos de seguridad, '
            'información sobre incidentes en el campus y recomendaciones. '
            'Sé amable, empático y conciso. Responde siempre en español. '
            'Contexto actual: reportes cercanos detectados: $resumen.',
      },
      {
        'role': 'assistant',
        'content':
            '¡Hola! Soy SafeBot, tu asistente de seguridad en el campus. '
            'Estoy al tanto de los incidentes cercanos y listo para ayudarte. '
            '¿En qué puedo asistirte hoy?',
      },
    ];
  }

  Future<String> sendChatMessage(
    List<Map<String, String>> history,
    String message,
  ) async {
    if (_apiKey == null) throw StateError('AiService no inicializado');
    final messages = [...history, {'role': 'user', 'content': message}];
    return await _complete(messages, maxTokens: 500) ??
        'No pude procesar tu consulta. Intenta de nuevo.';
  }

  // ── Clasificación + sugerencia ────────────────────────────────────────────

  Future<Map<String, String>?> classifyAndSuggest(String descripcion) async {
    if (_apiKey == null || descripcion.trim().length < 15) return null;
    try {
      final text = await _complete([
        {
          'role': 'system',
          'content':
              'Clasifica incidentes de seguridad universitaria. Responde ÚNICAMENTE con JSON válido sin markdown.',
        },
        {
          'role': 'user',
          'content':
              'Incidente: "$descripcion"\n\n'
              '{"tipo":"Robo|Acoso|Persona sospechosa|Iluminación|Pelea|Vandalismo|Accidente|Otro","urgencia":"bajo|medio|alto|critico","razon":"máximo 8 palabras"}',
        },
      ], maxTokens: 120, temperature: 0.2);
      if (text == null) return null;
      final clean = _extractJson(text);
      if (clean == null) return null;
      final data = jsonDecode(clean) as Map<String, dynamic>;
      return {
        'tipo': data['tipo']?.toString() ?? 'Otro',
        'urgencia': data['urgencia']?.toString() ?? 'medio',
        'razon': data['razon']?.toString() ?? '',
      };
    } catch (e) {
      _logger.e('classifyAndSuggest error: $e');
      return null;
    }
  }

  // ── Clasificación simple ──────────────────────────────────────────────────

  Future<String?> classifyReport(String description) async {
    if (_apiKey == null) return null;
    try {
      return await _complete([
        {
          'role': 'system',
          'content':
              'Clasifica el incidente en UNA categoría: Robo, Acoso, Persona sospechosa, Iluminación, Pelea, Vandalismo, Accidente, Otro. Responde solo con el nombre de la categoría.',
        },
        {'role': 'user', 'content': description},
      ], maxTokens: 15, temperature: 0.1);
    } catch (e) {
      _logger.e('classifyReport error: $e');
      return null;
    }
  }

  // ── Análisis de tendencias ────────────────────────────────────────────────

  Future<String?> analyzeTrends(List<Reporte> reports) async {
    if (_apiKey == null || reports.isEmpty) return null;
    final tipos = <String, int>{};
    final urgencias = <String, int>{};
    for (final r in reports) {
      tipos[r.tipo.label] = (tipos[r.tipo.label] ?? 0) + 1;
      urgencias[r.nivelUrgencia.label] = (urgencias[r.nivelUrgencia.label] ?? 0) + 1;
    }
    final tiposStr = tipos.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    final urgStr = urgencias.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    try {
      return await _complete([
        {
          'role': 'system',
          'content':
              'Eres un analista de seguridad universitaria. Responde en español, directo y útil.',
        },
        {
          'role': 'user',
          'content':
              'Analiza estos incidentes del campus (máximo 3 oraciones, incluye una recomendación práctica).\n\nTipos: $tiposStr\nUrgencias: $urgStr\nTotal: ${reports.length}',
        },
      ], maxTokens: 200);
    } catch (e) {
      _logger.e('analyzeTrends error: $e');
      return null;
    }
  }

  // ── Análisis de riesgo ────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> analyzeRisk(List<Reporte> nearbyReports) async {
    if (_apiKey == null || nearbyReports.isEmpty) return null;
    final resumen = nearbyReports
        .take(8)
        .map((r) => '- ${r.tipo.label}, urgencia: ${r.nivelUrgencia.label}')
        .join('\n');
    try {
      final text = await _complete([
        {
          'role': 'system',
          'content':
              'Analiza incidentes de seguridad. Responde ÚNICAMENTE con JSON válido sin markdown.',
        },
        {
          'role': 'user',
          'content':
              'Incidentes:\n$resumen\n\n'
              '{"nivel":"bajo|medio|alto|critico","recomendacion":"consejo breve de máximo 15 palabras"}',
        },
      ], maxTokens: 80, temperature: 0.2);
      if (text == null) return null;
      final clean = _extractJson(text);
      if (clean == null) return null;
      final data = jsonDecode(clean) as Map<String, dynamic>;
      return {
        'nivel': data['nivel']?.toString() ?? 'medio',
        'recomendacion': data['recomendacion']?.toString() ?? 'Mantente alerta.',
      };
    } catch (e) {
      _logger.e('analyzeRisk error: $e');
      return null;
    }
  }

  // ── Consejo SOS ───────────────────────────────────────────────────────────

  Future<String?> getEmergencyAdvice(String tipoEmergencia) async {
    if (_apiKey == null) return null;
    try {
      return await _complete([
        {
          'role': 'system',
          'content':
              'Eres un consejero de emergencias universitarias. Responde en español con pasos claros y directos.',
        },
        {
          'role': 'user',
          'content':
              'Emergencia: "$tipoEmergencia". Escribe 3 pasos de acción inmediata, numerados. Máximo 60 palabras.',
        },
      ], maxTokens: 150);
    } catch (e) {
      _logger.e('getEmergencyAdvice error: $e');
      return null;
    }
  }
}

final aiService = AiService();
