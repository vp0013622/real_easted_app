import 'package:inhabit_realties/models/address/UserAddressModel.dart';
import 'package:inhabit_realties/services/address/userAddressService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAddressController {
  final UserAddressService _userAddressService = UserAddressService();

  Future<Map<String, dynamic>> createUserAddress(UserAddressModel userAddress) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return await _userAddressService.createUserAddress(token, userAddress);
  }

  Future<Map<String, dynamic>> getAllUserAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return await _userAddressService.getAllUserAddresses(token);
  }

  Future<Map<String, dynamic>> getUserAddressById(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return await _userAddressService.getUserAddressById(token, addressId);
  }

  Future<Map<String, dynamic>> getUserAddressByUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return await _userAddressService.getUserAddressByUserId(token, userId);
  }

  Future<Map<String, dynamic>> updateUserAddress(String addressId, UserAddressModel userAddress) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return await _userAddressService.updateUserAddress(token, addressId, userAddress);
  }

  Future<Map<String, dynamic>> deleteUserAddress(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return await _userAddressService.deleteUserAddress(token, addressId);
  }
} 