import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class GuiaSeguridadScreen extends StatefulWidget {
  const GuiaSeguridadScreen({super.key});

  @override
  State<GuiaSeguridadScreen> createState() => _GuiaSeguridadScreenState();
}

class _GuiaSeguridadScreenState extends State<GuiaSeguridadScreen> {
  int _expandido = -1;

  List<_Guia> _guias(AppLocalizations l10n) => [
    _Guia(
      icono: Icons.no_backpack_rounded,
      color: AppColors.riskHigh,
      titulo: l10n.guia1Title,
      pasos: [l10n.guia1Step1, l10n.guia1Step2, l10n.guia1Step3, l10n.guia1Step4, l10n.guia1Step5],
    ),
    _Guia(
      icono: Icons.person_off_rounded,
      color: AppColors.riskMedium,
      titulo: l10n.guia2Title,
      pasos: [l10n.guia2Step1, l10n.guia2Step2, l10n.guia2Step3, l10n.guia2Step4, l10n.guia2Step5],
    ),
    _Guia(
      icono: Icons.car_crash_rounded,
      color: AppColors.riskHigh,
      titulo: l10n.guia3Title,
      pasos: [l10n.guia3Step1, l10n.guia3Step2, l10n.guia3Step3, l10n.guia3Step4, l10n.guia3Step5],
    ),
    _Guia(
      icono: Icons.sports_kabaddi_rounded,
      color: AppColors.riskCritical,
      titulo: l10n.guia4Title,
      pasos: [l10n.guia4Step1, l10n.guia4Step2, l10n.guia4Step3, l10n.guia4Step4, l10n.guia4Step5],
    ),
    _Guia(
      icono: Icons.lightbulb_outline_rounded,
      color: AppColors.riskLow,
      titulo: l10n.guia5Title,
      pasos: [l10n.guia5Step1, l10n.guia5Step2, l10n.guia5Step3, l10n.guia5Step4, l10n.guia5Step5],
    ),
    _Guia(
      icono: Icons.phone_in_talk_rounded,
      color: AppColors.accent,
      titulo: l10n.guia6Title,
      pasos: [l10n.guia6Step1, l10n.guia6Step2, l10n.guia6Step3, l10n.guia6Step4, l10n.guia6Step5],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final guias = _guias(l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            _buildHeroBanner(l10n),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                itemCount: guias.length,
                itemBuilder: (context, i) => FadeInUp(
                  delay: Duration(milliseconds: i * 50),
                  child: _GuiaCard(
                    guia: guias[i],
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

  Widget _buildHeader(AppLocalizations l10n) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.guiaTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(l10n.guiaSubtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(AppLocalizations l10n) {
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
        child: Row(
          children: [
            const Icon(Icons.shield_rounded, color: Colors.white, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.guiaHeroTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.guiaHeroDesc,
                    style: const TextStyle(
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
