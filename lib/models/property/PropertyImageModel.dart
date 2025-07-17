class PropertyImageModel {
  final String id;
  final String propertyId;
  final String fileName;
  final String originalUrl;
  final String? thumbnailUrl;
  final String? mediumUrl;
  final String? displayUrl;
  final String? imageId;
  final String? cloudinaryId;
  final int? size;
  final int? width;
  final int? height;
  final String? mimeType;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  PropertyImageModel({
    required this.id,
    required this.propertyId,
    required this.fileName,
    required this.originalUrl,
    this.thumbnailUrl,
    this.mediumUrl,
    this.displayUrl,
    this.imageId,
    this.cloudinaryId,
    this.size,
    this.width,
    this.height,
    this.mimeType,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialize from JSON
  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      id: json['_id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      fileName: json['fileName'] ?? '',
      originalUrl: json['originalUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      mediumUrl: json['mediumUrl'],
      displayUrl: json['displayUrl'],
      imageId: json['imageId'],
      cloudinaryId: json['cloudinaryId'],
      size: json['size'],
      width: json['width'],
      height: json['height'],
      mimeType: json['mimeType'],
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
      'propertyId': propertyId,
      'fileName': fileName,
      'originalUrl': originalUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediumUrl': mediumUrl,
      'displayUrl': displayUrl,
      'imageId': imageId,
      'cloudinaryId': cloudinaryId,
      'size': size,
      'width': width,
      'height': height,
      'mimeType': mimeType,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get the best URL for display (prioritize displayUrl, then mediumUrl, then originalUrl)
  String get displayImageUrl {
    if (displayUrl != null && displayUrl!.isNotEmpty) {
      return displayUrl!;
    } else if (mediumUrl != null && mediumUrl!.isNotEmpty) {
      return mediumUrl!;
    } else {
      return originalUrl;
    }
  }

  /// Get thumbnail URL for small displays
  String get thumbnailImageUrl {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return thumbnailUrl!;
    } else {
      return originalUrl;
    }
  }
}
