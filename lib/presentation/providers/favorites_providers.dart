import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/favorite_repository.dart';
import 'auth_providers.dart';
import 'dio_provider.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(dio: ref.read(dioProvider));
});

class FavoritesNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final FavoriteRepository _repository;
  final String? _customerId;
  final Set<String> _favoriteIds = {};
  FavoritesNotifier(this._repository, this._customerId) : super(const AsyncValue.data([]));

  Future<void> loadFavorites() async {
    if (_customerId == null) return;
    state = const AsyncValue.loading();
    try {
      final favorites = await _repository.getFavorites(_customerId);
      _favoriteIds.clear();
      _favoriteIds.addAll(favorites.map((p) => p.id));
      state = AsyncValue.data(favorites);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> toggleFavorite(String productId) async {
    if (_customerId == null) return;
    try {
      if (_favoriteIds.contains(productId)) {
        await _repository.removeFavorite(_customerId, productId);
        _favoriteIds.remove(productId);
      } else {
        await _repository.addFavorite(_customerId, productId);
        _favoriteIds.add(productId);
      }
      await loadFavorites();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<ProductModel>>>((ref) {
  final customerId = ref.watch(authProvider).user?.customerId;
  return FavoritesNotifier(ref.read(favoriteRepositoryProvider), customerId);
});
