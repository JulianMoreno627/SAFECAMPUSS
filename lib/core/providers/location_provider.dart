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

  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.medium,
    distanceFilter: 10,
  );

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
          isLoading: false, error: 'Servicio de ubicación desactivado');
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
      state = state.copyWith(
          isLoading: false, error: 'Permiso denegado permanentemente');
      return;
    }

    // Try last known first (instant response)
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        state = state.copyWith(
          currentPosition: LatLng(last.latitude, last.longitude),
          isLoading: false,
        );
      }
    } catch (_) {}

    // Request accurate position with timeout
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );
      state = state.copyWith(
        currentPosition: LatLng(position.latitude, position.longitude),
        isLoading: false,
      );
    } catch (_) {
      if (state.currentPosition == null) {
        state = state.copyWith(
            isLoading: false, error: 'No se pudo obtener la ubicación');
      } else {
        state = state.copyWith(isLoading: false);
      }
    }

    // Stream updates
    Geolocator.getPositionStream(locationSettings: _locationSettings)
        .listen((Position position) {
      state = state.copyWith(
        currentPosition: LatLng(position.latitude, position.longitude),
      );
    });
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
