import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../models/reporte.dart';
import 'location_provider.dart';

class ReportsState {
  final List<Reporte> reportesCercanos;
  final bool isLoading;
  final NivelRiesgo nivelRiesgo;
  final String? error;

  const ReportsState({
    this.reportesCercanos = const [],
    this.isLoading = false,
    this.nivelRiesgo = NivelRiesgo.bajo,
    this.error,
  });

  ReportsState copyWith({
    List<Reporte>? reportesCercanos,
    bool? isLoading,
    NivelRiesgo? nivelRiesgo,
    String? error,
  }) {
    return ReportsState(
      reportesCercanos: reportesCercanos ?? this.reportesCercanos,
      isLoading: isLoading ?? this.isLoading,
      nivelRiesgo: nivelRiesgo ?? this.nivelRiesgo,
      error: error ?? this.error,
    );
  }

  String get nivelRiesgoLabel => nivelRiesgo.label;
}

enum NivelRiesgo {
  bajo,
  medio,
  alto,
  critico;

  String get label {
    switch (this) {
      case NivelRiesgo.bajo:    return 'Bajo';
      case NivelRiesgo.medio:   return 'Medio';
      case NivelRiesgo.alto:    return 'Alto';
      case NivelRiesgo.critico: return 'Crítico';
    }
  }

  static NivelRiesgo fromString(String value) {
    switch (value.toLowerCase()) {
      case 'crítico':
      case 'critico': return NivelRiesgo.critico;
      case 'alto':    return NivelRiesgo.alto;
      case 'medio':   return NivelRiesgo.medio;
      default:        return NivelRiesgo.bajo;
    }
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ApiService _api = ApiService();
  final Ref ref;

  ReportsNotifier(this.ref) : super(const ReportsState()) {
    ref.listen(locationProvider, (previous, next) {
      if (next.currentPosition != null) {
        fetchNearbyReports(
            next.currentPosition!.latitude, next.currentPosition!.longitude);
      }
    });

    socketService.nuevoReporteStream.listen((data) {
      try {
        final nuevoReporte = Reporte.fromMap(data);
        if (!state.reportesCercanos.any((r) => r.id == nuevoReporte.id)) {
          final actualizados = [nuevoReporte, ...state.reportesCercanos];
          state = state.copyWith(
            reportesCercanos: actualizados,
            nivelRiesgo: _calcularNivelRiesgo(actualizados),
          );
        }
      } catch (e) {
        // Error parsing the realtime report
      }
    });
  }

  Future<void> fetchNearbyReports(double lat, double lng) async {
    state = state.copyWith(isLoading: true);
    try {
      final reportes = await _api.getReportesCercanos(lat, lng);
      state = state.copyWith(
        reportesCercanos: reportes,
        nivelRiesgo: _calcularNivelRiesgo(reportes),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  NivelRiesgo _calcularNivelRiesgo(List<Reporte> reportes) {
    if (reportes.isEmpty) return NivelRiesgo.bajo;
    final puntos = reportes.fold<int>(
        0, (sum, r) => sum + r.nivelUrgencia.puntos);
    if (puntos > 20) return NivelRiesgo.critico;
    if (puntos > 10) return NivelRiesgo.alto;
    if (puntos > 5)  return NivelRiesgo.medio;
    return NivelRiesgo.bajo;
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ref);
});
