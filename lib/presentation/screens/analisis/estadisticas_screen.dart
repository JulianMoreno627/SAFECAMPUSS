import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/models/reporte.dart';
import '../../../core/services/ai_service.dart';

class EstadisticasScreen extends ConsumerStatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  ConsumerState<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends ConsumerState<EstadisticasScreen> {
  bool _loading = true;
  String? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    final reports = ref.read(reportsProvider).reportesCercanos;
    if (reports.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final result = await aiService.analyzeTrends(reports);
    if (mounted) {
      setState(() {
        _aiAnalysis = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsProvider).reportesCercanos;
    
    // Preparar datos para el gráfico de tipos
    final typeCounts = <String, int>{};
    for (final r in reports) {
      typeCounts[r.tipo.label] = (typeCounts[r.tipo.label] ?? 0) + 1;
    }
    final topTypes = typeCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: reports.isEmpty
                  ? const Center(child: Text('No hay suficientes datos', style: TextStyle(color: Colors.white54)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      child: Column(
                        children: [
                          FadeInUp(child: _buildAiCard()),
                          const SizedBox(height: 20),
                          FadeInUp(delay: const Duration(milliseconds: 100), child: _buildChartCard(topTypes)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estadísticas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Análisis del Campus', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Text('Análisis IA de Tendencias', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              if (_loading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 14),
          if (!_loading && _aiAnalysis != null)
            Text(_aiAnalysis!, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5))
          else if (!_loading)
            const Text('No se pudo generar el análisis.', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<MapEntry<String, int>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    // Colores para el pie chart
    final colors = [
      AppColors.riskHigh,
      AppColors.accent,
      AppColors.riskMedium,
      AppColors.riskLow,
      Colors.purpleAccent,
      Colors.blueAccent,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tipos de Incidentes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: data.asMap().entries.map((e) {
                  final color = colors[e.key % colors.length];
                  return PieChartSectionData(
                    color: color,
                    value: e.value.value.toDouble(),
                    title: '${e.value.value}',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: data.asMap().entries.map((e) {
              final color = colors[e.key % colors.length];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(e.value.key, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
