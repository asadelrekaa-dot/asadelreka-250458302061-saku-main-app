import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../dashboard/dashboard_page.dart';
import 'auth_actions.dart';
import 'auth_scaffold.dart';
import 'auth_text_field.dart';
import 'google_auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordHidden = true;
  bool _confirmPasswordHidden = true;
  bool _canSubmit = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_syncButtonState);
    _passwordController.addListener(_syncButtonState);
    _confirmPasswordController.addListener(_syncButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _syncButtonState() {
    final canSubmit = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    if (_canSubmit != canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isSubmitting = true);
    try {
      final user = await GoogleAuthService.instance.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            userName: _displayNameFromUser(user.displayName, user.email),
            userEmail: user.email ?? _emailController.text.trim(),
          ),
        ),
      );
    } on GoogleAuthSetupException catch (error) {
      if (!mounted) return;
      _showGoogleAuthMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _continueWithGoogle() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final user = await GoogleAuthService.instance.authenticate();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            userName: _displayNameFromUser(user.displayName, user.email),
            userEmail: user.email ?? 'google@saku.app',
          ),
        ),
      );
    } on GoogleAuthSetupException catch (error) {
      if (!mounted) return;
      _showGoogleAuthMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showGoogleAuthMessage(
          'Daftar dengan Google dibatalkan atau belum siap.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showGoogleAuthMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Daftar',
      subtitle:
          'Satu langkah buat keuangan kamu yang\nlebih terkontrol - daftar sekarang!',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                label: 'Email',
                hint: 'Masukkan email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),
              const SizedBox(height: 22),
              AuthTextField(
                label: 'Password',
                hint: 'Masukkan password',
                controller: _passwordController,
                obscureText: _passwordHidden,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _passwordHidden = !_passwordHidden);
                  },
                  icon: Icon(
                    _passwordHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: SakuColors.neutral600,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              AuthTextField(
                label: 'Konfirmasi Password',
                hint: 'Masukkan ulang password',
                controller: _confirmPasswordController,
                obscureText: _confirmPasswordHidden,
                textInputAction: TextInputAction.done,
                validator: _validateConfirmPassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(
                      () => _confirmPasswordHidden = !_confirmPasswordHidden,
                    );
                  },
                  icon: Icon(
                    _confirmPasswordHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: SakuColors.neutral600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        AuthPrimaryButton(
          label: _isSubmitting ? 'Memproses...' : 'Daftar',
          enabled: _canSubmit && !_isSubmitting,
          onPressed: _submit,
        ),
        const AuthDividerLabel(),
        GoogleAuthButton(
          label: 'Daftar dengan Google',
          onPressed: _continueWithGoogle,
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'Sudah punya akun? ',
              style: TextStyle(fontSize: 16),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: SakuColors.blue700,
              ),
              child: const Text(
                'Masuk',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email wajib diisi';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Password wajib diisi';
    if ((value ?? '').length < 6) return 'Minimal 6 karakter';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != _passwordController.text) return 'Password belum sama';
    return null;
  }

  String _displayNameFromUser(String? displayName, String? email) {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final prefix = email?.split('@').first.trim();
    if (prefix != null && prefix.isNotEmpty) return prefix;

    return 'Pengguna';
  }
}
