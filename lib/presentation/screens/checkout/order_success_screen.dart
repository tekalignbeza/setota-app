import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Confetti decoration
              ..._buildConfetti(),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Green check
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 72,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Order Placed\nSuccessfully! 🎉',
                        style: AppTextStyles.h1.copyWith(height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Order #SET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                          style: AppTextStyles.body1
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your order is being prepared 💐',
                        style: AppTextStyles.body1
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ll notify you when it\'s on the way',
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/orders'),
                          icon: const Icon(Icons.local_shipping_outlined),
                          label: const Text('Track Order'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.local_florist),
                          label: const Text('Continue Shopping'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfetti() {
    final rng = Random(42);
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.giftPink,
      AppColors.starGold,
      AppColors.success,
      AppColors.info,
    ];
    return List.generate(20, (i) {
      final size = 6.0 + rng.nextDouble() * 12;
      return Positioned(
        left: rng.nextDouble() * 400,
        top: rng.nextDouble() * 200 + (i % 2 == 0 ? 0 : 600),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors[i % colors.length].withValues(alpha: 0.3 + rng.nextDouble() * 0.4),
            shape: i % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: i % 3 != 0
                ? BorderRadius.circular(2)
                : null,
          ),
        ),
      );
    });
  }
}
