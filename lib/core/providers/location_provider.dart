import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationState {
  final LatLng? currentPosition;
  final bool isLoading;
  final String? error;

  LocationState({
    this.currentPosition,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    LatLng? currentPosition,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(isLoading: false, error: 'Servicio de ubicación desactivado');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(isLoading: false, error: 'Permiso denegado');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(isLoading: false, error: 'Permiso denegado permanentemente');
      return;
    }

    // Obtener ubicación inicial
    final position = await Geolocator.getCurrentPosition();
    state = state.copyWith(
      currentPosition: LatLng(position.latitude, position.longitude),
      isLoading: false,
    );

    // Escuchar cambios en tiempo real
    Geolocator.getPositionStream().listen((Position position) {
      state = state.copyWith(
        currentPosition: LatLng(position.latitude, position.longitude),
      );
    });
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
