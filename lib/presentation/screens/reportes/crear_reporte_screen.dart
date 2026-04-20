import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class CrearReporteScreen extends StatefulWidget {
  const CrearReporteScreen({super.key});

  @override
  State<CrearReporteScreen> createState() => _CrearReporteScreenState();
}

class _CrearReporteScreenState extends State<CrearReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _testigosController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imagenSeleccionada;
  String? _tipoSeleccionado;
  String _nivelUrgencia = 'medio';
  bool _isLoading = false;
  bool _ubicacionObtenida = false;
  bool _isAnalyzing = false;
  late String _ubicacionTexto;
  late List<Map<String, dynamic>> _tiposIncidente;
  late List<Map<String, dynamic>> _nivelesUrgencia;

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

  // Tipos de incidente
  List<Map<String, dynamic>> _getTiposIncidente(BuildContext context) {
    return [
      {
        'tipo': 'Robo',
        'icon': Icons.phone_android_rounded,
        'color': AppColors.riskHigh
      },
      {
        'tipo': 'Acoso',
        'icon': Icons.warning_rounded,
        'color': AppColors.riskHigh
      },
      {
        'tipo': 'Persona sospechosa',
        'icon': Icons.person_off_rounded,
        'color': AppColors.riskMedium
      },
      {
        'tipo': 'Iluminación',
        'icon': Icons.light_mode_rounded,
        'color': AppColors.riskLow
      },
      {
        'tipo': 'Pelea',
        'icon': Icons.sports_mma_rounded,
        'color': AppColors.riskCritical
      },
      {
        'tipo': 'Vandalismo',
        'icon': Icons.broken_image_rounded,
        'color': AppColors.riskMedium
      },
      {
        'tipo': 'Accidente',
        'icon': Icons.car_crash_rounded,
        'color': AppColors.riskHigh
      },
      {
        'tipo': 'Otro',
        'icon': Icons.more_horiz_rounded,
        'color': AppColors.textSecondary
      },
    ];
  }

  // Niveles de urgencia
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
    _descripcionController.dispose();
    _testigosController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacion() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _ubicacionObtenida = true;
        _ubicacionTexto = 'Campus Universitario, Bloque C — Pasto';
      });
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.addPhoto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isAnalyzing)
              const Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI analizando...',
                    style: TextStyle(color: AppColors.accent, fontSize: 12),
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
      ),
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
          color: AppColors.cardColor,
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
              style: const TextStyle(
                color: Colors.white,
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
          backgroundColor: AppColors.riskHigh,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simular envío
      await Future.delayed(const Duration(seconds: 2));

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
            content: Text(l10n.errorGeneric),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Fondo decorativo
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
                // Header
                _buildHeader(),

                // Formulario
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sección foto
                          _buildSeccion(
                            '📸 Foto del Incidente',
                            'Opcional pero ayuda a la IA a clasificar mejor',
                            _buildFotoSection(),
                          ),

                          const SizedBox(height: 20),

                          // Sección tipo
                          _buildSeccion(
                            '🚨 Tipo de Incidente',
                            'Selecciona la categoría que mejor describe',
                            _buildTiposGrid(),
                          ),

                          const SizedBox(height: 20),

                          // Sección descripción
                          _buildSeccion(
                            '📝 Descripción',
                            'Cuéntanos qué pasó con el mayor detalle posible',
                            _buildDescripcionField(),
                          ),

                          const SizedBox(height: 20),

                          // Sección urgencia
                          _buildSeccion(
                            '⚡ Nivel de Urgencia',
                            'La IA también calculará su propio nivel',
                            _buildUrgenciaSelector(),
                          ),

                          const SizedBox(height: 20),

                          // Sección testigos
                          _buildSeccion(
                            '👥 Testigos',
                            'Número aproximado de personas que vieron el incidente',
                            _buildTestigosField(),
                          ),

                          const SizedBox(height: 20),

                          // Sección ubicación
                          _buildSeccion(
                            '📍 Ubicación',
                            'Se obtiene automáticamente',
                            _buildUbicacionCard(),
                          ),

                          const SizedBox(height: 20),

                          // Aviso IA
                          _buildAvisoIA(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botón enviar fijo abajo
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

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Reporte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ayuda a mantener el campus seguro',
                  style: TextStyle(
                    color: AppColors.textSecondary,
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
              child: const Row(
                children: [
                  Icon(Icons.psychology_rounded,
                      color: AppColors.accent, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'IA Activa',
                    style: TextStyle(
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

  // ── Sección wrapper ───────────────────────────────────────────────────────

  Widget _buildSeccion(String titulo, String subtitulo, Widget child) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Foto ──────────────────────────────────────────────────────────────────

  Widget _buildFotoSection() {
    return GestureDetector(
      onTap: _mostrarOpcionesImagen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: _imagenSeleccionada != null ? 200 : 130,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imagenSeleccionada != null
                ? AppColors.accent.withValues(alpha: 0.5)
                : Colors.white12,
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.psychology_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'IA analizará esta foto',
                            style: TextStyle(
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
                  const Text(
                    'Toca para agregar foto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cámara o galería',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Tipos de incidente ────────────────────────────────────────────────────

  Widget _buildTiposGrid() {
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
        final isSelected = _tipoSeleccionado == tipo['tipo'];
        return GestureDetector(
          onTap: () => setState(() => _tipoSeleccionado = tipo['tipo']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? (tipo['color'] as Color).withValues(alpha: 0.2)
                  : AppColors.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? tipo['color'] as Color : Colors.white12,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: (tipo['color'] as Color).withValues(alpha: 0.3),
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
                      : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  tipo['tipo'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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
        );
      },
    );
  }

  // ── Descripción ───────────────────────────────────────────────────────────

  Widget _buildDescripcionField() {
    return TextFormField(
      controller: _descripcionController,
      maxLines: 4,
      maxLength: 300,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText:
            'Ej: Vi a una persona sospechosa merodeando el parqueadero norte alrededor de las 10 PM...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        counterStyle: const TextStyle(color: AppColors.textSecondary),
        errorStyle: const TextStyle(color: AppColors.riskHigh),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Describe el incidente';
        if (v.length < 20) return 'Mínimo 20 caracteres';
        return null;
      },
    );
  }

  // ── Urgencia ──────────────────────────────────────────────────────────────

  Widget _buildUrgenciaSelector() {
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
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    nivel['icon'] as IconData,
                    color: isSelected ? color : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nivel['label'],
                    style: TextStyle(
                      color: isSelected ? color : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Testigos ──────────────────────────────────────────────────────────────

  Widget _buildTestigosField() {
    return Row(
      children: [
        // Botón menos
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
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child:
                const Icon(Icons.remove_rounded, color: Colors.white, size: 20),
          ),
        ),

        const SizedBox(width: 12),

        // Campo número
        Expanded(
          child: TextFormField(
            controller: _testigosController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
              filled: true,
              fillColor: AppColors.cardColor,
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

        // Botón más
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

  // ── Ubicación ─────────────────────────────────────────────────────────────

  Widget _buildUbicacionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _ubicacionObtenida
              ? AppColors.riskLow.withValues(alpha: 0.4)
              : Colors.white12,
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
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _ubicacionObtenida
                  ? Icons.location_on_rounded
                  : Icons.location_searching_rounded,
              color: _ubicacionObtenida
                  ? AppColors.riskLow
                  : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ubicacionObtenida ? 'Ubicación detectada' : 'Buscando...',
                  style: TextStyle(
                    color: _ubicacionObtenida
                        ? AppColors.riskLow
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _ubicacionTexto,
                  style: const TextStyle(
                    color: Colors.white,
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

  // ── Aviso IA ──────────────────────────────────────────────────────────────

  Widget _buildAvisoIA() {
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
      child: const Row(
        children: [
          Icon(Icons.psychology_rounded, color: AppColors.accent, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'La IA de SafeCampus analizará tu reporte, clasificará el incidente y notificará automáticamente a los estudiantes en un radio de 500m.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón enviar ──────────────────────────────────────────────────────────

  Widget _buildBotonEnviar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.white12)),
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
            _isLoading ? 'Enviando...' : 'Enviar Reporte',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
