import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/routing_service.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../l10n/app_localizations.dart';

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
  RouteResult? _routeResult;

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

  Future<void> _analizar(AppLocalizations l10n) async {
    if (_destinoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterDestinationHint),
          backgroundColor: AppColors.riskMedium,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _resultado = null;
      _routeResult = null;
    });

    LatLng? origLatLng;
    LatLng? destLatLng;

    // 1. Geocode origin
    final origStr = _origenCtrl.text.trim();
    if (origStr.contains(',')) {
      final parts = origStr.split(',');
      if (parts.length == 2) {
        origLatLng = LatLng(double.parse(parts[0].trim()), double.parse(parts[1].trim()));
      }
    }
    if (origLatLng == null && origStr.isNotEmpty) {
      final origPlaces = await RoutingService().searchPlaces(origStr);
      if (origPlaces.isNotEmpty) origLatLng = origPlaces.first.position;
    }

    // 2. Geocode destination
    final destStr = _destinoCtrl.text.trim();
    final destPlaces = await RoutingService().searchPlaces(destStr);
    if (destPlaces.isNotEmpty) destLatLng = destPlaces.first.position;

    // 3. Get Route
    if (origLatLng != null && destLatLng != null) {
      _routeResult = await RoutingService().getRoute(origLatLng, destLatLng);
    }

    final now = TimeOfDay.now();
    final hora =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final reportes = ref.read(reportsProvider).reportesCercanos;

    final result = await aiService.recomendarRuta(
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    FadeInUp(child: _buildInputCard(l10n)),
                    const SizedBox(height: 20),
                    if (_loading)
                      FadeIn(child: _buildLoadingCard(l10n)),
                    if (_resultado != null && !_loading)
                      FadeInUp(child: _buildResultado(l10n)),
                    if (_resultado == null && !_loading)
                      FadeIn(child: _buildPlaceholder(l10n)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.safeRouteTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(l10n.safeRouteSubtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
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

  Widget _buildInputCard(AppLocalizations l10n) {
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
          Text(l10n.whereAreYouGoing,
              style: const TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _routeField(
            controller: _origenCtrl,
            hint: l10n.routeOrigin,
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
            hint: l10n.routeDestination,
            icon: Icons.location_on_rounded,
            iconColor: AppColors.riskHigh,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : () => _analizar(l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              icon: const Icon(Icons.route_rounded, size: 20),
              label: Text(l10n.analyzeWithAI,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

  Widget _buildLoadingCard(AppLocalizations l10n) {
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
          Text(l10n.safebotAnalyzingRoute,
              style: const TextStyle(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(l10n.checkingNearbyReports,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(AppLocalizations l10n) {
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
          Text(l10n.aiRouteAnalysisTitle,
              style: const TextStyle(color: Colors.white,
                  fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            l10n.aiRouteAnalysisDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildResultado(AppLocalizations l10n) {
    final r = _resultado!;
    final score = (r['score_seguridad'] as num?)?.toInt() ?? 60;
    final nivel = r['nivel_riesgo']?.toString() ?? 'medio';
    final recomendacion = r['recomendacion']?.toString() ?? '';
    final rutaAlternativa = r['ruta_alternativa'] == true;
    final motivo = r['motivo']?.toString() ?? '';
    final tips = (r['tips'] as List?)?.map((t) => t.toString()).toList() ?? [];

    return Column(
      children: [
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
                        Text(l10n.safetyScore,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        _nivelBadge(nivel, l10n),
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
                              ? '${l10n.safebotRecommendsAlternative}: $motivo'
                              : l10n.safebotRecommendsAlternative,
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
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_rounded,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.routeTipsTitle,
                        style: const TextStyle(color: Colors.white,
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

        if (_routeResult != null)
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _routeResult!.points.first,
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.safecampus.safecampus_ai',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routeResult!.points,
                          color: Colors.black.withValues(alpha: 0.2),
                          strokeWidth: 7,
                        ),
                        Polyline(
                          points: _routeResult!.points,
                          color: _nivelColor(nivel),
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _routeResult!.points.first,
                          child: const Icon(Icons.my_location, color: AppColors.riskLow),
                        ),
                        Marker(
                          point: _routeResult!.points.last,
                          child: const Icon(Icons.flag, color: AppColors.riskHigh),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_routeResult!.distanceLabel} • ${_routeResult!.durationLabel}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 14),

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
            label: Text(l10n.newQueryLabel,
                style: const TextStyle(fontSize: 14)),
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

  Widget _nivelBadge(String nivel, AppLocalizations l10n) {
    final color = _nivelColor(nivel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '${l10n.riskLabel} ${nivel[0].toUpperCase()}${nivel.substring(1)}',
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
