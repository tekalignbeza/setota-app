import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

enum PaymentMethod {
  @JsonValue('TELEBIRR')
  telebirr,
  @JsonValue('PAYPAL')
  paypal,
  @JsonValue('SQUARE')
  square,
  @JsonValue('CASH_ON_DELIVERY')
  cashOnDelivery,
}

@freezed
class CheckoutRequest with _$CheckoutRequest {
  const factory CheckoutRequest({
    required String orderId,
    required PaymentMethod paymentMethod,
    required double amount,
    @Default('ETB') String currency,
    String? returnUrl,
    String? cancelUrl,
  }) = _CheckoutRequest;

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestFromJson(json);
}

@freezed
class CheckoutResponse with _$CheckoutResponse {
  const factory CheckoutResponse({
    @Default(false) bool success,
    String? redirectUrl,
    String? transactionId,
    String? message,
  }) = _CheckoutResponse;

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckoutResponseFromJson(json);
}

@freezed
class PaymentVerification with _$PaymentVerification {
  const factory PaymentVerification({
    String? transactionId,
    String? status,
    double? amount,
    String? method,
  }) = _PaymentVerification;

  factory PaymentVerification.fromJson(Map<String, dynamic> json) =>
      _$PaymentVerificationFromJson(json);
}
