import 'package:inhabit_realties/models/address/Address.dart';

class UserAddressModel {
  final String id;
  final String userId;
  final Address address;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserAddressModel({
    required this.id,
    required this.userId,
    required this.address,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialize from JSON
  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      address: Address.fromJson(json),
      createdByUserId: json['createdByUserId'] ?? '',
      updatedByUserId: json['updatedByUserId'] ?? '',
      published: json['published'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      ...address.toJson(),
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get full address as string
  String get fullAddress {
    return address.fullAddress;
  }

  /// Get short address (city, state, country)
  String get shortAddress {
    return address.shortAddress;
  }
}
