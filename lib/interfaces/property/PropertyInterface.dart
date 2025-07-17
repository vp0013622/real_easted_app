// ignore_for_file: file_names
import 'package:inhabit_realties/models/property/PropertyModel.dart';

abstract class PropertyInterface {
  Future<Map<String, dynamic>> getAllProperties(String token);
  Future<Map<String, dynamic>> createProperty(
    String token,
    PropertyModel propertyModel,
  );
  Future<Map<String, dynamic>> getPropertyById(
    String token,
    String propertyId,
  );
  Future<Map<String, dynamic>> editProperty(
    String token,
    String propertyId,
    PropertyModel propertyModel,
  );
}
