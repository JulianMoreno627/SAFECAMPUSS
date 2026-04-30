import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/reporte.dart';
import 'reports_provider.dart';

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
  final Ref ref;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _notifInitialized = false;
  DateTime? _lastAlertTime;

  LocationNotifier(this.ref) : super(LocationState()) {
    _init();
  }

  Future<void> _initNotifications() async {
    if (_notifInitialized) return;
    const androidParams = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinParams = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidParams, iOS: darwinParams);
    await _notificationsPlugin.initialize(initSettings);
    _notifInitialized = true;
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
      final newPos = LatLng(position.latitude, position.longitude);
      state = state.copyWith(currentPosition: newPos);
      _checkGeofencing(newPos);
    });
  }

  void _checkGeofencing(LatLng pos) async {
    await _initNotifications();
    
    // Evitar spam: máximo 1 alerta cada 5 minutos
    if (_lastAlertTime != null && DateTime.now().difference(_lastAlertTime!).inMinutes < 5) {
      return;
    }

    final reports = ref.read(reportsProvider).reportesCercanos;
    const distance = Distance();

    for (final r in reports) {
      if (r.nivelUrgencia == NivelUrgencia.critico) {
        final d = distance.as(LengthUnit.Meter, pos, LatLng(r.lat, r.lng));
        if (d <= 150) {
          _lastAlertTime = DateTime.now();
          _showWarningNotification(r);
          break; // Solo notificar 1 vez por ciclo
        }
      }
    }
  }

  Future<void> _showWarningNotification(Reporte r) async {
    const androidDetails = AndroidNotificationDetails(
      'geofencing_alerts',
      'Alertas de Proximidad',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      '⚠️ ZONA DE ALERTA CERCANA',
      'Estás a ${r.tipo.label} a menos de 150m. Mantente alerta.',
      details,
    );
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref);
});
