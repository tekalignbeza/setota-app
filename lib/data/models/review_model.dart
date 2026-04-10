import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    String? customerId,
    String? customerName,
    String? customerAvatar,
    @Default(5) int rating,
    String? title,
    String? comment,
    @Default([]) List<String> photos,
    String? vendorResponse,
    DateTime? createdAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
}

@freezed
class ReviewSummary with _$ReviewSummary {
  const factory ReviewSummary({
    @Default(0.0) double averageRating,
    @Default(0) int totalReviews,
    @Default({}) Map<int, int> ratingDistribution,
  }) = _ReviewSummary;

  factory ReviewSummary.fromJson(Map<String, dynamic> json) =>
      _$ReviewSummaryFromJson(json);
}
