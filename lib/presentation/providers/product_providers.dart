import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import 'dio_provider.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(dio: ref.read(dioProvider));
});

final productsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  return ref.read(productRepositoryProvider).getProducts();
});

final productDetailProvider = FutureProvider.autoDispose.family<ProductModel, String>((ref, id) async {
  return ref.read(productRepositoryProvider).getProductById(id);
});

final trendingProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  return ref.read(productRepositoryProvider).getTrendingProducts();
});

final newArrivalsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  return ref.read(productRepositoryProvider).getNewArrivals();
});

final productsByCategoryProvider = FutureProvider.autoDispose.family<List<ProductModel>, String>((ref, category) async {
  return ref.read(productRepositoryProvider).getProductsByCategory(category);
});

// Search state
final searchQueryProvider = StateProvider<String>((ref) => '');
final productFilterProvider = StateProvider<ProductFilter>((ref) => const ProductFilter());

final searchResultsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(productFilterProvider);
  if (query.isEmpty && filter == const ProductFilter()) return [];
  return ref.read(productRepositoryProvider).searchProducts(query, filter: filter);
});
