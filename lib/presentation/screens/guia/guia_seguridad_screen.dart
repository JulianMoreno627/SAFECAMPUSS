import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';

class GuiaSeguridadScreen extends StatefulWidget {
  const GuiaSeguridadScreen({super.key});

  @override
  State<GuiaSeguridadScreen> createState() => _GuiaSeguridadScreenState();
}

class _GuiaSeguridadScreenState extends State<GuiaSeguridadScreen> {
  int _expandido = -1;

  static const _guias = [
    _Guia(
      icono: Icons.no_backpack_rounded,
      color: AppColors.riskHigh,
      titulo: 'Ante un Robo o Asalto',
      pasos: [
        'No ofrezcas resistencia. Tu seguridad vale más que cualquier objeto.',
        'Memoriza características del agresor: ropa, altura, dirección que tomó.',
        'Aleja de la zona de inmediato y busca un lugar público y concurrido.',
        'Llama a emergencias (123) y reporta el incidente en SafeCampus.',
        'Conserva cualquier evidencia (mensajes, fotos) para el reporte policial.',
      ],
    ),
    _Guia(
      icono: Icons.person_off_rounded,
      color: AppColors.riskMedium,
      titulo: 'Ante Acoso',
      pasos: [
        'Sal del lugar y busca personas o zonas de seguridad del campus.',
        'Documenta: fecha, hora, lugar, descripción del agresor.',
        'Reporta en SafeCampus para alertar a otros estudiantes.',
        'Habla con la oficina de bienestar universitario o seguridad del campus.',
        'Si el acoso es digital, guarda capturas y bloquea al agresor.',
      ],
    ),
    _Guia(
      icono: Icons.car_crash_rounded,
      color: AppColors.riskHigh,
      titulo: 'Ante un Accidente',
      pasos: [
        'Evalúa la situación sin exponerte a más riesgos.',
        'Llama al 123 (emergencias) si hay heridos.',
        'No muevas a personas heridas salvo peligro inminente.',
        'Señaliza el área para prevenir más accidentes.',
        'Reporta el incidente en SafeCampus para activar alertas en la zona.',
      ],
    ),
    _Guia(
      icono: Icons.sports_kabaddi_rounded,
      color: AppColors.riskCritical,
      titulo: 'Ante una Pelea',
      pasos: [
        'No intervengas físicamente — llama a seguridad del campus.',
        'Aleja de la zona inmediatamente.',
        'Llama al número de seguridad del campus o al 123.',
        'Reporta en SafeCampus con la ubicación exacta.',
        'Si hay heridos, espera a los servicios de emergencia.',
      ],
    ),
    _Guia(
      icono: Icons.lightbulb_outline_rounded,
      color: AppColors.riskLow,
      titulo: 'Prevención General',
      pasos: [
        'Comparte tu ubicación con contactos de confianza cuando vayas solo/a.',
        'Evita zonas poco iluminadas o solitarias de noche.',
        'Mantén el teléfono cargado y el volumen al mínimo en zonas de riesgo.',
        'Usa auriculares con un solo oído para mantener conciencia del entorno.',
        'Configura tus contactos de emergencia en SafeCampus.',
      ],
    ),
    _Guia(
      icono: Icons.phone_in_talk_rounded,
      color: AppColors.accent,
      titulo: 'Números de Emergencia',
      pasos: [
        '123 — Policía Nacional',
        '132 — Bomberos',
        '125 — Defensa Civil',
        '115 — Cruz Roja',
        'Seguridad campus — consulta el directorio institucional',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildHeroBanner(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                itemCount: _guias.length,
                itemBuilder: (context, i) => FadeInUp(
                  delay: Duration(milliseconds: i * 50),
                  child: _GuiaCard(
                    guia: _guias[i],
                    expandido: _expandido == i,
                    onTap: () =>
                        setState(() => _expandido = _expandido == i ? -1 : i),
                  ),
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
              Text('Guía de Seguridad',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('Protocolos de acción ante emergencias',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.shield_rounded, color: Colors.white, size: 36),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mantente preparado/a',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    'Conocer los protocolos de seguridad puede salvar vidas. Toca cada situación para ver los pasos de acción.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modelo ────────────────────────────────────────────────────────────────────

class _Guia {
  final IconData icono;
  final Color color;
  final String titulo;
  final List<String> pasos;

  const _Guia({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.pasos,
  });
}

// ── Card expandible ───────────────────────────────────────────────────────────

class _GuiaCard extends StatelessWidget {
  final _Guia guia;
  final bool expandido;
  final VoidCallback onTap;

  const _GuiaCard({
    required this.guia,
    required this.expandido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: expandido
              ? guia.color.withValues(alpha: 0.08)
              : AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: expandido
                ? guia.color.withValues(alpha: 0.4)
                : Colors.white12,
            width: expandido ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: guia.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(guia.icono, color: guia.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      guia.titulo,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expandido ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white38, size: 22),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: expandido
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Divider(
                        color: guia.color.withValues(alpha: 0.25),
                        height: 1),
                    const SizedBox(height: 12),
                    ...guia.pasos.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: guia.color.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.key + 1}',
                                    style: TextStyle(
                                        color: guia.color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  e.value,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
