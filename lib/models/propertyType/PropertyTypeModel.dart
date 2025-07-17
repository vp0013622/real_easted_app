// ignore_for_file: file_names

class PropertyTypeModel {
  final String id;
  final String typeName;
  final String description;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;

  PropertyTypeModel({
    required this.id,
    required this.typeName,
    required this.description,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
  });

  /// Deserialize from JSON
  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: json['_id'] ?? '',
      typeName: json['typeName'] ?? '',
      description: json['description'] ?? '',
      createdByUserId: json['createdByUserId'] ?? '',
      updatedByUserId: json['updatedByUserId'] ?? '',
      published: json['published'] ?? false,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeName': typeName,
      'description': description,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
    };
  }
}
