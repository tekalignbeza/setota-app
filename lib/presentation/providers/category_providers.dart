import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import 'dio_provider.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(dio: ref.read(dioProvider));
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(categoryRepositoryProvider).getCategories();
});
