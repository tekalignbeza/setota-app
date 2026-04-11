import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/locale_provider.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String description;
  final Color accentColor;
  final IconData icon;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.icon,
  });
}

const _pages = [
  _OnboardingPage(
    emoji: '🌸',
    title: 'Send Beautiful Flowers',
    description:
        'Browse a curated collection of fresh flowers and bouquets for every occasion.',
    accentColor: AppColors.primary,
    icon: Icons.local_florist,
  ),
  _OnboardingPage(
    emoji: '🚚',
    title: 'Same Day Delivery',
    description:
        'Order before noon and get your flowers delivered the same day across Addis Ababa.',
    accentColor: AppColors.secondary,
    icon: Icons.delivery_dining,
  ),
  _OnboardingPage(
    emoji: '🎁',
    title: 'Gift with Love',
    description:
        'Add a personal message and send anonymously. Surprise your loved ones today!',
    accentColor: AppColors.giftPink,
    icon: Icons.card_giftcard,
  ),
];

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

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.onboardingCompleteKey, true);
    if (mounted) context.go('/login');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration container
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: page.accentColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              page.icon,
                              size: 80,
                              color: page.accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          style: AppTextStyles.h1.copyWith(
                            color: page.accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? _pages[_currentPage].accentColor
                          : AppColors.grey300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
