import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    String? description,
    required double price,
    double? originalPrice,
    @Default([]) List<String> images,
    String? category,
    String? occasion,
    @Default([]) List<String> colors,
    @Default([]) List<String> sizes,
    String? vendorId,
    String? vendorName,
    @Default(0.0) double averageRating,
    @Default(0) int reviewCount,
    @Default(true) bool inStock,
    DateTime? createdAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@freezed
class ProductFilter with _$ProductFilter {
  const factory ProductFilter({
    String? category,
    double? priceMin,
    double? priceMax,
    String? occasion,
    String? sortBy,
    String? searchQuery,
  }) = _ProductFilter;

  factory ProductFilter.fromJson(Map<String, dynamic> json) =>
      _$ProductFilterFromJson(json);
}
