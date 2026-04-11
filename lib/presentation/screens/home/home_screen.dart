import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../providers/category_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/product_providers.dart';
import '../../providers/vendor_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── SliverAppBar ──
            SliverAppBar(
              floating: true,
              snap: true,
              expandedHeight: 120,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              title: Row(
                children: [
                  const Text(
                    '🌸',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                      onPressed: () => context.push('/notifications'),
                    ),
                    if (unreadCount is AsyncData<int> &&
                        unreadCount.value! > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '${unreadCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () => context.go('/search'),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search, color: AppColors.grey500),
                          const SizedBox(width: 8),
                          Text(
                            'Search flowers, gifts...',
                            style: AppTextStyles.body2
                                .copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Hero Banner ──
            SliverToBoxAdapter(
              child: _HeroBanner(),
            ),

            // ── Categories ──
            SliverToBoxAdapter(
              child: _CategoriesSection(ref: ref),
            ),

            // ── Trending / Popular Now ──
            SliverToBoxAdapter(
              child: _TrendingSection(ref: ref),
            ),

            // ── Top Vendors ──
            SliverToBoxAdapter(
              child: _VendorsSection(ref: ref),
            ),

            // ── New Arrivals ──
            SliverToBoxAdapter(
              child: _NewArrivalsSection(ref: ref),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ── Hero Banner ──────────────────────────────────────────────────

class _HeroBanner extends StatefulWidget {
  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final _controller = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  static const _banners = [
    _BannerData(
      title: 'Fresh Flowers\nDelivered Fast',
      subtitle: 'Same-day delivery in Addis Ababa',
      gradient: [AppColors.primary, AppColors.primaryDark],
      emoji: '💐',
    ),
    _BannerData(
      title: 'Gift Someone\nSpecial Today',
      subtitle: 'Beautiful bouquets from Br 300',
      gradient: [AppColors.secondary, AppColors.secondaryDark],
      emoji: '🎁',
    ),
    _BannerData(
      title: 'Free Delivery\nOver Br 1,000',
      subtitle: 'Order now and save on delivery',
      gradient: [AppColors.giftPink, Color(0xFFAD1457)],
      emoji: '🚚',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final b = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: b.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              b.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              b.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(b.emoji, style: const TextStyle(fontSize: 48)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.primary
                    : AppColors.grey300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String emoji;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.emoji,
  });
}

// ── Categories Section ──────────────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  final WidgetRef ref;
  const _CategoriesSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _SectionHeader(title: 'Categories', onSeeAll: () {}),
          const SizedBox(height: 8),
          categories.when(
            data: (cats) => SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = cats[index];
                  return GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              cat.icon ?? '🌸',
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 70,
                          child: Text(
                            cat.name,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            loading: () => SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.shimmerBase,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (e, _) => _ErrorRow(
              message: 'Failed to load categories',
              onRetry: () => ref.invalidate(categoriesProvider),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trending Section ────────────────────────────────────────────

class _TrendingSection extends StatelessWidget {
  final WidgetRef ref;
  const _TrendingSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final trending = ref.watch(trendingProductsProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _SectionHeader(title: 'Popular Now 🔥', onSeeAll: () => context.push('/search')),
          const SizedBox(height: 8),
          trending.when(
            data: (products) => SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _ProductCard(product: products[index]),
              ),
            ),
            loading: () => SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => _ShimmerProductCard(),
              ),
            ),
            error: (e, _) => _ErrorRow(
              message: 'Failed to load trending',
              onRetry: () => ref.invalidate(trendingProductsProvider),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vendors Section ─────────────────────────────────────────────

class _VendorsSection extends StatelessWidget {
  final WidgetRef ref;
  const _VendorsSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final vendors = ref.watch(vendorsProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _SectionHeader(title: 'Top Vendors ⭐', onSeeAll: () {}),
          const SizedBox(height: 8),
          vendors.when(
            data: (list) => SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _VendorCard(vendor: list[index]),
              ),
            ),
            loading: () => SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            error: (e, _) => _ErrorRow(
              message: 'Failed to load vendors',
              onRetry: () => ref.invalidate(vendorsProvider),
            ),
          ),
        ],
      ),
    );
  }
}

// ── New Arrivals Section ────────────────────────────────────────

class _NewArrivalsSection extends StatelessWidget {
  final WidgetRef ref;
  const _NewArrivalsSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final newArrivals = ref.watch(newArrivalsProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _SectionHeader(title: 'New Arrivals ✨', onSeeAll: () => context.push('/search')),
          const SizedBox(height: 8),
          newArrivals.when(
            data: (products) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: products.length > 6 ? 6 : products.length,
                itemBuilder: (context, index) =>
                    _ProductGridCard(product: products[index]),
              ),
            ),
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            error: (e, _) => _ErrorRow(
              message: 'Failed to load new arrivals',
              onRetry: () => ref.invalidate(newArrivalsProvider),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Text('🌸', style: TextStyle(fontSize: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.vendorName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.vendorName!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${AppConstants.currencySymbol} ${product.price.toStringAsFixed(0)}',
                        style: AppTextStyles.priceSmall,
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 14, color: AppColors.starGold),
                      const SizedBox(width: 2),
                      Text(
                        product.averageRating.toStringAsFixed(1),
                        style: AppTextStyles.caption
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final ProductModel product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
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
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Center(
                  child: Text('🌸', style: TextStyle(fontSize: 40)),
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
                    Text(
                      product.name,
                      style: AppTextStyles.body2
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.vendorName ?? '',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${AppConstants.currencySymbol} ${product.price.toStringAsFixed(0)}',
                          style: AppTextStyles.priceSmall,
                        ),
                        const Spacer(),
                        const Icon(Icons.star, size: 14, color: AppColors.starGold),
                        const SizedBox(width: 2),
                        Text(
                          product.averageRating.toStringAsFixed(1),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final VendorModel vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/vendor/${vendor.id}'),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.secondaryLight.withValues(alpha: 0.2),
              child: Text(
                vendor.name.isNotEmpty ? vendor.name[0].toUpperCase() : 'V',
                style: AppTextStyles.h3.copyWith(color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vendor.name,
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 14, color: AppColors.starGold),
                const SizedBox(width: 2),
                Text(vendor.rating.toStringAsFixed(1),
                    style: AppTextStyles.caption),
                Text(' (${vendor.reviewCount})', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRow({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: AppTextStyles.body2),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
