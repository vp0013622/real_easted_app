// ignore_for_file: file_names

class UserProfilePictureModel {
  final String id;
  final String userId;
  final String fileName;
  final String? url;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;

  UserProfilePictureModel({
    required this.id,
    required this.userId,
    required this.fileName,
    this.url,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
  });

  /// Deserialize from JSON
  factory UserProfilePictureModel.fromJson(Map<String, dynamic> json) {
    // Try all possible fields for the image URL
    String? url = json['url'] ?? json['displayUrl'] ?? json['originalUrl'];
    return UserProfilePictureModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      fileName: json['fileName'] ?? '',
      url: url,
      createdByUserId: json['createdByUserId'] ?? '',
      updatedByUserId: json['updatedByUserId'] ?? '',
      published: json['published'] ?? false,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
    };
  }
}
