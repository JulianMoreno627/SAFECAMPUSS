import 'dart:async';
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
import '../../../core/services/routing_service.dart';
import '../../../core/services/ai_service.dart';
import '../../widgets/reporte_detalle_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  // ── Map ──────────────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  bool _centeredOnUser = false;
  bool _showZones = true;
  int _unreadCount = 0;
  int _lastSeenCount = 0;
  NivelUrgencia? _activeFilter;

  // ── Route ────────────────────────────────────────────────────────────────
  RouteResult? _route;
  LatLng? _routeDest;
  String _routeDestName = '';
  bool _loadingRoute = false;
  Map<String, dynamic>? _routeAI;
  bool _loadingAI = false;
  bool _showAICard = false;

  // ── Animation ────────────────────────────────────────────────────────────
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
          // ── Map ───────────────────────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: locationState.currentPosition ??
                    const LatLng(1.2136, -77.2811),
                initialZoom: 16,
                onTap: _route == null
                    ? null
                    : (_, __) {},
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.safecampus.safecampus_ai',
                ),

                // Danger zone circles (HeatMap Predictivo)
                if (_showZones)
                  CircleLayer(
                    circles: filtered.expand((r) {
                      final color = _nivelColor(r.nivelUrgencia);
                      final rMax = _dangerRadius(r.nivelUrgencia);
                      return [
                        CircleMarker(
                          point: LatLng(r.lat, r.lng),
                          radius: rMax,
                          useRadiusInMeter: true,
                          color: color.withValues(alpha: 0.05),
                          borderStrokeWidth: 0,
                        ),
                        CircleMarker(
                          point: LatLng(r.lat, r.lng),
                          radius: rMax * 0.6,
                          useRadiusInMeter: true,
                          color: color.withValues(alpha: 0.1),
                          borderStrokeWidth: 0,
                        ),
                        CircleMarker(
                          point: LatLng(r.lat, r.lng),
                          radius: rMax * 0.3,
                          useRadiusInMeter: true,
                          color: color.withValues(alpha: 0.25),
                          borderStrokeWidth: 0,
                        ),
                      ];
                    }).toList(),
                  ),

                // Active route — shadow + main polyline
                if (_route != null) ...[
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route!.points,
                        color: Colors.black.withValues(alpha: 0.2),
                        strokeWidth: 8,
                      ),
                    ],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route!.points,
                        color: _routeLineColor(),
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                ],

                // User location
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

                // Destination marker
                if (_routeDest != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _routeDest!,
                        width: 50,
                        height: 56,
                        child: _buildDestMarker(),
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

          // ── Header + Filter chips ─────────────────────────────────────────
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(child: _buildHeader(reportsState, l10n, cs)),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 80),
                  child: _buildFilterChips(reportsState),
                ),
              ],
            ),
          ),

          // ── AI route card (when route is active) ──────────────────────────
          if (_route != null && _showAICard)
            Positioned(
              bottom: 150,
              left: 20,
              right: 80,
              child: _buildRouteAICard(),
            ),

          // ── Route info bar (always visible when route active) ─────────────
          if (_route != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 80,
              child: _buildRouteInfoBar(),
            ),

          // ── FABs ──────────────────────────────────────────────────────────
          Positioned(
            bottom: 30,
            right: 20,
            child: _buildFabs(l10n, locationState),
          ),
        ],
      ),
    );
  }

  // ── Marker builders ───────────────────────────────────────────────────────

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
                color: AppColors.accent
                    .withValues(alpha: 0.12 + pulse * 0.08),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
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

  Widget _buildDestMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.flag_rounded,
              color: Colors.white, size: 18),
        ),
        Container(
          width: 3,
          height: 10,
          color: AppColors.accent,
        ),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
      ],
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
        child: Icon(reporte.tipo.mapIcon, size: size * 0.44, color: Colors.white),
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
                    color: riskColor.withValues(
                        alpha: 0.4 + _pulseController.value * 0.3),
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
                Text(l10n.mapTitle,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(
                  '${l10n.riskLevel}: ${state.nivelRiesgoLabel}  ·  ${state.reportesCercanos.length} reportes',
                  style: TextStyle(
                      color: riskColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _HeaderBtn(
            icon: Icons.layers_rounded,
            active: _showZones,
            activeColor: AppColors.accent,
            inactiveColor: cs.onSurface.withValues(alpha: 0.4),
            onTap: () => setState(() => _showZones = !_showZones),
          ),
          const SizedBox(width: 6),
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
                          shape: BoxShape.circle),
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold),
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
        children: chips.where((c) => c.filter == null || c.count > 0).map((chip) {
          final isActive = _activeFilter == chip.filter;
          final cs = Theme.of(context).colorScheme;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = chip.filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? chip.color : cs.surface.withValues(alpha: 0.93),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? chip.color : chip.color.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chip.label,
                      style: TextStyle(
                          color: isActive ? Colors.white : chip.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  if (chip.count > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.28)
                            : chip.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${chip.count}',
                          style: TextStyle(
                              color: isActive ? Colors.white : chip.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
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

  // ── Route info bar ────────────────────────────────────────────────────────

  Widget _buildRouteInfoBar() {
    if (_route == null) return const SizedBox.shrink();
    final lineColor = _routeLineColor();

    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: lineColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15), blurRadius: 12)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lineColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.route_rounded, color: lineColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _routeDestName.isNotEmpty
                        ? _routeDestName
                        : 'Destino',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  Row(
                    children: [
                      Icon(Icons.straighten_rounded,
                          size: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(
                        _route!.distanceLabel,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                            fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time_rounded,
                          size: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(
                        _route!.durationLabel,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // AI analysis toggle
            GestureDetector(
              onTap: () {
                if (_routeAI != null) {
                  setState(() => _showAICard = !_showAICard);
                } else {
                  _fetchRouteAI();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _loadingAI
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: AppColors.accent),
                      )
                    : Icon(
                        _showAICard
                            ? Icons.psychology_rounded
                            : Icons.psychology_outlined,
                        size: 18,
                        color: AppColors.accent,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // Clear route
            GestureDetector(
              onTap: _clearRoute,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.riskHigh.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.riskHigh),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AI route analysis card ────────────────────────────────────────────────

  Widget _buildRouteAICard() {
    if (_routeAI == null) return const SizedBox.shrink();
    final score = (_routeAI!['score_seguridad'] as num?)?.toInt() ?? 50;
    final nivel = _routeAI!['nivel_riesgo']?.toString() ?? 'medio';
    final reco = _routeAI!['recomendacion']?.toString() ?? '';
    final tips = (_routeAI!['tips'] as List?)
            ?.map((t) => t.toString())
            .take(3)
            .toList() ??
        [];
    final color = _colorFromNivel(nivel);
    final cs = Theme.of(context).colorScheme;

    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15), blurRadius: 14)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded,
                    color: AppColors.accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Análisis IA de Seguridad',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                const Spacer(),
                // Safety score circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(
                        color: color.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$score',
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Risk level badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 12, color: color),
                  const SizedBox(width: 5),
                  Text(
                    'Riesgo ${nivel.toUpperCase()}',
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (reco.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                reco,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                    height: 1.4),
              ),
            ],
            if (tips.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right_rounded,
                            size: 14, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                                color:
                                    cs.onSurface.withValues(alpha: 0.65),
                                fontSize: 11,
                                height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  // ── FABs ──────────────────────────────────────────────────────────────────

  Widget _buildFabs(AppLocalizations l10n, LocationState locationState) {
    final cardColor = Theme.of(context).cardColor;
    return Column(
      children: [
        FloatingActionButton(
          heroTag: 'my_location',
          mini: true,
          onPressed: () => _centerOnLocation(locationState.currentPosition),
          backgroundColor: cardColor,
          child: const Icon(AppIcons.location,
              color: AppColors.accent, size: 20),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'route',
          mini: true,
          onPressed: _loadingRoute ? null : _openRoutePlanner,
          backgroundColor: _route != null ? AppColors.accent : cardColor,
          child: _loadingRoute
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accent),
                )
              : Icon(
                  Icons.alt_route_rounded,
                  color: _route != null ? Colors.black : AppColors.accent,
                  size: 20,
                ),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'sos',
          onPressed: () => context.push('/sos'),
          backgroundColor: AppColors.sosRed,
          child: const Icon(AppIcons.sos, color: Colors.white),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'report',
          onPressed: () => context.push('/map/crear-reporte'),
          backgroundColor: AppColors.accent,
          child: const Icon(AppIcons.report, color: Colors.black),
        ),
      ],
    );
  }

  // ── Route planner sheet ────────────────────────────────────────────────────

  void _openRoutePlanner() {
    final userPos = ref.read(locationProvider).currentPosition;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RoutePlannerSheet(
        hasUserLocation: userPos != null,
        onRoute: (destPos, destName) {
          Navigator.pop(context);
          _calculateRoute(destPos, destName);
        },
      ),
    );
  }

  Future<void> _calculateRoute(LatLng dest, String destName) async {
    final userPos = ref.read(locationProvider).currentPosition;
    if (userPos == null) return;

    setState(() {
      _loadingRoute = true;
      _routeDest = dest;
      _routeDestName = destName;
      _route = null;
      _routeAI = null;
      _showAICard = false;
    });

    final result = await RoutingService().getRoute(userPos, dest);

    if (!mounted) return;
    if (result != null && result.points.isNotEmpty) {
      setState(() {
        _route = result;
        _loadingRoute = false;
      });
      // Fit map to the route bounds
      _fitRouteBounds(result.points);
      // Auto-fetch AI analysis
      _fetchRouteAI();
    } else {
      setState(() => _loadingRoute = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo calcular la ruta')),
        );
      }
    }
  }

  Future<void> _fetchRouteAI() async {
    if (_routeDest == null) return;
    setState(() {
      _loadingAI = true;
      _showAICard = false;
    });

    final reports = ref.read(reportsProvider).reportesCercanos;
    final now = TimeOfDay.now();
    final hora = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final result = await aiService.recomendarRuta(
      origen: 'Mi ubicación actual',
      destino: _routeDestName,
      hora: hora,
      reportesCercanos: reports,
    );

    if (!mounted) return;
    setState(() {
      _routeAI = result;
      _loadingAI = false;
      _showAICard = true;
    });
  }

  void _clearRoute() {
    setState(() {
      _route = null;
      _routeDest = null;
      _routeDestName = '';
      _routeAI = null;
      _showAICard = false;
    });
  }

  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    _mapController.move(LatLng(centerLat, centerLng), 14);
  }

  // ── Notifications panel ────────────────────────────────────────────────────

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

  void _centerOnLocation(LatLng? pos) {
    if (pos != null) _mapController.move(pos, 16);
  }

  // ── Color helpers ─────────────────────────────────────────────────────────

  Color _routeLineColor() {
    if (_routeAI == null) return AppColors.accent;
    return _colorFromNivel(_routeAI!['nivel_riesgo']?.toString() ?? 'bajo');
  }

  Color _colorFromNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'critico':
      case 'crítico':
        return AppColors.riskCritical;
      case 'alto':
        return AppColors.riskHigh;
      case 'medio':
        return AppColors.riskMedium;
      default:
        return AppColors.riskLow;
    }
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

// ── Header button ─────────────────────────────────────────────────────────────

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

// ── Route planner bottom sheet ────────────────────────────────────────────────

class _RoutePlannerSheet extends StatefulWidget {
  final bool hasUserLocation;
  final void Function(LatLng, String) onRoute;

  const _RoutePlannerSheet({
    required this.hasUserLocation,
    required this.onRoute,
  });

  @override
  State<_RoutePlannerSheet> createState() => _RoutePlannerSheetState();
}

class _RoutePlannerSheetState extends State<_RoutePlannerSheet> {
  final _destCtrl = TextEditingController();
  List<PlaceResult> _suggestions = [];
  bool _searching = false;
  bool _calculating = false;
  Timer? _debounce;

  @override
  void dispose() {
    _destCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onDestChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _searching = true);
      final results = await RoutingService().searchPlaces(value);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _searching = false;
        });
      }
    });
  }

  void _selectPlace(PlaceResult place) {
    setState(() {
      _calculating = true;
      _suggestions = [];
      _destCtrl.text = place.displayName;
    });
    widget.onRoute(place.position, place.displayName);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
              color: AppColors.accent.withValues(alpha: 0.3), width: 2),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), blurRadius: 30),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
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

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.alt_route_rounded,
                      color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ruta Segura',
                        style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const Text('Análisis IA de seguridad incluido',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Origin row
            _RouteField(
              icon: Icons.my_location_rounded,
              iconColor: AppColors.accent,
              label: 'Origen',
              value: widget.hasUserLocation
                  ? 'Mi ubicación actual'
                  : 'GPS no disponible',
              readOnly: true,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 2),
              child: Row(
                children: [
                  SizedBox(width: 17),
                  SizedBox(
                    height: 18,
                    child: VerticalDivider(
                        color: AppColors.accent, thickness: 1.5, width: 2),
                  ),
                ],
              ),
            ),

            // Destination field
            TextField(
              controller: _destCtrl,
              onChanged: _onDestChanged,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.flag_rounded,
                    color: AppColors.riskHigh, size: 20),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: AppColors.accent),
                        ),
                      )
                    : _destCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _destCtrl.clear();
                              setState(() => _suggestions = []);
                            },
                          )
                        : null,
                hintText: 'Busca un destino...',
                hintStyle: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.35),
                    fontSize: 14),
                filled: true,
                fillColor: cs.onSurface.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            // Suggestions list
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: cs.outlineVariant),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: cs.outlineVariant),
                  itemBuilder: (_, i) {
                    final s = _suggestions[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_rounded,
                          color: AppColors.accent, size: 18),
                      title: Text(
                        s.displayName,
                        style: TextStyle(
                            color: cs.onSurface, fontSize: 13),
                        maxLines: 2,
                      ),
                      onTap: () => _selectPlace(s),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Calculate button
            if (_suggestions.isEmpty && _destCtrl.text.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _calculating
                      ? null
                      : () async {
                          if (_destCtrl.text.trim().isEmpty) return;
                          setState(() => _searching = true);
                          final messenger = ScaffoldMessenger.of(context);
                          final results = await RoutingService()
                              .searchPlaces(_destCtrl.text);
                          if (!mounted) return;
                          setState(() => _searching = false);
                          if (results.isNotEmpty) {
                            _selectPlace(results.first);
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('Lugar no encontrado')),
                            );
                          }
                        },
                  icon: _calculating || _searching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.alt_route_rounded,
                          color: Colors.black),
                  label: Text(
                    _calculating ? 'Calculando...' : 'Trazar ruta segura',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RouteField extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool readOnly;

  const _RouteField({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                Text(value,
                    style:
                        TextStyle(color: cs.onSurface, fontSize: 13)),
              ],
            ),
          ),
        ],
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
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30),
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
                        Text('Alertas cercanas',
                            style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text('${reports.length} reportes en tu zona',
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.5),
                                fontSize: 12)),
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
                                color: AppColors.riskLow
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text('Sin alertas cercanas',
                                style: TextStyle(
                                    color:
                                        cs.onSurface.withValues(alpha: 0.5),
                                    fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: reports.length,
                        separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 72,
                            color: cs.outlineVariant),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      title: Text(reporte.tipo.label,
          style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14)),
      subtitle: Text(
        reporte.descripcion.isNotEmpty
            ? reporte.descripcion
            : 'Sin descripción',
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
            child: Text(reporte.nivelUrgencia.labelCapitalized,
                style: TextStyle(
                    color: _color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text(reporte.tiempoTranscurrido,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.38),
                  fontSize: 10)),
        ],
      ),
    );
  }
}
