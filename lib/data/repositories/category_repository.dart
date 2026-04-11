import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final Dio _dio;
  CategoryRepository({required Dio dio}) : _dio = dio;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get(AppConstants.categoriesEndpoint);
    final List data = response.data is List ? response.data : [];
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }
}
