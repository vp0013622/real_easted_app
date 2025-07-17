class FavoritePropertyModel {
  final String id;
  final String userId;
  final String propertyId;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoritePropertyModel({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FavoritePropertyModel.fromJson(Map<String, dynamic> json) {
    return FavoritePropertyModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      createdByUserId: json['createdByUserId'] ?? '',
      updatedByUserId: json['updatedByUserId'] ?? '',
      published: json['published'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'propertyId': propertyId,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FavoritePropertyModel(id: $id, userId: $userId, propertyId: $propertyId)';
  }
}
