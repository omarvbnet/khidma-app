class TaxiRequest {
  final String id;
  final String userId;
  final String? driverId;
  final String status;
  final String pickupLocation;
  final String dropoffLocation;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double price;
  final double distance;
  final double driverDeduction;
  final String userProvince;
  final String userPhone;
  final String userFullName;
  final String? paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? driverPhone;
  final String? driverName;
  final String? carId;
  final String? carType;
  final String? licenseId;
  final double? driverRate;
  final String tripType;

  TaxiRequest({
    required this.id,
    required this.userId,
    this.driverId,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.price,
    required this.distance,
    required this.driverDeduction,
    required this.userProvince,
    required this.userPhone,
    required this.userFullName,
    this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.driverPhone,
    this.driverName,
    this.carId,
    this.carType,
    this.licenseId,
    this.driverRate,
    required this.tripType,
  });

  factory TaxiRequest.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'USER_WAITING') as String;

    return TaxiRequest(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      driverId: json['driverId']?.toString(),
      status: rawStatus.toUpperCase(),
      pickupLocation: json['pickupLocation']?.toString() ?? '',
      dropoffLocation: json['dropoffLocation']?.toString() ?? '',
      pickupLat: (json['pickupLat'] ?? 0.0).toDouble(),
      pickupLng: (json['pickupLng'] ?? 0.0).toDouble(),
      dropoffLat: (json['dropoffLat'] ?? 0.0).toDouble(),
      dropoffLng: (json['dropoffLng'] ?? 0.0).toDouble(),
      price: (json['price'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      driverDeduction: (json['driverDeduction'] ?? 0.0).toDouble(),
      userProvince: json['userProvince']?.toString() ?? '',
      userPhone: json['userPhone']?.toString() ?? '',
      userFullName: json['userFullName']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      driverPhone: json['driverPhone']?.toString(),
      driverName: json['driverName']?.toString(),
      carId: json['carId']?.toString(),
      carType: json['carType']?.toString(),
      licenseId: json['licenseId']?.toString(),
      driverRate: json['driverRate'] != null
          ? (json['driverRate'] as num).toDouble()
          : null,
      tripType: json['tripType']?.toString() ?? 'ECO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'driverId': driverId,
      'status': status,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'price': price,
      'distance': distance,
      'driverDeduction': driverDeduction,
      'userProvince': userProvince,
      'userPhone': userPhone,
      'userFullName': userFullName,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'driverPhone': driverPhone,
      'driverName': driverName,
      'carId': carId,
      'carType': carType,
      'licenseId': licenseId,
      'driverRate': driverRate,
      'tripType': tripType,
    };
  }

  TaxiRequest copyWith({
    String? id,
    String? userId,
    String? driverId,
    String? status,
    String? pickupLocation,
    String? dropoffLocation,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    double? price,
    double? distance,
    double? driverDeduction,
    String? userProvince,
    String? userPhone,
    String? userFullName,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? driverPhone,
    String? driverName,
    String? carId,
    String? carType,
    String? licenseId,
    double? driverRate,
    String? tripType,
  }) {
    return TaxiRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      price: price ?? this.price,
      distance: distance ?? this.distance,
      driverDeduction: driverDeduction ?? this.driverDeduction,
      userProvince: userProvince ?? this.userProvince,
      userPhone: userPhone ?? this.userPhone,
      userFullName: userFullName ?? this.userFullName,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driverPhone: driverPhone ?? this.driverPhone,
      driverName: driverName ?? this.driverName,
      carId: carId ?? this.carId,
      carType: carType ?? this.carType,
      licenseId: licenseId ?? this.licenseId,
      driverRate: driverRate ?? this.driverRate,
      tripType: tripType ?? this.tripType,
    );
  }
}
