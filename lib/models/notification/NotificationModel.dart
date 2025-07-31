class NotificationModel {
  final String id;
  final List<String> recipientIds;
  final String type;
  final String title;
  final String message;
  final String? relatedId;
  final String? relatedModel;
  final Map<String, dynamic> data;
  final bool isRead;
  final String priority;
  final DateTime? expiresAt;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.recipientIds,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    this.relatedModel,
    required this.data,
    required this.isRead,
    required this.priority,
    this.expiresAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    print('🔍 [DEBUG] Parsing notification JSON: $json');

    // Handle both old single recipientId and new recipientIds array
    List<String> recipientIds = [];
    if (json['recipientIds'] != null) {
      // New format: array of recipient IDs (can be strings or objects with _id)
      if (json['recipientIds'] is List) {
        for (var recipient in json['recipientIds']) {
          if (recipient is String) {
            recipientIds.add(recipient);
          } else if (recipient is Map<String, dynamic> &&
              recipient['_id'] != null) {
            recipientIds.add(recipient['_id']);
          }
        }
      }
    } else if (json['recipientId'] != null) {
      // Old format: single recipient ID
      recipientIds = [json['recipientId']];
    }

    print('🔍 [DEBUG] Parsed recipientIds: $recipientIds');

    return NotificationModel(
      id: json['_id'] ?? '',
      recipientIds: recipientIds,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedId: json['relatedId'] is String
          ? json['relatedId']
          : json['relatedId']?['_id'],
      relatedModel: json['relatedModel'],
      data: json['data'] ?? {},
      isRead: json['isRead'] ?? false,
      priority: json['priority'] ?? 'medium',
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      createdByUserId: json['createdByUserId'] is String ? json['createdByUserId'] : json['createdByUserId']?['_id'] ?? '',
      updatedByUserId: json['updatedByUserId'] is String ? json['updatedByUserId'] : json['updatedByUserId']?['_id'] ?? '',
      published: json['published'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipientIds': recipientIds,
      'type': type,
      'title': title,
      'message': message,
      'relatedId': relatedId,
      'relatedModel': relatedModel,
      'data': data,
      'isRead': isRead,
      'priority': priority,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    List<String>? recipientIds,
    String? type,
    String? title,
    String? message,
    String? relatedId,
    String? relatedModel,
    Map<String, dynamic>? data,
    bool? isRead,
    String? priority,
    DateTime? expiresAt,
    String? createdByUserId,
    String? updatedByUserId,
    bool? published,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientIds: recipientIds ?? this.recipientIds,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      relatedId: relatedId ?? this.relatedId,
      relatedModel: relatedModel ?? this.relatedModel,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      expiresAt: expiresAt ?? this.expiresAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, message: $message, isRead: $isRead, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
