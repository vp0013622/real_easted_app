import 'dart:io';
import '../../models/document/DocumentModel.dart';

abstract class DocumentInterface {
  Future<Map<String, dynamic>> getAllDocuments(String token);
  Future<Map<String, dynamic>> getAllDocumentsWithParams(
      String token, Map<String, dynamic> params);
  Future<Map<String, dynamic>> getDocumentById(String token, String documentId);
  Future<Map<String, dynamic>> createDocument(
      String token, String userId, String documentTypeId, File file);
  Future<Map<String, dynamic>> editDocument(String token, String documentId,
      String userId, String documentTypeId, File file);
  Future<Map<String, dynamic>> deleteDocument(String token, String documentId);
}
