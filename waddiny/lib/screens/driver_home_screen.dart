import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../services/trip_service.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../models/trip_model.dart';
import '../models/taxi_request_model.dart';
import 'driver_waiting_trips_screen.dart';
import 'driver_navigation_screen.dart';
import 'driver_accepted_trip_screen.dart';
import 'dart:async';
import '../services/api_service.dart';
import 'driver_trip_details_screen.dart';
import 'driver_arrived_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _tripService = TripService();
  final _authService = AuthService();
  final _driverService = DriverService(ApiService());
  bool _isLoading = true;
  Trip? _currentTrip;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadCurrentTrip();
    // Refresh every 10 seconds to keep trip status in sync
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _loadCurrentTrip();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentTrip([String? status]) async {
    try {
      print('\n=== LOADING CURRENT TRIP ===');
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }
      print('Current user:');
      print('- ID: ${user['id']}');
      print('- Role: ${user['role']}');

      // Get driver profile (Driver entity) to get correct driver ID
      final driverProfile = await _driverService.getDriverProfile();
      final currentDriverId = driverProfile.id;
      print('Driver profile:');
      print('- Driver ID: $currentDriverId');

      final trips = await _tripService.getDriverTrips(currentDriverId);
      print('\nAll trips:');
      for (var trip in trips) {
        print('\nTrip ${trip.id}:');
        print('- Status: ${trip.status}');
        print('- Driver ID: ${trip.driverId}');
        print('- User ID: ${trip.userId}');
      }

      if (trips.isEmpty) {
        print('No trips found, showing waiting screen');
        if (mounted) {
          setState(() {
            _currentTrip = null;
            _isLoading = false;
          });
        }
        return;
      }

      // Find the most recent active trip with updated status handling
      final activeTrip = trips.firstWhereOrNull(
        (trip) {
          final isActive = trip.status == 'DRIVER_ACCEPTED' ||
              trip.status == 'DRIVER_IN_WAY' ||
              trip.status == 'DRIVER_ARRIVED' ||
              trip.status == 'USER_PICKED_UP' ||
              trip.status == 'DRIVER_IN_PROGRESS' ||
              trip.status == 'DRIVER_ARRIVED_DROPOFF';
          final isDriverMatch =
              trip.driverId == null || trip.driverId == currentDriverId;
          print('\nChecking trip ${trip.id}:');
          print('- Status: ${trip.status}');
          print('- Driver ID: ${trip.driverId}');
          print('- Current driver ID: $currentDriverId');
          print('- Is active: $isActive');
          print('- Is driver match: $isDriverMatch');
          return isActive && isDriverMatch;
        },
      );
      print('\nActive trip found:');
      if (activeTrip != null) {
        print('- ID: ${activeTrip.id}');
        print('- Status: ${activeTrip.status}');
        print('- Driver ID: ${activeTrip.driverId}');
      } else {
        print('No active trip found');
      }

      if (mounted) {
        setState(() {
          _currentTrip = activeTrip;
          _isLoading = false;
        });
        print('\nState updated with trip:');
        if (_currentTrip != null) {
          print('- ID: ${_currentTrip!.id}');
          print('- Status: ${_currentTrip!.status}');
          print('- Driver ID: ${_currentTrip!.driverId}');
        } else {
          print('No trip set');
        }
      }
    } catch (e) {
      print('Error in _loadCurrentTrip: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('\n=== BUILDING DRIVER HOME SCREEN ===');
    print('Current trip: ${_currentTrip?.id}');
    print('Current trip status: ${_currentTrip?.status}');
    print('Is loading: $_isLoading');

    if (_isLoading) {
      print('Showing loading screen');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentTrip == null) {
      print('No active trip, showing waiting screen');
      return const DriverWaitingTripsScreen();
    }

    print('Checking trip status: ${_currentTrip!.status}');

    // Handle different trip statuses
    switch (_currentTrip!.status.toUpperCase()) {
      case 'DRIVER_ACCEPTED':
        print('Showing accepted trip screen for trip: ${_currentTrip!.id}');
        return DriverAcceptedTripScreen(trip: _currentTrip!);

      case 'DRIVER_IN_WAY':
        print('Showing pickup navigation for trip: ${_currentTrip!.id}');
        return DriverNavigationScreen(
          trip: _currentTrip!,
          isPickup: true,
          onTripStatusChanged: _loadCurrentTrip,
        );

      case 'DRIVER_ARRIVED':
        print('Driver arrived, showing trip details with pick-up button');
        final taxiReq = TaxiRequest.fromJson(_currentTrip!.toJson());
        return DriverArrivedScreen(trip: taxiReq);

      case 'USER_PICKED_UP':
      case 'DRIVER_IN_PROGRESS':
        print('Showing dropoff navigation for trip: ${_currentTrip!.id}');
        return DriverNavigationScreen(
          trip: _currentTrip!,
          isPickup: false,
          onTripStatusChanged: _loadCurrentTrip,
        );

      case 'DRIVER_ARRIVED_DROPOFF':
      case 'TRIP_COMPLETED':
      case 'TRIP_CANCELLED':
        print('Trip ${_currentTrip!.status}, showing waiting screen');
        return const DriverWaitingTripsScreen();

      default:
        print(
            'Unexpected trip status: ${_currentTrip!.status}, showing waiting screen');
        return const DriverWaitingTripsScreen();
    }
  }
}
