import 'package:freezed_annotation/freezed_annotation.dart';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({
    String? id,
    @Default('Home') String label,
    required String street,
    String? apartment,
    @Default('Addis Ababa') String city,
    String? state,
    String? zipCode,
    @Default('Ethiopia') String country,
    double? latitude,
    double? longitude,
    @Default(false) bool isDefault,
  }) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
}
