import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrdersList(provider: activeOrdersProvider, emptyLabel: 'No active orders', ref: ref),
            _OrdersList(provider: pastOrdersProvider, emptyLabel: 'No past orders', ref: ref),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final AutoDisposeProvider<AsyncValue<List<OrderModel>>> provider;
  final String emptyLabel;
  final WidgetRef ref;
  const _OrdersList({required this.provider, required this.emptyLabel, required this.ref});

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(provider);

    return orders.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: AppColors.grey300),
                const SizedBox(height: 12),
                Text(emptyLabel,
                    style:
                        AppTextStyles.body1.copyWith(color: AppColors.grey500)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(provider),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OrderCard(order: list[index]),
          ),
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Failed to load orders', style: AppTextStyles.body1),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(provider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getStatusColor(order.status.name.toUpperCase());
    final dateStr = order.createdAt != null
        ? DateFormat('MMM d, yyyy').format(order.createdAt!)
        : '';

    return GestureDetector(
      onTap: () => context.push('/order/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderNumber ?? order.id.substring(0, 8)}',
                    style:
                        AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.name.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(dateStr, style: AppTextStyles.caption),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                order.items.map((i) => i.productName ?? 'Item').join(', '),
                style: AppTextStyles.body2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.priceSmall,
                ),
                const Spacer(),
                if (order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.cancelled)
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/order/${order.id}/tracking'),
                    icon: const Icon(Icons.local_shipping_outlined, size: 16),
                    label: const Text('Track'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
