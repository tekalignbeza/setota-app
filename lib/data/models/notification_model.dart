import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  @JsonValue('ORDER_UPDATE')
  orderUpdate,
  @JsonValue('PROMOTION')
  promotion,
  @JsonValue('SYSTEM')
  system,
  @JsonValue('DELIVERY_UPDATE')
  deliveryUpdate,
}

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    String? body,
    @Default(NotificationType.system) NotificationType type,
    @Default({}) Map<String, dynamic> data,
    @Default(false) bool isRead,
    DateTime? createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
