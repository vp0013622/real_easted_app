import 'package:inhabit_realties/models/address/UserAddressModel.dart';

abstract class UserAddressInterface {
  Future<Map<String, dynamic>> createUserAddress(String token, UserAddressModel userAddress);
  Future<Map<String, dynamic>> getAllUserAddresses(String token);
  Future<Map<String, dynamic>> getUserAddressById(String token, String addressId);
  Future<Map<String, dynamic>> getUserAddressByUserId(String token, String userId);
  Future<Map<String, dynamic>> updateUserAddress(String token, String addressId, UserAddressModel userAddress);
  Future<Map<String, dynamic>> deleteUserAddress(String token, String addressId);
} 