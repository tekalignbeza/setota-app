import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import 'dio_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(dio: ref.read(dioProvider));
});

final productReviewsProvider = FutureProvider.autoDispose.family<List<ReviewModel>, String>((ref, productId) async {
  return ref.read(reviewRepositoryProvider).getReviews(entityType: 'PRODUCT', entityId: productId);
});

final vendorReviewsProvider = FutureProvider.autoDispose.family<List<ReviewModel>, String>((ref, vendorId) async {
  return ref.read(reviewRepositoryProvider).getReviews(entityType: 'VENDOR', entityId: vendorId);
});

final reviewSummaryProvider = FutureProvider.autoDispose.family<ReviewSummary, ({String entityType, String entityId})>((ref, params) async {
  return ref.read(reviewRepositoryProvider).getReviewSummary(entityType: params.entityType, entityId: params.entityId);
});
