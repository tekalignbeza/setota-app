import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/address_model.dart';

class AddressRepository {
  final Dio _dio;
  AddressRepository({required Dio dio}) : _dio = dio;

  Future<List<AddressModel>> getAddresses(String customerId) async {
    final response = await _dio.get(AppConstants.customerAddressesEndpoint(customerId));
    final List data = response.data is List ? response.data : [];
    return data.map((json) => AddressModel.fromJson(json)).toList();
  }

  Future<AddressModel> addAddress(String customerId, AddressModel address) async {
    final response = await _dio.post(AppConstants.customerAddressesEndpoint(customerId), data: address.toJson());
    return AddressModel.fromJson(response.data);
  }

  Future<AddressModel> updateAddress(String customerId, String addressId, AddressModel address) async {
    final response = await _dio.put('${AppConstants.customerAddressesEndpoint(customerId)}/$addressId', data: address.toJson());
    return AddressModel.fromJson(response.data);
  }

  Future<void> deleteAddress(String customerId, String addressId) async {
    await _dio.delete('${AppConstants.customerAddressesEndpoint(customerId)}/$addressId');
  }

  Future<void> setDefaultAddress(String customerId, String addressId) async {
    await _dio.put('${AppConstants.customerAddressesEndpoint(customerId)}/$addressId/default');
  }
}
