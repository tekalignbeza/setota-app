import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/cart_model.dart';
import '../../providers/cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('My Cart'),
            if (cart.itemCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
      body: cart.isEmpty ? _buildEmptyState(context) : _buildCartContent(context, ref, cart),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text('Your Cart is Empty', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Start adding beautiful flowers & gifts!',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.local_florist),
            label: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, CartModel cart) {
    final belowMinimum = cart.subtotal < AppConstants.minimumOrderAmount;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartItemCard(item: item, ref: ref);
            },
          ),
        ),

        // ── Summary ──
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SummaryRow('Subtotal',
                    '${AppConstants.currencySymbol} ${cart.subtotal.toStringAsFixed(0)}'),
                const SizedBox(height: 6),
                _SummaryRow(
                  'Delivery Fee',
                  cart.deliveryFee == 0
                      ? 'Free 🎉'
                      : '${AppConstants.currencySymbol} ${cart.deliveryFee.toStringAsFixed(0)}',
                  valueColor:
                      cart.deliveryFee == 0 ? AppColors.cartGreen : null,
                ),
                if (cart.deliveryFee > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Free delivery on orders over ${AppConstants.currencySymbol} ${AppConstants.freeDeliveryThreshold.toStringAsFixed(0)}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.secondary),
                  ),
                ],
                const Divider(height: 20),
                _SummaryRow(
                  'Total',
                  '${AppConstants.currencySymbol} ${cart.total.toStringAsFixed(0)}',
                  isBold: true,
                ),
                if (belowMinimum) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Minimum order amount is ${AppConstants.currencySymbol} ${AppConstants.minimumOrderAmount.toStringAsFixed(0)}',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: belowMinimum
                        ? null
                        : () => context.push('/checkout'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatefulWidget {
  final CartItem item;
  final WidgetRef ref;
  const _CartItemCard({required this.item, required this.ref});

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  bool _showGiftMessage = false;
  bool _showInstructions = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final product = item.product;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          widget.ref.read(cartProvider.notifier).removeItem(product.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🌸', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: AppTextStyles.body2
                              .copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (product.vendorName != null)
                        Text(product.vendorName!,
                            style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        '${AppConstants.currencySymbol} ${product.price.toStringAsFixed(0)}',
                        style: AppTextStyles.priceSmall,
                      ),
                    ],
                  ),
                ),
                // Quantity controls
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (item.quantity > 1) {
                            widget.ref.read(cartProvider.notifier).updateQuantity(
                                product.id, item.quantity - 1);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${item.quantity}',
                            style: AppTextStyles.body2
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => widget.ref
                            .read(cartProvider.notifier)
                            .updateQuantity(product.id, item.quantity + 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quick action row
            Row(
              children: [
                _ExpandToggle(
                  icon: Icons.card_giftcard,
                  label: 'Gift Message',
                  isOpen: _showGiftMessage,
                  onTap: () =>
                      setState(() => _showGiftMessage = !_showGiftMessage),
                ),
                const SizedBox(width: 12),
                _ExpandToggle(
                  icon: Icons.note_alt_outlined,
                  label: 'Instructions',
                  isOpen: _showInstructions,
                  onTap: () =>
                      setState(() => _showInstructions = !_showInstructions),
                ),
              ],
            ),
            if (_showGiftMessage) ...[
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Write a gift message...',
                  prefixIcon: Icon(Icons.favorite, color: AppColors.giftPink),
                  isDense: true,
                ),
                maxLines: 2,
                onChanged: (v) => widget.ref
                    .read(cartProvider.notifier)
                    .updateGiftMessage(product.id, v),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Switch(
                    value: item.isAnonymous,
                    activeColor: AppColors.primary,
                    onChanged: (v) => widget.ref
                        .read(cartProvider.notifier)
                        .toggleAnonymous(product.id, v),
                  ),
                  const Text('Send anonymously',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ],
            if (_showInstructions) ...[
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Special instructions...',
                  prefixIcon: Icon(Icons.edit_note),
                  isDense: true,
                ),
                maxLines: 2,
                onChanged: (v) => widget.ref
                    .read(cartProvider.notifier)
                    .updateInstructions(product.id, v),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ExpandToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOpen;
  final VoidCallback onTap;
  const _ExpandToggle(
      {required this.icon,
      required this.label,
      required this.isOpen,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 16,
              color: isOpen ? AppColors.primary : AppColors.grey500),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
                color: isOpen ? AppColors.primary : AppColors.grey500),
          ),
          Icon(
            isOpen ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: isOpen ? AppColors.primary : AppColors.grey500,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _SummaryRow(this.label, this.value,
      {this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)
              : AppTextStyles.body2,
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.price
              : AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
        ),
      ],
    );
  }
}
