import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notificacion.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

class NotificacionesState {
  final List<Notificacion> notificaciones;
  final bool isLoading;
  final String? error;

  const NotificacionesState({
    this.notificaciones = const [],
    this.isLoading = false,
    this.error,
  });

  int get noLeidas => notificaciones.where((n) => !n.leida).length;

  NotificacionesState copyWith({
    List<Notificacion>? notificaciones,
    bool? isLoading,
    String? error,
  }) {
    return NotificacionesState(
      notificaciones: notificaciones ?? this.notificaciones,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NotificacionesNotifier extends StateNotifier<NotificacionesState> {
  final Ref _ref;
  RealtimeChannel? _channel;

  NotificacionesNotifier(this._ref) : super(const NotificacionesState()) {
    _init();
  }

  Future<void> _init() async {
    await fetchNotificaciones();
    _subscribeRealtime();
  }

  Future<void> fetchNotificaciones() async {
    final userId = _ref.read(authProvider).usuario?.id;
    if (userId == null || userId.isEmpty) return;

    state = state.copyWith(isLoading: true);
    try {
      final maps = await ApiService().getNotificaciones(userId);
      final lista =
          maps.map((m) => Notificacion.fromMap(m)).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(notificaciones: lista, isLoading: false, error: null);
    } catch (e) {
      // Si la API falla, mantenemos la lista local sin crashear
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _subscribeRealtime() {
    final userId = _ref.read(authProvider).usuario?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      final supabase = Supabase.instance.client;
      _channel = supabase
          .channel('notificaciones_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notificaciones',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              final nueva = Notificacion.fromMap(payload.newRecord);
              state = state.copyWith(
                notificaciones: [nueva, ...state.notificaciones],
              );
            },
          )
          .subscribe();
    } catch (_) {
      // Supabase no configurado: funciona sólo con API REST
    }
  }

  Future<void> marcarLeida(String id) async {
    state = state.copyWith(
      notificaciones: state.notificaciones
          .map((n) => n.id == id ? n.marcarLeida() : n)
          .toList(),
    );
    try {
      await ApiService().marcarNotificacionLeida(id);
    } catch (_) {}
  }

  void marcarTodasLeidas() {
    state = state.copyWith(
      notificaciones:
          state.notificaciones.map((n) => n.marcarLeida()).toList(),
    );
    for (final n in state.notificaciones) {
      ApiService().marcarNotificacionLeida(n.id);
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final notificacionesProvider =
    StateNotifierProvider<NotificacionesNotifier, NotificacionesState>((ref) {
  return NotificacionesNotifier(ref);
});
