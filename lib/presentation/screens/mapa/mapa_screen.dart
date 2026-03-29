import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();

  LatLng _currentPosition = const LatLng(1.2136, -77.2811);

  // 1. Definimos una posición inicial estática para evitar el error de 'Null'
  static const LatLng _pastoPosition = LatLng(1.2136, -77.2811);

  @override
  void initState() {
    super.initState();
    _determinarPosicion();
  }

  Future<void> _determinarPosicion() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor habilita la ubicación')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition, 16);
    }

    // Escuchar cambios de ubicación en tiempo real
    Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  bool _sosActivo = false;
  String _filtroActivo = 'Todo';

  Color _colorNivel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'critico':
        return AppColors.riskCritic;
      case 'alto':
        return AppColors.riskHigh;
      case 'medio':
        return AppColors.riskMedium;
      default:
        return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Mapa principal ──────────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pastoPosition, // Usamos la posición estática aquí
                initialZoom: 16,
                minZoom: 5,
                maxZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.safecampus.safecampus_ai',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition,
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Efecto de pulso
                          TweenAnimationBuilder(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(seconds: 2),
                            builder: (context, value, child) {
                              return Container(
                                width: 30 + (20 * value),
                                height: 30 + (20 * value),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withValues(alpha: 0.3 * (1 - value)),
                                ),
                              );
                            },
                          ),
                          // Círculo azul central
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── UI sobre el mapa ────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildBottomSheet(),
              ],
            ),
          ),

          // ── Botón SOS + Ubicación ───────────────────────────────────────
          _buildSOSButton(),
        ],
      ),
    );
  }

  // ── Barra superior ────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.97),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              color: AppColors.accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿A dónde vas?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Buscar ruta segura',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.white12,
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.tune_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildIconButton(
                  icon: Icons.notifications_rounded,
                  badge: true,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todo', Icons.layers_rounded),
                  _buildFilterChip('Robos', Icons.phone_android_rounded),
                  _buildFilterChip('Acoso', Icons.warning_rounded),
                  _buildFilterChip('Iluminación', Icons.light_mode_rounded),
                  _buildFilterChip('Sospechosos', Icons.person_off_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    bool badge = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (badge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.riskHigh,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _filtroActivo == label;
    return GestureDetector(
      onTap: () => setState(() => _filtroActivo = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.2)
              : AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.6)
                : Colors.white12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Panel inferior deslizable ─────────────────────────────────────────────

  Widget _buildBottomSheet() {
    return Container(); // Hacemos que el bottom sheet no ocupe espacio por ahora
  }

  // ── Botón SOS + ubicación ─────────────────────────────────────────────────

  Widget _buildSOSButton() {
    return Positioned(
      right: 16,
      bottom: 24,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _mapController.move(_currentPosition, 16),
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.97),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          GestureDetector(
            onTap: _activarSOS,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _sosActivo ? 68 : 60,
              height: _sosActivo ? 68 : 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sosRed,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sosRed
                        .withValues(alpha: _sosActivo ? 0.8 : 0.5),
                    blurRadius: _sosActivo ? 28 : 16,
                    spreadRadius: _sosActivo ? 8 : 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _sosActivo ? Icons.crisis_alert_rounded : Icons.sos_rounded,
                    color: Colors.white,
                    size: _sosActivo ? 28 : 24,
                  ),
                  if (!_sosActivo)
                    const Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Métodos ───────────────────────────────────────────────────────────────

  void _activarSOS() {
    setState(() => _sosActivo = !_sosActivo);
    if (_sosActivo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.crisis_alert_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('¡SOS Activado! Compartiendo ubicación...'),
            ],
          ),
          backgroundColor: AppColors.sosRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
