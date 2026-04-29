import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/ai_service.dart';
import 'core/services/gemini_service.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Iniciar con algo básico para evitar pantalla blanca
  runApp(const MaterialApp(
    home: Scaffold(body: Center(child: CircularProgressIndicator())),
  ));

  try {
    // 2. Cargar .env de forma segura
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Advertencia: No se pudo cargar .env: $e");
    }

    // 3. Inicializar Hive
    await Hive.initFlutter();
    await Hive.openBox('settings');

    // 4. Inicializar IA
    AiService().init();
    GeminiService().init();

    // 5. Arrancar la app real
    // Crear el ProviderContainer para acceder a providers fuera del widget tree si es necesario
    // Pero es mejor hacerlo dentro de un ProviderScope y usar un Consumer o ref.read en el primer widget.
    // Sin embargo, para inicializar el authProvider, podemos usar un truco en el primer widget o aquí.

    final container = ProviderContainer();
    await container.read(authProvider.notifier).init();

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const SafeCampusApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint("Error fatal: $e");
    debugPrint(stack.toString());
    runApp(MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text("Error al iniciar: $e\n\nStack: $stack")),
        ),
      ),
    ));
  }
}
