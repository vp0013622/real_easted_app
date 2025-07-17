// ignore_for_file: prefer_final_fields

import 'package:inhabit_realties/services/propertyType/propertyTypeService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyTypeController {
  PropertyTypeService _propertyTypeService = PropertyTypeService();

  Future<Map<String, dynamic>> getAllPropertyTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    var propertyTypeData =
        await _propertyTypeService.getAllPropertyTypes(token);
    return propertyTypeData;
  }
}
