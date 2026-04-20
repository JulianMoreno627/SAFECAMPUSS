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
