import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final _logger = Logger();
  GenerativeModel? _model;

  void init() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey != 'pending') {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    }
  }

  Future<String?> classifyReport(String description) async {
    if (_model == null) return null;

    final prompt = '''
    Analiza la siguiente descripción de un incidente de seguridad en un campus universitario y clasifícalo en UNA de estas categorías:
    - Robo
    - Acoso
    - Persona sospechosa
    - Iluminación
    - Pelea
    - Vandalismo
    - Accidente
    - Otro

    Descripción: "$description"

    Responde solo con el nombre de la categoría.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text?.trim();
    } catch (e) {
      _logger.e('Error en clasificación IA: $e');
      return null;
    }
  }

  bool get isReady => _model != null;

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
          'Tu función es ayudar a estudiantes universitarios con consejos de seguridad, '
          'información sobre incidentes en el campus y recomendaciones para mantenerse seguros. '
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

  Future<Map<String, dynamic>?> analyzeRisk(List<Map<String, dynamic>> nearbyReports) async {
    if (_model == null) return null;

    final reportsSummary = nearbyReports.map((r) => 
      '- Tipo: ${r['tipo']}, Urgencia: ${r['nivel_urgencia']}, Distancia: ${r['distancia']}m'
    ).join('\n');

    final prompt = '''
    Analiza estos incidentes cercanos y determina el nivel de riesgo (bajo, medio, alto, critico) y una breve recomendación de seguridad.
    
    Incidentes:
    $reportsSummary

    Responde en formato JSON:
    {
      "nivel": "bajo/medio/alto/critico",
      "recomendacion": "mensaje corto"
    }
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      // Aquí podrías parsear el JSON de la respuesta
      return {
        'nivel': 'medio', // Placeholder hasta implementar parseo robusto
        'recomendacion': response.text ?? 'Mantente alerta en esta zona.'
      };
    } catch (e) {
      return null;
    }
  }
}

final aiService = AiService();
