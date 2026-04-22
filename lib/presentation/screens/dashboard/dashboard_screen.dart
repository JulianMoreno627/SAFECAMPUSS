import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/models/reporte.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _aiTrends;
  bool _loadingTrends = false;
  List<dynamic> _lastReports = [];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);

    // Lanzar análisis cuando cambien los reportes
    if (state.reportesCercanos.isNotEmpty &&
        state.reportesCercanos != _lastReports &&
        !_loadingTrends) {
      _lastReports = state.reportesCercanos;
      _fetchTrends(state.reportesCercanos);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildRiskBanner(context, state),
              const SizedBox(height: 16),
              _buildStatsRow(context, state),
              const SizedBox(height: 20),
              _buildPieChart(context, state),
              const SizedBox(height: 20),
              _buildBarChart(context, state),
              const SizedBox(height: 20),
              _buildAITrendsCard(),
              const SizedBox(height: 20),
              _buildSafeBotCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FadeInDown(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              Text('Estadísticas del campus',
                  style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.54),
                      fontSize: 13)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.bar_chart_rounded,
              color: AppColors.accent, size: 28),
        ],
      ),
    );
  }

  // ── Risk Banner ───────────────────────────────────────────────────────────

  Widget _buildRiskBanner(BuildContext context, ReportsState state) {
    final cs = Theme.of(context).colorScheme;
    final color = _riskColor(state.nivelRiesgoLabel);

    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.06)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle),
              child: Icon(Icons.shield_rounded, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nivel de Riesgo Actual',
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 12)),
                const SizedBox(height: 2),
                Text(state.nivelRiesgoLabel,
                    style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${state.reportesCercanos.length}',
                    style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                Text('reportes cercanos',
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.54),
                        fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context, ReportsState state) {
    final reports = state.reportesCercanos;
    final criticos =
        reports.where((r) => r.nivelUrgencia == NivelUrgencia.critico).length;
    final altos =
        reports.where((r) => r.nivelUrgencia == NivelUrgencia.alto).length;
    final medios =
        reports.where((r) => r.nivelUrgencia == NivelUrgencia.medio).length;

    return FadeInUp(
      delay: const Duration(milliseconds: 80),
      child: Row(
        children: [
          _StatTile(
              label: 'Críticos',
              value: criticos,
              color: AppColors.riskCritical),
          const SizedBox(width: 10),
          _StatTile(
              label: 'Altos', value: altos, color: AppColors.riskHigh),
          const SizedBox(width: 10),
          _StatTile(
              label: 'Medios',
              value: medios,
              color: AppColors.riskMedium),
        ],
      ),
    );
  }

  // ── Pie Chart ─────────────────────────────────────────────────────────────

  Widget _buildPieChart(BuildContext context, ReportsState state) {
    final cs = Theme.of(context).colorScheme;
    final reports = state.reportesCercanos;
    if (reports.isEmpty) return const SizedBox.shrink();

    final counts = <String, int>{};
    for (final r in reports) {
      final tipo = r.tipo.label;
      counts[tipo] = (counts[tipo] ?? 0) + 1;
    }

    const palette = [
      AppColors.riskHigh,
      AppColors.riskMedium,
      AppColors.accent,
      AppColors.riskCritical,
      AppColors.riskLow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    final sections = counts.entries.toList().asMap().entries.map((e) {
      final i = e.key;
      final entry = e.value;
      final pct = entry.value / reports.length * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: palette[i % palette.length],
        title: '${pct.toStringAsFixed(0)}%',
        radius: 52,
        titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold),
        badgeWidget: entry.value > 1
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: palette[i % palette.length]
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              )
            : null,
      );
    }).toList();

    return FadeInUp(
      delay: const Duration(milliseconds: 160),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reportes por tipo',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 36,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: counts.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((e) {
                      final i = e.key;
                      final entry = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: palette[i % palette.length],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: cs.onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: 12),
                              ),
                            ),
                            Text('${entry.value}',
                                style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Bar Chart (urgency) ───────────────────────────────────────────────────

  Widget _buildBarChart(BuildContext context, ReportsState state) {
    final cs = Theme.of(context).colorScheme;
    final reports = state.reportesCercanos;

    int count(NivelUrgencia nivel) =>
        reports.where((r) => r.nivelUrgencia == nivel).length;

    final data = [
      ('Bajo',    count(NivelUrgencia.bajo).toDouble(),    AppColors.riskLow),
      ('Medio',   count(NivelUrgencia.medio).toDouble(),   AppColors.riskMedium),
      ('Alto',    count(NivelUrgencia.alto).toDouble(),    AppColors.riskHigh),
      ('Crítico', count(NivelUrgencia.critico).toDouble(), AppColors.riskCritical),
    ];

    final maxY =
        data.map((d) => d.$2).fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxY < 1 ? 5.0 : maxY + 2;

    return FadeInUp(
      delay: const Duration(milliseconds: 240),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribución por urgencia',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  maxY: chartMax,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: cs.outlineVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final label = data[value.toInt()].$1;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(label,
                                style: TextStyle(
                                    color: cs.onSurface
                                        .withValues(alpha: 0.54),
                                    fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: data.asMap().entries.map((e) {
                    final i = e.key;
                    final d = e.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.$2 == 0 ? 0.15 : d.$2,
                          color: d.$3,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: chartMax,
                            color: d.$3.withValues(alpha: 0.07),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AI Trends ─────────────────────────────────────────────────────────────

  Future<void> _fetchTrends(List<dynamic> reports) async {
    setState(() => _loadingTrends = true);
    final result = await AiService().analyzeTrends(reports);
    if (mounted) setState(() { _aiTrends = result; _loadingTrends = false; });
  }

  Widget _buildAITrendsCard() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Análisis IA del Campus',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _loadingTrends
                  ? Row(
                      key: const ValueKey('loading'),
                      children: [
                        const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: AppColors.accent),
                        ),
                        const SizedBox(width: 10),
                        Text('Analizando tendencias...',
                            style: TextStyle(
                                color: AppColors.accent.withValues(alpha: 0.8),
                                fontSize: 13)),
                      ],
                    )
                  : _aiTrends != null
                      ? Text(
                          _aiTrends!,
                          key: const ValueKey('result'),
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.6),
                        )
                      : const Text(
                          'El análisis de tendencias estará disponible cuando haya reportes cercanos.',
                          key: ValueKey('empty'),
                          style: TextStyle(
                              color: Colors.white38, fontSize: 13, height: 1.5),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SafeBot Card ──────────────────────────────────────────────────────────

  Widget _buildSafeBotCard(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 320),
      child: GestureDetector(
        onTap: () => context.push('/dashboard/chat-ia'),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF006064)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Habla con SafeBot',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                        'Tu asistente de seguridad con IA. Pregúntale lo que quieras.',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
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

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.54),
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
