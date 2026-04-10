import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

@freezed
class CartModel with _$CartModel {
  const CartModel._();

  const factory CartModel({
    @Default([]) List<CartItem> items,
  }) = _CartModel;

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  double get deliveryFee => subtotal >= 1000.0 ? 0.0 : 100.0;

  double get total => subtotal + deliveryFee;

  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
}

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required CartProduct product,
    @Default(1) int quantity,
    String? specialInstructions,
    String? giftMessage,
    @Default(false) bool isAnonymous,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

@freezed
class CartProduct with _$CartProduct {
  const factory CartProduct({
    required String id,
    required String name,
    required double price,
    String? imageUrl,
    String? vendorId,
    String? vendorName,
  }) = _CartProduct;

  factory CartProduct.fromJson(Map<String, dynamic> json) =>
      _$CartProductFromJson(json);
}
