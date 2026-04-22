import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/providers/auth_provider.dart';

class AnalisisRiesgoScreen extends ConsumerStatefulWidget {
  const AnalisisRiesgoScreen({super.key});

  @override
  ConsumerState<AnalisisRiesgoScreen> createState() =>
      _AnalisisRiesgoScreenState();
}

class _AnalisisRiesgoScreenState extends ConsumerState<AnalisisRiesgoScreen> {
  bool _loading = false;
  Map<String, dynamic>? _resultado;
  bool _analizado = false;

  Future<void> _analizar() async {
    setState(() {
      _loading = true;
      _resultado = null;
    });

    final reportes = ref.read(reportsProvider).reportesCercanos;
    final userId =
        ref.read(authProvider).user?['id']?.toString() ?? '';

    // Derivar parámetros de los reportes del usuario
    final misReportes = reportes
        .where((r) =>
            r['user_id']?.toString() == userId ||
            r['usuario_id']?.toString() == userId)
        .toList();

    final zonas = misReportes
        .map((r) => r['tipo']?.toString() ?? 'Zona desconocida')
        .toSet()
        .take(5)
        .toList();

    final hora = TimeOfDay.now();
    final horario = hora.hour < 12
        ? 'Mañana'
        : hora.hour < 18
            ? 'Tarde'
            : 'Noche';

    final rutaFrecuente = misReportes.isNotEmpty
        ? 'Zona con incidentes de ${misReportes.first['tipo'] ?? 'tipo desconocido'}'
        : 'Campus universitario general';

    final result = await GeminiService().analizarRiesgoPersonal(
      rutaFrecuente: rutaFrecuente,
      horarioHabitual: horario,
      zonasVisitadas: zonas.isEmpty ? ['Campus principal', 'Biblioteca', 'Cafetería'] : zonas,
    );

    if (mounted) {
      setState(() {
        _resultado = result;
        _loading = false;
        _analizado = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    FadeInUp(child: _buildInfoCard()),
                    const SizedBox(height: 20),
                    if (!_analizado && !_loading)
                      FadeIn(child: _buildPlaceholder()),
                    if (_loading)
                      FadeIn(child: _buildLoading()),
                    if (_resultado != null && !_loading)
                      FadeInUp(child: _buildResultado()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Análisis de Riesgo',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('Evaluación personal con IA',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.riskMedium.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.riskMedium.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_search_rounded,
                    color: AppColors.riskMedium, size: 14),
                SizedBox(width: 4),
                Text('Personal',
                    style: TextStyle(
                        color: AppColors.riskMedium,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.secondary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Qué tan expuesto/a estás?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'SafeBot analiza tu historial de incidentes, zonas frecuentadas y horario para calcular tu perfil de riesgo personal.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Placeholder ───────────────────────────────────────────────────────────

  Widget _buildPlaceholder() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.riskMedium.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppColors.riskMedium, size: 44),
              ),
              const SizedBox(height: 16),
              const Text('Analiza tu perfil de riesgo',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'SafeBot evaluará tu exposición a riesgos basándose en los incidentes reportados en tu zona y tu horario habitual.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white54, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _analizar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.riskMedium,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            icon: const Icon(Icons.analytics_rounded, size: 20),
            label: const Text('Analizar mi riesgo personal',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.riskMedium.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 52, height: 52,
            child: CircularProgressIndicator(
                color: AppColors.riskMedium, strokeWidth: 3),
          ),
          const SizedBox(height: 18),
          const Text('SafeBot evaluando tu perfil...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Analizando incidentes cercanos, zonas y horario',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Resultado ─────────────────────────────────────────────────────────────

  Widget _buildResultado() {
    final r = _resultado!;
    final score = (r['score_riesgo'] as num?)?.toInt() ?? 50;
    final nivel = r['nivel_exposicion']?.toString() ?? 'moderado';
    final zona = r['zona_mas_riesgosa']?.toString() ?? 'No identificada';
    final dia = r['dia_vulnerable']?.toString() ?? 'No identificado';
    final recomendacion =
        r['recomendacion_principal']?.toString() ?? '';
    final acciones =
        (r['acciones'] as List?)?.map((a) => a.toString()).toList() ?? [];

    return Column(
      children: [
        // Score principal
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _nivelColor(nivel).withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _RiskGauge(score: score, nivel: nivel),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nivel de Exposición',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 6),
                        _NivelBadge(nivel: nivel),
                        const SizedBox(height: 10),
                        if (recomendacion.isNotEmpty)
                          Text(
                            recomendacion,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: Colors.white12),
              const SizedBox(height: 14),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.location_on_rounded,
                    label: 'Zona más riesgosa',
                    value: zona,
                    color: AppColors.riskHigh,
                  ),
                  const SizedBox(width: 10),
                  _InfoChip(
                    icon: Icons.calendar_today_rounded,
                    label: 'Día vulnerable',
                    value: dia,
                    color: AppColors.riskMedium,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Acciones recomendadas
        if (acciones.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.task_alt_rounded,
                        color: AppColors.riskLow, size: 18),
                    SizedBox(width: 8),
                    Text('Acciones recomendadas',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                ...acciones.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22, height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: AppColors.riskLow
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: AppColors.riskLow,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(e.value,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.5)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

        const SizedBox(height: 14),

        // Re-analizar
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: _loading ? null : _analizar,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.riskMedium,
              side: const BorderSide(
                  color: AppColors.riskMedium, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Actualizar análisis',
                style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Color _nivelColor(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'alto':   return AppColors.riskHigh;
      case 'bajo':   return AppColors.riskLow;
      default:       return AppColors.riskMedium;
    }
  }
}

// ── Risk Gauge ────────────────────────────────────────────────────────────────

class _RiskGauge extends StatelessWidget {
  final int score;
  final String nivel;

  const _RiskGauge({required this.score, required this.nivel});

  Color get _color {
    if (score <= 33) return AppColors.riskLow;
    if (score <= 66) return AppColors.riskMedium;
    return AppColors.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90, height: 90,
      child: CustomPaint(
        painter: _GaugePainter(value: score / 100, color: _color),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$score',
                  style: TextStyle(
                      color: _color,
                      fontSize: 26,
                      fontWeight: FontWeight.w900)),
              Text('/100',
                  style: TextStyle(
                      color: _color.withValues(alpha: 0.6),
                      fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final bg = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi, false, bg);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi * value, false, fg);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _NivelBadge extends StatelessWidget {
  final String nivel;
  const _NivelBadge({required this.nivel});

  Color get _color {
    switch (nivel.toLowerCase()) {
      case 'alto':   return AppColors.riskHigh;
      case 'bajo':   return AppColors.riskLow;
      default:       return AppColors.riskMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = nivel.isEmpty
        ? 'Moderado'
        : nivel[0].toUpperCase() + nivel.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text('Exposición $label',
          style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 10)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
