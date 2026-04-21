import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _activated = false;

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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildSosButton(),
                    const SizedBox(height: 40),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildEmergencyContacts(),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergencia SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Presiona y mantén para activar',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.history_rounded, color: Colors.white54, size: 20),
          ),
        ],
      ),
    );
  }

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
                // Outer pulse ring
                Container(
                  width: 220 + pulse * 30,
                  height: 220 + pulse * 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sosRed.withValues(alpha: 0.08 + pulse * 0.08),
                  ),
                ),
                // Middle ring
                Container(
                  width: 180 + pulse * 16,
                  height: 180 + pulse * 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.sosRed.withValues(alpha: 0.15 + pulse * 0.1),
                  ),
                ),
                // Main button
                Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _activated ? AppColors.sosRed : AppColors.cardColor,
                    border: Border.all(
                      color: AppColors.sosRed,
                      width: _activated ? 0 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sosRed.withValues(alpha: _activated ? 0.5 : 0.2),
                        blurRadius: _activated ? 40 : 20,
                        spreadRadius: _activated ? 4 : 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emergency_rounded,
                        color: _activated ? Colors.white : AppColors.sosRed,
                        size: 48,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activated ? 'ACTIVO' : 'SOS',
                        style: TextStyle(
                          color: _activated ? Colors.white : AppColors.sosRed,
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

  Widget _buildQuickActions() {
    final actions = [
      (Icons.phone_rounded, 'Llamar\nEmergencias', '123', AppColors.riskHigh),
      (Icons.share_location_rounded, 'Compartir\nUbicación', '', AppColors.accent),
      (Icons.record_voice_over_rounded, 'Alertar\nContactos', '', AppColors.riskMedium),
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: actions.map((a) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _QuickActionButton(
                    icon: a.$1,
                    label: a.$2,
                    subtitle: a.$3,
                    color: a.$4,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Contactos de Emergencia',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.accent),
                label: const Text('Agregar', style: TextStyle(color: AppColors.accent, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildContactPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildContactPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const Column(
        children: [
          Icon(Icons.group_add_rounded, color: Colors.white24, size: 40),
          SizedBox(height: 12),
          Text(
            'Sin contactos de emergencia',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Agrega personas de confianza que serán alertadas en caso de emergencia',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
