class User {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String status;
  final String province;
  final double budget;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.status,
    required this.province,
    required this.budget,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'USER',
      status: json['status'] ?? 'ACTIVE',
      province: json['province'] ?? '',
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'status': status,
      'province': province,
      'budget': budget,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isDriver => role == 'DRIVER';
}
