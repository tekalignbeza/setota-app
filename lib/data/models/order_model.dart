import 'package:freezed_annotation/freezed_annotation.dart';

import 'address_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

enum OrderStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('CONFIRMED')
  confirmed,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('READY')
  ready,
  @JsonValue('PICKED_UP')
  pickedUp,
  @JsonValue('OUT_FOR_DELIVERY')
  outForDelivery,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('CANCELLED')
  cancelled,
}

enum PaymentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PAID')
  paid,
  @JsonValue('FAILED')
  failed,
  @JsonValue('REFUNDED')
  refunded,
}

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    String? orderNumber,
    String? customerId,
    @Default(OrderStatus.pending) OrderStatus status,
    @Default([]) List<OrderItem> items,
    @Default(0.0) double subtotal,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double totalAmount,
    String? paymentMethod,
    @Default(PaymentStatus.pending) PaymentStatus paymentStatus,
    AddressModel? deliveryAddress,
    VendorSummary? vendorInfo,
    String? giftMessage,
    @Default(false) bool isAnonymousSender,
    DateTime? scheduledDeliveryDate,
    String? driverName,
    String? driverPhone,
    String? estimatedDelivery,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String productId,
    String? productName,
    String? productImage,
    @Default(1) int quantity,
    @Default(0.0) double price,
    String? specialInstructions,
    String? giftMessage,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
class VendorSummary with _$VendorSummary {
  const factory VendorSummary({
    required String id,
    String? name,
    String? phone,
    String? logoUrl,
  }) = _VendorSummary;

  factory VendorSummary.fromJson(Map<String, dynamic> json) =>
      _$VendorSummaryFromJson(json);
}
