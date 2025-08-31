import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:inhabit_realties/constants/apiUrls.dart';
import 'package:inhabit_realties/models/property/PropertyImageModel.dart';

class PropertyImageService {
  // Create property image
  Future<Map<String, dynamic>> createPropertyImage(
    String token,
    String propertyId,
    File imageFile,
  ) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.createPropertyImage}$propertyId';

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add propertyId to body
      request.fields['propertyId'] = propertyId;

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'],
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

  // Get all property images by property ID
  Future<Map<String, dynamic>> getAllPropertyImagesByPropertyId(
    String token,
    String propertyId,
  ) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getAllPropertyImages}$propertyId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
          "count": data['count'],
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'],
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

  // Get property image by ID
  Future<Map<String, dynamic>> getPropertyImageById(
    String token,
    String imageId,
  ) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.getPropertyImageById}$imageId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'],
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

  // Delete property image by ID
  Future<Map<String, dynamic>> deletePropertyImageById(
    String token,
    String propertyId,
    String imageId,
  ) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.deletePropertyImageById}$imageId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'imageId': imageId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'],
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

  // Delete all property images by property ID
  Future<Map<String, dynamic>> deleteAllPropertyImagesByPropertyId(
    String token,
    String propertyId,
  ) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.deleteAllPropertyImages}$propertyId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'],
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

  // Delete property image by ID (alternative method)
  Future<Map<String, dynamic>> deletePropertyImageByImageId(
    String token,
    String imageId,
  ) async {
    Map<String, dynamic> result = {};
    try {
      final url = '${ApiUrls.deletePropertyImageById}$imageId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        result = {
          "statusCode": 200,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'],
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
}
