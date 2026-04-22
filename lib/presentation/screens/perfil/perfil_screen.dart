import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, user),
              const SizedBox(height: 32),
              _buildStatsRow(context),
              const SizedBox(height: 28),
              _buildOptions(context, ref),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic>? user) {
    final cs = Theme.of(context).colorScheme;
    final nombre = user?['nombre'] ?? 'Usuario';
    final apellido = user?['apellido'] ?? '';
    final email = user?['email'] ?? '';
    final initials = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return FadeInDown(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 14, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$nombre $apellido'.trim(),
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.54), fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.riskLow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.riskLow.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded,
                    color: AppColors.riskLow, size: 14),
                SizedBox(width: 6),
                Text(
                  'Estudiante Verificado',
                  style: TextStyle(
                      color: AppColors.riskLow,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return FadeInUp(
      child: Row(
        children: [
          const _StatItem(value: '0', label: 'Reportes'),
          _divider(context),
          const _StatItem(value: '0', label: 'Alertas'),
          _divider(context),
          const _StatItem(value: '0', label: 'Rutas'),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(
        width: 1,
        height: 40,
        color: Theme.of(context).colorScheme.outlineVariant);
  }

  Widget _buildOptions(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    return FadeInUp(
      delay: const Duration(milliseconds: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuenta',
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.54),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.person_outline_rounded,
            label: 'Editar Perfil',
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.notifications_outlined,
            label: 'Notificaciones',
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.lock_outline_rounded,
            label: 'Cambiar Contraseña',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Text(
            'Seguridad',
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.54),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.contacts_rounded,
            label: 'Contactos de Emergencia',
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.history_rounded,
            label: 'Historial de Reportes',
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.route_rounded,
            label: 'Rutas Guardadas',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Text(
            'App',
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.54),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // ── Toggle Dark/Light ─────────────────────────────────────────
          _ThemeToggleTile(isDark: isDark, ref: ref),
          // ── Toggle Idioma ─────────────────────────────────────────────
          _LangToggleTile(ref: ref),
          _OptionTile(
            icon: Icons.settings_outlined,
            label: 'Configuración',
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.help_outline_rounded,
            label: 'Guía de Seguridad',
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.info_outline_rounded,
            label: 'Acerca de',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.logout_rounded,
            label: 'Cerrar Sesión',
            color: AppColors.riskHigh,
            onTap: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

// ── Language Toggle ───────────────────────────────────────────────────────────

class _LangToggleTile extends ConsumerWidget {
  final WidgetRef ref;

  const _LangToggleTile({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final cs = Theme.of(context).colorScheme;
    final isEs = widgetRef.watch(localeProvider).languageCode == 'es';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language_rounded,
            color: AppColors.accent.withValues(alpha: 0.8),
            size: 20,
          ),
          const SizedBox(width: 14),
          Text(
            isEs ? 'Español' : 'English',
            style: TextStyle(color: cs.onSurface, fontSize: 14),
          ),
          const Spacer(),
          Switch(
            value: isEs,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
            onChanged: (_) =>
                widgetRef.read(localeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }
}

// ── Theme Toggle ──────────────────────────────────────────────────────────────

class _ThemeToggleTile extends ConsumerWidget {
  final bool isDark;
  final WidgetRef ref;

  const _ThemeToggleTile({required this.isDark, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppColors.accent.withValues(alpha: 0.8),
            size: 20,
          ),
          const SizedBox(width: 14),
          Text(
            isDark ? 'Modo Oscuro' : 'Modo Claro',
            style: TextStyle(color: cs.onSurface, fontSize: 14),
          ),
          const Spacer(),
          Switch(
            value: isDark,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
            onChanged: (_) =>
                widgetRef.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }
}

// ── Inner widgets ─────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.54),
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: c.withValues(alpha: 0.8), size: 20),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: c, fontSize: 14)),
            const Spacer(),
            if (color == null)
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurface.withValues(alpha: 0.24), size: 20),
          ],
        ),
      ),
    );
  }
}
