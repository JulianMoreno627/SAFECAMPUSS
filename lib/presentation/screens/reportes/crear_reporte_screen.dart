import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../l10n/app_localizations.dart';

class CrearReporteScreen extends ConsumerStatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  ConsumerState<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends ConsumerState<CrearReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _testigosController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imagenSeleccionada;
  String? _tipoSeleccionado;
  String _nivelUrgencia = 'medio';
  bool _isLoading = false;
  bool _ubicacionObtenida = false;
  final bool _isAnalyzing = false;
  late String _ubicacionTexto;
  late List<Map<String, dynamic>> _tiposIncidente;
  late List<Map<String, dynamic>> _nivelesUrgencia;
  double? _lat;
  double? _lng;

  // IA
  Timer? _debounceTimer;
  bool _aiSuggesting = false;
  String? _aiSuggestedTipo;
  String? _aiSuggestedUrgencia;
  String? _aiRazon;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ubicacionTexto = AppLocalizations.of(context)!.obtainingLocation;
    _tiposIncidente = _getTiposIncidente(context);
    _nivelesUrgencia = _getNivelesUrgencia(context);
  }

  List<Map<String, dynamic>> _getTiposIncidente(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'code': 'Robo',
        'label': l10n.incidentTheft,
        'icon': Icons.phone_android_rounded,
        'color': AppColors.riskHigh
      },
      {
        'code': 'Acoso',
        'label': l10n.incidentHarassment,
        'icon': Icons.warning_rounded,
        'color': AppColors.riskHigh
      },
      {
        'code': 'Persona sospechosa',
        'label': l10n.incidentSuspiciousPerson,
        'icon': Icons.person_off_rounded,
        'color': AppColors.riskMedium
      },
      {
        'code': 'Iluminación',
        'label': l10n.incidentLighting,
        'icon': Icons.light_mode_rounded,
        'color': AppColors.riskLow
      },
      {
        'code': 'Pelea',
        'label': l10n.incidentFight,
        'icon': Icons.sports_mma_rounded,
        'color': AppColors.riskCritical
      },
      {
        'code': 'Vandalismo',
        'label': l10n.incidentVandalism,
        'icon': Icons.broken_image_rounded,
        'color': AppColors.riskMedium
      },
      {
        'code': 'Accidente',
        'label': l10n.incidentAccident,
        'icon': Icons.car_crash_rounded,
        'color': AppColors.riskHigh
      },
      {
        'code': 'Otro',
        'label': l10n.incidentOther,
        'icon': Icons.more_horiz_rounded,
        'color': Theme.of(context).colorScheme.onSurfaceVariant
      },
    ];
  }

  List<Map<String, dynamic>> _getNivelesUrgencia(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'nivel': 'bajo',
        'label': l10n.low,
        'color': AppColors.riskLow,
        'icon': Icons.arrow_downward_rounded
      },
      {
        'nivel': 'medio',
        'label': l10n.medium,
        'color': AppColors.riskMedium,
        'icon': Icons.remove_rounded
      },
      {
        'nivel': 'alto',
        'label': l10n.high,
        'color': AppColors.riskHigh,
        'icon': Icons.arrow_upward_rounded
      },
      {
        'nivel': 'critico',
        'label': l10n.critical,
        'color': AppColors.riskCritical,
        'icon': Icons.priority_high_rounded
      },
    ];
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _descripcionController.dispose();
    _testigosController.dispose();
    super.dispose();
  }

  void _onDescripcionChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().length < 20) {
      if (_aiSuggesting) setState(() => _aiSuggesting = false);
      return;
    }
    setState(() => _aiSuggesting = true);
    _debounceTimer = Timer(
        const Duration(milliseconds: 1600), () => _clasificarConIA(value));
  }

  Future<void> _clasificarConIA(String descripcion) async {
    final result = await AiService().classifyAndSuggest(descripcion);
    if (!mounted) return;
    setState(() {
      _aiSuggesting = false;
      if (result != null) {
        _aiSuggestedTipo = _normalizeIncidentType(result['tipo']?.toString());
        _aiSuggestedUrgencia = result['urgencia'];
        _aiRazon = result['razon'];
        _tipoSeleccionado ??= _aiSuggestedTipo;
        _nivelUrgencia = result['urgencia'] ?? _nivelUrgencia;
      }
    });
  }

  Future<void> _obtenerUbicacion() async {
    // 1. Try provider (already resolved)
    final providerPos = ref.read(locationProvider).currentPosition;
    if (providerPos != null) {
      _lat = providerPos.latitude;
      _lng = providerPos.longitude;
      await _resolverDireccion(_lat!, _lng!);
      return;
    }

    // 2. Last known position (instant, no GPS wait)
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _lat = last.latitude;
        _lng = last.longitude;
        await _resolverDireccion(_lat!, _lng!);
        return;
      }
    } catch (_) {}

    // 3. Fresh GPS with timeout
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      _lat = pos.latitude;
      _lng = pos.longitude;
      await _resolverDireccion(_lat!, _lng!);
    } catch (_) {
      if (mounted) {
        setState(() {
          _ubicacionObtenida = false;
          _ubicacionTexto = AppLocalizations.of(context)!.errorLocation;
        });
      }
    }
  }

  Future<void> _resolverDireccion(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (!mounted) return;
      final p = placemarks.isNotEmpty ? placemarks.first : null;
      final addr = [p?.street, p?.subLocality, p?.locality]
          .where((s) => s != null && s.isNotEmpty)
          .join(', ');
      setState(() {
        _ubicacionObtenida = true;
        _ubicacionTexto = addr.isNotEmpty
            ? addr
            : '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _ubicacionObtenida = true;
          _ubicacionTexto =
              '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
        });
      }
    }
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final XFile? imagen = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (imagen != null) {
      setState(() => _imagenSeleccionada = File(imagen.path));
    }
  }

  void _mostrarOpcionesImagen() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.addPhoto,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_isAnalyzing)
                Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.aiAnalyzing,
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 12),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildImageOption(
                      icon: Icons.camera_alt_rounded,
                      label: l10n.camera,
                      onTap: () {
                        Navigator.pop(context);
                        _seleccionarImagen(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageOption(
                      icon: Icons.photo_library_rounded,
                      label: l10n.gallery,
                      onTap: () {
                        Navigator.pop(context);
                        _seleccionarImagen(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarReporte() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_tipoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.selectType),
            backgroundColor: AppColors.riskHigh),
      );
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.waitingGps),
          backgroundColor: AppColors.riskMedium,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(authProvider).usuario?.id ?? '';
      await ApiService().crearReporte(
        tipo: _tipoSeleccionado!,
        descripcion: _descripcionController.text.trim(),
        nivelUrgencia: _nivelUrgencia,
        lat: _lat!,
        lng: _lng!,
        userId: userId,
      );

      await ref.read(reportsProvider.notifier).fetchNearbyReports(_lat!, _lng!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reportSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorGeneric}: $e'),
            backgroundColor: AppColors.riskCritical,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If location wasn't ready at initState, update as soon as provider resolves
    ref.listen(locationProvider, (prev, next) {
      if (_lat == null && next.currentPosition != null) {
        _lat = next.currentPosition!.latitude;
        _lng = next.currentPosition!.longitude;
        _resolverDireccion(_lat!, _lng!);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.riskHigh.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSeccion(
                            AppLocalizations.of(context)!.photoSectionTitle,
                            AppLocalizations.of(context)!.photoSectionSub,
                            _buildFotoSection(),
                          ),
                          const SizedBox(height: 20),
                          _buildSeccion(
                            AppLocalizations.of(context)!
                                .incidentTypeSectionTitle,
                            AppLocalizations.of(context)!
                                .incidentTypeSectionSub,
                            _buildTiposGrid(),
                          ),
                          const SizedBox(height: 20),
                          _buildSeccion(
                            AppLocalizations.of(context)!
                                .descriptionSectionTitle,
                            AppLocalizations.of(context)!.descriptionSectionSub,
                            _buildDescripcionField(),
                          ),
                          const SizedBox(height: 20),
                          _buildSeccion(
                            AppLocalizations.of(context)!.urgencySectionTitle,
                            AppLocalizations.of(context)!.urgencySectionSub,
                            _buildUrgenciaSelector(),
                          ),
                          const SizedBox(height: 20),
                          _buildSeccion(
                            AppLocalizations.of(context)!.witnessesSectionTitle,
                            AppLocalizations.of(context)!.witnessesSectionSub,
                            _buildTestigosField(),
                          ),
                          const SizedBox(height: 20),
                          _buildSeccion(
                            AppLocalizations.of(context)!.locationSectionTitle,
                            AppLocalizations.of(context)!.locationSectionSub,
                            _buildUbicacionCard(),
                          ),
                          const SizedBox(height: 20),
                          _buildAvisoIA(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBotonEnviar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: cs.onSurface,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createReport,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.helpKeepCampusSafe,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.riskHigh.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.riskHigh.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded,
                      color: AppColors.accent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    l10n.aiActive,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo, String subtitulo, Widget child) {
    final cs = Theme.of(context).colorScheme;
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFotoSection() {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _mostrarOpcionesImagen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: _imagenSeleccionada != null ? 200 : 130,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imagenSeleccionada != null
                ? AppColors.accent.withValues(alpha: 0.5)
                : cs.outlineVariant,
            width: _imagenSeleccionada != null ? 2 : 1,
          ),
        ),
        child: _imagenSeleccionada != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      _imagenSeleccionada!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _imagenSeleccionada = null),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.psychology_rounded,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            l10n.aiWillAnalyzePhoto,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.tapToAddPhoto,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.cameraOrGallery,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTiposGrid() {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _tiposIncidente.length,
      itemBuilder: (context, index) {
        final tipo = _tiposIncidente[index];
        final isSelected = _tipoSeleccionado == tipo['code'];
        final isAiSuggested = _aiSuggestedTipo == tipo['code'];
        return GestureDetector(
          onTap: () => setState(() => _tipoSeleccionado = tipo['code']),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (tipo['color'] as Color).withValues(alpha: 0.2)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? tipo['color'] as Color
                        : isAiSuggested
                            ? AppColors.accent.withValues(alpha: 0.6)
                            : cs.outlineVariant,
                    width: isSelected || isAiSuggested ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                (tipo['color'] as Color).withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tipo['icon'] as IconData,
                      color: isSelected
                          ? tipo['color'] as Color
                          : cs.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tipo['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isAiSuggested)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(AppLocalizations.of(context)!.aiShortLabel,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescripcionField() {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _descripcionController,
          maxLines: 4,
          maxLength: 300,
          style: TextStyle(color: cs.onSurface, fontSize: 14),
          onChanged: _onDescripcionChanged,
          decoration: InputDecoration(
            hintText: l10n.incidentExampleHint,
            hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            counterStyle: TextStyle(color: cs.onSurfaceVariant),
            errorStyle: const TextStyle(color: AppColors.riskHigh),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return l10n.describeIncident;
            if (v.length < 20) return l10n.minTwentyChars;
            return null;
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _aiSuggesting
              ? Padding(
                  key: const ValueKey('suggesting'),
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: AppColors.accent),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.aiClassifying,
                          style: TextStyle(
                              color: AppColors.accent.withValues(alpha: 0.8),
                              fontSize: 12)),
                    ],
                  ),
                )
              : _aiRazon != null
                  ? Padding(
                      key: const ValueKey('result'),
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology_rounded,
                              color: AppColors.accent, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${l10n.aiReasonPrefix}: $_aiRazon',
                              style: const TextStyle(
                                  color: AppColors.accent, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }

  Widget _buildUrgenciaSelector() {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: _nivelesUrgencia.map((nivel) {
        final isSelected = _nivelUrgencia == nivel['nivel'];
        final color = nivel['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _nivelUrgencia = nivel['nivel']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: nivel != _nivelesUrgencia.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : cs.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    nivel['icon'] as IconData,
                    color: isSelected ? color : cs.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nivel['label'],
                    style: TextStyle(
                      color: isSelected ? color : cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 14,
                    child: _aiSuggestedUrgencia == nivel['nivel']
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                                AppLocalizations.of(context)!.aiShortLabel,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold)),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTestigosField() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            final val = int.tryParse(_testigosController.text) ?? 0;
            if (val > 0) {
              _testigosController.text = (val - 1).toString();
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Icon(Icons.remove_rounded,
                color: Theme.of(context).colorScheme.onSurface, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _testigosController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 18,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            final val = int.tryParse(_testigosController.text) ?? 0;
            _testigosController.text = (val + 1).toString();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(Icons.add_rounded,
                color: AppColors.accent, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildUbicacionCard() {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _ubicacionObtenida
              ? AppColors.riskLow.withValues(alpha: 0.4)
              : cs.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _ubicacionObtenida
                  ? AppColors.riskLow.withValues(alpha: 0.15)
                  : cs.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _ubicacionObtenida
                  ? Icons.location_on_rounded
                  : Icons.location_searching_rounded,
              color:
                  _ubicacionObtenida ? AppColors.riskLow : cs.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ubicacionObtenida ? l10n.locationDetected : l10n.searching,
                  style: TextStyle(
                    color: _ubicacionObtenida
                        ? AppColors.riskLow
                        : cs.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _ubicacionTexto,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!_ubicacionObtenida)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          if (_ubicacionObtenida)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.riskLow,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildAvisoIA() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_rounded,
              color: AppColors.accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.aiAnalysisNotice,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonEnviar() {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _enviarReporte,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.riskHigh,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 6,
            shadowColor: AppColors.riskHigh.withValues(alpha: 0.4),
          ),
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send_rounded, size: 20),
          label: Text(
            _isLoading ? l10n.sending : l10n.sendReport,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String? _normalizeIncidentType(String? raw) {
    if (raw == null) return null;
    final normalized = raw
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();

    switch (normalized) {
      case 'robo':
      case 'theft':
        return 'Robo';
      case 'acoso':
      case 'harassment':
        return 'Acoso';
      case 'persona sospechosa':
      case 'suspicious person':
        return 'Persona sospechosa';
      case 'iluminacion':
      case 'lighting':
        return 'Iluminación';
      case 'pelea':
      case 'fight':
        return 'Pelea';
      case 'vandalismo':
      case 'vandalism':
        return 'Vandalismo';
      case 'accidente':
      case 'accident':
        return 'Accidente';
      case 'otro':
      case 'other':
        return 'Otro';
      default:
        return raw;
    }
  }
}
