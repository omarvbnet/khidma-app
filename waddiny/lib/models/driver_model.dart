class Driver {
  final String id;
  final String name;
  final String phone;
  final String status;
  final String role;
  final double budget;
  final String province;
  final String? carId;
  final String? carNumber;
  final String? carType;
  final String? licenseId;
  final double? rating;
  final int totalTrips;
  final DateTime createdAt;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.role,
    required this.budget,
    required this.province,
    this.carId,
    this.carNumber,
    this.carType,
    this.licenseId,
    this.rating,
    required this.totalTrips,
    required this.createdAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      role: json['role'] as String,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      province: json['province'] as String,
      carId: json['carId'] as String?,
      carNumber: json['carNumber'] as String?,
      carType: json['carType'] as String?,
      licenseId: json['licenseId'] as String?,
      rating: (json['rate'] as num?)?.toDouble(),
      totalTrips: json['totalTrips'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'status': status,
      'role': role,
      'budget': budget,
      'province': province,
      'carId': carId,
      'carNumber': carNumber,
      'carType': carType,
      'licenseId': licenseId,
      'rating': rating,
      'totalTrips': totalTrips,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Driver copyWith({
    String? id,
    String? name,
    String? phone,
    String? status,
    String? role,
    double? budget,
    String? province,
    String? carId,
    String? carNumber,
    String? carType,
    String? licenseId,
    double? rating,
    int? totalTrips,
    DateTime? createdAt,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      role: role ?? this.role,
      budget: budget ?? this.budget,
      province: province ?? this.province,
      carId: carId ?? this.carId,
      carNumber: carNumber ?? this.carNumber,
      carType: carType ?? this.carType,
      licenseId: licenseId ?? this.licenseId,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
