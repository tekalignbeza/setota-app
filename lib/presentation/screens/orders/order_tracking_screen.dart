import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_providers.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  Timer? _refreshTimer;

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
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(orderDetailProvider(widget.orderId));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: orderAsync.when(
        data: (order) => _buildContent(order),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load tracking', style: AppTextStyles.body1),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(orderDetailProvider(widget.orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(OrderModel order) {
    final statusColor =
        AppColors.getStatusColor(order.status.name.toUpperCase());
    final currentStepIndex = _statusSteps.indexOf(order.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Large Status Icon ──
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(order.status),
              size: 52,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _statusLabel(order.status),
            style: AppTextStyles.h2.copyWith(color: statusColor),
          ),
          if (order.estimatedDelivery != null) ...[
            const SizedBox(height: 4),
            Text(
              'Estimated: ${order.estimatedDelivery}',
              style: AppTextStyles.body2
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 24),

          // ── Timeline ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: List.generate(_statusSteps.length, (i) {
                final isComplete = i <= currentStepIndex;
                final isCurrent = i == currentStepIndex;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color:
                                isComplete ? statusColor : AppColors.grey200,
                            shape: BoxShape.circle,
                          ),
                          child: isComplete
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: AppColors.grey500,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                        if (i < _statusSteps.length - 1)
                          Container(
                            width: 2,
                            height: 32,
                            color: isComplete
                                ? statusColor
                                : AppColors.grey200,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _statusLabel(_statusSteps[i]),
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isComplete
                                    ? AppColors.textPrimary
                                    : AppColors.grey400,
                              ),
                            ),
                            if (isCurrent)
                              Text(
                                'Current status',
                                style: AppTextStyles.caption
                                    .copyWith(color: statusColor),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // ── Map Placeholder ──
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 40, color: AppColors.grey400),
                const SizedBox(height: 8),
                Text(
                  'Live tracking coming soon',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Driver Info ──
          if (order.driverName != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.info,
                    child: Icon(Icons.delivery_dining,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Driver',
                            style: AppTextStyles.caption),
                        Text(
                          order.driverName!,
                          style: AppTextStyles.body1
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (order.driverPhone != null) ...[
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.phone, color: AppColors.success),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.message, color: AppColors.info),
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
