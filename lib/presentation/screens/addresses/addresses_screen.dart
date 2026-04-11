import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/address_model.dart';
import '../../providers/address_providers.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/addresses/add'),
          ),
        ],
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 64, color: AppColors.grey300),
                  const SizedBox(height: 16),
                  Text('No Addresses Yet', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Add a delivery address to get started',
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/addresses/add'),
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Add Address'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return _AddressCard(
                address: addr,
                onSetDefault: () =>
                    ref.read(addressProvider.notifier).setDefault(addr.id!),
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Address?'),
                      content: Text('Remove "${addr.label}" address?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref
                                .read(addressProvider.notifier)
                                .deleteAddress(addr.id!);
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.error),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
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
                onPressed: () => ref.invalidate(addressProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/addresses/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;
  const _AddressCard(
      {required this.address, required this.onSetDefault, required this.onDelete});

  IconData get _labelIcon {
    switch (address.label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.borderLight,
          width: address.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_labelIcon,
                  color: address.isDefault
                      ? AppColors.primary
                      : AppColors.grey500,
                  size: 22),
              const SizedBox(width: 10),
              Text(
                address.label,
                style: AppTextStyles.body1
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (v) {
                  if (v == 'default') onSetDefault();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Set as Default'),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${address.street}${address.apartment != null ? ', ${address.apartment}' : ''}',
            style: AppTextStyles.body2,
          ),
          Text(
            '${address.city}${address.state != null ? ', ${address.state}' : ''}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
