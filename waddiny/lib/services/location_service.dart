import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static const Duration _timeout = Duration(seconds: 5);
  static const int _maxRetries = 2;
  StreamSubscription<Position>? _positionStreamSubscription;
  double _currentHeading = 0;

  Future<bool> requestLocationPermission() async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // If permission is already granted, return true
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }

      // If permission is denied forever, return false
      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // If permission is denied, request it
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      // Check if we have the required permissions
      var locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        locationStatus = await Permission.location.request();
        if (!locationStatus.isGranted) {
          return false;
        }
      }

      // Try to get background permission if not already granted
      var backgroundStatus = await Permission.locationAlways.status;
      if (!backgroundStatus.isGranted) {
        backgroundStatus = await Permission.locationAlways.request();
        // We'll continue even if background permission is denied
        print('Background location permission status: $backgroundStatus');
      }

      return true;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  Future<Position> getCurrentLocation() async {
    try {
      // Check if we already have permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: _timeout,
        );
      }

      // If we don't have permission, request it
      if (!await requestLocationPermission()) {
        throw Exception('Location permission not granted');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: _timeout,
      );
    } catch (e) {
      print('Error getting current location: $e');
      rethrow;
    }
  }

  void startLocationUpdates({
    required Function(Position) onLocationChanged,
    Function(double)? onHeadingChanged,
    Function(double)? onSpeedChanged,
  }) async {
    try {
      // Check if we already have permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _startUpdates(
          onLocationChanged: onLocationChanged,
          onHeadingChanged: onHeadingChanged,
          onSpeedChanged: onSpeedChanged,
        );
        return;
      }

      // If we don't have permission, request it
      if (!await requestLocationPermission()) {
        throw Exception('Location permission not granted');
      }

      _startUpdates(
        onLocationChanged: onLocationChanged,
        onHeadingChanged: onHeadingChanged,
        onSpeedChanged: onSpeedChanged,
      );
    } catch (e) {
      print('Error starting location updates: $e');
      rethrow;
    }
  }

  void _startUpdates({
    required Function(Position) onLocationChanged,
    Function(double)? onHeadingChanged,
    Function(double)? onSpeedChanged,
  }) {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (Position position) {
        _currentHeading = position.heading;
        onLocationChanged(position);
        if (onHeadingChanged != null) {
          onHeadingChanged(position.heading);
        }
        if (onSpeedChanged != null) {
          onSpeedChanged(position.speed);
        }
      },
      onError: (error) {
        print('Error in location stream: $error');
      },
    );
  }

  double getCurrentHeading() {
    return _currentHeading;
  }

  void dispose() {
    _positionStreamSubscription?.cancel();
  }

  Future<String> getProvinceFromCoordinates(double lat, double lng) async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        final response = await http.get(
          Uri.parse(
              '${ApiConstants.baseUrl}/location/province?lat=$lat&lng=$lng'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(_timeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['province'];
        }
        retryCount++;
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        retryCount++;
        if (retryCount == _maxRetries) {
          throw Exception('Failed to get province after $_maxRetries attempts');
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('Failed to get province');
  }

  Future<void> updateUserProvince(String token, String province) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConstants.baseUrl}/users/province'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'province': province}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to update province');
      }
    } catch (e) {
      throw Exception('Error updating province: $e');
    }
  }

  Future<void> updateProvinceOnAppStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final position = await getCurrentLocation();
      final province = await getProvinceFromCoordinates(
        position.latitude,
        position.longitude,
      );

      await updateUserProvince(token, province);
    } catch (e) {
      print('Error updating province on app start: $e');
    }
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
      return 'Unknown location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown location';
    }
  }
}
