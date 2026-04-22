import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final _logger = Logger();
  GenerativeModel? _model;

  bool get isReady => _model != null;

  void init() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty && apiKey != 'pending') {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    }
  }

  // ── Chat multi-turn ───────────────────────────────────────────────────────

  ChatSession startChatSession({List<dynamic>? reportesCercanos}) {
    final resumen = (reportesCercanos != null && reportesCercanos.isNotEmpty)
        ? reportesCercanos
            .take(6)
            .map((r) => '${r['tipo']} (${r['nivel_urgencia']})')
            .join(', ')
        : 'ninguno por el momento';

    return _model!.startChat(history: [
      Content('user', [
        TextPart(
          'Eres SafeBot, el asistente inteligente de seguridad de SafeCampus AI. '
          'Ayudas a estudiantes universitarios con consejos de seguridad, '
          'información sobre incidentes en el campus y recomendaciones. '
          'Sé amable, empático y conciso. Responde siempre en español. '
          'Contexto actual: reportes cercanos detectados: $resumen.',
        ),
      ]),
      Content('model', [
        TextPart(
          '¡Hola! Soy SafeBot 🤖, tu asistente de seguridad en el campus. '
          'Estoy al tanto de los incidentes cercanos y listo para ayudarte. '
          '¿En qué puedo asistirte hoy?',
        ),
      ]),
    ]);
  }

  // ── Clasificación + sugerencia de urgencia ────────────────────────────────

  Future<Map<String, String>?> classifyAndSuggest(String descripcion) async {
    if (_model == null || descripcion.trim().length < 15) return null;

    final prompt = '''
Analiza este incidente de seguridad universitaria y responde ÚNICAMENTE con JSON válido (sin markdown, sin texto extra):

Descripción: "$descripcion"

{
  "tipo": "Robo|Acoso|Persona sospechosa|Iluminación|Pelea|Vandalismo|Accidente|Otro",
  "urgencia": "bajo|medio|alto|critico",
  "razon": "máximo 8 palabras explicando la clasificación"
}
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final raw = response.text?.trim() ?? '';
      final clean = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
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

  // ── Clasificación simple (tipo solamente) ─────────────────────────────────

  Future<String?> classifyReport(String description) async {
    if (_model == null) return null;

    const categorias = [
      'Robo', 'Acoso', 'Persona sospechosa', 'Iluminación',
      'Pelea', 'Vandalismo', 'Accidente', 'Otro',
    ];

    final prompt = '''
Clasifica este incidente de seguridad universitaria en UNA de estas categorías:
${categorias.join(', ')}

Descripción: "$description"

Responde solo con el nombre de la categoría.
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      _logger.e('classifyReport error: $e');
      return null;
    }
  }

  // ── Análisis de tendencias del campus ─────────────────────────────────────

  Future<String?> analyzeTrends(List<dynamic> reports) async {
    if (_model == null || reports.isEmpty) return null;

    final tipos = <String, int>{};
    final urgencias = <String, int>{};
    for (final r in reports) {
      final tipo = r['tipo']?.toString() ?? 'Otro';
      final urg = r['nivel_urgencia']?.toString() ?? 'bajo';
      tipos[tipo] = (tipos[tipo] ?? 0) + 1;
      urgencias[urg] = (urgencias[urg] ?? 0) + 1;
    }

    final tiposStr = tipos.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    final urgStr = urgencias.entries.map((e) => '${e.key}: ${e.value}').join(', ');

    final prompt = '''
Analiza estos incidentes de seguridad en un campus universitario y escribe un análisis breve (máximo 3 oraciones) en español con tendencias detectadas y una recomendación práctica para los estudiantes. Sé directo y útil.

Tipos de incidente: $tiposStr
Niveles de urgencia: $urgStr
Total de reportes: ${reports.length}
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      _logger.e('analyzeTrends error: $e');
      return null;
    }
  }

  // ── Análisis de riesgo (nivel + recomendación) ────────────────────────────

  Future<Map<String, dynamic>?> analyzeRisk(List<dynamic> nearbyReports) async {
    if (_model == null || nearbyReports.isEmpty) return null;

    final resumen = nearbyReports
        .take(8)
        .map((r) => '- ${r['tipo']}, urgencia: ${r['nivel_urgencia']}')
        .join('\n');

    final prompt = '''
Analiza estos incidentes cercanos y responde ÚNICAMENTE con JSON válido (sin markdown):

$resumen

{
  "nivel": "bajo|medio|alto|critico",
  "recomendacion": "consejo breve de máximo 15 palabras"
}
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final raw = response.text?.trim() ?? '';
      final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();
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

  // ── Consejo de emergencia SOS ─────────────────────────────────────────────

  Future<String?> getEmergencyAdvice(String tipoEmergencia) async {
    if (_model == null) return null;

    final prompt = '''
Un estudiante universitario está viviendo una emergencia de tipo: "$tipoEmergencia".
Escribe 3 pasos de acción inmediata, numerados, claros y directos. Máximo 60 palabras en total. En español.
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text?.trim();
    } catch (e) {
      _logger.e('getEmergencyAdvice error: $e');
      return null;
    }
  }
}

final aiService = AiService();
