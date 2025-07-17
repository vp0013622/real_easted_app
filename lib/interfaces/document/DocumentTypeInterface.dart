import '../../models/document/DocumentTypeModel.dart';

abstract class DocumentTypeInterface {
  Future<Map<String, dynamic>> getAllDocumentTypes(String token);
  Future<Map<String, dynamic>> getDocumentTypeById(
      String token, String documentTypeId);
  Future<Map<String, dynamic>> createDocumentType(
      String token, Map<String, dynamic> documentTypeData);
  Future<Map<String, dynamic>> editDocumentType(String token,
      String documentTypeId, Map<String, dynamic> documentTypeData);
  Future<Map<String, dynamic>> deleteDocumentType(
      String token, String documentTypeId);
}
