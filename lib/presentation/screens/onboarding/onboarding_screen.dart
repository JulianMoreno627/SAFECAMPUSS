import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.shield_rounded,
      title: 'Mantente Seguro',
      description:
          'Conoce en tiempo real las zonas de riesgo dentro y fuera de tu campus universitario.',
      highlight: 'zonas de riesgo',
      gradientColors: [const Color(0xFF0A0E21), const Color(0xFF0D2137)],
      accentColor: const Color(0xFF00BCD4),
      particles: [Icons.location_on, Icons.warning_rounded, Icons.visibility],
    ),
    OnboardingData(
      icon: Icons.map_rounded,
      title: 'Reporta Incidentes',
      description:
          'Ayuda a tu comunidad reportando situaciones peligrosas al instante con foto y ubicación.',
      highlight: 'reportando',
      gradientColors: [const Color(0xFF0A0E21), const Color(0xFF0D3724)],
      accentColor: const Color(0xFF4CAF50),
      particles: [Icons.camera_alt, Icons.send_rounded, Icons.people_rounded],
    ),
    OnboardingData(
      icon: Icons.psychology_rounded,
      title: 'IA que te Protege',
      description:
          'Nuestra inteligencia artificial predice rutas seguras y detecta patrones de riesgo por ti.',
      highlight: 'predice rutas seguras',
      gradientColors: [const Color(0xFF0A0E21), const Color(0xFF1A1037)],
      accentColor: const Color(0xFF00E5FF),
      particles: [
        Icons.route_rounded,
        Icons.analytics_rounded,
        Icons.notifications_active
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _skip() => context.go('/login');

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) =>
                _OnboardingPage(data: _pages[index]),
          ),

          // Botón Skip
          Positioned(
            top: 50,
            right: 20,
            child: _currentPage < _pages.length - 1
                ? TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Saltar',
                      style: TextStyle(
                        color: _pages[_currentPage].accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 50),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].accentColor
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: _pages[_currentPage]
                            .accentColor
                            .withValues(alpha: 0.5),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Siguiente'
                            : '¡Comenzar!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Página individual ────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Ícono animado con partículas
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: _AnimatedIcon(data: data),
              ),

              const SizedBox(height: 48),

              // Título
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Descripción
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildDescription(
                  data.description,
                  data.highlight,
                  data.accentColor,
                ),
              ),

              const SizedBox(height: 20),

              // Línea decorativa
              FadeIn(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: data.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(String text, String highlight, Color accentColor) {
    final parts = text.split(highlight);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          height: 1.6,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: highlight,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}

// ─── Ícono animado con partículas orbitando ───────────────────────────────────

class _AnimatedIcon extends StatefulWidget {
  final OnboardingData data;
  const _AnimatedIcon({required this.data});

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _orbitAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _orbitAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _orbitController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _orbitAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Círculo exterior pulsante
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.data.accentColor.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Círculo medio
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.data.accentColor.withValues(alpha: 0.08),
                  border: Border.all(
                    color: widget.data.accentColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
              ),

              // Ícono central
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.data.accentColor.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.accentColor.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.data.icon,
                    size: 60,
                    color: widget.data.accentColor,
                  ),
                ),
              ),

              // Partículas orbitando
              ...List.generate(widget.data.particles.length, (index) {
                final angle = _orbitAnimation.value +
                    (index * 2 * 3.14159 / widget.data.particles.length);
                const radius = 115.0;
                return Positioned(
                  left: 140 + radius * _cos(angle) - 16,
                  top: 140 + radius * _sin(angle) - 16,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.data.accentColor.withValues(alpha: 0.2),
                      border: Border.all(
                        color: widget.data.accentColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.data.particles[index],
                      size: 16,
                      color: widget.data.accentColor,
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  double _cos(double angle) {
    return (angle == 0)
        ? 1.0
        : (1.0 - 2.0 * ((angle / (2 * 3.14159)) % 1.0)) *
            (angle < 3.14159 ? 1 : -1);
  }

  double _sin(double angle) {
    return _cos(angle - 3.14159 / 2);
  }
}

// ─── Modelo ──────────────────────────────────────────────────────────────────

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final String highlight;
  final List<Color> gradientColors;
  final Color accentColor;
  final List<IconData> particles;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.highlight,
    required this.gradientColors,
    required this.accentColor,
    required this.particles,
  });
}
