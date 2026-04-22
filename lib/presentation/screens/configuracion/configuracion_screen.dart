import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  // Notificaciones
  bool _notifAlertas = true;
  bool _notifReportes = true;
  bool _notifSos = true;
  bool _notifIa = false;

  // Privacidad
  bool _compartirUbicacion = true;
  bool _ubicacionSegundoPlano = false;
  bool _reportesAnonimos = false;

  // App
  bool _sonido = true;
  bool _vibracion = true;
  String _radioAlertas = '500m';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(child: _buildSeccion('Notificaciones', _notifItems())),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 80),
                      child: _buildSeccion('Privacidad y Ubicación', _privItems()),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 160),
                      child: _buildSeccion('Radio de Alertas', _radioItems()),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 240),
                      child: _buildSeccion('Sonido y Vibración', _sonidoItems()),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 320),
                      child: _buildSeccion('Información', _infoItems()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuración',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('Personaliza tu experiencia',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeccion(String titulo, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo.toUpperCase(),
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  List<Widget> _notifItems() => [
        _ToggleTile(
          icon: Icons.warning_amber_rounded,
          label: 'Alertas de seguridad',
          subtitle: 'Incidentes cerca de tu ubicación',
          color: AppColors.riskHigh,
          value: _notifAlertas,
          onChanged: (v) => setState(() => _notifAlertas = v),
          isFirst: true,
        ),
        _ToggleTile(
          icon: Icons.report_rounded,
          label: 'Nuevos reportes',
          subtitle: 'Reportes enviados por la comunidad',
          color: AppColors.riskMedium,
          value: _notifReportes,
          onChanged: (v) => setState(() => _notifReportes = v),
        ),
        _ToggleTile(
          icon: Icons.emergency_rounded,
          label: 'Alertas SOS',
          subtitle: 'Emergencias activas en el campus',
          color: AppColors.sosRed,
          value: _notifSos,
          onChanged: (v) => setState(() => _notifSos = v),
        ),
        _ToggleTile(
          icon: Icons.psychology_rounded,
          label: 'Análisis de SafeBot',
          subtitle: 'Recomendaciones y tendencias de IA',
          color: AppColors.accent,
          value: _notifIa,
          onChanged: (v) => setState(() => _notifIa = v),
          isLast: true,
        ),
      ];

  List<Widget> _privItems() => [
        _ToggleTile(
          icon: Icons.share_location_rounded,
          label: 'Compartir ubicación',
          subtitle: 'Necesario para alertas en tiempo real',
          color: AppColors.accent,
          value: _compartirUbicacion,
          onChanged: (v) => setState(() => _compartirUbicacion = v),
          isFirst: true,
        ),
        _ToggleTile(
          icon: Icons.location_on_rounded,
          label: 'Ubicación en segundo plano',
          subtitle: 'Alertas aunque la app esté cerrada',
          color: AppColors.riskMedium,
          value: _ubicacionSegundoPlano,
          onChanged: (v) => setState(() => _ubicacionSegundoPlano = v),
        ),
        _ToggleTile(
          icon: Icons.visibility_off_rounded,
          label: 'Reportes anónimos',
          subtitle: 'Tu nombre no aparecerá en los reportes',
          color: AppColors.riskLow,
          value: _reportesAnonimos,
          onChanged: (v) => setState(() => _reportesAnonimos = v),
          isLast: true,
        ),
      ];

  List<Widget> _radioItems() {
    final opciones = ['200m', '500m', '1km', '2km'];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.radar_rounded,
                      color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Radio de detección',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      Text('Distancia para recibir alertas',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: opciones.map((op) {
                final sel = _radioAlertas == op;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _radioAlertas = op),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                          right: op != opciones.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.accent.withValues(alpha: 0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? AppColors.accent
                              : Colors.white12,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Text(op,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color:
                                  sel ? AppColors.accent : Colors.white38,
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _sonidoItems() => [
        _ToggleTile(
          icon: Icons.volume_up_rounded,
          label: 'Sonido',
          subtitle: 'Alertas con sonido',
          color: AppColors.riskMedium,
          value: _sonido,
          onChanged: (v) => setState(() => _sonido = v),
          isFirst: true,
        ),
        _ToggleTile(
          icon: Icons.vibration_rounded,
          label: 'Vibración',
          subtitle: 'Alertas con vibración',
          color: AppColors.riskLow,
          value: _vibracion,
          onChanged: (v) => setState(() => _vibracion = v),
          isLast: true,
        ),
      ];

  List<Widget> _infoItems() => [
        const _InfoTile(
          icon: Icons.info_outline_rounded,
          label: 'Versión',
          trailing: 'v1.0.0',
          isFirst: true,
        ),
        _InfoTile(
          icon: Icons.description_outlined,
          label: 'Términos y condiciones',
          onTap: () {},
        ),
        _InfoTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Política de privacidad',
          onTap: () {},
          isLast: true,
        ),
      ];
}

// ── Toggle tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : const BorderSide(color: Colors.white12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 13)),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
