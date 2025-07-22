class MeetingSchedule {
  final String id;
  final String title;
  final String description;
  final String meetingDate;
  final String startTime;
  final String? endTime;
  final String? duration;
  final dynamic status; // Can be String (ID) or Map (populated object)
  final String scheduledByUserId;
  final String customerId;
  final String? propertyId;
  final String notes;
  final String createdByUserId;
  final String updatedByUserId;
  final bool published;
  final String? createdAt;
  final String? updatedAt;

  MeetingSchedule({
    required this.id,
    required this.title,
    required this.description,
    required this.meetingDate,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.status,
    required this.scheduledByUserId,
    required this.customerId,
    this.propertyId,
    required this.notes,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.published,
    this.createdAt,
    this.updatedAt,
  });

  factory MeetingSchedule.fromJson(Map<String, dynamic> json) {
    return MeetingSchedule(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      meetingDate: json['meetingDate'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'],
      duration: json['duration'],
      status: json['status'] ?? '',
      scheduledByUserId: json['scheduledByUserId'] ?? '',
      customerId: json['customerId'] ?? '',
      propertyId: json['propertyId'],
      notes: json['notes'] ?? '',
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
      'title': title,
      'description': description,
      'meetingDate': meetingDate,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'status': status,
      'scheduledByUserId': scheduledByUserId,
      'customerId': customerId,
      'propertyId': propertyId,
      'notes': notes,
      'createdByUserId': createdByUserId,
      'updatedByUserId': updatedByUserId,
      'published': published,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to get status name
  String getStatusName() {
    if (status is Map<String, dynamic>) {
      return status['name'] ?? '';
    }
    return status.toString();
  }
}
