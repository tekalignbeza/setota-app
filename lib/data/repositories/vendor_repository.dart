import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/vendor_model.dart';
import '../models/product_model.dart';

class VendorRepository {
  final Dio _dio;
  VendorRepository({required Dio dio}) : _dio = dio;

  Future<List<VendorModel>> getVendors({int page = 0}) async {
    final response = await _dio.get(AppConstants.vendorsEndpoint, queryParameters: {'page': page});
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => VendorModel.fromJson(json)).toList();
  }

  Future<VendorModel> getVendorById(String id) async {
    final response = await _dio.get(AppConstants.vendorByIdEndpoint(id));
    return VendorModel.fromJson(response.data);
  }

  Future<List<ProductModel>> getVendorProducts(String vendorId, {int page = 0}) async {
    final response = await _dio.get('${AppConstants.vendorByIdEndpoint(vendorId)}/products', queryParameters: {'page': page});
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
}
