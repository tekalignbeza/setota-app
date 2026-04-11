import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/cart_model.dart';

class CartRepository {
  final Dio _dio;
  CartRepository({required Dio dio}) : _dio = dio;

  Future<CartModel> getCart() async {
    final response = await _dio.get(AppConstants.cartEndpoint);
    return CartModel.fromJson(response.data);
  }

  Future<CartModel> addToCart({required String productId, int quantity = 1, String? specialInstructions, String? giftMessage, bool isAnonymous = false}) async {
    final response = await _dio.post('${AppConstants.cartEndpoint}/items', data: {
      'productId': productId,
      'quantity': quantity,
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
      if (giftMessage != null) 'giftMessage': giftMessage,
      'isAnonymous': isAnonymous,
    });
    return CartModel.fromJson(response.data);
  }

  Future<CartModel> updateCartItem({required String productId, required int quantity}) async {
    final response = await _dio.put('${AppConstants.cartEndpoint}/items/$productId', data: {'quantity': quantity});
    return CartModel.fromJson(response.data);
  }

  Future<CartModel> removeFromCart(String productId) async {
    final response = await _dio.delete('${AppConstants.cartEndpoint}/items/$productId');
    return CartModel.fromJson(response.data);
  }

  Future<void> clearCart() async {
    await _dio.delete(AppConstants.cartEndpoint);
  }
}
