import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;
  NotificationRepository({required Dio dio}) : _dio = dio;

  Future<List<NotificationModel>> getNotifications({int page = 0}) async {
    final response = await _dio.get(AppConstants.notificationsEndpoint, queryParameters: {'page': page});
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _dio.put('${AppConstants.notificationsEndpoint}/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.put('${AppConstants.notificationsEndpoint}/read-all');
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('${AppConstants.notificationsEndpoint}/unread-count');
    return response.data is int ? response.data : (response.data['count'] ?? 0);
  }
}
