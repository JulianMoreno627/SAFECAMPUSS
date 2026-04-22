import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/language_toggle_button.dart';

final _localAuth = LocalAuthentication();
final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() => _biometricAvailable = canCheck && isSupported);
      }
    } catch (_) {}
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final l10n = AppLocalizations.of(context)!;
      final ok = await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (!ok) {
        if (mounted) {
          _showError(ref.read(authProvider).error ?? l10n.loginError);
        }
        return;
      }
      final box = Hive.box('settings');
      final token = ref.read(authProvider).token;
      if (token != null) await box.put('session_token', token);
      if (mounted) context.go('/map');
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() => _isLoading = true);
    try {
      final l10n = AppLocalizations.of(context)!;
      final account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() => _isLoading = false);
        return;
      }
      final auth = await account.authentication;
      // Enviar idToken al backend para validar y obtener sesión
      final response = await ApiService().loginWithGoogle(
        idToken: auth.idToken ?? '',
        email: account.email,
        nombre: account.displayName?.split(' ').first ?? '',
        apellido: account.displayName?.split(' ').skip(1).join(' ') ?? '',
      );
      if (response && mounted) {
        context.go('/map');
      } else if (mounted) {
        _showError(l10n.googleLoginFailed);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      if (mounted) {
        _showError(
          '${l10n.googleErrorPrefix}: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _biometricLogin() async {
    final l10n = AppLocalizations.of(context)!;
    // Verificar si hay sesión guardada
    final box = Hive.box('settings');
    final savedToken = box.get('session_token') as String?;
    if (savedToken == null || savedToken.isEmpty) {
      _showError(l10n.biometricSetupRequired);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: l10n.biometricPrompt,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) {
        ApiService().setToken(savedToken);
        context.go('/map');
      }
    } on PlatformException catch (e) {
      if (mounted) _showError('${l10n.biometricUnavailable}: ${e.message}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.riskHigh,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildStaticBackground(),
          const Positioned(
            top: 52,
            right: 20,
            child: LanguageToggleButton(),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildHeader(l10n),
                      const SizedBox(height: 32),
                      Expanded(child: _buildForm(l10n)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticBackground() {
    return Stack(
      children: [
        Positioned(
          top: -80, left: -60,
          child: Container(
            width: 250, height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.accent.withValues(alpha: 0.25),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -60, right: -80,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.riskLow.withValues(alpha: 0.15),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          top: 220, right: -40,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withValues(alpha: 0.3),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 30, spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(AppIcons.login, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, AppColors.accent],
            ).createShader(bounds),
            child: Text(
              l10n.appTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        FadeInDown(
          delay: const Duration(milliseconds: 300),
          child: Text(
            l10n.loginSubtitle,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
        ),
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.loginButton,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(l10n.loginSubtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              _buildEmailField(l10n),
              const SizedBox(height: 14),
              _buildPasswordField(l10n),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: Text(l10n.forgotPassword,
                      style: const TextStyle(color: AppColors.accent, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 20),
              _buildLoginButton(l10n),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildGoogleButton()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildBiometricButton()),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/register'),
                  child: RichText(
                    text: TextSpan(
                      text: l10n.noAccount,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                      children: [
                        TextSpan(
                          text: ' ${l10n.registerButton}',
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: l10n.emailLabel,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.accent),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
        errorStyle: const TextStyle(color: AppColors.riskHigh),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return l10n.fieldRequired;
        if (!v.contains('@')) return l10n.invalidEmail;
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: l10n.passwordLabel,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon:
            const Icon(Icons.lock_outline_rounded, color: AppColors.accent),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary, size: 20,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
        errorStyle: const TextStyle(color: AppColors.riskHigh),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return l10n.fieldRequired;
        if (v.length < 6) return l10n.minSixChars;
        return null;
      },
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          shadowColor: AppColors.accent.withValues(alpha: 0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.black))
            : Text(l10n.loginButton,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildDivider() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
            child: Divider(color: Colors.white.withValues(alpha: 0.1))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.orDivider,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ),
        Expanded(
            child: Divider(color: Colors.white.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildGoogleButton() {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _googleLogin,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 13),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      icon: Image.network(
        'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
        height: 20,
        errorBuilder: (_, __, ___) => const Icon(
            Icons.g_mobiledata_rounded,
            color: Colors.white, size: 24),
      ),
      label: Text(l10n.googleErrorPrefix == 'Google error' ? 'Google' : 'Google',
          style: const TextStyle(color: Colors.white, fontSize: 14),
          overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildBiometricButton() {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _biometricLogin,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 13),
        side: BorderSide(
            color: _biometricAvailable
                ? AppColors.accent.withValues(alpha: 0.5)
                : Colors.white12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(
        Icons.fingerprint_rounded,
        color:
            _biometricAvailable ? AppColors.accent : AppColors.textSecondary,
        size: 22,
      ),
      label: Text(
        l10n.biometricLabel,
        style: TextStyle(
            color: _biometricAvailable
                ? AppColors.accent
                : AppColors.textSecondary,
            fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
