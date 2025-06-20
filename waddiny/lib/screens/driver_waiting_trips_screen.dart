import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/taxi_request_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/trip_service.dart';
import '../models/user_model.dart';
import 'dart:async';
import '../services/map_service.dart';
import '../screens/driver_trip_details_screen.dart';
import '../screens/driver_home_screen.dart';

class DriverWaitingTripsScreen extends StatefulWidget {
  const DriverWaitingTripsScreen({super.key});

  @override
  State<DriverWaitingTripsScreen> createState() =>
      _DriverWaitingTripsScreenState();
}

class _DriverWaitingTripsScreenState extends State<DriverWaitingTripsScreen> {
  final _apiService = ApiService();
  final _tripService = TripService();
  final _mapService = MapService();
  List<TaxiRequest> _trips = [];
  bool _isLoading = true;
  User? _user;
  Timer? _refreshTimer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkUserStatusAndLoadTrips();
    // Set up auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _user?.status == 'ACTIVE') {
        _loadTrips();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkUserStatusAndLoadTrips() async {
    try {
      final user = await _tripService.checkUserStatus();
      setState(() {
        _user = user;
        _error = null;
      });

      if (user?.status != 'ACTIVE') {
        setState(() {
          _isLoading = false;
          _error = 'Your account is not active. Please contact support.';
        });
        return;
      }

      await _loadTrips();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error checking user status: $e';
      });
    }
  }

  Future<void> _loadTrips() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final trips = await _apiService.getDriverTrips();
      print('Received ${trips.length} trips from service');

      // Filter for waiting trips
      final waitingTrips =
          trips.where((trip) => trip.status == 'USER_WAITING').toList();
      print('Found ${waitingTrips.length} waiting trips');

      if (mounted) {
        setState(() {
          _trips = waitingTrips;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _loadTrips: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading trips: $e';
        });
      }
    }
  }

  Future<void> _acceptTrip(TaxiRequest trip) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updatedTaxiRequest =
          await _apiService.updateTripStatus(trip.id, 'DRIVER_ACCEPTED');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const DriverHomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting trip: $e'),
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

  Future<void> _showTripDetails(TaxiRequest request) async {
    try {
      // Validate coordinates more thoroughly
      if (!_isValidCoordinate(request.pickupLat, request.pickupLng) ||
          !_isValidCoordinate(request.dropoffLat, request.dropoffLng)) {
        throw Exception(
            'Invalid coordinates in trip data. Please contact support.');
      }

      if (!mounted) return;

      // Navigate to trip details screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverTripDetailsScreen(trip: request),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading trip details: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  bool _isValidCoordinate(double lat, double lng) {
    // Check for NaN values
    if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) {
      return false;
    }

    // Check for zero coordinates (common invalid value)
    if (lat == 0.0 && lng == 0.0) {
      return false;
    }

    // Check if coordinates are within valid ranges
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Waiting Trips'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.red[800],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkUserStatusAndLoadTrips,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_trips.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Waiting Trips'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadTrips,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No waiting trips',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'New trip requests will appear here',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting Trips'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrips,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _trips.length,
          itemBuilder: (context, index) {
            final trip = _trips[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trip #${trip.id.substring(0, 8)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        _buildStatusChip(trip.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'From',
                      trip.pickupLocation,
                      Icons.location_on,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'To',
                      trip.dropoffLocation,
                      Icons.location_on,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Price',
                      '${trip.price} IQD',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Distance',
                      '${trip.distance.toStringAsFixed(1)} km',
                      Icons.straighten,
                      Colors.purple,
                    ),
                    if (trip.userFullName != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'User',
                        trip.userFullName!,
                        Icons.person,
                        Colors.teal,
                      ),
                    ],
                    if (trip.userPhone != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Phone',
                        trip.userPhone!,
                        Icons.phone,
                        Colors.indigo,
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showTripDetails(trip),
                        icon: const Icon(Icons.visibility),
                        label: const Text(
                          'View Trip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'TRIP_COMPLETED':
        color = Colors.green;
        break;
      case 'TRIP_CANCELLED':
        color = Colors.red;
        break;
      case 'DRIVER_IN_PROGRESS':
        color = Colors.blue;
        break;
      case 'DRIVER_ACCEPTED':
      case 'USER_WAITING':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
