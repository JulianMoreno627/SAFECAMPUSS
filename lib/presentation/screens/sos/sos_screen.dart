import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/contacto_emergencia.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/emergency_contacts_provider.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _activated = false;

  String? _aiAdvice;
  bool _loadingAdvice = false;
  String? _selectedEmergency;

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

  List<(String, IconData, Color)> _emergencias(AppLocalizations l10n) => [
        (l10n.emergRobo, Icons.no_backpack_rounded, AppColors.riskHigh),
        (l10n.emergAcoso, Icons.person_off_rounded, AppColors.riskMedium),
        (l10n.emergAccidente, Icons.car_crash_rounded, AppColors.riskHigh),
        (l10n.emergPelea, Icons.sports_kabaddi_rounded, AppColors.riskCritical),
        (l10n.emergPeligro, Icons.emergency_rounded, AppColors.sosRed),
        (l10n.emergOtro, Icons.report_problem_rounded, AppColors.riskMedium),
      ];

  String? _localizedRelation(AppLocalizations l10n, String? relation) {
    switch (ContactoEmergencia.normalizeRelationCode(relation)) {
      case ContactoEmergencia.relationFamily:
        return l10n.relationshipFamily;
      case ContactoEmergencia.relationFriend:
        return l10n.relationshipFriend;
      case ContactoEmergencia.relationPartner:
        return l10n.relationshipPartner;
      case ContactoEmergencia.relationClassmate:
        return l10n.relationshipClassmate;
      case ContactoEmergencia.relationOther:
        return l10n.relationshipOther;
      default:
        return null;
    }
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

  Future<void> _callEmergencies() async {
    final l10n = AppLocalizations.of(context)!;
    final Uri tel = Uri.parse('tel:123');
    if (await canLaunchUrl(tel)) {
      await launchUrl(tel);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sosCallFailed)),
        );
      }
    }
  }

  Future<void> _shareLocation() async {
    final l10n = AppLocalizations.of(context)!;
    final location = ref.read(locationProvider);
    if (location.currentPosition == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sosObtainingLocationRetry)),
        );
      }
      return;
    }

    final lat = location.currentPosition!.latitude;
    final lng = location.currentPosition!.longitude;
    final mapUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    await Share.share(l10n.sosShareLocationMessage(mapUrl));
  }

  Future<void> _alertContacts() async {
    final l10n = AppLocalizations.of(context)!;
    final contacts = ref.read(emergencyContactsProvider).contacts;
    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sosNoContactsConfigured)),
        );
      }
      return;
    }

    final location = ref.read(locationProvider);
    String mapUrl = '';
    if (location.currentPosition != null) {
      final lat = location.currentPosition!.latitude;
      final lng = location.currentPosition!.longitude;
      mapUrl = ' https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }

    final message = mapUrl.isEmpty
        ? l10n.sosEmergencyAlertMessage
        : '${l10n.sosEmergencyAlertMessage}$mapUrl';
    final phones = contacts.map((c) => c.telefono).join(',');

    // Abrir app de SMS con los contactos y el mensaje
    final Uri smsUri =
        Uri.parse('sms:$phones?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      // Fallback a compartir el mensaje individualmente si sms: no es soportado
      await Share.share(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cs, l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildSosButton(l10n),
                    const SizedBox(height: 32),
                    _buildQuickActions(l10n),
                    const SizedBox(height: 28),
                    _buildAIAdvisor(l10n),
                    const SizedBox(height: 28),
                    _buildEmergencyContacts(l10n),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sosTitle,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.holdToActivate,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.54), fontSize: 13),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSosButton(AppLocalizations l10n) {
    return FadeInUp(
      child: GestureDetector(
        onLongPress: () {
          setState(() => _activated = !_activated);
          if (_activated) {
            _alertContacts();
            HapticFeedback.heavyImpact();
          }
        },
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
                    color:
                        AppColors.sosRed.withValues(alpha: 0.08 + pulse * 0.08),
                  ),
                ),
                Container(
                  width: 180 + pulse * 16,
                  height: 180 + pulse * 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AppColors.sosRed.withValues(alpha: 0.15 + pulse * 0.1),
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
                        color: AppColors.sosRed, width: _activated ? 0 : 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sosRed
                            .withValues(alpha: _activated ? 0.5 : 0.2),
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
                        _activated ? l10n.sosActiveLabel : 'SOS',
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

  Widget _buildQuickActions(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return FadeInUp(
      delay: const Duration(milliseconds: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: TextStyle(
                color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickActionButton(
                icon: Icons.phone_rounded,
                label: l10n.callEmergencies,
                color: AppColors.riskHigh,
                onTap: _callEmergencies,
              ),
              const SizedBox(width: 10),
              _QuickActionButton(
                icon: Icons.share_location_rounded,
                label: l10n.shareLocation,
                color: AppColors.accent,
                onTap: _shareLocation,
              ),
              const SizedBox(width: 10),
              _QuickActionButton(
                icon: Icons.record_voice_over_rounded,
                label: l10n.alertContacts,
                color: AppColors.riskMedium,
                onTap: _alertContacts,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIAdvisor(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final emergencias = _emergencias(l10n);
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.sosAdvisorTitle,
                          style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text(l10n.sosAdvisorSubtitle,
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.54),
                              fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(l10n.sosWhatsHappening,
                style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.7), fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emergencias.map((e) {
                final isSelected = _selectedEmergency == e.$1;
                return GestureDetector(
                  onTap: () => _getAdvice(e.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? e.$3.withValues(alpha: 0.2)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? e.$3 : cs.outlineVariant,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(e.$2,
                            size: 14,
                            color: isSelected
                                ? e.$3
                                : cs.onSurface.withValues(alpha: 0.54)),
                        const SizedBox(width: 6),
                        Text(e.$1,
                            style: TextStyle(
                                color: isSelected
                                    ? e.$3
                                    : cs.onSurface.withValues(alpha: 0.54),
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
            if (_loadingAdvice || _aiAdvice != null) ...[
              const SizedBox(height: 16),
              Divider(color: cs.outlineVariant),
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
                          Text(l10n.sosBotPreparing,
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
                              Expanded(
                                child: Text(
                                  '${l10n.sosActionSteps} — $_selectedEmergency',
                                  style: const TextStyle(
                                      color: AppColors.riskMedium,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _aiAdvice ?? '',
                            style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.7),
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

  Widget _buildEmergencyContacts(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final contactsState = ref.watch(emergencyContactsProvider);
    final contacts = contactsState.contacts;

    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.emergencyContacts,
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push('/sos/contactos-emergencia'),
                icon: const Icon(Icons.add_rounded,
                    size: 16, color: AppColors.accent),
                label: Text(l10n.addLabel,
                    style:
                        const TextStyle(color: AppColors.accent, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: contacts.isEmpty
                ? Column(
                    children: [
                      Icon(Icons.group_add_rounded,
                          color: cs.onSurface.withValues(alpha: 0.24),
                          size: 40),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noEmergencyContacts,
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.54),
                            fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.addTrustedPeople,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.3),
                            fontSize: 12),
                      ),
                    ],
                  )
                : Column(
                    children: contacts.take(3).map((c) {
                      final relationLabel =
                          _localizedRelation(l10n, c.relacion);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  AppColors.accent.withValues(alpha: 0.1),
                              child: Text(c.iniciales,
                                  style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(c.nombre,
                                  style: TextStyle(
                                      color: cs.onSurface, fontSize: 13)),
                            ),
                            if (relationLabel != null)
                              Text(relationLabel,
                                  style: TextStyle(
                                      color:
                                          cs.onSurface.withValues(alpha: 0.4),
                                      fontSize: 11)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

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
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
