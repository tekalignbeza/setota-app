import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_providers.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // ── Language ──
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.language, color: AppColors.info, size: 22),
            ),
            title: const Text('Language'),
            subtitle: Text(
              locale.languageCode == 'am' ? 'አማርኛ' : 'English',
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Select Language'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(localeProvider.notifier).setLocale('en');
                        Navigator.pop(ctx);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Text('🇺🇸 ', style: TextStyle(fontSize: 20)),
                            const Text('English'),
                            if (locale.languageCode == 'en') ...[
                              const Spacer(),
                              const Icon(Icons.check, color: AppColors.primary),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        ref.read(localeProvider.notifier).setLocale('am');
                        Navigator.pop(ctx);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Text('🇪🇹 ', style: TextStyle(fontSize: 20)),
                            const Text('አማርኛ'),
                            if (locale.languageCode == 'am') ...[
                              const Spacer(),
                              const Icon(Icons.check, color: AppColors.primary),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // ── Notifications ──
          SwitchListTile(
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.starGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.starGold, size: 22),
            ),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive order and promo updates'),
            value: _notificationsEnabled,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const Divider(),

          // ── Change Password ──
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline,
                  color: AppColors.secondary, size: 22),
            ),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(),

          // ── Dark Mode ──
          SwitchListTile(
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.dark_mode_outlined,
                  color: AppColors.grey500, size: 22),
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Coming soon'),
            value: false,
            onChanged: null,
          ),
          const Divider(),

          // ── App Version ──
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Setota v${AppConstants.appVersion}',
              style: AppTextStyles.caption,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Made with 💐 in Ethiopia',
              style: AppTextStyles.caption,
            ),
          ),
          const SizedBox(height: 32),

          // ── Delete Account ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'This action cannot be undone. All your data, orders, and preferences will be permanently deleted.\n\nAre you sure you want to continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Account deletion requested')),
                          );
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.error),
                        child: const Text('Delete Account'),
                      ),
                    ],
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete Account'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
