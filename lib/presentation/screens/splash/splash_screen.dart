import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Check auth state
    await ref.read(authProvider.notifier).checkAuthState();

    // Wait for splash duration
    await Future.delayed(
      const Duration(milliseconds: AppConstants.splashDurationMillis),
    );

    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go('/home');
    } else {
      // Router handles onboarding check via redirect
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / Emoji
            const Text(
              '🌸',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 16),

            // App Name in Amharic
            Text(
              'ስጦታ',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.primary,
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 8),

            // App Name in English
            Text(
              AppConstants.appName,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),

            // Tagline
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
