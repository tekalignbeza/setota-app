import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/payment_model.dart';
import '../../providers/address_providers.dart';
import '../../providers/cart_providers.dart';
import '../../providers/checkout_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isScheduled = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  final _giftController = TextEditingController();
  bool _sendAnonymously = false;

  @override
  void dispose() {
    _giftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final defaultAddress = ref.watch(defaultAddressProvider);
    final selectedPayment = ref.watch(selectedPaymentMethodProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Cart is empty'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Go Shopping'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Delivery Address ──
                        _SectionTitle(icon: Icons.location_on, title: 'Delivery Address'),
                        const SizedBox(height: 8),
                        defaultAddress.when(
                          data: (addr) {
                            if (addr == null) {
                              return _ActionCard(
                                icon: Icons.add_location_alt,
                                label: 'Add Delivery Address',
                                onTap: () => context.push('/addresses/add'),
                              );
                            }
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                children: [
                                  Icon(_labelIcon(addr.label),
                                      color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(addr.label,
                                            style: AppTextStyles.body2.copyWith(
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                          '${addr.street}${addr.apartment != null ? ', ${addr.apartment}' : ''}, ${addr.city}',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push('/addresses'),
                                    child: const Text('Change'),
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (_, __) => _ActionCard(
                            icon: Icons.add_location_alt,
                            label: 'Add Delivery Address',
                            onTap: () => context.push('/addresses/add'),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Delivery Type ──
                        _SectionTitle(icon: Icons.schedule, title: 'Delivery Type'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _ToggleOption(
                                label: 'On-Demand',
                                icon: Icons.flash_on,
                                selected: !_isScheduled,
                                onTap: () => setState(() => _isScheduled = false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ToggleOption(
                                label: 'Scheduled',
                                icon: Icons.calendar_today,
                                selected: _isScheduled,
                                onTap: () => setState(() => _isScheduled = true),
                              ),
                            ),
                          ],
                        ),
                        if (_isScheduled) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now()
                                          .add(const Duration(days: 1)),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 30)),
                                    );
                                    if (date != null) {
                                      setState(() => _scheduledDate = date);
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_month, size: 18),
                                  label: Text(_scheduledDate != null
                                      ? '${_scheduledDate!.day}/${_scheduledDate!.month}'
                                      : 'Date'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setState(() => _scheduledTime = time);
                                    }
                                  },
                                  icon: const Icon(Icons.access_time, size: 18),
                                  label: Text(_scheduledTime != null
                                      ? _scheduledTime!.format(context)
                                      : 'Time'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),

                        // ── Gift Message ──
                        _SectionTitle(icon: Icons.card_giftcard, title: 'Gift Message'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _giftController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Write a heartfelt message... 💝',
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          value: _sendAnonymously,
                          onChanged: (v) => setState(() => _sendAnonymously = v),
                          title: const Text('Send Anonymously'),
                          subtitle: const Text(
                              'Recipient won\'t see your name'),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 20),

                        // ── Order Summary ──
                        _SectionTitle(icon: Icons.receipt_long, title: 'Order Summary'),
                        const SizedBox(height: 8),
                        ...cart.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text('${item.quantity}x ',
                                      style: AppTextStyles.body2
                                          .copyWith(fontWeight: FontWeight.w600)),
                                  Expanded(
                                    child: Text(item.product.name,
                                        style: AppTextStyles.body2),
                                  ),
                                  Text(
                                    '${AppConstants.currencySymbol} ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                                    style: AppTextStyles.body2
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        _PriceRow('Subtotal',
                            '${AppConstants.currencySymbol} ${cart.subtotal.toStringAsFixed(0)}'),
                        _PriceRow(
                          'Delivery Fee',
                          cart.deliveryFee == 0
                              ? 'Free'
                              : '${AppConstants.currencySymbol} ${cart.deliveryFee.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 4),
                        _PriceRow(
                          'Total',
                          '${AppConstants.currencySymbol} ${cart.total.toStringAsFixed(0)}',
                          isBold: true,
                        ),
                        const SizedBox(height: 20),

                        // ── Payment Method ──
                        _SectionTitle(icon: Icons.payment, title: 'Payment Method'),
                        const SizedBox(height: 8),
                        _PaymentTile(
                          icon: Icons.phone_android,
                          label: 'Telebirr',
                          subtitle: 'Pay with mobile money',
                          method: PaymentMethod.telebirr,
                          selected: selectedPayment,
                          onTap: () => ref
                              .read(selectedPaymentMethodProvider.notifier)
                              .state = PaymentMethod.telebirr,
                        ),
                        const SizedBox(height: 8),
                        _PaymentTile(
                          icon: Icons.paypal_outlined,
                          label: 'PayPal',
                          subtitle: 'International payments',
                          method: PaymentMethod.paypal,
                          selected: selectedPayment,
                          onTap: () => ref
                              .read(selectedPaymentMethodProvider.notifier)
                              .state = PaymentMethod.paypal,
                        ),
                        const SizedBox(height: 8),
                        _PaymentTile(
                          icon: Icons.credit_card,
                          label: 'Square',
                          subtitle: 'Credit/debit card',
                          method: PaymentMethod.square,
                          selected: selectedPayment,
                          onTap: () => ref
                              .read(selectedPaymentMethodProvider.notifier)
                              .state = PaymentMethod.square,
                        ),
                        const SizedBox(height: 8),
                        _PaymentTile(
                          icon: Icons.money,
                          label: 'Cash on Delivery',
                          subtitle: 'Pay when you receive',
                          method: PaymentMethod.cashOnDelivery,
                          selected: selectedPayment,
                          onTap: () => ref
                              .read(selectedPaymentMethodProvider.notifier)
                              .state = PaymentMethod.cashOnDelivery,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ── Place Order Button ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedPayment == PaymentMethod.cashOnDelivery) {
                            context.go('/checkout/success');
                          } else {
                            context.push('/checkout/payment');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Place Order • ${AppConstants.currencySymbol} ${cart.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 17)),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleOption(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.grey500),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.body2.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final PaymentMethod method;
  final PaymentMethod selected;
  final VoidCallback onTap;
  const _PaymentTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.grey600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
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
