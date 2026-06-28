import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _consent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Mirror the backend password rule (FR-001) for instant feedback.
  bool get _passwordStrong {
    final p = _password.text;
    return p.length >= 12 &&
        RegExp(r'[a-z]').hasMatch(p) &&
        RegExp(r'[A-Z]').hasMatch(p) &&
        RegExp(r'\d').hasMatch(p) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(p);
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (!_passwordStrong) {
      setState(() => _error = 'Password needs 12+ characters with uppercase, lowercase, a number and a symbol.');
      return;
    }
    if (!_consent) {
      setState(() => _error = 'Please accept the Terms and Privacy Policy to continue.');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            consentAccepted: _consent,
          );
      // AuthGate swaps to the app on success.
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: MioMascot(variant: MioVariant.calm, size: 84)),
                  const SizedBox(height: 20),
                  Text('Create your account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Text("Mio will guide you through every step of your heart journey.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textMedium, height: 1.4)),
                  const SizedBox(height: 28),
                  MioTextField(
                    controller: _name,
                    label: 'Full name',
                    hint: 'e.g. Ahmet Yilmaz',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 18),
                  MioTextField(
                    controller: _email,
                    label: 'Email',
                    hint: 'you@example.com',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  MioTextField(
                    controller: _password,
                    label: 'Password',
                    hint: 'Create a password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textLight),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_passwordStrong ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          size: 16, color: _passwordStrong ? AppColors.success : AppColors.textLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('At least 12 characters, with an uppercase, lowercase, number and symbol.',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: _passwordStrong ? AppColors.success : AppColors.textMedium)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // GDPR consent (FR-001)
                  GestureDetector(
                    onTap: () => setState(() => _consent = !_consent),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _consent,
                          onChanged: (v) => setState(() => _consent = v ?? false),
                          activeColor: AppColors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text('I agree to the Terms of Service and Privacy Policy, and consent to MioHeart processing my health data to support my recovery.',
                                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium, height: 1.45)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  MioErrorBanner(message: _error),
                  MioPrimaryButton(label: 'Create account', loading: _loading, onPressed: _submit),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: GoogleFonts.poppins(fontSize: 14.5, color: AppColors.textMedium)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text('Log in',
                            style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
