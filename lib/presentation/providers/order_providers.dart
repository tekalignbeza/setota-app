import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'auth_providers.dart';
import 'dio_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(dio: ref.read(dioProvider));
});

final customerOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final auth = ref.watch(authProvider);
  final customerId = auth.user?.customerId;
  if (customerId == null) return [];
  return ref.read(orderRepositoryProvider).getCustomerOrders(customerId);
});

final orderDetailProvider = FutureProvider.autoDispose.family<OrderModel, String>((ref, id) async {
  return ref.read(orderRepositoryProvider).getOrderById(id);
});

final activeOrdersProvider = Provider.autoDispose<AsyncValue<List<OrderModel>>>((ref) {
  return ref.watch(customerOrdersProvider).whenData((orders) =>
    orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList()
  );
});

final pastOrdersProvider = Provider.autoDispose<AsyncValue<List<OrderModel>>>((ref) {
  return ref.watch(customerOrdersProvider).whenData((orders) =>
    orders.where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled).toList()
  );
});
