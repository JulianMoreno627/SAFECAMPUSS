import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../widgets/reporte_detalle_sheet.dart';

class MisReportesScreen extends ConsumerStatefulWidget {
  const MisReportesScreen({super.key});

  @override
  ConsumerState<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends ConsumerState<MisReportesScreen> {
  String _filtro = 'Todos';

  static const _filtros = ['Todos', 'Crítico', 'Alto', 'Medio', 'Bajo'];

  static const _tipoIconos = {
    'robo':                Icons.phone_android_rounded,
    'acoso':               Icons.warning_rounded,
    'persona sospechosa':  Icons.person_off_rounded,
    'iluminación':         Icons.light_mode_rounded,
    'pelea':               Icons.sports_mma_rounded,
    'vandalismo':          Icons.broken_image_rounded,
    'accidente':           Icons.car_crash_rounded,
    'otro':                Icons.more_horiz_rounded,
  };

  static const _nivelColores = {
    'critico': AppColors.riskCritical,
    'alto':    AppColors.riskHigh,
    'medio':   AppColors.riskMedium,
    'bajo':    AppColors.riskLow,
  };

  Future<void> _refresh() async {
    final pos = ref.read(locationProvider).currentPosition;
    if (pos != null) {
      await ref
          .read(reportsProvider.notifier)
          .fetchNearbyReports(pos.latitude, pos.longitude);
    }
  }

  List<dynamic> _filtrados(List<dynamic> todos, String userId) {
    return todos.where((r) {
      final esDelUsuario =
          r['user_id']?.toString() == userId ||
          r['usuario_id']?.toString() == userId;
      if (!esDelUsuario) return false;
      if (_filtro == 'Todos') return true;
      final nivel = r['nivel_urgencia']?.toString().toLowerCase() ?? '';
      return nivel == _filtro.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsProvider);
    final userId = ref.watch(authProvider).user?['id']?.toString() ?? '';
    final todos = reportsState.reportesCercanos;
    final misReportes = _filtrados(todos, userId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(misReportes.length),
            _buildFiltros(),
            Expanded(
              child: reportsState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accent, strokeWidth: 2))
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.accent,
                      backgroundColor: AppColors.cardColor,
                      child: misReportes.isEmpty
                          ? _buildEmpty()
                          : _buildLista(misReportes),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int total) {
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mis Reportes',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('$total reporte${total != 1 ? 's' : ''} enviados',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: _filtros.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filtros[i];
          final sel = _filtro == f;
          return GestureDetector(
            onTap: () => setState(() => _filtro = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? AppColors.accent : AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? AppColors.accent : Colors.white12,
                ),
              ),
              child: Text(
                f,
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

  Widget _buildEmpty() {
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
                _filtro == 'Todos'
                    ? 'No has enviado reportes'
                    : 'Sin reportes de nivel $_filtro',
                style: const TextStyle(color: Colors.white,
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ayuda a la comunidad reportando\nincidentes en el campus',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13,
                    height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLista(List<dynamic> reportes) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: reportes.length,
      itemBuilder: (ctx, i) => FadeInUp(
        delay: Duration(milliseconds: i * 40),
        child: _ReporteCard(
          reporte: reportes[i],
          tipoIconos: _tipoIconos,
          nivelColores: _nivelColores,
          onTap: () => ReporteDetalleSheet.show(
              ctx, Map<String, dynamic>.from(reportes[i])),
        ),
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _ReporteCard extends StatelessWidget {
  final dynamic reporte;
  final Map<String, IconData> tipoIconos;
  final Map<String, Color> nivelColores;
  final VoidCallback onTap;

  const _ReporteCard({
    required this.reporte,
    required this.tipoIconos,
    required this.nivelColores,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tipo  = reporte['tipo']?.toString() ?? 'Otro';
    final desc  = reporte['descripcion']?.toString() ?? '';
    final nivel = reporte['nivel_urgencia']?.toString().toLowerCase() ?? 'bajo';
    final fecha = _formatFecha(reporte['created_at']?.toString());

    final icon  = tipoIconos[tipo.toLowerCase()] ?? Icons.report_outlined;
    final color = nivelColores[nivel] ?? AppColors.riskLow;

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
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(tipo,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      _NivelBadge(nivel: nivel, color: color),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      desc,
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
                      Text(fecha,
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

  String _formatFecha(String? raw) {
    if (raw == null || raw.isEmpty) return 'Fecha desconocida';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Fecha desconocida';
    }
  }
}

class _NivelBadge extends StatelessWidget {
  final String nivel;
  final Color color;

  const _NivelBadge({required this.nivel, required this.color});

  @override
  Widget build(BuildContext context) {
    final label =
        nivel.isEmpty ? 'bajo' : nivel[0].toUpperCase() + nivel.substring(1);
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
