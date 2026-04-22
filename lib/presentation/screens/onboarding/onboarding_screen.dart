import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../widgets/language_toggle_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinished();
    }
  }

  void _onFinished() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<OnboardingData> pages = [
      OnboardingData(
        icon: AppIcons.sos,
        title: l10n.onboard1Title,
        description: l10n.onboard1Desc,
        accentColor: AppColors.accent,
      ),
      OnboardingData(
        icon: AppIcons.map,
        title: l10n.onboard2Title,
        description: l10n.onboard2Desc,
        accentColor: AppColors.riskLow,
      ),
      OnboardingData(
        icon: Icons.psychology_rounded,
        title: l10n.onboard3Title,
        description: l10n.onboard3Desc,
        accentColor: AppColors.accent,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: pages.length,
            itemBuilder: (context, index) =>
                _OnboardingPage(data: pages[index]),
          ),

          // Boton de idioma — top-left
          const Positioned(
            top: 50,
            left: 20,
            child: LanguageToggleButton(),
          ),

          // Skip button — top-right
          Positioned(
            top: 50,
            right: 20,
            child: _currentPage < pages.length - 1
                ? TextButton(
                    onPressed: _onFinished,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: pages[_currentPage].accentColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Bottom controls
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? pages[_currentPage].accentColor
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _nextPage(pages.length),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pages[_currentPage].accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage < pages.length - 1 ? 'Next' : 'Get Started',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 100, color: data.accentColor),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
