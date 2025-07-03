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
import '../services/notification_service.dart';
import '../components/language_switcher.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _tripService = TripService();
  final _authService = AuthService();
  final _driverService = DriverService(ApiService());
  final _apiService = ApiService();
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

  Future<void> _loadCurrentTrip() async {
    try {
      print('\n=== LOADING CURRENT TRIP ===');
      final trips = await _apiService.getDriverTrips();
      print('Loaded ${trips.length} trips');

      // Find the most recent active trip
      TaxiRequest? activeTrip;
      for (final trip in trips) {
        print('Checking trip ${trip.id}: ${trip.status}');
        if ([
          'DRIVER_ACCEPTED',
          'DRIVER_IN_WAY',
          'DRIVER_ARRIVED',
          'USER_PICKED_UP',
          'DRIVER_IN_PROGRESS',
          'DRIVER_ARRIVED_DROPOFF',
        ].contains(trip.status.toUpperCase())) {
          activeTrip = trip;
          print('Found active trip: ${trip.id} with status: ${trip.status}');
          break;
        }
      }

      if (mounted) {
        final newTrip =
            activeTrip != null ? Trip.fromJson(activeTrip.toJson()) : null;
        final oldTripId = _currentTrip?.id;
        final newTripId = newTrip?.id;

        setState(() {
          _currentTrip = newTrip;
          _isLoading = false;
        });

        print('\nState updated:');
        print('- Old trip ID: $oldTripId');
        print('- New trip ID: $newTripId');
        print('- New trip status: ${newTrip?.status}');

        // If we had a trip before but now we don't, it might have been completed
        if (oldTripId != null && newTripId == null) {
          print(
              '⚠️ Trip $oldTripId was completed or cancelled - showing waiting screen');
        }
      }

      // Check for new trips and send notifications
      await _checkForNewTrips();
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

  Future<void> _checkForNewTrips() async {
    try {
      // Get current user to check if they're a driver
      final user = await _authService.getCurrentUser();
      if (user == null || user['role'] != 'DRIVER') return;

      // Get waiting trips
      final waitingTrips = await _apiService.getTaxiRequests();
      final newTrips = waitingTrips
          .where(
              (trip) => trip.status == 'USER_WAITING' && trip.driverId == null)
          .toList();

      // Send notifications for new trips
      for (final trip in newTrips) {
        final tripModel = Trip.fromJson(trip.toJson());
        await NotificationService.handleNewTripAvailableForDriver(
          trip: tripModel,
          driverId: user['id'],
        );
      }
    } catch (e) {
      print('Error checking for new trips: $e');
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
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading trip information...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
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
          onTripStatusChanged: (String status) {
            print('🔄 Trip status changed to: $status');
            _loadCurrentTrip();
          },
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
          onTripStatusChanged: (String status) {
            print('🔄 Trip status changed to: $status');
            if (status == 'TRIP_COMPLETED') {
              print('✅ Trip completed - will refresh to show waiting screen');
            }
            _loadCurrentTrip();
          },
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
