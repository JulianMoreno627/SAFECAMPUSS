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
import '../../widgets/reporte_detalle_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _sosActive = false;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final reportsState = ref.watch(reportsProvider);
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // ── Main Map ────────────────────────────────────────────────────
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
                MarkerLayer(
                  markers:
                      reportsState.reportesCercanos.map((report) {
                    return Marker(
                      point: LatLng(report['lat'], report['lng']),
                      width: 40,
                      height: 40,
                      child: _buildReportMarker(report),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ── Header ──────────────────────────────────────────────────────
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: _buildHeader(reportsState, l10n, cs),
          ),

          // ── Floating Action Buttons ─────────────────────────────────────
          Positioned(
            bottom: 30,
            right: 20,
            child: _buildFloatingActions(l10n, locationState),
          ),
        ],
      ),
    );
  }

  void _centerOnLocation(LatLng? position) {
    if (position != null) {
      _mapController.move(position, 16);
    }
  }

  Widget _buildLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withValues(alpha: 0.3),
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
            padding: const EdgeInsets.all(2),
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
  }

  Widget _buildReportMarker(dynamic report) {
    return GestureDetector(
      onTap: () => _showReportDetail(report),
      child: Hero(
        tag: 'report-${report['id']}',
        child: Container(
          decoration: BoxDecoration(
            color: _getRiskColor(report['nivel_urgencia']),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: _getRiskColor(report['nivel_urgencia'])
                    .withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(AppIcons.riskHigh,
              size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Color _getRiskColor(String? level) {
    switch (level?.toLowerCase()) {
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

  Widget _buildHeader(
      ReportsState reportsState, AppLocalizations l10n, ColorScheme cs) {
    return FadeInDown(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(AppIcons.map, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.mapTitle,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${l10n.riskLevel}: ${reportsState.nivelRiesgo}',
                    style: TextStyle(
                      color: _getRiskColor(reportsState.nivelRiesgo),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.notification,
                color: cs.onSurface.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions(
      AppLocalizations l10n, LocationState locationState) {
    final cardColor = Theme.of(context).cardColor;

    return Column(
      children: [
        FloatingActionButton(
          heroTag: 'my_location',
          onPressed: () =>
              _centerOnLocation(locationState.currentPosition),
          backgroundColor: cardColor,
          child:
              const Icon(AppIcons.location, color: AppColors.accent),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'sos',
          onPressed: () =>
              setState(() => _sosActive = !_sosActive),
          backgroundColor:
              _sosActive ? AppColors.sosRed : cardColor,
          child: Icon(AppIcons.sos,
              color: _sosActive ? Colors.white : AppColors.sosRed),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'report',
          onPressed: () => context.push('/map/crear-reporte'),
          backgroundColor: AppColors.accent,
          child:
              const Icon(AppIcons.report, color: Colors.black),
        ),
      ],
    );
  }

  void _showReportDetail(dynamic report) {
    ReporteDetalleSheet.show(
        context, Map<String, dynamic>.from(report));
  }
}
