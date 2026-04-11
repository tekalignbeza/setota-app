import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/review_model.dart';
import '../../providers/review_providers.dart';

class ProductReviewsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductReviewsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductReviewsScreen> createState() =>
      _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends ConsumerState<ProductReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(productReviewsProvider(widget.productId));
    final summaryAsync = ref.watch(reviewSummaryProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: reviewsAsync.when(
        data: (reviews) => _buildContent(reviews, summaryAsync),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load reviews', style: AppTextStyles.body1),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref
                    .invalidate(productReviewsProvider(widget.productId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWriteReview(context),
        icon: const Icon(Icons.rate_review),
        label: const Text('Write a Review'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildContent(
      List<ReviewModel> reviews, AsyncValue<ReviewSummary> summaryAsync) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Summary Card ──
        summaryAsync.when(
          data: (summary) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      summary.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < summary.averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 18,
                          color: AppColors.starGold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${summary.totalReviews} reviews',
                        style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count =
                          summary.ratingDistribution[star] ?? 0;
                      final total = summary.totalReviews;
                      final fraction =
                          total > 0 ? count / total : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$star',
                                style: AppTextStyles.caption
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star,
                                size: 12, color: AppColors.starGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: fraction,
                                backgroundColor: AppColors.grey200,
                                color: AppColors.starGold,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 24,
                              child: Text('$count',
                                  style: AppTextStyles.caption,
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          loading: () => Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          error: (_, __) => const SizedBox(),
        ),
        const SizedBox(height: 20),

        // ── Review List ──
        if (reviews.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.rate_review_outlined,
                    size: 48, color: AppColors.grey300),
                const SizedBox(height: 12),
                Text('No reviews yet',
                    style: AppTextStyles.body1
                        .copyWith(color: AppColors.grey500)),
                const Text('Be the first to review!',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          ...reviews.map((review) => _ReviewCard(review: review)),
        const SizedBox(height: 80),
      ],
    );
  }

  void _showWriteReview(BuildContext context) {
    int selectedRating = 5;
    final titleCtrl = TextEditingController();
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Write a Review', style: AppTextStyles.h2),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedRating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          size: 36,
                          color: AppColors.starGold,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Review title',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Review submitted! Thank you 🌟')),
                    );
                  },
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final dateStr = review.createdAt != null
        ? DateFormat('MMM d, yyyy').format(review.createdAt!)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                radius: 18,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                child: Text(
                  (review.customerName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.customerName ?? 'Anonymous',
                        style: AppTextStyles.body2
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(dateStr, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppColors.starGold,
                  ),
                ),
              ),
            ],
          ),
          if (review.title != null) ...[
            const SizedBox(height: 8),
            Text(review.title!,
                style:
                    AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
          ],
          if (review.comment != null) ...[
            const SizedBox(height: 4),
            Text(review.comment!, style: AppTextStyles.body2),
          ],
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) => Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                      child: Icon(Icons.image, color: AppColors.grey400)),
                ),
              ),
            ),
          ],
          if (review.vendorResponse != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.store, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vendor Response',
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w600)),
                        Text(review.vendorResponse!,
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
