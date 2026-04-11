import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/vendor_repository.dart';
import 'dio_provider.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository(dio: ref.read(dioProvider));
});

final vendorsProvider = FutureProvider.autoDispose<List<VendorModel>>((ref) async {
  return ref.read(vendorRepositoryProvider).getVendors();
});

final vendorDetailProvider = FutureProvider.autoDispose.family<VendorModel, String>((ref, id) async {
  return ref.read(vendorRepositoryProvider).getVendorById(id);
});

final vendorProductsProvider = FutureProvider.autoDispose.family<List<ProductModel>, String>((ref, vendorId) async {
  return ref.read(vendorRepositoryProvider).getVendorProducts(vendorId);
});
