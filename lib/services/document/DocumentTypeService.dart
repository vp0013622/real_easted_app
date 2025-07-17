import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/apiUrls.dart';
import '../../interfaces/document/DocumentTypeInterface.dart';
import '../../models/document/DocumentTypeModel.dart';

class DocumentTypeService implements DocumentTypeInterface {
  @override
  Future<Map<String, dynamic>> getAllDocumentTypes(String token) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse(ApiUrls.getAllDocumentTypes);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> documentTypesData = data['data'] ?? [];
        final List<DocumentTypeModel> documentTypes = documentTypesData
            .map((item) => DocumentTypeModel.fromJson(item))
            .toList();

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Document types retrieved successfully',
          "data": documentTypes,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to retrieve document types',
          "data": null,
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
  Future<Map<String, dynamic>> getDocumentTypeById(
      String token, String documentTypeId) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse('${ApiUrls.getDocumentTypeById}$documentTypeId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final documentType = DocumentTypeModel.fromJson(data['data']);

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Document type retrieved successfully',
          "data": documentType,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to retrieve document type',
          "data": null,
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
  Future<Map<String, dynamic>> createDocumentType(
      String token, Map<String, dynamic> documentTypeData) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse(ApiUrls.createDocumentType);
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(documentTypeData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final documentType = DocumentTypeModel.fromJson(data['data']);

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Document type created successfully',
          "data": documentType,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to create document type',
          "data": null,
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
  Future<Map<String, dynamic>> editDocumentType(String token,
      String documentTypeId, Map<String, dynamic> documentTypeData) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse('${ApiUrls.editDocumentType}$documentTypeId');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(documentTypeData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final documentType = DocumentTypeModel.fromJson(data['data']);

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Document type updated successfully',
          "data": documentType,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to update document type',
          "data": null,
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
  Future<Map<String, dynamic>> deleteDocumentType(
      String token, String documentTypeId) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse('${ApiUrls.deleteDocumentType}$documentTypeId');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Document type deleted successfully',
          "data": null,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to delete document type',
          "data": null,
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
