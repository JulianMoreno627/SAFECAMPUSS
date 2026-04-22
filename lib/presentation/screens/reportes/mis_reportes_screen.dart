import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/reporte.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/reporte_detalle_sheet.dart';

final _misReportesProvider =
    FutureProvider.autoDispose<List<Reporte>>((ref) async {
  final userId = ref.watch(authProvider).usuario?.id ?? '';
  if (userId.isEmpty) return [];
  return ApiService().getReportesDelUsuario(userId);
});

class MisReportesScreen extends ConsumerStatefulWidget {
  const MisReportesScreen({super.key});

  @override
  ConsumerState<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends ConsumerState<MisReportesScreen> {
  String _filtroKey = '';

  List<(String, String)> _filtros(AppLocalizations l10n) => [
        ('', l10n.filterAll),
        ('critico', l10n.criticalRisk),
        ('alto', l10n.highRisk),
        ('medio', l10n.mediumRisk),
        ('bajo', l10n.lowRisk),
      ];

  List<Reporte> _filtrados(List<Reporte> todos) {
    if (_filtroKey.isEmpty) return todos;
    return todos.where((r) => r.nivelUrgencia.name == _filtroKey).toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncReportes = ref.watch(_misReportesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: asyncReportes.when(
          loading: () => Column(
            children: [
              _buildHeader(null, l10n),
              _buildFiltros(l10n),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accent, strokeWidth: 2),
                ),
              ),
            ],
          ),
          error: (e, _) => Column(
            children: [
              _buildHeader(null, l10n),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          color: Colors.white30, size: 48),
                      const SizedBox(height: 12),
                      Text(l10n.errorLoadingReports,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(_misReportesProvider),
                        icon: const Icon(Icons.refresh_rounded,
                            color: AppColors.accent),
                        label: Text(l10n.retryLabel,
                            style: const TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          data: (todos) {
            final misReportes = _filtrados(todos);
            return Column(
              children: [
                _buildHeader(todos.length, l10n),
                _buildFiltros(l10n),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => ref.invalidate(_misReportesProvider),
                    color: AppColors.accent,
                    backgroundColor: AppColors.cardColor,
                    child: misReportes.isEmpty
                        ? _buildEmpty(l10n)
                        : _buildLista(misReportes),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int? total, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
              Text(l10n.myReportsTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(
                total != null
                    ? '$total ${l10n.statsReports.toLowerCase()}'
                    : l10n.loadingLabel,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(AppLocalizations l10n) {
    final filtros = _filtros(l10n);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: filtros.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label) = filtros[i];
          final sel = _filtroKey == key;
          return GestureDetector(
            onTap: () => setState(() => _filtroKey = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? AppColors.accent : AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: sel ? AppColors.accent : Colors.white12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: sel ? Colors.black : Colors.white54,
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.article_outlined,
                    color: Colors.white24, size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                _filtroKey.isEmpty ? l10n.noReportsSent : l10n.noResults,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.helpCommunityReport,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLista(List<Reporte> reportes) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: reportes.length,
      itemBuilder: (ctx, i) => FadeInUp(
        delay: Duration(milliseconds: i * 40),
        child: _ReporteCard(
          reporte: reportes[i],
          onTap: () => ReporteDetalleSheet.show(ctx, reportes[i]),
        ),
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _ReporteCard extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onTap;

  const _ReporteCard({required this.reporte, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = switch (reporte.nivelUrgencia) {
      NivelUrgencia.critico => AppColors.riskCritical,
      NivelUrgencia.alto => AppColors.riskHigh,
      NivelUrgencia.medio => AppColors.riskMedium,
      NivelUrgencia.bajo => AppColors.riskLow,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
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
              child: Icon(reporte.tipo.icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(reporte.tipo.localizedLabel(l10n),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ),
                      _NivelBadge(
                          label: reporte.nivelUrgencia.localizedLabel(l10n),
                          color: color),
                    ],
                  ),
                  if (reporte.descripcion.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reporte.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: Colors.white30, size: 12),
                      const SizedBox(width: 4),
                      Text(reporte.localizedTiempoTranscurrido(l10n),
                          style: const TextStyle(
                              color: Colors.white30, fontSize: 11)),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.white24, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
