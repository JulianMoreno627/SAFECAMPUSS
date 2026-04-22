import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_service.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _activated = false;

  // IA
  String? _aiAdvice;
  bool _loadingAdvice = false;
  String? _selectedEmergency;

  static const _emergencias = [
    ('Robo / Asalto', Icons.no_backpack_rounded, AppColors.riskHigh),
    ('Acoso', Icons.person_off_rounded, AppColors.riskMedium),
    ('Accidente', Icons.car_crash_rounded, AppColors.riskHigh),
    ('Pelea', Icons.sports_kabaddi_rounded, AppColors.riskCritical),
    ('Me siento en peligro', Icons.emergency_rounded, AppColors.sosRed),
    ('Otro', Icons.report_problem_rounded, AppColors.riskMedium),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getAdvice(String tipo) async {
    setState(() {
      _selectedEmergency = tipo;
      _loadingAdvice = true;
      _aiAdvice = null;
    });
    final advice = await AiService().getEmergencyAdvice(tipo);
    if (mounted) {
      setState(() {
        _aiAdvice = advice;
        _loadingAdvice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cs),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildSosButton(),
<<<<<<< HEAD
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                    const SizedBox(height: 28),
                    _buildAIAdvisor(),
                    const SizedBox(height: 28),
                    _buildEmergencyContacts(),
                    const SizedBox(height: 20),
=======
                    const SizedBox(height: 40),
                    _buildQuickActions(cs),
                    const SizedBox(height: 32),
                    _buildEmergencyContacts(cs),
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
=======
  Widget _buildHeader(ColorScheme cs) {
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
<<<<<<< HEAD
              Text('Emergencia SOS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              Text('Presiona y mantén para activar',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.history_rounded,
                  color: Colors.white54, size: 20),
            ),
=======
              Text(
                'Emergencia SOS',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Presiona y mantén para activar',
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.54),
                    fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history_rounded,
                color: cs.onSurface.withValues(alpha: 0.54), size: 20),
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
          ),
        ],
      ),
    );
  }

  // ── SOS Button ────────────────────────────────────────────────────────────

  Widget _buildSosButton() {
    return FadeInUp(
      child: GestureDetector(
        onLongPress: () => setState(() => _activated = !_activated),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulse = _activated ? _pulseController.value : 0.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220 + pulse * 30,
                  height: 220 + pulse * 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sosRed
                        .withValues(alpha: 0.08 + pulse * 0.08),
                  ),
                ),
                Container(
                  width: 180 + pulse * 16,
                  height: 180 + pulse * 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sosRed
                        .withValues(alpha: 0.15 + pulse * 0.1),
                  ),
                ),
                Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _activated
                        ? AppColors.sosRed
                        : Theme.of(context).cardColor,
                    border: Border.all(
                        color: AppColors.sosRed,
                        width: _activated ? 0 : 3),
                    boxShadow: [
                      BoxShadow(
<<<<<<< HEAD
                        color: AppColors.sosRed
                            .withValues(alpha: _activated ? 0.5 : 0.2),
=======
                        color: AppColors.sosRed.withValues(
                            alpha: _activated ? 0.5 : 0.2),
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
                        blurRadius: _activated ? 40 : 20,
                        spreadRadius: _activated ? 4 : 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
<<<<<<< HEAD
                      Icon(Icons.emergency_rounded,
                          color: _activated ? Colors.white : AppColors.sosRed,
                          size: 48),
=======
                      Icon(
                        Icons.emergency_rounded,
                        color: _activated
                            ? Colors.white
                            : AppColors.sosRed,
                        size: 48,
                      ),
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
                      const SizedBox(height: 4),
                      Text(
                        _activated ? 'ACTIVO' : 'SOS',
                        style: TextStyle(
                          color: _activated
                              ? Colors.white
                              : AppColors.sosRed,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

<<<<<<< HEAD
  // ── Quick Actions ─────────────────────────────────────────────────────────
=======
  Widget _buildQuickActions(ColorScheme cs) {
    final actions = [
      (Icons.phone_rounded, 'Llamar\nEmergencias', '123',
          AppColors.riskHigh),
      (Icons.share_location_rounded, 'Compartir\nUbicación', '',
          AppColors.accent),
      (Icons.record_voice_over_rounded, 'Alertar\nContactos', '',
          AppColors.riskMedium),
    ];
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db

  Widget _buildQuickActions() {
    return FadeInUp(
      delay: const Duration(milliseconds: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          const Text('Acciones Rápidas',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickActionButton(
                icon: Icons.phone_rounded,
                label: 'Llamar\nEmergencias',
                color: AppColors.riskHigh,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _QuickActionButton(
                icon: Icons.share_location_rounded,
                label: 'Compartir\nUbicación',
                color: AppColors.accent,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              _QuickActionButton(
                icon: Icons.record_voice_over_rounded,
                label: 'Alertar\nContactos',
                color: AppColors.riskMedium,
                onTap: () {},
              ),
            ],
=======
          Text(
            'Acciones Rápidas',
            style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: actions.map((a) {
              return Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child: _QuickActionButton(
                    icon: a.$1,
                    label: a.$2,
                    subtitle: a.$3,
                    color: a.$4,
                  ),
                ),
              );
            }).toList(),
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  // ── AI Advisor ────────────────────────────────────────────────────────────

  Widget _buildAIAdvisor() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_rounded,
                      color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Asistente de Emergencia',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text('SafeBot te guía paso a paso',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Selector de tipo de emergencia
            const Text('¿Qué está pasando?',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emergencias.map((e) {
                final isSelected = _selectedEmergency == e.$1;
                return GestureDetector(
                  onTap: () => _getAdvice(e.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? e.$3.withValues(alpha: 0.2)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? e.$3
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(e.$2,
                            size: 14,
                            color: isSelected ? e.$3 : Colors.white54),
                        const SizedBox(width: 6),
                        Text(e.$1,
                            style: TextStyle(
                                color: isSelected ? e.$3 : Colors.white54,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Respuesta IA
            if (_loadingAdvice || _aiAdvice != null) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _loadingAdvice
                    ? Row(
                        key: const ValueKey('loading'),
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.5, color: AppColors.accent),
                          ),
                          const SizedBox(width: 10),
                          Text('SafeBot preparando consejos...',
                              style: TextStyle(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.8),
                                  fontSize: 13)),
                        ],
                      )
                    : Column(
                        key: const ValueKey('advice'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.riskMedium, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Pasos de acción — $_selectedEmergency',
                                style: const TextStyle(
                                    color: AppColors.riskMedium,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _aiAdvice ?? '',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.6),
                          ),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Emergency Contacts ────────────────────────────────────────────────────

  Widget _buildEmergencyContacts() {
=======
  Widget _buildEmergencyContacts(ColorScheme cs) {
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
<<<<<<< HEAD
              const Text('Contactos de Emergencia',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push('/sos/contactos-emergencia'),
                icon: const Icon(Icons.add_rounded,
                    size: 16, color: AppColors.accent),
                label: const Text('Agregar',
                    style:
                        TextStyle(color: AppColors.accent, fontSize: 12)),
=======
              Text(
                'Contactos de Emergencia',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded,
                    size: 16, color: AppColors.accent),
                label: const Text('Agregar',
                    style: TextStyle(
                        color: AppColors.accent, fontSize: 12)),
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
              ),
            ],
          ),
          const SizedBox(height: 8),
<<<<<<< HEAD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Column(
              children: [
                Icon(Icons.group_add_rounded, color: Colors.white24, size: 40),
                SizedBox(height: 12),
                Text('Sin contactos de emergencia',
                    style: TextStyle(color: Colors.white54, fontSize: 14)),
                SizedBox(height: 4),
                Text(
                  'Agrega personas de confianza para alertarlas automáticamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
=======
          _buildContactPlaceholder(cs),
        ],
      ),
    );
  }

  Widget _buildContactPlaceholder(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.group_add_rounded,
              color: cs.onSurface.withValues(alpha: 0.24), size: 40),
          const SizedBox(height: 12),
          Text(
            'Sin contactos de emergencia',
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.54),
                fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega personas de confianza que serán alertadas en caso de emergencia',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.3),
                fontSize: 12),
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
=======
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ],
>>>>>>> 58271cffa769bba33d5fd7dd62f07d58de9a16db
        ),
      ),
    );
  }
}
