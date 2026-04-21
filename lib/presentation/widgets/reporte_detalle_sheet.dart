import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';

class ReporteDetalleSheet extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReporteDetalleSheet({super.key, required this.report});

  static void show(BuildContext context, Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReporteDetalleSheet(report: report),
    );
  }

  Color get _riskColor {
    switch (report['nivel_urgencia']?.toString().toLowerCase()) {
      case 'critico': return AppColors.riskCritical;
      case 'alto':    return AppColors.riskHigh;
      case 'medio':   return AppColors.riskMedium;
      default:        return AppColors.riskLow;
    }
  }

  IconData get _typeIcon {
    switch (report['tipo']?.toString().toLowerCase()) {
      case 'robo':               return Icons.no_backpack_rounded;
      case 'acoso':              return Icons.person_off_rounded;
      case 'pelea':              return Icons.sports_kabaddi_rounded;
      case 'vandalismo':         return Icons.broken_image_rounded;
      case 'accidente':          return Icons.car_crash_rounded;
      case 'persona sospechosa': return Icons.visibility_rounded;
      case 'iluminación':        return Icons.flashlight_off_rounded;
      default:                   return Icons.report_rounded;
    }
  }

  String _timeAgo(String? raw) {
    if (raw == null) return 'Hace un momento';
    final date = DateTime.tryParse(raw);
    if (date == null) return 'Hace un momento';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1)  return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7)     return 'Hace ${diff.inDays} días';
    return 'Hace más de una semana';
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.35,
      maxChildSize: 0.88,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              // ── Drag handle ────────────────────────────────────────────
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Risk badge ─────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: color),
                        const SizedBox(width: 6),
                        Text(
                          (report['nivel_urgencia'] ?? 'bajo').toString().toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _timeAgo(report['created_at']?.toString()),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Tipo + ícono ───────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(_typeIcon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['tipo'] ?? 'Incidente',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Incidente reportado',
                          style: TextStyle(color: color, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Descripción ────────────────────────────────────────────
              _Section(
                title: 'Descripción',
                child: Text(
                  report['descripcion'] ?? 'Sin descripción disponible.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Metadata ───────────────────────────────────────────────
              _Section(
                title: 'Detalles',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.group_rounded,
                      label: 'Testigos',
                      value: '${report['testigos'] ?? 0}',
                      color: color,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: 'Coordenadas',
                      value: report['lat'] != null
                          ? '${(report['lat'] as num).toStringAsFixed(4)}, ${(report['lng'] as num).toStringAsFixed(4)}'
                          : 'No disponible',
                      color: color,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Acciones ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.share_rounded,
                      label: 'Compartir',
                      color: AppColors.accent,
                      onTap: () {
                        final tipo = report['tipo'] ?? 'Incidente';
                        final desc = report['descripcion'] ?? '';
                        final urgencia = report['nivel_urgencia'] ?? '';
                        Share.share(
                          'SafeCampus AI — Reporte: $tipo ($urgencia)\n$desc',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.map_rounded,
                      label: 'Ver en mapa',
                      color: color,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
