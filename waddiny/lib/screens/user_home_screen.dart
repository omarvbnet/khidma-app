import 'package:flutter/material.dart';
import 'dart:async';
import '../services/trip_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper
import 'user_pending_screen.dart';
import 'user_waiting_screen.dart';
import 'user_select_trip_screen.dart';
import 'user_navigation_screen.dart';
import 'user_trip_completed_screen.dart';
import '../components/language_switcher.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _tripService = TripService();
  final _authService = AuthService();
  bool _isLoading = true;
  User? _user;
  Map<String, dynamic>? _waitingTrip;
  Trip? _currentTrip;
  Timer? _statusCheckTimer;
  bool _showingCompletedScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check user status
      final user = await _tripService.checkUserStatus();
      setState(() {
        _user = user;
      });

      // Check for waiting and active trips
      await _checkWaitingTrip();
      await _loadCurrentTrip();

      _startStatusCheck();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startStatusCheck() {
    _statusCheckTimer?.cancel();

    // If current trip is completed, check every 10 seconds
    // Otherwise check every 3 seconds
    final interval = (_currentTrip?.status == 'TRIP_COMPLETED')
        ? const Duration(seconds: 10)
        : const Duration(seconds: 3);

    _statusCheckTimer = Timer.periodic(interval, (timer) async {
      if (mounted) {
        await _checkWaitingTrip();
        await _loadCurrentTrip();

        // Check if we need to adjust the timer interval
        final newInterval = (_currentTrip?.status == 'TRIP_COMPLETED')
            ? const Duration(seconds: 10)
            : const Duration(seconds: 3);

        // If interval needs to change, restart timer
        if (newInterval.inSeconds != interval.inSeconds) {
          timer.cancel();
          _startStatusCheck();
        }
      }
    });
  }

  Future<void> _checkWaitingTrip() async {
    try {
      final trip = await _tripService.getWaitingTrip();
      if (mounted) {
        setState(() {
          _waitingTrip = trip;
        });
      }
    } catch (e) {
      print('Error checking waiting trip: $e');
    }
  }

  Future<void> _loadCurrentTrip() async {
    try {
      final trips = await _tripService.getUserTrips(_user!.id);
      print('\nLoaded ${trips.length} trips');

      // Find the most recent active trip
      Trip? activeTrip;
      for (final trip in trips) {
        if ([
          'USER_WAITING',
          'DRIVER_ACCEPTED',
          'DRIVER_IN_WAY',
          'DRIVER_ARRIVED',
          'USER_PICKED_UP',
          'DRIVER_IN_PROGRESS',
          'DRIVER_ARRIVED_DROPOFF',
          'TRIP_COMPLETED',
          'TRIP_CANCELLED'
        ].contains(trip.status.toUpperCase())) {
          activeTrip = trip;
          break;
        }
      }

      if (activeTrip != null) {
        print('Found active trip:');
        print('- ID: ${activeTrip.id}');
        print('- Status: ${activeTrip.status}');
        print('- Created at: ${activeTrip.createdAt}');

        // Check if status has changed
        final statusChanged = _currentTrip?.status != activeTrip.status;

        if (mounted) {
          setState(() {
            _currentTrip = activeTrip;
            // Reset completed screen flag if status is not completed
            if (activeTrip?.status != 'TRIP_COMPLETED') {
              _showingCompletedScreen = false;
            }
          });

          // If status changed, restart status check with appropriate interval
          if (statusChanged) {
            _startStatusCheck();
          }
        }
      } else {
        // No active trip found
        if (mounted) {
          setState(() {
            _currentTrip = null;
            _showingCompletedScreen = false;
          });
          _startStatusCheck(); // Restart with default interval
        }
      }
    } catch (e) {
      print('Error loading current trip: $e');
    }
  }

  Future<void> _handleTripCompleted(Trip completedTrip) async {
    print('Handling trip completion for trip: ${completedTrip.id}');

    // Wait for 10 seconds
    await Future.delayed(const Duration(seconds: 10));

    if (mounted) {
      setState(() {
        _currentTrip = null;
        _showingCompletedScreen = false;
      });
      _startStatusCheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('\n=== BUILDING USER HOME SCREEN ===');
    print('Current trip: ${_currentTrip?.id}');
    print('Current trip status: ${_currentTrip?.status}');
    print('Is loading: $_isLoading');

    if (_isLoading) {
      print('Showing loading screen');
      return Scaffold(
        body: Center(
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
                    _isLoading = true;
                  });
                  _loadCurrentTrip();
                },
                child: Text(getLocalizations(context).retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentTrip == null) {
      print('No active trip, showing home screen');
      return _buildHomeScreen();
    }

    print('Checking trip status: ${_currentTrip!.status}');

    // Handle different trip statuses
    switch (_currentTrip!.status.toUpperCase()) {
      case 'USER_WAITING':
        print('Showing waiting screen for trip: ${_currentTrip!.id}');
        return UserWaitingScreen(
          trip: _currentTrip!.toJson(),
          onTripCancelled: () => _loadCurrentTrip(),
        );

      case 'DRIVER_ACCEPTED':
      case 'DRIVER_IN_WAY':
      case 'DRIVER_ARRIVED':
      case 'USER_PICKED_UP':
      case 'DRIVER_IN_PROGRESS':
      case 'DRIVER_ARRIVED_DROPOFF':
        print('Showing navigation screen for trip: ${_currentTrip!.id}');
        return UserNavigationScreen(
          trip: _currentTrip!,
          onTripStatusChanged: (String newStatus) async {
            await _loadCurrentTrip();
          },
        );

      case 'TRIP_COMPLETED':
        print('Trip ${_currentTrip!.status}, showing completed screen');
        if (!_showingCompletedScreen) {
          _showingCompletedScreen = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleTripCompleted(_currentTrip!);
          });
        }
        return UserTripCompletedScreen(
          trip: _currentTrip!,
        );

      case 'TRIP_CANCELLED':
        print('Trip ${_currentTrip!.status}, showing home screen');
        return _buildHomeScreen();

      default:
        print(
            'Unexpected trip status: ${_currentTrip!.status}, showing home screen');
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizations(context).home),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getLocalizations(context)
                            .welcomeUser(_user?.fullName ?? 'User'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        getLocalizations(context).whereWouldYouLikeToGo,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Language switcher
              LanguageSwitcher(),
              const SizedBox(height: 24),

              // Create trip button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserSelectTripScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_location_alt),
                label: Text(getLocalizations(context).createNewTrip),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'USER_WAITING':
        return Colors.orange;
      case 'DRIVER_ACCEPTED':
        return Colors.blue;
      case 'DRIVER_IN_WAY':
        return Colors.purple;
      case 'DRIVER_ARRIVED':
        return Colors.green;
      case 'USER_PICKED_UP':
        return Colors.teal;
      case 'DRIVER_IN_PROGRESS':
        return Colors.indigo;
      case 'DRIVER_ARRIVED_DROPOFF':
        return Colors.amber;
      case 'TRIP_COMPLETED':
        return Colors.green;
      case 'TRIP_CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'USER_WAITING':
        return Icons.timer;
      case 'DRIVER_ACCEPTED':
        return Icons.check_circle;
      case 'DRIVER_IN_WAY':
        return Icons.directions_car;
      case 'DRIVER_ARRIVED':
        return Icons.location_on;
      case 'USER_PICKED_UP':
        return Icons.person;
      case 'DRIVER_IN_PROGRESS':
        return Icons.directions;
      case 'DRIVER_ARRIVED_DROPOFF':
        return Icons.flag;
      case 'TRIP_COMPLETED':
        return Icons.check_circle;
      case 'TRIP_CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String getLocalizedStatus(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'USER_WAITING':
        return getLocalizations(context).statusUserWaiting;
      case 'DRIVER_ACCEPTED':
        return getLocalizations(context).statusDriverAccepted;
      case 'DRIVER_IN_WAY':
        return getLocalizations(context).statusDriverInWay;
      case 'DRIVER_ARRIVED':
        return getLocalizations(context).statusDriverArrived;
      case 'USER_PICKED_UP':
        return getLocalizations(context).statusUserPickedUp;
      case 'DRIVER_IN_PROGRESS':
        return getLocalizations(context).statusDriverInProgress;
      case 'DRIVER_ARRIVED_DROPOFF':
        return getLocalizations(context).statusDriverArrivedDropoff;
      case 'TRIP_COMPLETED':
        return getLocalizations(context).statusTripCompleted;
      case 'TRIP_CANCELLED':
        return getLocalizations(context).statusTripCancelled;
      default:
        return status;
    }
  }
}
