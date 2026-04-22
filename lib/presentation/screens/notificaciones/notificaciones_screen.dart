import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/notificacion.dart';
import '../../../core/providers/notificaciones_provider.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificacionesProvider);
    final notifier = ref.read(notificacionesProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              noLeidas: state.noLeidas,
              onMarcarTodas: notifier.marcarTodasLeidas,
              onBack: () => Navigator.pop(context),
              l10n: l10n,
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accent, strokeWidth: 2))
                  : state.notificaciones.isEmpty
                      ? _buildEmpty(state.error, l10n, theme, cs)
                      : RefreshIndicator(
                          onRefresh: notifier.fetchNotificaciones,
                          color: AppColors.accent,
                          backgroundColor: theme.cardColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            itemCount: state.notificaciones.length,
                            itemBuilder: (ctx, i) {
                              final n = state.notificaciones[i];
                              return FadeInUp(
                                delay: Duration(milliseconds: i * 40),
                                child: _NotifCard(
                                  notif: n,
                                  onTap: () => notifier.marcarLeida(n.id),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(
      String? error, AppLocalizations l10n, ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined,
                color: cs.onSurface.withValues(alpha: 0.2), size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            error != null
                ? 'Sin conexión al servidor'
                : l10n.notifNoNotifications,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Te avisaremos cuando haya alertas en el campus',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: cs.onSurface.withValues(alpha: 0.3), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int noLeidas;
  final VoidCallback onMarcarTodas;
  final VoidCallback onBack;
  final AppLocalizations l10n;

  const _Header({
    required this.noLeidas,
    required this.onMarcarTodas,
    required this.onBack,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 44,
              height: 44,
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
              Text(l10n.notifScreenTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              if (noLeidas > 0)
                Text('$noLeidas ${l10n.notifScreenSubtitle}',
                    style:
                        const TextStyle(color: AppColors.accent, fontSize: 12)),
            ],
          ),
          const Spacer(),
          if (noLeidas > 0)
            TextButton(
              onPressed: onMarcarTodas,
              child: Text(l10n.notifMarkAllRead,
                  style:
                      const TextStyle(color: AppColors.accent, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final Notificacion notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  Color get _color {
    switch (notif.tipo) {
      case TipoNotificacion.alerta:
        return AppColors.riskHigh;
      case TipoNotificacion.reporte:
        return AppColors.riskMedium;
      case TipoNotificacion.ia:
        return AppColors.accent;
      case TipoNotificacion.sistema:
        return AppColors.riskLow;
    }
  }

  IconData get _icon {
    switch (notif.tipo) {
      case TipoNotificacion.alerta:
        return Icons.warning_amber_rounded;
      case TipoNotificacion.reporte:
        return Icons.report_rounded;
      case TipoNotificacion.ia:
        return Icons.psychology_rounded;
      case TipoNotificacion.sistema:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              notif.leida ? AppColors.cardColor : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.leida ? Colors.white12 : color.withValues(alpha: 0.35),
            width: notif.leida ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.titulo,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: notif.leida
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notif.leida)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.cuerpo,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(notif.localizedTiempoTranscurrido(l10n),
                      style:
                          const TextStyle(color: Colors.white30, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
