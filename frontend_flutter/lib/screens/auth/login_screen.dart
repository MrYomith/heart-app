import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import 'auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _email.text.trim(),
            password: _password.text,
          );
      // On success the AuthGate swaps to the app automatically.
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _demoLogin(String email) async {
    setState(() { _error = null; _loading = true; });
    try {
      await ref.read(authControllerProvider.notifier).login(email: email, password: 'demo1234');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _demoChip(String label, String email) {
    return Expanded(
      child: GestureDetector(
        onTap: _loading ? null : () => _demoLogin(email),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(label, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)),
          ),
        ),
      ),
    );
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what is coming soon.'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: MioMascot(variant: MioVariant.happy, size: 92)),
                  const SizedBox(height: 24),
                  Text('Welcome back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Text("Mio is glad to see you. Let's continue your journey.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textMedium, height: 1.4)),
                  const SizedBox(height: 32),
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
                    hint: 'Your password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textLight),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _comingSoon('Password reset'),
                      child: Text('Forgot password?', style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.teal)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  MioErrorBanner(message: _error),
                  MioPrimaryButton(label: 'Log in', loading: _loading, onPressed: _submit),
                  const SizedBox(height: 24),
                  Row(children: [
                    const Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
                    ),
                    const Expanded(child: Divider(color: AppColors.border)),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => _comingSoon('Google sign-in'),
                      icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF4285F4))),
                      label: Text('Continue with Google', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Demo access (for testing / client preview) ──
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgTeal,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.science_outlined, size: 18, color: AppColors.teal),
                          const SizedBox(width: 6),
                          Text('Try the demo', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal)),
                        ]),
                        const SizedBox(height: 4),
                        Text('Explore a real patient journey — no signup needed.',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
                        const SizedBox(height: 10),
                        Row(children: [
                          _demoChip('🔍 Diagnosis', 'omar@example.com'),
                          const SizedBox(width: 8),
                          _demoChip('🩹 Inpatient', 'ahmet@example.com'),
                          const SizedBox(width: 8),
                          _demoChip('🚶 Rehab', 'maria@example.com'),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New here? ', style: GoogleFonts.poppins(fontSize: 14.5, color: AppColors.textMedium)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        ),
                        child: Text('Create account',
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
