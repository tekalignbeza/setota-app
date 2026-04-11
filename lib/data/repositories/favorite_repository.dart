import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/product_model.dart';

class FavoriteRepository {
  final Dio _dio;
  FavoriteRepository({required Dio dio}) : _dio = dio;

  Future<List<ProductModel>> getFavorites(String customerId) async {
    final response = await _dio.get(AppConstants.customerFavoritesEndpoint(customerId));
    final List data = response.data is List ? response.data : [];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<void> addFavorite(String customerId, String productId) async {
    await _dio.post(AppConstants.customerFavoritesEndpoint(customerId), data: {'productId': productId});
  }

  Future<void> removeFavorite(String customerId, String productId) async {
    await _dio.delete('${AppConstants.customerFavoritesEndpoint(customerId)}/$productId');
  }

  Future<bool> isFavorite(String customerId, String productId) async {
    final response = await _dio.get('${AppConstants.customerFavoritesEndpoint(customerId)}/$productId/check');
    return response.data == true || response.data['isFavorite'] == true;
  }
}
