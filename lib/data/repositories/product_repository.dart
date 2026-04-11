import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio _dio;
  ProductRepository({required Dio dio}) : _dio = dio;

  Future<List<ProductModel>> getProducts({int page = 0, int size = 20}) async {
    final response = await _dio.get(AppConstants.productsEndpoint, queryParameters: {'page': page, 'size': size});
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _dio.get(AppConstants.productByIdEndpoint(id));
    return ProductModel.fromJson(response.data);
  }

  Future<List<ProductModel>> getProductsByCategory(String category, {int page = 0}) async {
    final response = await _dio.get(AppConstants.productsByCategoryEndpoint(category), queryParameters: {'page': page});
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> searchProducts(String query, {ProductFilter? filter}) async {
    final params = <String, dynamic>{'keyword': query};
    if (filter?.category != null) params['category'] = filter!.category;
    if (filter?.priceMin != null) params['priceMin'] = filter!.priceMin;
    if (filter?.priceMax != null) params['priceMax'] = filter!.priceMax;
    if (filter?.occasion != null) params['occasion'] = filter!.occasion;
    if (filter?.sortBy != null) params['sortBy'] = filter!.sortBy;
    final response = await _dio.get(AppConstants.productsSearchEndpoint, queryParameters: params);
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getTrendingProducts() async {
    final response = await _dio.get(AppConstants.productsTrendingEndpoint);
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> getNewArrivals() async {
    final response = await _dio.get(AppConstants.productsNewArrivalsEndpoint);
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
}
