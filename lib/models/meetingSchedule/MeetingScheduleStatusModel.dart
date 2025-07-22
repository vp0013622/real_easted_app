class MeetingScheduleStatusModel {
  final String id;
  final String name;
  final int statusCode;
  final String description;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final String? createdAt;
  final String? updatedAt;

  MeetingScheduleStatusModel({
    required this.id,
    required this.name,
    required this.statusCode,
    required this.description,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    this.createdAt,
    this.updatedAt,
  });

  factory MeetingScheduleStatusModel.fromJson(Map<String, dynamic> json) {
    return MeetingScheduleStatusModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      description: json['description'] ?? '',
      createdByUserId: json['createdByUserId'] ?? '',
      updatedByUserId: json['updatedByUserId'] ?? '',
      published: json['published'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'statusCode': statusCode,
      'description': description,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
