import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_model.freezed.dart';
part 'vendor_model.g.dart';

@freezed
class VendorModel with _$VendorModel {
  const factory VendorModel({
    required String id,
    required String name,
    String? description,
    String? logoUrl,
    String? coverImageUrl,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    String? deliveryTime,
    double? minimumOrder,
    @Default(true) bool isOpen,
    String? address,
    double? distance,
    @Default(0) int productCount,
    @Default([]) List<String> categories,
  }) = _VendorModel;

  factory VendorModel.fromJson(Map<String, dynamic> json) =>
      _$VendorModelFromJson(json);
}
