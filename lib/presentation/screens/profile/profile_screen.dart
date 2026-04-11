import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final initials =
        '${(user?.firstName ?? 'U')[0]}${(user?.lastName ?? '')[0]}'.toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // ── Avatar & Name ──
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                child: Text(
                  initials,
                  style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${user?.firstName ?? 'User'} ${user?.lastName ?? ''}',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style:
                    AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              // ── Menu Items ──
              _MenuItem(
                icon: Icons.favorite_outline,
                iconColor: AppColors.heartRed,
                label: 'My Favorites',
                onTap: () => context.push('/favorites'),
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                iconColor: AppColors.secondary,
                label: 'My Addresses',
                onTap: () => context.push('/addresses'),
              ),
              _MenuItem(
                icon: Icons.credit_card_outlined,
                iconColor: AppColors.info,
                label: 'Payment Methods',
                trailing: _ComingSoon(),
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.starGold,
                label: 'Notifications',
                onTap: () => context.push('/notifications'),
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                iconColor: AppColors.grey600,
                label: 'Settings',
                onTap: () => context.push('/settings'),
              ),
              _MenuItem(
                icon: Icons.help_outline,
                iconColor: AppColors.accent,
                label: 'Help & Support',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Help & Support'),
                      content: const Text(
                        'Need help? Contact us:\n\n📧 support@setota.com\n📞 +251 911 123 456\n\nOr visit our help center at setota.com/help',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _MenuItem(
                icon: Icons.info_outline,
                iconColor: AppColors.secondary,
                label: 'About Us',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Row(
                        children: [
                          const Text('🌸 '),
                          Text('Setota',
                              style: AppTextStyles.h3
                                  .copyWith(color: AppColors.primary)),
                        ],
                      ),
                      content: const Text(
                        'Setota is Ethiopia\'s premier flower and gift delivery app.\n\nSend beautiful flowers, thoughtful gifts, and heartfelt messages to your loved ones.\n\nVersion 1.0.0',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Logout ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                            'Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(authProvider.notifier).logout();
                              context.go('/login');
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.error),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Logout',
                      style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(label),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.grey400),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Soon',
        style: TextStyle(fontSize: 11, color: AppColors.grey600),
      ),
    );
  }
}
