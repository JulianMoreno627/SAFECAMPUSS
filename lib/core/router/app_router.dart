import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/reportes/lista_reportes_screen.dart';
import '../../presentation/screens/sos/sos_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/perfil/perfil_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash',     builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login',      builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register',   builder: (c, s) => const RegisterScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/map',       builder: (c, s) => const MapScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/reportes',  builder: (c, s) => const ListaReportesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/sos',       builder: (c, s) => const SosScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/perfil',    builder: (c, s) => const PerfilScreen()),
          ]),
        ],
      ),
    ],
  );
}
