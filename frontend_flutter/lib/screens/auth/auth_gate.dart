import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mio_mascot.dart';
import '../main_scaffold.dart';
import '../onboarding/onboarding_flow.dart';
import 'login_screen.dart';

/// Decides what the app shows based on auth state:
///  - unknown        -> splash while we check the stored token
///  - unauthenticated -> Login
///  - authenticated   -> the app (MainScaffold)
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    switch (auth.status) {
      case AuthStatus.unknown:
        return const _Splash();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        // New patients finish onboarding before entering the app.
        if (auth.user != null && !auth.user!.onboardingComplete) {
          return const OnboardingFlow();
        }
        return const MainScaffold();
    }
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MioMascot(variant: MioVariant.defaultMio, size: 96),
            SizedBox(height: 28),
            SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.teal)),
          ],
        ),
      ),
    );
  }
}
