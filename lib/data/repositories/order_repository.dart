import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/order_model.dart';

class OrderRepository {
  final Dio _dio;
  OrderRepository({required Dio dio}) : _dio = dio;

  Future<List<OrderModel>> getCustomerOrders(String customerId) async {
    final response = await _dio.get(AppConstants.ordersByCustomerEndpoint(customerId));
    final List data = response.data is List ? response.data : (response.data['content'] ?? []);
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _dio.get(AppConstants.orderByIdEndpoint(id));
    return OrderModel.fromJson(response.data);
  }

  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    final response = await _dio.post(AppConstants.ordersEndpoint, data: orderData);
    return OrderModel.fromJson(response.data);
  }

  Future<OrderModel> cancelOrder(String id) async {
    final response = await _dio.put('${AppConstants.orderByIdEndpoint(id)}/cancel');
    return OrderModel.fromJson(response.data);
  }
}
