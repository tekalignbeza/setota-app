import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final Dio _dio;
  ReviewRepository({required Dio dio}) : _dio = dio;

  Future<List<ReviewModel>> getReviews({required String entityType, required String entityId, int page = 0}) async {
    final response = await _dio.get(AppConstants.reviewsEndpoint, queryParameters: {'entityType': entityType, 'entityId': entityId, 'page': page});
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => ReviewModel.fromJson(json)).toList();
  }

  Future<ReviewSummary> getReviewSummary({required String entityType, required String entityId}) async {
    final response = await _dio.get('${AppConstants.reviewsEndpoint}/summary', queryParameters: {'entityType': entityType, 'entityId': entityId});
    return ReviewSummary.fromJson(response.data);
  }

  Future<ReviewModel> createReview(Map<String, dynamic> reviewData) async {
    final response = await _dio.post(AppConstants.reviewsEndpoint, data: reviewData);
    return ReviewModel.fromJson(response.data);
  }
}
