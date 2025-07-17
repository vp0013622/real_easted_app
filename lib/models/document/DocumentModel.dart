class DocumentModel {
  final String id;
  final String userId;
  final String documentTypeId;
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

  DocumentModel({
    required this.id,
    required this.userId,
    required this.documentTypeId,
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
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    // Helper function to extract ID from either string or object
    String extractId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return value['_id']?.toString() ?? '';
      }
      return value.toString();
    }

    return DocumentModel(
      id: json['_id'] ?? '',
      userId: extractId(json['userId']),
      documentTypeId: extractId(json['documentTypeId']),
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
      createdByUserId: extractId(json['createdByUserId']),
      updatedByUserId: extractId(json['updatedByUserId']),
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
      'userId': userId,
      'documentTypeId': documentTypeId,
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

  /// Get display URL (prefer displayUrl, fallback to originalUrl)
  String get displayDocumentUrl {
    return displayUrl ?? originalUrl;
  }

  /// Get file size in human readable format
  String get fileSizeFormatted {
    if (size == null) return 'Unknown size';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int index = 0;
    double fileSize = size!.toDouble();

    while (fileSize >= 1024 && index < suffixes.length - 1) {
      fileSize /= 1024;
      index++;
    }

    return '${fileSize.toStringAsFixed(1)} ${suffixes[index]}';
  }

  /// Get file extension
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check if file is an image
  bool get isImage {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  /// Check if file is a PDF
  bool get isPdf {
    return fileExtension == 'pdf';
  }

  /// Check if file is a document (Word, Excel, etc.)
  bool get isDocument {
    final docExtensions = ['doc', 'docx', 'xls', 'xlsx', 'txt'];
    return docExtensions.contains(fileExtension);
  }
}
