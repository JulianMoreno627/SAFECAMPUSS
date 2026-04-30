import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/models/reporte.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../l10n/app_localizations.dart';

class DetalleReporteScreen extends StatefulWidget {
  final Reporte reporte;

  const DetalleReporteScreen({super.key, required this.reporte});

  @override
  State<DetalleReporteScreen> createState() => _DetalleReporteScreenState();
}

class _DetalleReporteScreenState extends State<DetalleReporteScreen> {
  bool _loadingAi = true;
  String? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _fetchAiAnalysis();
  }

  Future<void> _fetchAiAnalysis() async {
    final l10n = AppLocalizations.of(context);
    final history = [
      {
        'role': 'system',
        'content':
            'Eres SafeBot, un analista de seguridad universitaria. Analiza el siguiente incidente y da una breve recomendación (máximo 40 palabras) de cómo evitar o reaccionar ante esto en el campus.',
      }
    ];

    final msg =
        'Incidente de tipo ${widget.reporte.tipo.label} (${widget.reporte.nivelUrgencia.label}). Descripción: ${widget.reporte.descripcion}';

    try {
      final analysis = await aiService.sendChatMessage(history, msg);
      if (mounted) {
        setState(() {
          _aiAnalysis = analysis;
          _loadingAi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiAnalysis = l10n?.errorLoadingReports ?? 'Error al analizar el incidente.';
          _loadingAi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final r = widget.reporte;
    final cs = Theme.of(context).colorScheme;

    final color = switch (r.nivelUrgencia) {
      NivelUrgencia.critico => AppColors.riskCritical,
      NivelUrgencia.alto => AppColors.riskHigh,
      NivelUrgencia.medio => AppColors.riskMedium,
      NivelUrgencia.bajo => AppColors.riskLow,
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: r.fotoUrl != null && r.fotoUrl!.isNotEmpty ? 250 : 120,
            pinned: true,
            backgroundColor: cs.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Detalles del Reporte',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: r.fotoUrl != null && r.fotoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: r.fotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: cs.surfaceContainerHighest),
                      errorWidget: (context, url, error) => Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.broken_image, color: cs.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.2), cs.surface],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(r.tipo.icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.tipo.localizedLabel(l10n),
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                r.localizedTiempoTranscurrido(l10n),
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _NivelBadge(label: r.nivelUrgencia.localizedLabel(l10n), color: color),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (r.descripcion.isNotEmpty) ...[
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'Descripción',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      child: Text(
                        r.descripcion,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // AI Analysis Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology_rounded, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Text(
                                'Análisis SafeBot',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_loadingAi)
                            Shimmer.fromColors(
                              baseColor: AppColors.accent.withValues(alpha: 0.2),
                              highlightColor: AppColors.accent.withValues(alpha: 0.1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(height: 12, width: double.infinity, color: Colors.white),
                                  const SizedBox(height: 6),
                                  Container(height: 12, width: '80%'.length.toDouble() * 10, color: Colors.white),
                                  const SizedBox(height: 6),
                                  Container(height: 12, width: '60%'.length.toDouble() * 10, color: Colors.white),
                                ],
                              ),
                            )
                          else
                            Text(
                              _aiAnalysis ?? '',
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Map Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: Text(
                      'Ubicación',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(r.lat, r.lng),
                            initialZoom: 16.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.safecampus.ai',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(r.lat, r.lng),
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: color,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NivelBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _NivelBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
