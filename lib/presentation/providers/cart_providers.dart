import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'dio_provider.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(dio: ref.read(dioProvider));
});

class CartNotifier extends StateNotifier<AsyncValue<CartModel>> {
  final CartRepository _repository;
  CartNotifier(this._repository) : super(const AsyncValue.data(CartModel()));

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    try {
      final cart = await _repository.getCart();
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addToCart({required String productId, int quantity = 1, String? specialInstructions, String? giftMessage, bool isAnonymous = false}) async {
    try {
      final cart = await _repository.addToCart(productId: productId, quantity: quantity, specialInstructions: specialInstructions, giftMessage: giftMessage, isAnonymous: isAnonymous);
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateQuantity({required String productId, required int quantity}) async {
    try {
      final cart = await _repository.updateCartItem(productId: productId, quantity: quantity);
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final cart = await _repository.removeFromCart(productId);
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      state = const AsyncValue.data(CartModel());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<CartModel>>((ref) {
  return CartNotifier(ref.read(cartRepositoryProvider));
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).whenOrNull(data: (cart) => cart.itemCount) ?? 0;
});
