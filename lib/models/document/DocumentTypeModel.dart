class DocumentTypeModel {
  final String id;
  final String name;
  final String description;
  final List<String> allowedExtensions;
  final int maxFileSize;
  final bool isRequired;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.allowedExtensions,
    required this.maxFileSize,
    required this.isRequired,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deserialize from JSON
  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      allowedExtensions: json['allowedExtensions'] != null
          ? List<String>.from(json['allowedExtensions'])
          : ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      maxFileSize: json['maxFileSize'] ?? 10 * 1024 * 1024, // 10MB default
      isRequired: json['isRequired'] ?? false,
      createdByUserId: json['createdByUserId'] ?? '',
      updatedByUserId: json['updatedByUserId'] ?? '',
      published: json['published'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'allowedExtensions': allowedExtensions,
      'maxFileSize': maxFileSize,
      'isRequired': isRequired,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get max file size in human readable format
  String get maxFileSizeFormatted {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int index = 0;
    double fileSize = maxFileSize.toDouble();

    while (fileSize >= 1024 && index < suffixes.length - 1) {
      fileSize /= 1024;
      index++;
    }

    return '${fileSize.toStringAsFixed(1)} ${suffixes[index]}';
  }

  /// Get allowed extensions as a formatted string
  String get allowedExtensionsFormatted {
    return allowedExtensions.join(', ').toUpperCase();
  }

  /// Check if a file extension is allowed
  bool isExtensionAllowed(String extension) {
    // Normalize the extension (remove dot if present and convert to lowercase)
    final normalizedExtension = extension.toLowerCase().replaceAll('.', '');

    // Check if the normalized extension is in the allowed extensions list
    // Also handle cases where allowedExtensions might have dots
    final result = allowedExtensions.any((allowedExt) {
      final normalizedAllowedExt = allowedExt.toLowerCase().replaceAll('.', '');
      final matches = normalizedAllowedExt == normalizedExtension;
      return matches;
    });

    return result;
  }

  /// Check if a file size is within limits
  bool isFileSizeAllowed(int fileSize) {
    return fileSize <= maxFileSize;
  }
}
