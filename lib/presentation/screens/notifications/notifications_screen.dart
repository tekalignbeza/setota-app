import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/notification_model.dart';
import '../../providers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationProvider.notifier).markAllAsRead(),
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 72, color: AppColors.grey300),
                  const SizedBox(height: 16),
                  Text('No Notifications', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  child: const Icon(Icons.done, color: AppColors.secondary),
                ),
                onDismissed: (_) => ref
                    .read(notificationProvider.notifier)
                    .markAsRead(n.id),
                child: Container(
                  color: n.isRead
                      ? Colors.transparent
                      : AppColors.primary.withValues(alpha: 0.03),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _typeColor(n.type).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_typeIcon(n.type),
                          color: _typeColor(n.type), size: 22),
                    ),
                    title: Text(
                      n.title,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight:
                            n.isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    subtitle: n.body != null
                        ? Text(n.body!,
                            style: AppTextStyles.caption, maxLines: 2)
                        : null,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _timeAgo(n.createdAt),
                          style: AppTextStyles.overline,
                        ),
                        if (!n.isRead) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(notificationProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return Icons.receipt_long;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.deliveryUpdate:
        return Icons.delivery_dining;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return AppColors.info;
      case NotificationType.promotion:
        return AppColors.giftPink;
      case NotificationType.deliveryUpdate:
        return AppColors.secondary;
      case NotificationType.system:
        return AppColors.grey600;
    }
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }
}
