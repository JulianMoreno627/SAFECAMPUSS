import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:animate_do/animate_do.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/models/reporte.dart';
import '../../widgets/reporte_detalle_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _centeredOnUser = false;
  bool _showZones = true;
  int _unreadCount = 0;
  int _lastSeenCount = 0;
  NivelUrgencia? _activeFilter;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final reportsState = ref.watch(reportsProvider);
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    ref.listen(locationProvider, (prev, next) {
      if (!_centeredOnUser && next.currentPosition != null) {
        _centeredOnUser = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(next.currentPosition!, 16);
        });
      }
    });

    ref.listen(reportsProvider, (prev, next) {
      final total = next.reportesCercanos.length;
      if (_lastSeenCount > 0 && total > _lastSeenCount) {
        setState(() => _unreadCount += total - _lastSeenCount);
      }
      if (total != _lastSeenCount) _lastSeenCount = total;
    });

    final filtered = _activeFilter == null
        ? reportsState.reportesCercanos
        : reportsState.reportesCercanos
            .where((r) => r.nivelUrgencia == _activeFilter)
            .toList();

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ─────────────────────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: locationState.currentPosition ??
                    const LatLng(1.2136, -77.2811),
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.safecampus.safecampus_ai',
                ),

                // Danger zone circles
                if (_showZones)
                  CircleLayer(
                    circles: filtered.map((r) {
                      final color = _nivelColor(r.nivelUrgencia);
                      return CircleMarker(
                        point: LatLng(r.lat, r.lng),
                        radius: _dangerRadius(r.nivelUrgencia),
                        useRadiusInMeter: true,
                        color: color.withValues(alpha: 0.14),
                        borderColor: color.withValues(alpha: 0.45),
                        borderStrokeWidth: 1.5,
                      );
                    }).toList(),
                  ),

                // User location marker
                if (locationState.currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: locationState.currentPosition!,
                        width: 60,
                        height: 60,
                        child: _buildLocationMarker(),
                      ),
                    ],
                  ),

                // Report markers
                MarkerLayer(
                  markers: filtered.map((reporte) {
                    final sz = _markerSize(reporte.nivelUrgencia);
                    return Marker(
                      point: LatLng(reporte.lat, reporte.lng),
                      width: sz,
                      height: sz,
                      child: _buildReportMarker(reporte, sz),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ── Header + Filter chips ────────────────────────────────────────
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: _buildHeader(reportsState, l10n, cs),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 80),
                  child: _buildFilterChips(reportsState),
                ),
              ],
            ),
          ),

          // ── FABs ─────────────────────────────────────────────────────────
          Positioned(
            bottom: 30,
            right: 20,
            child: _buildFabs(l10n, locationState),
          ),
        ],
      ),
    );
  }

  // ── Markers ──────────────────────────────────────────────────────────────

  Widget _buildLocationMarker() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final pulse = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36 + pulse * 10,
              height: 36 + pulse * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12 + pulse * 0.08),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportMarker(Reporte reporte, double size) {
    final color = _nivelColor(reporte.nivelUrgencia);
    final core = GestureDetector(
      onTap: () => ReporteDetalleSheet.show(context, reporte),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.55),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          reporte.tipo.mapIcon,
          size: size * 0.44,
          color: Colors.white,
        ),
      ),
    );

    if (reporte.nivelUrgencia == NivelUrgencia.critico) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (_, child) => Transform.scale(
          scale: 0.88 + _pulseController.value * 0.16,
          child: child,
        ),
        child: core,
      );
    }
    return core;
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
      ReportsState state, AppLocalizations l10n, ColorScheme cs) {
    final riskColor = _riesgoColor(state.nivelRiesgo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Risk dot
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: riskColor,
                boxShadow: [
                  BoxShadow(
                    color: riskColor
                        .withValues(alpha: 0.4 + _pulseController.value * 0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.mapTitle,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${l10n.riskLevel}: ${state.nivelRiesgoLabel}  ·  ${state.reportesCercanos.length} reportes',
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Zones toggle
          _HeaderBtn(
            icon: Icons.layers_rounded,
            active: _showZones,
            activeColor: AppColors.accent,
            inactiveColor: cs.onSurface.withValues(alpha: 0.4),
            onTap: () => setState(() => _showZones = !_showZones),
          ),
          const SizedBox(width: 6),

          // Bell with badge
          GestureDetector(
            onTap: _openNotificationsPanel,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _HeaderBtn(
                  icon: _unreadCount > 0
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_rounded,
                  active: _unreadCount > 0,
                  activeColor: AppColors.riskHigh,
                  inactiveColor: cs.onSurface.withValues(alpha: 0.5),
                  onTap: _openNotificationsPanel,
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.riskCritical,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips(ReportsState state) {
    final all = state.reportesCercanos;

    final chips = [
      (label: 'Todos', filter: null as NivelUrgencia?, color: AppColors.accent, count: all.length),
      (label: 'Crítico', filter: NivelUrgencia.critico, color: AppColors.riskCritical, count: all.where((r) => r.nivelUrgencia == NivelUrgencia.critico).length),
      (label: 'Alto', filter: NivelUrgencia.alto, color: AppColors.riskHigh, count: all.where((r) => r.nivelUrgencia == NivelUrgencia.alto).length),
      (label: 'Medio', filter: NivelUrgencia.medio, color: AppColors.riskMedium, count: all.where((r) => r.nivelUrgencia == NivelUrgencia.medio).length),
      (label: 'Bajo', filter: NivelUrgencia.bajo, color: AppColors.riskLow, count: all.where((r) => r.nivelUrgencia == NivelUrgencia.bajo).length),
    ];

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: chips
            .where((c) => c.filter == null || c.count > 0)
            .map((chip) {
          final isActive = _activeFilter == chip.filter;
          final cs = Theme.of(context).colorScheme;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = chip.filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? chip.color
                    : cs.surface.withValues(alpha: 0.93),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? chip.color
                      : chip.color.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chip.label,
                    style: TextStyle(
                      color: isActive ? Colors.white : chip.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (chip.count > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.28)
                            : chip.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${chip.count}',
                        style: TextStyle(
                          color: isActive ? Colors.white : chip.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── FABs ─────────────────────────────────────────────────────────────────

  Widget _buildFabs(AppLocalizations l10n, LocationState locationState) {
    final cardColor = Theme.of(context).cardColor;
    return Column(
      children: [
        FloatingActionButton(
          heroTag: 'my_location',
          onPressed: () => _centerOnLocation(locationState.currentPosition),
          backgroundColor: cardColor,
          child: const Icon(AppIcons.location, color: AppColors.accent),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'sos',
          onPressed: () => context.push('/sos'),
          backgroundColor: AppColors.sosRed,
          child: const Icon(AppIcons.sos, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'report',
          onPressed: () => context.push('/map/crear-reporte'),
          backgroundColor: AppColors.accent,
          child: const Icon(AppIcons.report, color: Colors.black),
        ),
      ],
    );
  }

  // ── Notifications panel ───────────────────────────────────────────────────

  void _openNotificationsPanel() {
    setState(() => _unreadCount = 0);
    final reports = ref.read(reportsProvider).reportesCercanos;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationsPanel(reports: reports),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _centerOnLocation(LatLng? pos) {
    if (pos != null) _mapController.move(pos, 16);
  }

  Color _nivelColor(NivelUrgencia n) {
    switch (n) {
      case NivelUrgencia.critico: return AppColors.riskCritical;
      case NivelUrgencia.alto:    return AppColors.riskHigh;
      case NivelUrgencia.medio:   return AppColors.riskMedium;
      case NivelUrgencia.bajo:    return AppColors.riskLow;
    }
  }

  Color _riesgoColor(NivelRiesgo n) {
    switch (n) {
      case NivelRiesgo.critico: return AppColors.riskCritical;
      case NivelRiesgo.alto:    return AppColors.riskHigh;
      case NivelRiesgo.medio:   return AppColors.riskMedium;
      case NivelRiesgo.bajo:    return AppColors.riskLow;
    }
  }

  double _dangerRadius(NivelUrgencia n) {
    switch (n) {
      case NivelUrgencia.critico: return 250;
      case NivelUrgencia.alto:    return 180;
      case NivelUrgencia.medio:   return 120;
      case NivelUrgencia.bajo:    return 70;
    }
  }

  double _markerSize(NivelUrgencia n) {
    switch (n) {
      case NivelUrgencia.critico: return 48;
      case NivelUrgencia.alto:    return 42;
      case NivelUrgencia.medio:   return 36;
      case NivelUrgencia.bajo:    return 32;
    }
  }
}

// ── Small header button ───────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _HeaderBtn({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.15)
              : cs.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: active ? activeColor : inactiveColor),
      ),
    );
  }
}

// ── Notifications panel ───────────────────────────────────────────────────────

class _NotificationsPanel extends StatelessWidget {
  final List<Reporte> reports;
  const _NotificationsPanel({required this.reports});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.88,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                  color: AppColors.accent.withValues(alpha: 0.3), width: 2),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2), blurRadius: 30),
            ],
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_rounded,
                          color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alertas cercanas',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${reports.length} reportes en tu zona',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: cs.outlineVariant),
              Expanded(
                child: reports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 52,
                                color:
                                    AppColors.riskLow.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              'Sin alertas cercanas',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: reports.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, indent: 72, color: cs.outlineVariant),
                        itemBuilder: (_, i) => _NotifTile(
                          reporte: reports[i],
                          onTap: () {
                            Navigator.pop(context);
                            ReporteDetalleSheet.show(context, reports[i]);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onTap;
  const _NotifTile({required this.reporte, required this.onTap});

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
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _color.withValues(alpha: 0.3)),
        ),
        child: Icon(reporte.tipo.mapIcon, color: _color, size: 20),
      ),
      title: Text(
        reporte.tipo.label,
        style: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        reporte.descripcion.isNotEmpty ? reporte.descripcion : 'Sin descripción',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.5), fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              reporte.nivelUrgencia.labelCapitalized,
              style: TextStyle(
                  color: _color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reporte.tiempoTranscurrido,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.38),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
