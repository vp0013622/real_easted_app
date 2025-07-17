import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../constants/apiUrls.dart';
import '../../interfaces/document/DocumentInterface.dart';
import '../../models/document/DocumentModel.dart';

class DocumentService implements DocumentInterface {
  /// Get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Future<Map<String, dynamic>> getAllDocuments(String token) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse(ApiUrls.getAllDocuments);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> documentsData = data['data'] ?? [];
        final List<DocumentModel> documents =
            documentsData.map((item) => DocumentModel.fromJson(item)).toList();

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Documents retrieved successfully',
          "data": documents,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to retrieve documents',
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
  Future<Map<String, dynamic>> getAllDocumentsWithParams(
      String token, Map<String, dynamic> params) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse(ApiUrls.getAllDocumentsWithParams);
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(params),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> documentsData = data['data'] ?? [];
        final List<DocumentModel> documents =
            documentsData.map((item) => DocumentModel.fromJson(item)).toList();

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Documents retrieved successfully',
          "data": documents,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to retrieve documents',
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
  Future<Map<String, dynamic>> getDocumentById(
      String token, String documentId) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse('${ApiUrls.getDocumentById}$documentId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final document = DocumentModel.fromJson(data['data']);

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Document retrieved successfully',
          "data": document,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to retrieve document',
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
  Future<Map<String, dynamic>> createDocument(
      String token, String userId, String documentTypeId, File file) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse(ApiUrls.createDocument);
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add fields
      request.fields['userId'] = userId;
      request.fields['documentTypeId'] = documentTypeId;

      // Add file with filename and correct MIME type
      final fileName = file.path.split('/').last;
      final mimeType = _getMimeType(fileName);
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final document = DocumentModel.fromJson(data['data']);

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Document uploaded successfully',
          "data": document,
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
  Future<Map<String, dynamic>> editDocument(String token, String documentId,
      String userId, String documentTypeId, File file) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse('${ApiUrls.editDocument}$documentId');
      var request = http.MultipartRequest('PUT', url);

      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add fields
      request.fields['userId'] = userId;
      request.fields['documentTypeId'] = documentTypeId;

      // Add file with filename and correct MIME type
      final fileName = file.path.split('/').last;
      final mimeType = _getMimeType(fileName);
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final document = DocumentModel.fromJson(data['data']);

        result = {
          "statusCode": 200,
          "message": data['message'] ?? 'Document updated successfully',
          "data": document,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Update failed',
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
  Future<Map<String, dynamic>> deleteDocument(
      String token, String documentId) async {
    Map<String, dynamic> result = {};

    try {
      final url = Uri.parse('${ApiUrls.deleteDocument}$documentId');
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
          "message": data['message'] ?? 'Document deleted successfully',
          "data": null,
        };
      } else {
        result = {
          "statusCode": response.statusCode,
          "message": data['message'] ?? 'Failed to delete document',
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
