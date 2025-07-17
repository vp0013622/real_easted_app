class ReferenceSourceModel {
  final String id;
  final String name;
  final String description;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferenceSourceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Helper method to extract ObjectId from MongoDB format
  static String _extractObjectId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map && value.containsKey('\$oid')) {
      return value['\$oid'] ?? '';
    }
    return value.toString();
  }

  /// Helper method to extract date from MongoDB format
  static DateTime _extractDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (value is Map && value.containsKey('\$date')) {
      final dateValue = value['\$date'];
      if (dateValue is Map && dateValue.containsKey('\$numberLong')) {
        final timestamp = int.tryParse(dateValue['\$numberLong'] ?? '0') ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    }
    return DateTime.now();
  }

  /// Deserialize from JSON
  factory ReferenceSourceModel.fromJson(Map<String, dynamic> json) {
    return ReferenceSourceModel(
      id: _extractObjectId(json['_id']),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdByUserId: _extractObjectId(json['createdByUserId']),
      updatedByUserId: _extractObjectId(json['updatedByUserId']),
      published: json['published'] ?? false,
      createdAt: _extractDate(json['createdAt']),
      updatedAt: _extractDate(json['updatedAt']),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
 