import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/checkout_repository.dart';
import 'dio_provider.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepository(dio: ref.read(dioProvider));
});

final paymentMethodsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  return ref.read(checkoutRepositoryProvider).getAvailablePaymentMethods();
});

final selectedPaymentMethodProvider = StateProvider<PaymentMethod>((ref) => PaymentMethod.telebirr);

class CheckoutNotifier extends StateNotifier<AsyncValue<CheckoutResponse?>> {
  final CheckoutRepository _repository;
  CheckoutNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<CheckoutResponse?> initiatePayment(CheckoutRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.initiatePayment(request);
      state = AsyncValue.data(response);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<PaymentVerification?> verifyPayment(String method, {String? transactionId}) async {
    try {
      return await _repository.verifyPayment(method, transactionId: transactionId);
    } catch (_) {
      return null;
    }
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, AsyncValue<CheckoutResponse?>>((ref) {
  return CheckoutNotifier(ref.read(checkoutRepositoryProvider));
});
