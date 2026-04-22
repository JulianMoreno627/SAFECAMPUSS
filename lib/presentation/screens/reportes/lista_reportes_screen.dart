import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/models/reporte.dart';
import '../../widgets/reporte_detalle_sheet.dart';

const _tipos = [
  'Todos',
  'Robo',
  'Acoso',
  'Pelea',
  'Vandalismo',
  'Accidente',
  'Persona sospechosa',
  'Iluminación',
  'Otro'
];

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
  String _selectedTipo = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Reporte> _filtered(List<Reporte> all) {
    return all.where((r) {
      final tipo = r.tipo.label.toLowerCase();
      final desc = r.descripcion.toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesTipo = _selectedTipo == 'Todos' ||
          tipo == _selectedTipo.toLowerCase();
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(reportsState, cs),
            _buildSearchBar(cs),
            _buildFilterChips(cs),
            Expanded(
              child: reportsState.isLoading
                  ? _buildShimmer()
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.accent,
                      backgroundColor: Theme.of(context).cardColor,
                      child: filtered.isEmpty
                          ? _buildEmpty(cs)
                          : _buildList(filtered),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ReportsState state, ColorScheme cs) {
    final color = _riskColor(state.nivelRiesgoLabel);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reportes',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${state.reportesCercanos.length} incidentes cercanos',
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
                  state.nivelRiesgoLabel,
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

  Widget _buildSearchBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: cs.onSurface),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Buscar por tipo o descripción...',
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

  Widget _buildFilterChips(ColorScheme cs) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _tipos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tipo = _tipos[i];
          final selected = tipo == _selectedTipo;
          return GestureDetector(
            onTap: () => setState(() => _selectedTipo = tipo),
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
                tipo,
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

  Widget _buildList(List<Reporte> items) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: items.length,
      itemBuilder: (context, i) => _ReportCard(
        reporte: items[i],
        onTap: () => ReporteDetalleSheet.show(context, items[i]),
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

  Widget _buildEmpty(ColorScheme cs) {
    final noResults =
        _searchQuery.isNotEmpty || _selectedTipo != 'Todos';
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
                noResults ? 'Sin resultados' : 'Zona tranquila',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                noResults
                    ? 'Prueba con otro filtro o búsqueda'
                    : 'No hay incidentes cercanos reportados',
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
  final Reporte reporte;
  final VoidCallback onTap;

  const _ReportCard({required this.reporte, required this.onTap});

  Color get _color {
    switch (reporte.nivelUrgencia) {
      case NivelUrgencia.critico: return AppColors.riskCritical;
      case NivelUrgencia.alto:    return AppColors.riskHigh;
      case NivelUrgencia.medio:   return AppColors.riskMedium;
      case NivelUrgencia.bajo:    return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final cs = Theme.of(context).colorScheme;

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
              child: Icon(reporte.tipo.mapIcon, color: color, size: 24),
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
                          reporte.tipo.label,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        reporte.tiempoTranscurrido,
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.38),
                            fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reporte.descripcion,
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
                          reporte.nivelUrgencia.label.toUpperCase(),
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (reporte.testigos > 0) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.group_rounded,
                            size: 12,
                            color: cs.onSurface.withValues(alpha: 0.38)),
                        const SizedBox(width: 4),
                        Text(
                          '${reporte.testigos} testigo${reporte.testigos == 1 ? '' : 's'}',
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
                color: cs.onSurface.withValues(alpha: 0.24),
                size: 20),
          ],
        ),
      ),
    );
  }
}
