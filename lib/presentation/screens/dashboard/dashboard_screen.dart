import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/reports_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildRiskCard(reportsState),
              const SizedBox(height: 20),
              _buildStatsRow(reportsState),
              const SizedBox(height: 24),
              _buildChartPlaceholder(),
              const SizedBox(height: 24),
              _buildRecentActivity(reportsState),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: const Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Estadísticas del campus',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          Spacer(),
          Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 18),
          SizedBox(width: 6),
          Text(
            'Hoy',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(ReportsState state) {
    final color = _getRiskColor(state.nivelRiesgo);

    return FadeInUp(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shield_rounded, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nivel de Riesgo Actual',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  state.nivelRiesgo,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${state.reportesCercanos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'reportes cercanos',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ReportsState state) {
    final total = state.reportesCercanos.length;
    final altos = state.reportesCercanos
        .where((r) => r['nivel_urgencia'] == 'alto' || r['nivel_urgencia'] == 'critico')
        .length;
    final medios = state.reportesCercanos
        .where((r) => r['nivel_urgencia'] == 'medio')
        .length;

    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Row(
        children: [
          _StatCard(label: 'Total', value: '$total', color: AppColors.accent),
          const SizedBox(width: 12),
          _StatCard(label: 'Urgentes', value: '$altos', color: AppColors.riskHigh),
          const SizedBox(width: 12),
          _StatCard(label: 'Medios', value: '$medios', color: AppColors.riskMedium),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reportes por tipo',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Bar(label: 'Robo', height: 0.7, color: AppColors.riskHigh),
                  _Bar(label: 'Acoso', height: 0.4, color: AppColors.riskMedium),
                  _Bar(label: 'Pelea', height: 0.55, color: AppColors.riskCritical),
                  _Bar(label: 'Vandal.', height: 0.3, color: AppColors.accent),
                  _Bar(label: 'Otro', height: 0.2, color: Colors.white24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ReportsState state) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividad Reciente',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (state.reportesCercanos.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'No hay actividad reciente',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
            )
          else
            ...state.reportesCercanos.take(3).map(
              (r) => _ActivityRow(report: r),
            ),
        ],
      ),
    );
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'critico': return AppColors.riskCritical;
      case 'alto': return AppColors.riskHigh;
      case 'medio': return AppColors.riskMedium;
      default: return AppColors.riskLow;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double height;
  final Color color;

  const _Bar({required this.label, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 120 * height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final dynamic report;

  const _ActivityRow({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.accent, size: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              report['tipo'] ?? 'Incidente',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Text(
            report['nivel_urgencia'] ?? '',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
