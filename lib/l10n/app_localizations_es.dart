// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SafeCampus AI';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Inicia sesión en tu cuenta';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get createReport => 'Crear reporte';

  @override
  String get mapTitle => 'Mapa de seguridad';

  @override
  String get riskLevel => 'Nivel de riesgo';

  @override
  String get lowRisk => 'Bajo';

  @override
  String get mediumRisk => 'Medio';

  @override
  String get highRisk => 'Alto';

  @override
  String get criticalRisk => 'Crítico';

  @override
  String get onboard1Title => 'Mantente Seguro';

  @override
  String get onboard1Desc =>
      'Conoce las zonas de riesgo en tiempo real dentro y fuera del campus';

  @override
  String get onboard2Title => 'Reporta Incidentes';

  @override
  String get onboard2Desc =>
      'Ayuda a tu comunidad reportando situaciones peligrosas al instante';

  @override
  String get onboard3Title => 'IA que te Protege';

  @override
  String get onboard3Desc =>
      'Nuestra inteligencia artificial predice rutas seguras para ti';

  @override
  String get reportIncident => 'Reportar Incidente';

  @override
  String get selectType => 'Selecciona el tipo';

  @override
  String get description => 'Descripción';

  @override
  String get witnesses => 'Testigos (opcional)';

  @override
  String get urgencyLevel => 'Nivel de urgencia';

  @override
  String get location => 'Ubicación';

  @override
  String get addPhoto => 'Agregar foto';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get submitReport => 'Enviar reporte';

  @override
  String get obtainingLocation => 'Obteniendo ubicación...';

  @override
  String get reportSuccess => 'Reporte enviado con éxito';

  @override
  String get errorGeneric => 'Algo salió mal';

  @override
  String get errorLocation => 'No se pudo obtener la ubicación';

  @override
  String get low => 'Bajo';

  @override
  String get medium => 'Medio';

  @override
  String get high => 'Alto';

  @override
  String get critical => 'Crítico';
}
