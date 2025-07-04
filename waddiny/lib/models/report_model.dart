class Report {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? category;
  final Map<String, dynamic>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  Report({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.category,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      priority: json['priority'] ?? 'MEDIUM',
      category: json['category'],
      attachments: json['attachments'] != null
          ? Map<String, dynamic>.from(json['attachments'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      resolvedBy: json['resolvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'category': category,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
    };
  }
}
