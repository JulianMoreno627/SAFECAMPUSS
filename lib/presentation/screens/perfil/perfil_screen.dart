import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/usuario.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  String? _photoPath;
  final _picker = ImagePicker();

  static const _photoKey = 'profile_photo_path';

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  void _loadPhoto() {
    final path = Hive.box('settings').get(_photoKey) as String?;
    if (path != null && File(path).existsSync()) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Cambiar foto de perfil',
                style: TextStyle(
                    color: Theme.of(ctx).colorScheme.onSurface,
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _photoOption(ctx, Icons.camera_alt_rounded, 'Cámara', ImageSource.camera)),
              const SizedBox(width: 12),
              Expanded(child: _photoOption(ctx, Icons.photo_library_rounded, 'Galería', ImageSource.gallery)),
            ]),
            if (_photoPath != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _removePhoto();
                },
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.riskHigh),
                label: const Text('Eliminar foto', style: TextStyle(color: AppColors.riskHigh)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _photoOption(BuildContext ctx, IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(ctx);
        final file = await _picker.pickImage(source: source, imageQuality: 85);
        if (file != null) {
          await Hive.box('settings').put(_photoKey, file.path);
          if (mounted) setState(() => _photoPath = file.path);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.accent, size: 30),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurface, fontSize: 13)),
        ]),
      ),
    );
  }

  void _removePhoto() {
    Hive.box('settings').delete(_photoKey);
    setState(() => _photoPath = null);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final usuario = authState.usuario;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(context, usuario, l10n),
              const SizedBox(height: 32),
              _buildStatsRow(context, l10n),
              const SizedBox(height: 28),
              _buildOptions(context, l10n),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Usuario? user, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final nombre = user?.nombre ?? 'Usuario';
    final apellido = user?.apellido ?? '';
    final email = user?.email ?? '';
    final initials = user?.iniciales ?? 'U';

    return FadeInDown(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _photoPath == null
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 20, spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _photoPath != null
                      ? ClipOval(
                          child: Image.file(
                            File(_photoPath!),
                            width: 90, height: 90,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold)),
                        ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$nombre $apellido'.trim(),
            style: TextStyle(
                color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(email,
              style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.54), fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.riskLow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.riskLow.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                    color: AppColors.riskLow, size: 14),
                const SizedBox(width: 6),
                Text(
                  l10n.verifiedStudent,
                  style: const TextStyle(
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

  Widget _buildStatsRow(BuildContext context, AppLocalizations l10n) {
    return FadeInUp(
      child: Row(
        children: [
          _StatItem(value: '0', label: l10n.statsReports),
          _divider(context),
          _StatItem(value: '0', label: l10n.statsAlerts),
          _divider(context),
          _StatItem(value: '0', label: l10n.statsRoutes),
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

  Widget _buildOptions(BuildContext context, AppLocalizations l10n) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    return FadeInUp(
      delay: const Duration(milliseconds: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sectionAccount,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.54),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.person_outline_rounded,
            label: l10n.editProfile,
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.notifications_outlined,
            label: l10n.notificationsLabel,
            onTap: () => context.push('/perfil/notificaciones'),
          ),
          _OptionTile(
            icon: Icons.lock_outline_rounded,
            label: l10n.changePassword,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Text(
            l10n.sectionSecurity,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.54),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _OptionTile(
            icon: Icons.contacts_rounded,
            label: l10n.emergencyContactsMenu,
            onTap: () => context.push('/sos/contactos-emergencia'),
          ),
          _OptionTile(
            icon: Icons.history_rounded,
            label: l10n.reportHistory,
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.route_rounded,
            label: l10n.savedRoutes,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Text(
            l10n.sectionApp,
            style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.54),
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _ThemeToggleTile(isDark: isDark, ref: ref, l10n: l10n),
          _LangToggleTile(ref: ref, l10n: l10n),
          _OptionTile(
            icon: Icons.settings_outlined,
            label: l10n.settingsMenu,
            onTap: () => context.push('/perfil/configuracion'),
          ),
          _OptionTile(
            icon: Icons.help_outline_rounded,
            label: l10n.safetyGuide,
            onTap: () => context.push('/perfil/guia-seguridad'),
          ),
          _OptionTile(
            icon: Icons.info_outline_rounded,
            label: l10n.aboutApp,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.logout_rounded,
            label: l10n.logoutLabel,
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
  final AppLocalizations l10n;

  const _LangToggleTile({required this.ref, required this.l10n});

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
            isEs ? l10n.languageSpanish : l10n.languageEnglish,
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
  final AppLocalizations l10n;

  const _ThemeToggleTile({required this.isDark, required this.ref, required this.l10n});

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
            isDark ? l10n.darkMode : l10n.lightMode,
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
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurface.withValues(alpha: 0.24), size: 20),
          ],
        ),
      ),
    );
  }
}
