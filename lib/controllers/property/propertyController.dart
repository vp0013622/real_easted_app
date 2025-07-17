// ignore_for_file: prefer_final_fields, avoid_init_to_null

import 'package:inhabit_realties/Enums/propertyStatusEnum.dart';
import 'package:inhabit_realties/models/address/Address.dart';
import 'package:inhabit_realties/models/property/FeaturesModel.dart';
import 'package:inhabit_realties/models/property/PropertyModel.dart';
import 'package:inhabit_realties/services/property/propertyService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyController {
  PropertyService _propertyService = PropertyService();

  Future<Map<String, dynamic>> getAllProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    var response = null;
    response = await _propertyService.getAllProperties(token);
    return response;
  }

  Future<Map<String, dynamic>> createProperty(
    String name,
    String propertyTypeId,
    String description,
    String street,
    String area,
    String city,
    String state,
    String zipOrPinCode,
    String country,
    double lat,
    double lng,
    String ownerId,
    double price,
    String propertyStatus,
    int bedRooms,
    int bathRooms,
    double areaInSquarFoot,
    List<String> amenities,
    DateTime listedDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    var response = null;
    PropertyModel propertyModel = PropertyModel(
      id: '',
      name: name,
      propertyTypeId: propertyTypeId,
      description: description,
      propertyAddress: Address(
        street: street,
        area: area,
        city: city,
        state: state,
        zipOrPinCode: zipOrPinCode,
        country: country,
        location: Location(lat: lat, lng: lng),
      ),
      owner: ownerId,
      price: price,
      propertyStatus: PropertyStatus.fromString(propertyStatus),
      features: Features(
        bedRooms: bedRooms,
        bathRooms: bathRooms,
        areaInSquarFoot: areaInSquarFoot,
        amenities: amenities,
      ),
      listedDate: listedDate,
      createdByUserId: '',
      updatedByUserId: '',
      published: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    response = await _propertyService.createProperty(token, propertyModel);
    return response;
  }

  Future<Map<String, dynamic>> editProperty(
    String propertyId,
    String name,
    String propertyTypeId,
    String description,
    String street,
    String area,
    String city,
    String state,
    String zipOrPinCode,
    String country,
    double lat,
    double lng,
    String ownerId,
    double price,
    String propertyStatus,
    int bedRooms,
    int bathRooms,
    double areaInSquarFoot,
    List<String> amenities,
    DateTime listedDate,
    bool published,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    var response = null;
    PropertyModel propertyModel = PropertyModel(
      id: propertyId,
      name: name,
      propertyTypeId: propertyTypeId,
      description: description,
      propertyAddress: Address(
        street: street,
        area: area,
        city: city,
        state: state,
        zipOrPinCode: zipOrPinCode,
        country: country,
        location: Location(lat: lat, lng: lng),
      ),
      owner: ownerId,
      price: price,
      propertyStatus: PropertyStatus.fromString(propertyStatus),
      features: Features(
        bedRooms: bedRooms,
        bathRooms: bathRooms,
        areaInSquarFoot: areaInSquarFoot,
        amenities: amenities,
      ),
      listedDate: listedDate,
      createdByUserId: '',
      updatedByUserId: '',
      published: published,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    response =
        await _propertyService.editProperty(token, propertyId, propertyModel);
    return response;
  }
}
