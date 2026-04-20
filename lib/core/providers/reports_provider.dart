import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'location_provider.dart';

class ReportsState {
  final List<dynamic> reportesCercanos;
  final bool isLoading;
  final String nivelRiesgo; // 'Bajo', 'Medio', 'Alto', 'Crítico'
  final String? error;

  ReportsState({
    this.reportesCercanos = const [],
    this.isLoading = false,
    this.nivelRiesgo = 'Bajo',
    this.error,
  });

  ReportsState copyWith({
    List<dynamic>? reportesCercanos,
    bool? isLoading,
    String? nivelRiesgo,
    String? error,
  }) {
    return ReportsState(
      reportesCercanos: reportesCercanos ?? this.reportesCercanos,
      isLoading: isLoading ?? this.isLoading,
      nivelRiesgo: nivelRiesgo ?? this.nivelRiesgo,
      error: error ?? this.error,
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ApiService _apiService = ApiService();
  final Ref ref;

  ReportsNotifier(this.ref) : super(ReportsState()) {
    // Escuchar cambios de ubicación para actualizar reportes automáticamente
    ref.listen(locationProvider, (previous, next) {
      if (next.currentPosition != null) {
        fetchNearbyReports(next.currentPosition!.latitude, next.currentPosition!.longitude);
      }
    });
  }

  Future<void> fetchNearbyReports(double lat, double lng) async {
    state = state.copyWith(isLoading: true);
    try {
      final reportes = await _apiService.getReportesCercanos(lat, lng);
      
      // Calcular nivel de riesgo basado en cantidad y urgencia de reportes cercanos
      String riesgo = _calcularNivelRiesgo(reportes);

      state = state.copyWith(
        reportesCercanos: reportes,
        nivelRiesgo: riesgo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  String _calcularNivelRiesgo(List<dynamic> reportes) {
    if (reportes.isEmpty) return 'Bajo';
    
    int puntos = 0;
    for (var r in reportes) {
      switch (r['nivel_urgencia']?.toString().toLowerCase()) {
        case 'critico': puntos += 10; break;
        case 'alto': puntos += 5; break;
        case 'medio': puntos += 2; break;
        default: puntos += 1;
      }
    }

    if (puntos > 20) return 'Crítico';
    if (puntos > 10) return 'Alto';
    if (puntos > 5) return 'Medio';
    return 'Bajo';
  }
}

final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ref);
});
