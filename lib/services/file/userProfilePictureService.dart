import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:inhabit_realties/interfaces/file/UserProfilePictureInterface.dart';

class UserProfilePictureService implements UserProfilePictureInterface {
  @override
  Future<Map<String, dynamic>> upload(
    String token,
    String userId,
    String fileName,
    File file,
  ) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse(ApiUrls.createProfileImage); // your upload endpoint
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add fields (non-file form fields)
      request.fields['userId'] = userId;
      request.fields['fileName'] = fileName;

      // Add file
      request.files
          .add(await http.MultipartFile.fromPath('profile', file.path));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Upload failed',
          "data": data['data'],
        };
      }
    } catch (error) {
      result = {
        "statusCode": 500,
        "message": 'Internal server error',
        "data": error.toString(),
      };
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>> get(String token, String userId) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getProfileImage}$userId';
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
}
