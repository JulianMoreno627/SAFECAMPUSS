import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar IA
  AiService().init();

  // Inicializar Hive (BD local)
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: SafeCampusApp(),
    ),
  );
}
