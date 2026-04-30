import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/reporte.dart';
import '../../../core/services/ai_service.dart';

class DetalleZonaScreen extends ConsumerStatefulWidget {
  final List<Reporte> reportes;
  final String nombreZona;

  const DetalleZonaScreen({
    super.key,
    required this.reportes,
    required this.nombreZona,
  });

  @override
  ConsumerState<DetalleZonaScreen> createState() => _DetalleZonaScreenState();
}

class _DetalleZonaScreenState extends ConsumerState<DetalleZonaScreen> {
  bool _loading = true;
  Map<String, dynamic>? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    if (widget.reportes.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final result = await aiService.analyzeRisk(widget.reportes);
    if (mounted) {
      setState(() {
        _aiAnalysis = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    FadeInUp(child: _buildAiCard()),
                    const SizedBox(height: 20),
                    FadeInUp(delay: const Duration(milliseconds: 100), child: _buildReportList()),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalle de Zona', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(widget.nombreZona, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiCard() {
    final nivel = _aiAnalysis?['nivel']?.toString() ?? 'medio';
    final reco = _aiAnalysis?['recomendacion']?.toString() ?? 'Mantente alerta en esta zona.';
    
    Color color;
    switch(nivel) {
      case 'critico': color = AppColors.riskCritical; break;
      case 'alto': color = AppColors.riskHigh; break;
      case 'bajo': color = AppColors.riskLow; break;
      default: color = AppColors.riskMedium;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Text('Análisis IA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              if (_loading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 14),
          if (!_loading && _aiAnalysis != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Nivel: ${nivel.toUpperCase()}',
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Text(reco, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
          ] else if (!_loading)
            const Text('No se pudo generar el análisis.', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.reportes.length} incidentes en esta zona', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 14),
        ...widget.reportes.map((r) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Icon(r.tipo.mapIcon, color: AppColors.accent, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.tipo.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(r.descripcion.isEmpty ? 'Sin descripción' : r.descripcion, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
