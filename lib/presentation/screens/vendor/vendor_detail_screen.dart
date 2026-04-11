import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../providers/review_providers.dart';
import '../../providers/vendor_providers.dart';

class VendorDetailScreen extends ConsumerWidget {
  final String vendorId;

  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorDetailProvider(vendorId));

    return Scaffold(
      body: vendorAsync.when(
        data: (vendor) => DefaultTabController(
          length: 3,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ── Cover Image ──
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          color: AppColors.grey200,
                          child: const Center(
                            child:
                                Text('🏪', style: TextStyle(fontSize: 48)),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 12,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, size: 20),
                              onPressed: () => context.pop(),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -36,
                          left: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.surface, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.secondaryLight
                                  .withValues(alpha: 0.3),
                              child: Text(
                                vendor.name.isNotEmpty
                                    ? vendor.name[0].toUpperCase()
                                    : 'V',
                                style: AppTextStyles.h1
                                    .copyWith(color: AppColors.secondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),

                    // ── Vendor Info ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(vendor.name,
                                    style: AppTextStyles.h2),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: vendor.isOpen
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  vendor.isOpen ? 'Open' : 'Closed',
                                  style: TextStyle(
                                    color: vendor.isOpen
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 18, color: AppColors.starGold),
                              const SizedBox(width: 4),
                              Text(vendor.rating.toStringAsFixed(1),
                                  style: AppTextStyles.body2
                                      .copyWith(fontWeight: FontWeight.w600)),
                              Text(' (${vendor.reviewCount} reviews)',
                                  style: AppTextStyles.caption),
                              if (vendor.deliveryTime != null) ...[
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time,
                                    size: 16, color: AppColors.grey500),
                                const SizedBox(width: 4),
                                Text(vendor.deliveryTime!,
                                    style: AppTextStyles.caption),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  const TabBar(
                    tabs: [
                      Tab(text: 'Products'),
                      Tab(text: 'Reviews'),
                      Tab(text: 'Info'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _ProductsTab(vendorId: vendorId, ref: ref),
                _ReviewsTab(vendorId: vendorId, ref: ref),
                _InfoTab(vendor: vendor),
              ],
            ),
          ),
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load vendor', style: AppTextStyles.body1),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(vendorDetailProvider(vendorId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

class _ProductsTab extends StatelessWidget {
  final String vendorId;
  final WidgetRef ref;
  const _ProductsTab({required this.vendorId, required this.ref});

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(vendorProductsProvider(vendorId));

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('No products available'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];
            return GestureDetector(
              onTap: () => context.push('/product/${p.id}'),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                        child: const Center(
                          child:
                              Text('🌸', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: AppTextStyles.body2
                                    .copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Text(
                              '${AppConstants.currencySymbol} ${p.price.toStringAsFixed(0)}',
                              style: AppTextStyles.priceSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
            Text('Failed to load products', style: AppTextStyles.body1),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(vendorProductsProvider(vendorId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final String vendorId;
  final WidgetRef ref;
  const _ReviewsTab({required this.vendorId, required this.ref});

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(vendorReviewsProvider(vendorId));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(child: Text('No reviews yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = reviews[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primaryLight.withValues(alpha: 0.2),
                        child: Text(
                          (r.customerName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(r.customerName ?? 'Anonymous',
                            style: AppTextStyles.body2
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                      ...List.generate(
                        5,
                        (j) => Icon(
                          j < r.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: AppColors.starGold,
                        ),
                      ),
                    ],
                  ),
                  if (r.comment != null) ...[
                    const SizedBox(height: 6),
                    Text(r.comment!, style: AppTextStyles.body2),
                  ],
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: ElevatedButton(
          onPressed: () =>
              ref.invalidate(vendorReviewsProvider(vendorId)),
          child: const Text('Retry'),
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final dynamic vendor;
  const _InfoTab({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vendor.description != null) ...[
          Text('About', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 6),
          Text(vendor.description!, style: AppTextStyles.body2),
          const SizedBox(height: 16),
        ],
        if (vendor.address != null) ...[
          ListTile(
            leading: const Icon(Icons.location_on, color: AppColors.primary),
            title: const Text('Address'),
            subtitle: Text(vendor.address!),
            contentPadding: EdgeInsets.zero,
          ),
        ],
        if (vendor.categories.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Categories',
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (vendor.categories as List<String>)
                .map((c) => Chip(label: Text(c)))
                .toList(),
          ),
        ],
        if (vendor.minimumOrder != null) ...[
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.monetization_on_outlined,
                color: AppColors.secondary),
            title: const Text('Minimum Order'),
            subtitle: Text(
                '${AppConstants.currencySymbol} ${vendor.minimumOrder!.toStringAsFixed(0)}'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
        if (vendor.productCount > 0) ...[
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined,
                color: AppColors.accent),
            title: const Text('Products'),
            subtitle: Text('${vendor.productCount} available'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ],
    );
  }
}
