import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'dio_provider.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(dio: ref.read(dioProvider));
});

class CartNotifier extends StateNotifier<CartModel> {
  final CartRepository _repository;
  CartNotifier(this._repository) : super(const CartModel());

  Future<void> loadCart() async {
    try {
      final cart = await _repository.getCart();
      state = cart;
    } catch (_) {
      // keep current state on error
    }
  }

  Future<void> addToCart({required String productId, int quantity = 1, String? specialInstructions, String? giftMessage, bool isAnonymous = false}) async {
    try {
      final cart = await _repository.addToCart(productId: productId, quantity: quantity, specialInstructions: specialInstructions, giftMessage: giftMessage, isAnonymous: isAnonymous);
      state = cart;
    } catch (_) {}
  }

  /// Alias used by screens
  void addItem(CartItem item) {
    final existing = state.items.indexWhere((i) => i.product.id == item.product.id);
    if (existing >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[existing] = item.copyWith(quantity: updated[existing].quantity + item.quantity);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  /// Alias used by screens
  void removeItem(String productId) {
    state = state.copyWith(items: state.items.where((i) => i.product.id != productId).toList());
  }

  void updateQuantity(String productId, int quantity) {
    final updated = state.items.map((i) {
      if (i.product.id == productId) return i.copyWith(quantity: quantity);
      return i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void updateGiftMessage(String productId, String message) {
    final updated = state.items.map((i) {
      if (i.product.id == productId) return i.copyWith(giftMessage: message);
      return i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void toggleAnonymous(String productId, bool value) {
    final updated = state.items.map((i) {
      if (i.product.id == productId) return i.copyWith(isAnonymous: value);
      return i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  void updateInstructions(String productId, String text) {
    final updated = state.items.map((i) {
      if (i.product.id == productId) return i.copyWith(specialInstructions: text);
      return i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final cart = await _repository.removeFromCart(productId);
      state = cart;
    } catch (_) {}
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
      state = const CartModel();
    } catch (_) {}
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartModel>((ref) {
  return CartNotifier(ref.read(cartRepositoryProvider));
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});
