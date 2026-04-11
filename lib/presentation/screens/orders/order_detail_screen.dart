import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_providers.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  static const _statusSteps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.ready,
    OrderStatus.pickedUp,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        data: (order) => _buildContent(context, ref, order),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load order', style: AppTextStyles.body1),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, OrderModel order) {
    final statusColor = AppColors.getStatusColor(order.status.name.toUpperCase());
    final currentStepIndex = _statusSteps.indexOf(order.status);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: statusColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(_statusIcon(order.status), color: statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(order.status),
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      if (order.estimatedDelivery != null)
                        Text(
                          'Estimated: ${order.estimatedDelivery}',
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                Text(
                  '#${order.orderNumber ?? order.id.substring(0, 8)}',
                  style: AppTextStyles.body2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // ── Status Timeline ──
          if (order.status != OrderStatus.cancelled)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Progress',
                      style: AppTextStyles.h3.copyWith(fontSize: 17)),
                  const SizedBox(height: 12),
                  ...List.generate(_statusSteps.length, (i) {
                    final isComplete = i <= currentStepIndex;
                    final isCurrent = i == currentStepIndex;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isComplete
                                    ? statusColor
                                    : AppColors.grey200,
                                shape: BoxShape.circle,
                                border: isCurrent
                                    ? Border.all(
                                        color: statusColor, width: 3)
                                    : null,
                              ),
                              child: isComplete
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                            if (i < _statusSteps.length - 1)
                              Container(
                                width: 2,
                                height: 28,
                                color: isComplete
                                    ? statusColor
                                    : AppColors.grey200,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _statusLabel(_statusSteps[i]),
                            style: AppTextStyles.body2.copyWith(
                              fontWeight:
                                  isCurrent ? FontWeight.w600 : FontWeight.normal,
                              color: isComplete
                                  ? AppColors.textPrimary
                                  : AppColors.grey400,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

          const Divider(),

          // ── Vendor Info ──
          if (order.vendorInfo != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondaryLight.withValues(alpha: 0.2),
                      child: Text(
                        order.vendorInfo!.name?[0].toUpperCase() ?? 'V',
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.vendorInfo!.name ?? 'Vendor',
                              style: AppTextStyles.body2
                                  .copyWith(fontWeight: FontWeight.w600)),
                          if (order.vendorInfo!.phone != null)
                            Text(order.vendorInfo!.phone!,
                                style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    if (order.vendorInfo!.phone != null)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, color: AppColors.secondary),
                      ),
                  ],
                ),
              ),
            ),

          // ── Items List ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Items', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          ),
          ...order.items.map((item) => ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                      child: Text('🌸', style: TextStyle(fontSize: 20))),
                ),
                title: Text(item.productName ?? 'Product'),
                subtitle: Text('Qty: ${item.quantity}'),
                trailing: Text(
                  '${AppConstants.currencySymbol} ${(item.price * item.quantity).toStringAsFixed(0)}',
                  style: AppTextStyles.body2
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              )),

          // ── Gift Message ──
          if (order.giftMessage != null && order.giftMessage!.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.giftPink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.giftPink.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gift Message',
                              style: AppTextStyles.body2
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(order.giftMessage!, style: AppTextStyles.body2),
                          if (order.isAnonymousSender)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '(Sent anonymously)',
                                style: AppTextStyles.caption.copyWith(
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Price Breakdown ──
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PriceRow('Subtotal',
                    '${AppConstants.currencySymbol} ${order.subtotal.toStringAsFixed(0)}'),
                _PriceRow('Delivery Fee',
                    '${AppConstants.currencySymbol} ${order.deliveryFee.toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                _PriceRow(
                  'Total',
                  '${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}',
                  isBold: true,
                ),
              ],
            ),
          ),

          // ── Driver Info ──
          if (order.driverName != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.info,
                      child: Icon(Icons.delivery_dining, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Driver',
                              style: AppTextStyles.caption),
                          Text(order.driverName!,
                              style: AppTextStyles.body2
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (order.driverPhone != null)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone, color: AppColors.info),
                      ),
                  ],
                ),
              ),
            ),
          ],

          // ── Action Buttons ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (order.status == OrderStatus.pending)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancel Order?'),
                            content: const Text(
                                'Are you sure you want to cancel this order?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error),
                                child: const Text('Cancel Order'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Cancel Order'),
                    ),
                  ),
                if (order.status == OrderStatus.delivered) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.replay),
                      label: const Text('Reorder'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Rate Order'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.ready:
        return Icons.inventory_2;
      case OrderStatus.pickedUp:
        return Icons.local_shipping;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _PriceRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)
                  : AppTextStyles.body2),
          Text(value,
              style: isBold
                  ? AppTextStyles.price
                  : AppTextStyles.body2
                      .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
