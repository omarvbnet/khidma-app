import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart' show Colors;
import '../constants/api_keys.dart';

class MapService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  static const String _apiKey = ApiKeys.googleMapsApiKey;
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 10);

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5),
    );
  }

  Future<Map<String, dynamic>> getRouteDetails(
    LatLng origin,
    LatLng destination,
  ) async {
    int attempts = 0;
    const maxAttempts = 3;
    const retryDelay = Duration(seconds: 1);

    while (attempts < maxAttempts) {
      try {
        // Validate coordinates more thoroughly
        if (!_isValidCoordinate(origin) || !_isValidCoordinate(destination)) {
          print('Invalid coordinates provided, using fallback route');
          // Return a simple fallback route instead of throwing an exception
          final points = [origin, destination];
          final encodedPolyline = _encodePolyline(points);
          return {
            'distance': '0.1 km',
            'duration': '1 min',
            'polyline': encodedPolyline,
            'points': points,
          };
        }

        // Check if coordinates are too close to each other
        final distance = Geolocator.distanceBetween(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude,
        );

        if (distance < 10) {
          // If less than 10 meters apart, return a direct route
          final points = [origin, destination];
          final encodedPolyline = _encodePolyline(points);
          return {
            'distance': '0.01 km',
            'duration': '1 min',
            'polyline': encodedPolyline,
            'points': points,
          };
        }

        // Get multiple route alternatives to find the shortest one
        final url =
            Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
                '?origin=${origin.latitude},${origin.longitude}'
                '&destination=${destination.latitude},${destination.longitude}'
                '&key=$_apiKey'
                '&mode=driving'
                '&alternatives=true'
                '&language=en'
                '&units=metric'
                '&region=iq'
                '&avoid=tolls|highways');

        final response = await http.get(url);
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          // Find the shortest route among alternatives
          Map<String, dynamic> shortestRoute = data['routes'][0];
          double shortestDistance = double.infinity;

          for (final route in data['routes']) {
            final leg = route['legs'][0];
            final distanceText = leg['distance']['text'];
            final distanceValue =
                leg['distance']['value']; // Distance in meters

            if (distanceValue < shortestDistance) {
              shortestDistance = distanceValue.toDouble();
              shortestRoute = route;
            }
          }

          final leg = shortestRoute['legs'][0];
          final distance = leg['distance']['text'];
          final duration = leg['duration']['text'];
          final polyline = shortestRoute['overview_polyline']['points'];

          // Decode the polyline points
          final points = _decodePolyline(polyline);

          print(
              'Selected shortest route: $distance (${shortestDistance.toStringAsFixed(0)} meters)');

          return {
            'distance': distance,
            'duration': duration,
            'polyline': polyline,
            'points': points,
            'distanceInMeters': shortestDistance,
          };
        }

        // If no route found, try with a larger offset
        if (attempts < maxAttempts - 1) {
          // Add a larger offset to the destination coordinates
          final offset =
              0.001 * (attempts + 1); // Increasing offset with each attempt
          destination = LatLng(
            destination.latitude + offset,
            destination.longitude + offset,
          );
          attempts++;
          await Future.delayed(retryDelay);
          continue;
        }
        throw Exception('No valid route found between the locations');
      } catch (e) {
        if (attempts == maxAttempts - 1) {
          throw Exception(
              'Failed to get route after $maxAttempts attempts: $e');
        }
        attempts++;
        await Future.delayed(retryDelay);
      }
    }

    throw Exception('Failed to get route after $maxAttempts attempts');
  }

  String _encodePolyline(List<LatLng> points) {
    if (points.isEmpty) return '';

    final result = StringBuffer();
    int lat = 0;
    int lng = 0;

    for (final point in points) {
      final latDiff = (point.latitude * 1E5).round() - lat;
      final lngDiff = (point.longitude * 1E5).round() - lng;

      lat = (point.latitude * 1E5).round();
      lng = (point.longitude * 1E5).round();

      result.write(_encodeNumber(latDiff));
      result.write(_encodeNumber(lngDiff));
    }

    return result.toString();
  }

  String _encodeNumber(int num) {
    num = num < 0 ? ~(num << 1) : (num << 1);
    final result = StringBuffer();

    while (num >= 0x20) {
      result.write(String.fromCharCode((0x20 | (num & 0x1f)) + 63));
      num >>= 5;
    }

    result.write(String.fromCharCode(num + 63));
    return result.toString();
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return poly;
  }

  Set<Polyline> decodePolyline(String encoded) {
    final points = _decodePolyline(encoded);
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: points,
        patterns: [PatternItem.dash(30), PatternItem.gap(20)],
        consumeTapEvents: true,
        geodesic: true,
      ),
    };
  }

  String getMapStyle() {
    return '''
      [
        {
          "featureType": "all",
          "elementType": "all",
          "stylers": [
            {
              "visibility": "on"
            }
          ]
        },
        {
          "featureType": "administrative",
          "elementType": "all",
          "stylers": [
            {
              "visibility": "on"
            }
          ]
        },
        {
          "featureType": "landscape",
          "elementType": "all",
          "stylers": [
            {
              "visibility": "on"
            }
          ]
        },
        {
          "featureType": "poi",
          "elementType": "all",
          "stylers": [
            {
              "visibility": "on"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "all",
          "stylers": [
            {
              "visibility": "on"
            }
          ]
        },
        {
          "featureType": "transit",
          "elementType": "all",
          "stylers": [
            {
              "visibility": "on"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "all",
          "stylers": [
            {
              "visibility": "on"
            }
          ]
        }
      ]
    ''';
  }

  Map<String, dynamic> getMapConfiguration() {
    return {
      'mapType': MapType.normal,
      'zoomControlsEnabled': true,
      'myLocationEnabled': true,
      'myLocationButtonEnabled': true,
      'compassEnabled': true,
      'rotateGesturesEnabled': true,
      'scrollGesturesEnabled': true,
      'tiltGesturesEnabled': true,
      'zoomGesturesEnabled': true,
    };
  }

  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/geocode/json?latlng=${position.latitude},${position.longitude}'
        '&key=$_apiKey'
        '&language=en',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      throw Exception('Failed to get address');
    } catch (e) {
      throw Exception('Error getting address: $e');
    }
  }

  Future<List<LatLng>> searchPlaces(String query) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/place/textsearch/json?query=$query'
        '&key=$_apiKey'
        '&language=en',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'].map<LatLng>((place) {
            final location = place['geometry']['location'];
            return LatLng(location['lat'], location['lng']);
          }).toList();
        }
      }
      throw Exception('No places found');
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMultipleRouteOptions(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      // Validate coordinates
      if (!_isValidCoordinate(origin) || !_isValidCoordinate(destination)) {
        throw Exception('Invalid coordinates provided');
      }

      // Check if coordinates are too close to each other
      final distance = Geolocator.distanceBetween(
        origin.latitude,
        origin.longitude,
        destination.latitude,
        destination.longitude,
      );

      if (distance < 10) {
        // If less than 10 meters apart, return a direct route
        final points = [origin, destination];
        final encodedPolyline = _encodePolyline(points);
        return [
          {
            'distance': '0.01 km',
            'duration': '1 min',
            'polyline': encodedPolyline,
            'points': points,
            'distanceInMeters': 10.0,
            'isShortest': true,
          }
        ];
      }

      final url =
          Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
              '?origin=${origin.latitude},${origin.longitude}'
              '&destination=${destination.latitude},${destination.longitude}'
              '&key=$_apiKey'
              '&mode=driving'
              '&alternatives=true'
              '&language=en'
              '&units=metric'
              '&region=iq');

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        List<Map<String, dynamic>> routeOptions = [];
        double shortestDistance = double.infinity;

        // First pass: find the shortest distance
        for (final route in data['routes']) {
          final leg = route['legs'][0];
          final distanceValue = leg['distance']['value'];
          if (distanceValue < shortestDistance) {
            shortestDistance = distanceValue.toDouble();
          }
        }

        // Second pass: build route options
        for (int i = 0; i < data['routes'].length; i++) {
          final route = data['routes'][i];
          final leg = route['legs'][0];
          final distance = leg['distance']['text'];
          final duration = leg['duration']['text'];
          final polyline = route['overview_polyline']['points'];
          final distanceValue = leg['distance']['value'];
          final points = _decodePolyline(polyline);

          routeOptions.add({
            'index': i,
            'distance': distance,
            'duration': duration,
            'polyline': polyline,
            'points': points,
            'distanceInMeters': distanceValue.toDouble(),
            'isShortest': distanceValue == shortestDistance,
            'summary': leg['summary'] ?? 'Route ${i + 1}',
          });
        }

        // Sort by distance (shortest first)
        routeOptions.sort(
            (a, b) => a['distanceInMeters'].compareTo(b['distanceInMeters']));

        return routeOptions;
      }

      throw Exception('No valid routes found between the locations');
    } catch (e) {
      throw Exception('Error getting route options: $e');
    }
  }

  Future<Map<String, dynamic>> _getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    int attempts = 0;
    const maxAttempts = 3;
    const retryDelay = Duration(seconds: 1);

    while (attempts < maxAttempts) {
      try {
        // Validate coordinates more thoroughly
        if (!_isValidCoordinate(origin) || !_isValidCoordinate(destination)) {
          print('Invalid coordinates provided, using fallback route');
          // Return a simple fallback route instead of throwing an exception
          final points = [origin, destination];
          final encodedPolyline = _encodePolyline(points);
          return {
            'distance': '0.1 km',
            'duration': '1 min',
            'polyline': encodedPolyline,
            'points': points,
          };
        }

        // Check if coordinates are too close to each other
        final distance = Geolocator.distanceBetween(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude,
        );

        if (distance < 10) {
          // If less than 10 meters apart, return a direct route
          final points = [origin, destination];
          final encodedPolyline = _encodePolyline(points);
          return {
            'distance': '0.01 km',
            'duration': '1 min',
            'polyline': encodedPolyline,
            'points': points,
          };
        }

        final url =
            Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
                '?origin=${origin.latitude},${origin.longitude}'
                '&destination=${destination.latitude},${destination.longitude}'
                '&key=$_apiKey'
                '&mode=driving'
                '&alternatives=false'
                '&language=en'
                '&units=metric'
                '&region=iq');

        final response = await http.get(url);
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          final distance = leg['distance']['text'];
          final duration = leg['duration']['text'];
          final polyline = route['overview_polyline']['points'];

          // Decode the polyline points
          final points = _decodePolyline(polyline);

          return {
            'distance': distance,
            'duration': duration,
            'polyline': polyline,
            'points': points,
          };
        }

        // If no route found, try with a larger offset
        if (attempts < maxAttempts - 1) {
          // Add a larger offset to the destination coordinates
          final offset =
              0.001 * (attempts + 1); // Increasing offset with each attempt
          destination = LatLng(
            destination.latitude + offset,
            destination.longitude + offset,
          );
          attempts++;
          await Future.delayed(retryDelay);
          continue;
        }
        throw Exception('No valid route found between the locations');
      } catch (e) {
        if (attempts == maxAttempts - 1) {
          throw Exception(
              'Failed to get route after $maxAttempts attempts: $e');
        }
        attempts++;
        await Future.delayed(retryDelay);
      }
    }

    throw Exception('Failed to get route after $maxAttempts attempts');
  }

  Future<Map<String, dynamic>> getRoute(
    LatLng currentLocation,
    LatLng pickupLocation,
    LatLng dropoffLocation,
  ) async {
    try {
      // Validate all coordinates
      if (!_isValidCoordinate(currentLocation) ||
          !_isValidCoordinate(pickupLocation) ||
          !_isValidCoordinate(dropoffLocation)) {
        print('Invalid coordinates provided in getRoute, using fallback');
        // Return empty route instead of throwing exception
        return {
          'polylines': <Polyline>{},
          'markers': <Marker>{},
        };
      }

      // Get route from current location to pickup
      final pickupRoute = await _getDirections(
        currentLocation,
        pickupLocation,
      );

      // Get route from pickup to dropoff
      final dropoffRoute = await _getDirections(
        pickupLocation,
        dropoffLocation,
      );

      // Combine polylines
      final polylines = <Polyline>{
        ...pickupRoute['polylines'] as Set<Polyline>,
        ...dropoffRoute['polylines'] as Set<Polyline>,
      };

      // Combine markers
      final markers = <Marker>{
        ...pickupRoute['markers'] as Set<Marker>,
        ...dropoffRoute['markers'] as Set<Marker>,
      };

      return {
        'polylines': polylines,
        'markers': markers,
      };
    } catch (e) {
      print('Error getting route: $e');
      // Return empty route instead of rethrowing
      return {
        'polylines': <Polyline>{},
        'markers': <Marker>{},
      };
    }
  }

  bool _isValidCoordinate(LatLng coordinate) {
    // Check for null coordinates
    if (coordinate == null) {
      return false;
    }

    // Check for NaN values
    if (coordinate.latitude.isNaN ||
        coordinate.longitude.isNaN ||
        coordinate.latitude.isInfinite ||
        coordinate.longitude.isInfinite) {
      return false;
    }

    // Check for zero coordinates (common invalid value)
    if (coordinate.latitude == 0.0 && coordinate.longitude == 0.0) {
      return false;
    }

    // Check if coordinates are within valid ranges
    if (coordinate.latitude < -90 ||
        coordinate.latitude > 90 ||
        coordinate.longitude < -180 ||
        coordinate.longitude > 180) {
      return false;
    }

    return true;
  }
}
