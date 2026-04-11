import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';
import 'auth_providers.dart';
import 'dio_provider.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(dio: ref.read(dioProvider));
});

class AddressNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
  final AddressRepository _repository;
  final String? _customerId;
  AddressNotifier(this._repository, this._customerId) : super(const AsyncValue.data([]));

  Future<void> loadAddresses() async {
    if (_customerId == null) return;
    state = const AsyncValue.loading();
    try {
      final addresses = await _repository.getAddresses(_customerId);
      state = AsyncValue.data(addresses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAddress(AddressModel address) async {
    if (_customerId == null) return;
    try {
      await _repository.addAddress(_customerId, address);
      await loadAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAddress(String addressId, AddressModel address) async {
    if (_customerId == null) return;
    try {
      await _repository.updateAddress(_customerId, addressId, address);
      await loadAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAddress(String addressId) async {
    if (_customerId == null) return;
    try {
      await _repository.deleteAddress(_customerId, addressId);
      await loadAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setDefault(String addressId) async {
    if (_customerId == null) return;
    try {
      await _repository.setDefaultAddress(_customerId, addressId);
      await loadAddresses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AsyncValue<List<AddressModel>>>((ref) {
  final customerId = ref.watch(authProvider).user?.customerId;
  return AddressNotifier(ref.read(addressRepositoryProvider), customerId);
});

final defaultAddressProvider = Provider<AddressModel?>((ref) {
  return ref.watch(addressProvider).whenOrNull(data: (addresses) => addresses.where((a) => a.isDefault).firstOrNull);
});
