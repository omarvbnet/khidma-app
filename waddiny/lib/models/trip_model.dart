import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {
  final String id;
  final String userId;
  final String? driverId;
  final String pickupLocation;
  final String dropoffLocation;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double fare;
  final double distance;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  final DateTime? acceptedAt;
  DateTime? startedAt;
  DateTime? completedAt;
  final String userProvince;
  final String? userFullName;
  final String? userPhone;
  final String? tripType;
  final double? driverDeduction;
  final String? driverPhone;
  final String? driverName;
  final String? carId;
  final String? carType;
  final String? licenseId;
  final double? driverRate;
  final LatLng pickupLocationLatLng;
  final LatLng dropoffLocationLatLng;
  final String pickupAddress;
  final String dropoffAddress;
  final String? routeDetails;

  Trip({
    required this.id,
    required this.userId,
    this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.fare,
    required this.distance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    required this.userProvince,
    this.userFullName,
    this.userPhone,
    this.tripType,
    this.driverDeduction,
    this.driverPhone,
    this.driverName,
    this.carId,
    this.carType,
    this.licenseId,
    this.driverRate,
    required this.pickupLocationLatLng,
    required this.dropoffLocationLatLng,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.routeDetails,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    print('\n=== PARSING TRIP FROM JSON ===');
    print('Raw JSON data:');
    print('- ID: ${json['id']}');
    print('- Status: ${json['status']}');
    print('- Pickup: (${json['pickupLat']}, ${json['pickupLng']})');
    print('- Dropoff: (${json['dropoffLat']}, ${json['dropoffLng']})');
    print('- Price: ${json['price']}');
    print('- Distance: ${json['distance']}');

    // Helper function to safely convert to double
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('Error parsing string to double: $value');
          return 0.0;
        }
      }
      print('Invalid value type for double conversion: $value');
      return 0.0;
    }

    // Helper function to normalize status
    String normalizeStatus(String? status) {
      if (status == null) return 'WAITING';
      return status.toUpperCase().replaceAll(' ', '_');
    }

    // Validate coordinates
    final pickupLat = safeToDouble(json['pickupLat']);
    final pickupLng = safeToDouble(json['pickupLng']);
    final dropoffLat = safeToDouble(json['dropoffLat']);
    final dropoffLng = safeToDouble(json['dropoffLng']);

    if (pickupLat == 0 ||
        pickupLng == 0 ||
        dropoffLat == 0 ||
        dropoffLng == 0) {
      print('Invalid coordinates detected:');
      print('- Pickup: ($pickupLat, $pickupLng)');
      print('- Dropoff: ($dropoffLat, $dropoffLng)');
      throw Exception('Invalid coordinates in trip data');
    }

    // Validate coordinate ranges
    if (pickupLat < -90 ||
        pickupLat > 90 ||
        dropoffLat < -90 ||
        dropoffLat > 90) {
      throw Exception('Invalid latitude values. Must be between -90 and 90.');
    }
    if (pickupLng < -180 ||
        pickupLng > 180 ||
        dropoffLng < -180 ||
        dropoffLng > 180) {
      throw Exception(
          'Invalid longitude values. Must be between -180 and 180.');
    }

    // Parse price and distance
    final price =
        safeToDouble(json['price'] ?? json['fare'] ?? json['tripCost']);
    final distance = safeToDouble(json['distance']);

    print('\nParsed trip details:');
    print('- ID: ${json['id']}');
    print('- Status: ${normalizeStatus(json['status'])}');
    print('- Price/Fare: $price');
    print('- Distance: $distance');
    print('- Pickup: ($pickupLat, $pickupLng)');
    print('- Dropoff: ($dropoffLat, $dropoffLng)');

    // Create LatLng objects for pickup and dropoff
    final pickupLocationLatLng = LatLng(pickupLat, pickupLng);
    final dropoffLocationLatLng = LatLng(dropoffLat, dropoffLng);

    return Trip(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      driverId: json['driverId']?.toString(),
      pickupLocation: json['pickupLocation']?.toString() ?? 'Unknown',
      dropoffLocation: json['dropoffLocation']?.toString() ?? 'Unknown',
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      fare: price,
      distance: distance,
      status: normalizeStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      userProvince: json['userProvince']?.toString() ?? 'Baghdad',
      userFullName: json['userFullName']?.toString(),
      userPhone: json['userPhone']?.toString(),
      tripType: json['tripType']?.toString() ?? 'ECO',
      driverDeduction: safeToDouble(json['driverDeduction']),
      driverPhone: json['driverPhone']?.toString(),
      driverName: json['driverName']?.toString(),
      carId: json['carId']?.toString(),
      carType: json['carType']?.toString(),
      licenseId: json['licenseId']?.toString(),
      driverRate: safeToDouble(json['driverRate']),
      pickupLocationLatLng: pickupLocationLatLng,
      dropoffLocationLatLng: dropoffLocationLatLng,
      pickupAddress: json['pickupAddress']?.toString() ??
          json['pickupLocation']?.toString() ??
          'Unknown',
      dropoffAddress: json['dropoffAddress']?.toString() ??
          json['dropoffLocation']?.toString() ??
          'Unknown',
      routeDetails: json['routeDetails']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'fare': fare,
      'distance': distance,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'userProvince': userProvince,
      'userFullName': userFullName,
      'userPhone': userPhone,
      'tripType': tripType,
      'driverDeduction': driverDeduction,
      'driverPhone': driverPhone,
      'driverName': driverName,
      'carId': carId,
      'carType': carType,
      'licenseId': licenseId,
      'driverRate': driverRate,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'routeDetails': routeDetails,
    };
  }

  bool get isActive {
    return status != 'TRIP_COMPLETED';
  }

  bool get isWaitingForDriver {
    return status == 'USER_WAITING';
  }

  bool get isDriverAccepted {
    return status == 'DRIVER_ACCEPTED';
  }

  bool get isDriverInWay {
    return status == 'DRIVER_IN_WAY';
  }

  bool get isDriverArrived {
    return status == 'DRIVER_ARRIVED';
  }

  bool get isUserPickedUp {
    return status == 'USER_PICKED_UP';
  }

  bool get isDriverInProgress {
    return status == 'DRIVER_IN_PROGRESS';
  }

  bool get isDriverArrivedDropoff {
    return status == 'DRIVER_ARRIVED_DROPOFF';
  }

  bool get isCompleted {
    return status == 'TRIP_COMPLETED';
  }

  bool get isCancelled {
    return status == 'TRIP_CANCELLED';
  }
}
