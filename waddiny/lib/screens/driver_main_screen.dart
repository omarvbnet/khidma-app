import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/trip_service.dart';
import '../models/trip_model.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper
import 'driver_home_screen.dart';
import 'driver_waiting_trips_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_trips_screen.dart';
import '../services/api_service.dart';
import '../models/taxi_request_model.dart';
import 'driver_navigation_screen.dart';
import 'driver_accepted_trip_screen.dart';
import 'driver_arrived_screen.dart';
import 'dart:async';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({Key? key}) : super(key: key);

  @override
  _DriverMainScreenState createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _selectedIndex = 0;
  final _apiService = ApiService();
  Trip? _currentTrip;
  bool _isLoadingTrip = true;
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
      print('🔄 Starting to load current trip...');
      final trips = await _apiService.getDriverTrips().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏰ API call timed out');
          throw Exception(
              'Request timeout - please check your internet connection');
        },
      );
      print('📋 Received ${trips.length} trips from API');

      // Find the most recent active trip
      TaxiRequest? activeTrip;
      for (final trip in trips) {
        print('🔍 Checking trip ${trip.id} with status: ${trip.status}');
        if ([
          'DRIVER_ACCEPTED',
          'DRIVER_IN_WAY',
          'DRIVER_ARRIVED',
          'USER_PICKED_UP',
          'DRIVER_IN_PROGRESS',
          'DRIVER_ARRIVED_DROPOFF',
        ].contains(trip.status.toUpperCase())) {
          activeTrip = trip;
          print('✅ Found active trip: ${trip.id} with status: ${trip.status}');
          break;
        }
      }

      if (mounted) {
        setState(() {
          _currentTrip =
              activeTrip != null ? Trip.fromJson(activeTrip.toJson()) : null;
          _isLoadingTrip = false;
        });
        print(
            '✅ State updated - Current trip: ${_currentTrip?.id ?? 'None'}, Loading: $_isLoadingTrip');
      } else {
        print('⚠️ Widget not mounted, skipping state update');
      }
    } catch (e) {
      print('❌ Error loading current trip: $e');
      if (mounted) {
        setState(() {
          _isLoadingTrip = false;
        });
        print('✅ Error state set - Loading: $_isLoadingTrip');
      }
    }
  }

  Widget _getHomeScreen() {
    if (_isLoadingTrip) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              getLocalizations(context).loadingTripInformation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoadingTrip = true;
                });
                _loadCurrentTrip();
              },
              child: Text(getLocalizations(context).retry),
            ),
          ],
        ),
      );
    }

    if (_currentTrip == null) {
      return const DriverWaitingTripsScreen();
    }

    // Handle different trip statuses
    switch (_currentTrip!.status.toUpperCase()) {
      case 'DRIVER_ACCEPTED':
        return DriverAcceptedTripScreen(trip: _currentTrip!);

      case 'DRIVER_IN_WAY':
        return DriverNavigationScreen(
          trip: _currentTrip!,
          isPickup: true,
          onTripStatusChanged: (String status) {
            print('🔄 Trip status changed to: $status');
            _loadCurrentTrip();
          },
        );

      case 'DRIVER_ARRIVED':
        final taxiReq = TaxiRequest.fromJson(_currentTrip!.toJson());
        return DriverArrivedScreen(
          trip: taxiReq,
          onTripStatusChanged: (String status) {
            print('🔄 Trip status changed to: $status');
            _loadCurrentTrip();
          },
        );

      case 'USER_PICKED_UP':
      case 'DRIVER_IN_PROGRESS':
        return DriverNavigationScreen(
          trip: _currentTrip!,
          isPickup: false,
          onTripStatusChanged: (String status) {
            print('🔄 Trip status changed to: $status');
            _loadCurrentTrip();
          },
        );

      case 'DRIVER_ARRIVED_DROPOFF':
      case 'TRIP_COMPLETED':
      case 'TRIP_CANCELLED':
        return const DriverWaitingTripsScreen();

      default:
        return const DriverWaitingTripsScreen();
    }
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _getHomeScreen();
      case 1:
        return const DriverTripsScreen();
      case 2:
        return const DriverProfileScreen();
      default:
        return _getHomeScreen();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: getLocalizations(context).home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: getLocalizations(context).trips,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: getLocalizations(context).profile,
          ),
        ],
      ),
    );
  }
}
