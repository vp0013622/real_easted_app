import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:inhabit_realties/interfaces/propertyType/PropertyTypeInterface.dart';

class PropertyTypeService implements PropertyTypeInterface {
  @override
  Future<Map<String, dynamic>> getAllPropertyTypes(String token) async {
    Map<String, dynamic> result = {};
    try {
      final url = ApiUrls.getAllPropertyTypes;
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
          "count": data['count'],
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
        "data": error
      };
    }
    return result;
  }
}
