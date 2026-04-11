import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';
import '../../providers/cart_providers.dart';
import '../../providers/favorites_providers.dart';
import '../../providers/product_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImagePage = 0;
  int _quantity = 1;
  String? _selectedSize;
  String? _selectedColor;
  bool _showGiftMessage = false;
  final _giftController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _giftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      body: productAsync.when(
        data: (product) =>
            _buildContent(context, product, favorites),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load product', style: AppTextStyles.body1),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(productDetailProvider(widget.productId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ProductModel product, AsyncValue favorites) {
    final isFavorite = favorites.whenOrNull<bool>(
          data: (list) => list.any((p) => p.id == product.id),
        ) ??
        false;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // ── Image Carousel ──
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 340,
                      child: PageView.builder(
                        itemCount: product.images.isEmpty
                            ? 3
                            : product.images.length,
                        onPageChanged: (i) =>
                            setState(() => _currentImagePage = i),
                        itemBuilder: (_, i) => Container(
                          color: AppColors.grey100,
                          child: const Center(
                            child:
                                Text('🌸', style: TextStyle(fontSize: 64)),
                          ),
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 12,
                      child: CircleAvatar(
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite
                                ? AppColors.heartRed
                                : AppColors.grey600,
                            size: 20,
                          ),
                          onPressed: () => ref
                              .read(favoritesProvider.notifier)
                              .toggle(product),
                        ),
                      ),
                    ),
                    // Dot indicator
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.isEmpty ? 3 : product.images.length,
                          (i) => Container(
                            width: _currentImagePage == i ? 20 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: _currentImagePage == i
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Product Info ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vendor
                      if (product.vendorName != null)
                        GestureDetector(
                          onTap: () => product.vendorId != null
                              ? context.push('/vendor/${product.vendorId}')
                              : null,
                          child: Text(
                            product.vendorName!,
                            style: AppTextStyles.body2
                                .copyWith(color: AppColors.secondary),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(product.name, style: AppTextStyles.h2),
                      const SizedBox(height: 8),

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${AppConstants.currencySymbol} ${product.price.toStringAsFixed(0)}',
                            style: AppTextStyles.price,
                          ),
                          if (product.originalPrice != null &&
                              product.originalPrice != product.price) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${AppConstants.currencySymbol} ${product.originalPrice!.toStringAsFixed(0)}',
                              style: AppTextStyles.strikethrough,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rating
                      GestureDetector(
                        onTap: () => context.push(
                            '/product/${product.id}/reviews'),
                        child: Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < product.averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 20,
                                color: AppColors.starGold,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              '${product.averageRating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                              style: AppTextStyles.body2
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            const Icon(Icons.chevron_right,
                                size: 18, color: AppColors.grey500),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sizes
                      if (product.sizes.isNotEmpty) ...[
                        Text('Size',
                            style: AppTextStyles.body2
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: product.sizes.map((s) {
                            final sel = _selectedSize == s;
                            return ChoiceChip(
                              label: Text(s),
                              selected: sel,
                              selectedColor: AppColors.primaryLight,
                              onSelected: (v) =>
                                  setState(() => _selectedSize = v ? s : null),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Colors
                      if (product.colors.isNotEmpty) ...[
                        Text('Color',
                            style: AppTextStyles.body2
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: product.colors.map((c) {
                            final sel = _selectedColor == c;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedColor = sel ? null : c),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.grey200,
                                  border: sel
                                      ? Border.all(
                                          color: AppColors.primary, width: 3)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(c[0],
                                      style: const TextStyle(fontSize: 12)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      if (product.description != null) ...[
                        Text('Description',
                            style: AppTextStyles.body2
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(product.description!,
                            style: AppTextStyles.body2
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                      ],

                      // Gift message toggle
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showGiftMessage = !_showGiftMessage),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.giftPink.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.giftPink.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.card_giftcard,
                                  color: AppColors.giftPink, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('Add Gift Message'),
                              ),
                              Icon(
                                _showGiftMessage
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.giftPink,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showGiftMessage) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _giftController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Write your message... 💝',
                          ),
                        ),
                        SwitchListTile(
                          value: _isAnonymous,
                          onChanged: (v) => setState(() => _isAnonymous = v),
                          title: const Text('Send Anonymously',
                              style: TextStyle(fontSize: 14)),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Quantity
                      Row(
                        children: [
                          Text('Quantity',
                              style: AppTextStyles.body2
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                ),
                                Text('$_quantity',
                                    style: AppTextStyles.body1.copyWith(
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () =>
                                      setState(() => _quantity++),
                                ),
                              ],
                            ),
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

        // ── Bottom Buttons ──
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart! 🛒')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _addToCart(product);
                      context.push('/checkout');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Buy Now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addToCart(ProductModel product) {
    ref.read(cartProvider.notifier).addItem(
          CartItem(
            product: CartProduct(
              id: product.id,
              name: product.name,
              price: product.price,
              imageUrl: product.images.isNotEmpty ? product.images.first : null,
              vendorId: product.vendorId,
              vendorName: product.vendorName,
            ),
            quantity: _quantity,
            giftMessage:
                _giftController.text.isNotEmpty ? _giftController.text : null,
            isAnonymous: _isAnonymous,
          ),
        );
  }
}
