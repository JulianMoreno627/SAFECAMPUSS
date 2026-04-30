import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/reportes/lista_reportes_screen.dart';
import '../../presentation/screens/reportes/crear_reporte_screen.dart';
import '../../presentation/screens/sos/sos_screen.dart';
import '../../presentation/screens/sos/contactos_emergencia_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/chat/chat_ia_screen.dart';
import '../../presentation/screens/perfil/perfil_screen.dart';
import '../../presentation/screens/perfil/editar_perfil_screen.dart';
import '../../presentation/screens/notificaciones/notificaciones_screen.dart';
import '../../presentation/screens/configuracion/configuracion_screen.dart';
import '../../presentation/screens/guia/guia_seguridad_screen.dart';
import '../../presentation/screens/reportes/mis_reportes_screen.dart';
import '../../presentation/screens/reportes/detalle_reporte_screen.dart';
import '../../presentation/screens/rutas/ruta_segura_screen.dart';
import '../../presentation/screens/analisis/analisis_riesgo_screen.dart';
import '../../presentation/screens/analisis/estadisticas_screen.dart';
import '../../presentation/screens/sos/historial_sos_screen.dart';
import '../../presentation/screens/map/detalle_zona_screen.dart';
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/map',
              builder: (c, s) => const MapScreen(),
              routes: [
                GoRoute(
                  path: 'crear-reporte',
                  builder: (c, s) => const CrearReporteScreen(),
                ),
                GoRoute(
                  path: 'ruta-segura',
                  builder: (c, s) => const RutaSeguraScreen(),
                ),
                GoRoute(
                  path: 'detalle-zona',
                  builder: (c, s) {
                    final args = s.extra as Map<String, dynamic>?;
                    return DetalleZonaScreen(
                      reportes: args?['reportes'] ?? [],
                      nombreZona: args?['nombreZona'] ?? 'Zona seleccionada',
                    );
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/reportes',
                builder: (c, s) => const ListaReportesScreen(),
                routes: [
                  GoRoute(
                    path: 'detalle',
                    builder: (c, s) {
                      final extra = s.extra;
                      if (extra == null) return const ListaReportesScreen();
                      return DetalleReporteScreen(reporte: extra as dynamic);
                    },
                  ),
                ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/sos',
              builder: (c, s) => const SosScreen(),
              routes: [
                GoRoute(
                  path: 'contactos-emergencia',
                  builder: (c, s) => const ContactosEmergenciaScreen(),
                ),
                GoRoute(
                  path: 'historial-sos',
                  builder: (c, s) => const HistorialSosScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (c, s) => const DashboardScreen(),
              routes: [
                GoRoute(
                  path: 'chat-ia',
                  builder: (c, s) => const ChatIaScreen(),
                ),
                GoRoute(
                  path: 'analisis-riesgo',
                  builder: (c, s) => const AnalisisRiesgoScreen(),
                ),
                GoRoute(
                  path: 'estadisticas',
                  builder: (c, s) => const EstadisticasScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/perfil',
              builder: (c, s) => const PerfilScreen(),
              routes: [
                GoRoute(
                  path: 'editar-perfil',
                  builder: (c, s) => const EditarPerfilScreen(),
                ),
                GoRoute(
                  path: 'notificaciones',
                  builder: (c, s) => const NotificacionesScreen(),
                ),
                GoRoute(
                  path: 'configuracion',
                  builder: (c, s) => const ConfiguracionScreen(),
                ),
                GoRoute(
                  path: 'guia-seguridad',
                  builder: (c, s) => const GuiaSeguridadScreen(),
                ),
                GoRoute(
                  path: 'mis-reportes',
                  builder: (c, s) => const MisReportesScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}
