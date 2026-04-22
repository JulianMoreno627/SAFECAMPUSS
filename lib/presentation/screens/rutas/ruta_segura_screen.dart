import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/providers/location_provider.dart';

class RutaSeguraScreen extends ConsumerStatefulWidget {
  const RutaSeguraScreen({super.key});

  @override
  ConsumerState<RutaSeguraScreen> createState() => _RutaSeguraScreenState();
}

class _RutaSeguraScreenState extends ConsumerState<RutaSeguraScreen> {
  final _origenCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();

  bool _loading = false;
  Map<String, dynamic>? _resultado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pos = ref.read(locationProvider).currentPosition;
      if (pos != null) {
        _origenCtrl.text =
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      }
    });
  }

  @override
  void dispose() {
    _origenCtrl.dispose();
    _destinoCtrl.dispose();
    super.dispose();
  }

  Future<void> _analizar() async {
    if (_destinoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el destino'),
          backgroundColor: AppColors.riskMedium,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _resultado = null;
    });

    final now = TimeOfDay.now();
    final hora =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final reportes = ref
        .read(reportsProvider)
        .reportesCercanos
        .cast<Map<String, dynamic>>();

    final result = await GeminiService().recomendarRuta(
      origen: _origenCtrl.text.trim(),
      destino: _destinoCtrl.text.trim(),
      hora: hora,
      reportesCercanos: reportes,
    );

    if (mounted) {
      setState(() {
        _resultado = result;
        _loading = false;
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
                    FadeInUp(child: _buildInputCard()),
                    const SizedBox(height: 20),
                    if (_loading)
                      FadeIn(child: _buildLoadingCard()),
                    if (_resultado != null && !_loading)
                      FadeInUp(child: _buildResultado()),
                    if (_resultado == null && !_loading)
                      FadeIn(child: _buildPlaceholder()),
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
              Text('Ruta Segura',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('Análisis de seguridad con IA',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology_rounded, color: AppColors.accent, size: 14),
                SizedBox(width: 4),
                Text('SafeBot', style: TextStyle(color: AppColors.accent,
                    fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Input card ────────────────────────────────────────────────────────────

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿A dónde vas?',
              style: TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _routeField(
            controller: _origenCtrl,
            hint: 'Origen',
            icon: Icons.my_location_rounded,
            iconColor: AppColors.riskLow,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Container(
              width: 2, height: 20,
              color: Colors.white12,
            ),
          ),
          _routeField(
            controller: _destinoCtrl,
            hint: 'Destino',
            icon: Icons.location_on_rounded,
            iconColor: AppColors.riskHigh,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _analizar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              icon: const Icon(Icons.route_rounded, size: 20),
              label: const Text('Analizar Ruta con IA',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      required Color iconColor}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: iconColor.withValues(alpha: 0.6),
              width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
                color: AppColors.accent, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          const Text('SafeBot analizando la ruta...',
              style: TextStyle(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Revisando reportes cercanos y calculando el riesgo',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12)),
        ],
      ),
    );
  }

  // ── Placeholder ───────────────────────────────────────────────────────────

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(28),
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
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.route_rounded,
                color: AppColors.accent, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Análisis de ruta con IA',
              style: TextStyle(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Ingresa origen y destino. SafeBot analizará los reportes de seguridad cercanos y calculará el nivel de riesgo de tu ruta.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Resultado ─────────────────────────────────────────────────────────────

  Widget _buildResultado() {
    final r = _resultado!;
    final score = (r['score_seguridad'] as num?)?.toInt() ?? 60;
    final nivel = r['nivel_riesgo']?.toString() ?? 'medio';
    final recomendacion = r['recomendacion']?.toString() ?? '';
    final rutaAlternativa = r['ruta_alternativa'] == true;
    final motivo = r['motivo']?.toString() ?? '';
    final tips = (r['tips'] as List?)?.map((t) => t.toString()).toList() ?? [];

    return Column(
      children: [
        // Score card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _nivelColor(nivel).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _ScoreGauge(score: score, nivel: nivel),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Score de Seguridad',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        _nivelBadge(nivel),
                        const SizedBox(height: 10),
                        Text(
                          recomendacion,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Ruta alternativa
              if (rutaAlternativa) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.riskMedium.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.riskMedium.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alt_route_rounded,
                          color: AppColors.riskMedium, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          motivo.isNotEmpty
                              ? 'Ruta alternativa recomendada: $motivo'
                              : 'SafeBot recomienda tomar una ruta alternativa',
                          style: const TextStyle(
                              color: AppColors.riskMedium,
                              fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Tips card
        if (tips.isNotEmpty)
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
                    Icon(Icons.tips_and_updates_rounded,
                        color: AppColors.accent, size: 18),
                    SizedBox(width: 8),
                    Text('Consejos para esta ruta',
                        style: TextStyle(color: Colors.white,
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),
                ...tips.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22, height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(e.value,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13, height: 1.5)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

        const SizedBox(height: 14),

        // Nueva consulta
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _resultado = null),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(
                  color: AppColors.accent, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Nueva consulta',
                style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Color _nivelColor(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'critico': return AppColors.riskCritical;
      case 'alto':    return AppColors.riskHigh;
      case 'bajo':    return AppColors.riskLow;
      default:        return AppColors.riskMedium;
    }
  }

  Widget _nivelBadge(String nivel) {
    final color = _nivelColor(nivel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        'Riesgo ${nivel[0].toUpperCase()}${nivel.substring(1)}',
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── Score Gauge ───────────────────────────────────────────────────────────────

class _ScoreGauge extends StatelessWidget {
  final int score;
  final String nivel;

  const _ScoreGauge({required this.score, required this.nivel});

  Color get _color {
    if (score >= 75) return AppColors.riskLow;
    if (score >= 50) return AppColors.riskMedium;
    if (score >= 30) return AppColors.riskHigh;
    return AppColors.riskCritical;
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

    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      bgPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color;
}
