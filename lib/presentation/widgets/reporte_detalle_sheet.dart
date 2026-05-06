import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/reporte.dart';
import '../../l10n/app_localizations.dart';

class ReporteDetalleSheet extends StatelessWidget {
  final Reporte reporte;

  const ReporteDetalleSheet({super.key, required this.reporte});

  static void show(BuildContext context, Reporte reporte) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReporteDetalleSheet(reporte: reporte),
    );
  }

  Color get _riskColor {
    switch (reporte.nivelUrgencia) {
      case NivelUrgencia.critico:
        return AppColors.riskCritical;
      case NivelUrgencia.alto:
        return AppColors.riskHigh;
      case NivelUrgencia.medio:
        return AppColors.riskMedium;
      case NivelUrgencia.bajo:
        return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.35,
      maxChildSize: 0.88,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (reporte.fotoUrl != null && reporte.fotoUrl!.isNotEmpty)
                Builder(builder: (_) {
                  try {
                    final bytes = base64Decode(reporte.fotoUrl!.split(',').last);
                    return ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: cs.surfaceContainerHigh,
                            child: const Icon(Icons.image_not_supported_rounded, size: 40),
                          ),
                        ),
                      ),
                    );
                  } catch (_) {
                    return Container(
                      height: 180,
                      color: cs.surfaceContainerHigh,
                      child: const Center(child: Icon(Icons.image_not_supported_rounded, size: 40)),
                    );
                  }
                }),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

              // Risk badge + tiempo
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          reporte.nivelUrgencia
                              .localizedLabel(l10n)
                              .toUpperCase(),
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
                    reporte.localizedTiempoTranscurrido(l10n),
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.38),
                        fontSize: 12),
                  ),
                ],
              ),

                    const SizedBox(height: 20),

                    // Autor del reporte
                    if (reporte.userName != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                              backgroundImage: (reporte.userFotoUrl != null && reporte.userFotoUrl!.isNotEmpty)
                                  ? MemoryImage(base64Decode(reporte.userFotoUrl!.split(',').last))
                                  : null,
                              child: (reporte.userFotoUrl == null || reporte.userFotoUrl!.isEmpty)
                                  ? Icon(Icons.person_rounded, size: 20, color: AppColors.accent)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.anonymousUser,
                                    style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    'Autor del reporte',
                                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            if (reporte.createdAt != null)
                              Text(
                                reporte.localizedFechaHora(l10n),
                                textAlign: TextAlign.right,
                                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10, height: 1.2),
                              ),
                          ],
                        ),
                      ),

              // Tipo + ícono
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(reporte.tipo.getMapIcon(reporte.tipoRaw), color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporte.tipo.localizedLabel(l10n, reporte.tipoRaw),
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.reportedIncident,
                          style: TextStyle(color: color, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Descripción
              _Section(
                title: l10n.descriptionTitleUpper,
                child: Text(
                  reporte.descripcion.isNotEmpty
                      ? reporte.descripcion
                      : l10n.noDescriptionAvailable,
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Detalles
              _Section(
                title: l10n.detailsTitleUpper,
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.group_rounded,
                      label: l10n.witnesses,
                      value: '${reporte.testigos}',
                      color: color,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.location_on_rounded,
                      label: l10n.coordinatesLabel,
                      value:
                          '${reporte.lat.toStringAsFixed(4)}, ${reporte.lng.toStringAsFixed(4)}',
                      color: color,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Gamificación (Karma)
              _Section(
                title: 'CONFIABILIDAD DEL REPORTE',
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.thumb_up_alt_rounded,
                        label: 'Confirmar (${reporte.votosPositivos})',
                        color: Colors.greenAccent,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gracias por confirmar este reporte.')));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.thumb_down_alt_rounded,
                        label: 'Falsa Alarma (${reporte.votosNegativos})',
                        color: Colors.redAccent,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voto registrado. Lo revisaremos.')));
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Acciones
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.share_rounded,
                      label: l10n.shareLabel,
                      color: AppColors.accent,
                      onTap: () {
                        SharePlus.instance.share(ShareParams(
                          text: 'SafeCampus AI - ${l10n.createReport}: ${reporte.tipo.localizedLabel(l10n, reporte.tipoRaw)} '
                          '(${reporte.nivelUrgencia.localizedLabel(l10n)})\n${reporte.descripcion}',
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.map_rounded,
                      label: l10n.viewOnMapLabel,
                      color: color,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.54),
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
    final cs = Theme.of(context).colorScheme;
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
            Text(label,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.38), fontSize: 11)),
            Text(value, style: TextStyle(color: cs.onSurface, fontSize: 14)),
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
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
