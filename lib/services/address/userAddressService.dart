import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:inhabit_realties/interfaces/address/userAddressInterface.dart';
import 'package:inhabit_realties/models/address/UserAddressModel.dart';

class UserAddressService implements UserAddressInterface {
  @override
  Future<Map<String, dynamic>> createUserAddress(String token, UserAddressModel userAddress) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.createUserAddress;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userAddress.toJson()),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getAllUserAddresses(String token) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAllUserAddresses;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getUserAddressById(String token, String addressId) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getUserAddressById}$addressId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getUserAddressByUserId(String token, String userId) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getUserAddressByUserId}$userId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> updateUserAddress(String token, String addressId, UserAddressModel userAddress) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.updateUserAddress}$addressId';
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userAddress.toJson()),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> deleteUserAddress(String token, String addressId) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.deleteUserAddress}$addressId';
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": 400,
          "message": data['message'],
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'internal server error',
        "data": error,
      };
    }
    return result;
  }
} 