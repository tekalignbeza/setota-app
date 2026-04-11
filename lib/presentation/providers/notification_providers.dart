import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'dio_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(dio: ref.read(dioProvider));
});

class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;
  NotificationNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      await loadNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationNotifier(ref.read(notificationRepositoryProvider));
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  return ref.read(notificationRepositoryProvider).getUnreadCount();
});
