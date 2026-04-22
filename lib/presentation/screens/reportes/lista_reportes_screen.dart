import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/reporte_detalle_sheet.dart';

class ListaReportesScreen extends ConsumerStatefulWidget {
  const ListaReportesScreen({super.key});

  @override
  ConsumerState<ListaReportesScreen> createState() =>
      _ListaReportesScreenState();
}

class _ListaReportesScreenState
    extends ConsumerState<ListaReportesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedKey = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<(String, String)> _tipos(AppLocalizations l10n) => [
    ('', l10n.filterAll),
    ('robo', l10n.filterTheft),
    ('acoso', l10n.filterHarassment),
    ('pelea', l10n.filterFight),
    ('vandalismo', l10n.filterVandalism),
    ('accidente', l10n.filterAccident),
    ('persona sospechosa', l10n.filterSuspicious),
    ('iluminación', l10n.filterLighting),
    ('otro', l10n.filterOther),
  ];

  List<dynamic> _filtered(List<dynamic> all) {
    return all.where((r) {
      final tipo = r['tipo']?.toString().toLowerCase() ?? '';
      final desc = r['descripcion']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      final matchesTipo = _selectedKey.isEmpty || tipo == _selectedKey;
      final matchesSearch = query.isEmpty ||
          tipo.contains(query) ||
          desc.contains(query);

      return matchesTipo && matchesSearch;
    }).toList();
  }

  Future<void> _refresh() async {
    final loc = ref.read(locationProvider).currentPosition;
    if (loc != null) {
      await ref
          .read(reportsProvider.notifier)
          .fetchNearbyReports(loc.latitude, loc.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsProvider);
    final filtered = _filtered(reportsState.reportesCercanos);
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(reportsState, cs, l10n),
            _buildSearchBar(cs, l10n),
            _buildFilterChips(cs, l10n),
            Expanded(
              child: reportsState.isLoading
                  ? _buildShimmer()
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.accent,
                      backgroundColor: Theme.of(context).cardColor,
                      child: filtered.isEmpty
                          ? _buildEmpty(cs, l10n)
                          : _buildList(filtered),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ReportsState state, ColorScheme cs, AppLocalizations l10n) {
    final color = _riskColor(state.nivelRiesgo);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportsTitle,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${state.reportesCercanos.length} ${l10n.nearbyReportsLabel}',
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.54),
                    fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_rounded, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  state.nivelRiesgo,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme cs, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: cs.onSurface),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          hintStyle:
              TextStyle(color: cs.onSurface.withValues(alpha: 0.3)),
          prefixIcon: Icon(Icons.search_rounded,
              color: cs.onSurface.withValues(alpha: 0.38)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: cs.onSurface.withValues(alpha: 0.38)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.accent, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme cs, AppLocalizations l10n) {
    final tipos = _tipos(l10n);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: tipos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label) = tipos[i];
          final selected = key == _selectedKey;
          return GestureDetector(
            onTap: () => setState(() => _selectedKey = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.accent : cs.outlineVariant,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.black
                      : cs.onSurface.withValues(alpha: 0.54),
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<dynamic> items) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: items.length,
      itemBuilder: (context, i) => _ReportCard(
        report: items[i],
        onTap: () => ReporteDetalleSheet.show(
            context, Map<String, dynamic>.from(items[i])),
      ),
    );
  }

  Widget _buildShimmer() {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor,
      highlightColor: cs.surface,
      child: ListView.builder(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 88,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs, AppLocalizations l10n) {
    final noResults =
        _searchQuery.isNotEmpty || _selectedKey.isNotEmpty;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Icon(
                noResults
                    ? Icons.search_off_rounded
                    : Icons.check_circle_outline_rounded,
                color: noResults
                    ? cs.onSurface.withValues(alpha: 0.24)
                    : AppColors.riskLow,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                noResults ? l10n.noResults : l10n.quietZone,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                noResults
                    ? l10n.tryOtherFilter
                    : l10n.noNearbyIncidents,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.54),
                    fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'crítico':
      case 'critico':
        return AppColors.riskCritical;
      case 'alto':
        return AppColors.riskHigh;
      case 'medio':
        return AppColors.riskMedium;
      default:
        return AppColors.riskLow;
    }
  }
}

class _ReportCard extends StatelessWidget {
  final dynamic report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  Color get _riskColor {
    switch (report['nivel_urgencia']?.toString().toLowerCase()) {
      case 'critico':
        return AppColors.riskCritical;
      case 'alto':
        return AppColors.riskHigh;
      case 'medio':
        return AppColors.riskMedium;
      default:
        return AppColors.riskLow;
    }
  }

  IconData get _typeIcon {
    switch (report['tipo']?.toString().toLowerCase()) {
      case 'robo':
        return Icons.no_backpack_rounded;
      case 'acoso':
        return Icons.person_off_rounded;
      case 'pelea':
        return Icons.sports_kabaddi_rounded;
      case 'vandalismo':
        return Icons.broken_image_rounded;
      case 'accidente':
        return Icons.car_crash_rounded;
      case 'persona sospechosa':
        return Icons.visibility_rounded;
      case 'iluminación':
        return Icons.flashlight_off_rounded;
      default:
        return Icons.report_rounded;
    }
  }

  String _timeAgo(String? raw, AppLocalizations l10n) {
    if (raw == null) return '';
    final date = DateTime.tryParse(raw);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return l10n.timeAgoNow;
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_typeIcon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report['tipo'] ?? l10n.incidentDefault,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        _timeAgo(report['created_at']?.toString(), l10n),
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.38),
                            fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['descripcion'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.54),
                        fontSize: 12,
                        height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (report['nivel_urgencia'] ?? 'bajo')
                              .toString()
                              .toUpperCase(),
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (report['testigos'] != null &&
                          report['testigos'] != 0) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.group_rounded,
                            size: 12,
                            color: cs.onSurface.withValues(alpha: 0.38)),
                        const SizedBox(width: 4),
                        Text(
                          '${report['testigos']} ${report['testigos'] == 1 ? l10n.witnessCount : l10n.witnessCountPlural}',
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.38),
                              fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.24),
                size: 20),
          ],
        ),
      ),
    );
  }
}
