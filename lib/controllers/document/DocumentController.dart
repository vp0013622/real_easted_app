import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/document/DocumentModel.dart';
import '../../models/document/DocumentTypeModel.dart';
import '../../services/document/DocumentService.dart';
import '../../services/document/DocumentTypeService.dart';

class DocumentController {
  final DocumentService _documentService = DocumentService();
  final DocumentTypeService _documentTypeService = DocumentTypeService();

  // Cache for documents and document types
  List<DocumentModel> _documents = [];
  List<DocumentTypeModel> _documentTypes = [];
  bool _isLoading = false;

  // Getters
  List<DocumentModel> get documents => _documents;
  List<DocumentTypeModel> get documentTypes => _documentTypes;
  bool get isLoading => _isLoading;

  /// Get all documents
  Future<Map<String, dynamic>> getAllDocuments() async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return {
          'statusCode': 401,
          'message': 'Authentication required',
          'data': null,
        };
      }

      final response = await _documentService.getAllDocuments(token);

      if (response['statusCode'] == 200) {
        _documents = response['data'] ?? [];
        return response;
      } else {
        return response;
      }
    } catch (error) {
      return {
        'statusCode': 500,
        'message': 'Error loading documents: $error',
        'data': null,
      };
    } finally {
      setLoading(false);
    }
  }

  /// Get documents with parameters
  Future<Map<String, dynamic>> getDocumentsWithParams(
      Map<String, dynamic> params) async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return {
          'statusCode': 401,
          'message': 'Authentication required',
          'data': null,
        };
      }

      final response =
          await _documentService.getAllDocumentsWithParams(token, params);

      if (response['statusCode'] == 200) {
        _documents = response['data'] ?? [];
        return response;
      } else {
        return response;
      }
    } catch (error) {
      return {
        'statusCode': 500,
        'message': 'Error loading documents: $error',
        'data': null,
      };
    } finally {
      setLoading(false);
    }
  }

  /// Get document by ID
  Future<Map<String, dynamic>> getDocumentById(String documentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return {
          'statusCode': 401,
          'message': 'Authentication required',
          'data': null,
        };
      }

      return await _documentService.getDocumentById(token, documentId);
    } catch (error) {
      return {
        'statusCode': 500,
        'message': 'Error loading document: $error',
        'data': null,
      };
    }
  }

  /// Upload a new document
  Future<Map<String, dynamic>> uploadDocument(
      String userId, String documentTypeId, File file) async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return {
          'statusCode': 401,
          'message': 'Authentication required',
          'data': null,
        };
      }

      final response = await _documentService.createDocument(
          token, userId, documentTypeId, file);

      if (response['statusCode'] == 200) {
        // Refresh documents list
        await getAllDocuments();
      }

      return response;
    } catch (error) {
      return {
        'statusCode': 500,
        'message': 'Error uploading document: $error',
        'data': null,
      };
    } finally {
      setLoading(false);
    }
  }

  /// Edit an existing document
  Future<Map<String, dynamic>> editDocument(String documentId, String userId,
      String documentTypeId, File file) async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return {
          'statusCode': 401,
          'message': 'Authentication required',
          'data': null,
        };
      }

      final response = await _documentService.editDocument(
          token, documentId, userId, documentTypeId, file);

      if (response['statusCode'] == 200) {
        // Refresh documents list
        await getAllDocuments();
      }

      return response;
    } catch (error) {
      return {
        'statusCode': 500,
        'message': 'Error updating document: $error',
        'data': null,
      };
    } finally {
      setLoading(false);
    }
  }

  /// Delete a document
  Future<Map<String, dynamic>> deleteDocument(String documentId) async {
    try {
      setLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return {
          'statusCode': 401,
          'message': 'Authentication required',
          'data': null,
        };
      }

      final response = await _documentService.deleteDocument(token, documentId);

      if (response['statusCode'] == 200) {
        // Refresh documents list
        await getAllDocuments();
      }

      return response;
    } catch (error) {
      return {
        'statusCode': 500,
        'message': 'Error deleting document: $error',
        'data': null,
      };
    } finally {
      setLoading(false);
    }
  }

  /// Get all document types
  Future<Map<String, dynamic>> getAllDocumentTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return {
          'statusCode': 401,
          'message': 'Authentication required',
          'data': null,
        };
      }

      final response = await _documentTypeService.getAllDocumentTypes(token);

      if (response['statusCode'] == 200) {
        _documentTypes = response['data'] ?? [];
        return response;
      } else {
        return response;
      }
    } catch (error) {
      return {
        'statusCode': 500,
        'message': 'Error loading document types: $error',
        'data': null,
      };
    }
  }

  /// Get documents by user ID
  List<DocumentModel> getDocumentsByUserId(String userId) {
    return _documents
        .where((doc) => doc.userId == userId && doc.published)
        .toList();
  }

  /// Get documents by document type ID
  List<DocumentModel> getDocumentsByTypeId(String documentTypeId) {
    return _documents
        .where((doc) => doc.documentTypeId == documentTypeId && doc.published)
        .toList();
  }

  /// Get document type by ID
  DocumentTypeModel? getDocumentTypeById(String documentTypeId) {
    try {
      return _documentTypes.firstWhere((type) => type.id == documentTypeId);
    } catch (e) {
      return null;
    }
  }

  /// Validate file for document type
  Map<String, dynamic> validateFileForDocumentType(
      File file, DocumentTypeModel documentType) {
    try {
      // Check if file exists
      if (!file.existsSync()) {
        return {
          'isValid': false,
          'message': 'File does not exist or is not accessible',
        };
      }

      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      // Safely get file size
      int fileSize;
      try {
        fileSize = file.lengthSync();
      } catch (e) {
        return {
          'isValid': false,
          'message': 'Unable to read file size. Please try again.',
        };
      }

      // Check file extension
      final isExtensionValid = documentType.isExtensionAllowed(extension);

      if (!isExtensionValid) {
        return {
          'isValid': false,
          'message':
              'File type not allowed. Allowed types: ${documentType.allowedExtensionsFormatted}. Your file: $extension',
        };
      }

      // Check file size
      if (!documentType.isFileSizeAllowed(fileSize)) {
        return {
          'isValid': false,
          'message':
              'File size too large. Maximum size: ${documentType.maxFileSizeFormatted}',
        };
      }

      return {
        'isValid': true,
        'message': 'File is valid',
      };
    } catch (error) {
      return {
        'isValid': false,
        'message': 'Error validating file: $error',
      };
    }
  }

  /// Clear cache
  void clearCache() {
    _documents.clear();
    _documentTypes.clear();
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
  }
}
