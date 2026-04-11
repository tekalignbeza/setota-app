import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/payment_model.dart';

class CheckoutRepository {
  final Dio _dio;
  CheckoutRepository({required Dio dio}) : _dio = dio;

  Future<CheckoutResponse> initiatePayment(CheckoutRequest request) async {
    final response = await _dio.post(AppConstants.checkoutPayEndpoint, data: request.toJson());
    return CheckoutResponse.fromJson(response.data);
  }

  Future<PaymentVerification> verifyPayment(String method, {String? transactionId}) async {
    final response = await _dio.get(AppConstants.checkoutVerifyEndpoint(method), queryParameters: {if (transactionId != null) 'transactionId': transactionId});
    return PaymentVerification.fromJson(response.data);
  }

  Future<List<String>> getAvailablePaymentMethods() async {
    final response = await _dio.get(AppConstants.checkoutMethodsEndpoint);
    final List data = response.data is List ? response.data : [];
    return data.map((e) => e.toString()).toList();
  }
}
