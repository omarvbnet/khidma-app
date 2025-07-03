import 'package:flutter/material.dart';
import '../models/taxi_request_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/trip_service.dart';
import '../services/driver_service.dart';
import '../models/user_model.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper
import 'dart:async';
import '../screens/driver_trip_details_screen.dart';
import '../screens/driver_home_screen.dart';
import '../services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import '../components/language_switcher.dart';

class DriverWaitingTripsScreen extends StatefulWidget {
  const DriverWaitingTripsScreen({super.key});

  @override
  State<DriverWaitingTripsScreen> createState() =>
      _DriverWaitingTripsScreenState();
}

class _DriverWaitingTripsScreenState extends State<DriverWaitingTripsScreen> {
  final _apiService = ApiService();
  final _tripService = TripService();
  late final DriverService _driverService;
  List<TaxiRequest> _trips = [];
  bool _isLoading = true;
  User? _user;
  Timer? _refreshTimer;
  String? _error;
  Map<String, dynamic>? _driverBudget;
  bool _isLoadingBudget = false;

  @override
  void initState() {
    super.initState();
    _driverService = DriverService(_apiService);
    _initializeScreen();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    print('🚀 Initializing driver waiting trips screen');

    // Load driver budget
    await _loadDriverBudget();

    // Then check user status and load trips
    await _checkUserStatusAndLoadTrips();

    // Set up auto-refresh every 30 seconds as backup
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _user?.status == 'ACTIVE') {
        _loadTrips();
        _loadDriverBudget(); // Also refresh budget
      }
    });

    print('✅ Driver waiting trips screen initialization completed');
  }

  Future<void> _loadDriverBudget() async {
    try {
      setState(() {
        _isLoadingBudget = true;
      });

      final budget = await _driverService.getDriverBudget();

      if (mounted) {
        setState(() {
          _driverBudget = budget;
          _isLoadingBudget = false;
        });
      }
    } catch (e) {
      print('❌ Error loading driver budget: $e');
      if (mounted) {
        setState(() {
          _isLoadingBudget = false;
        });
      }
    }
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
          _error = getLocalizations(context).accountNotActive;
        });
        return;
      }

      await _loadTrips();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = getLocalizations(context).errorLoadingData(e.toString());
      });
    }
  }

  Future<void> _loadTrips({bool isRetry = false}) async {
    try {
      if (!isRetry) {
        print('🔄 Loading trips for driver...');
      } else {
        print('🔄 Retrying trip loading...');
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Add timeout to prevent infinite loading
      final trips = await _apiService.getDriverTrips().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(getLocalizations(context).requestTimeout);
        },
      );

      print('📋 Received ${trips.length} total trips from service');

      // Filter for waiting trips
      final waitingTrips =
          trips.where((trip) => trip.status == 'USER_WAITING').toList();
      print('⏳ Found ${waitingTrips.length} waiting trips');

      if (mounted) {
        setState(() {
          _trips = waitingTrips;
          _isLoading = false;
        });

        // If we found new trips, show a notification
        if (waitingTrips.isNotEmpty) {
          print('🎉 New trips available for driver');
          _showNewTripsNotification(waitingTrips.length);
        }
      }
    } catch (e) {
      print('❌ Error in _loadTrips: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = getLocalizations(context).errorLoadingTrips(e.toString());
        });

        // Show retry option for network errors
        if (e.toString().contains('timeout') ||
            e.toString().contains('network')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(getLocalizations(context).networkError),
                action: SnackBarAction(
                  label: getLocalizations(context).retry,
                  onPressed: () => _loadTrips(isRetry: true),
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    }
  }

  // Show a local notification when new trips are found
  void _showNewTripsNotification(int tripCount) {
    if (tripCount > 0) {
      NotificationService.showLocalNotification(
        title: getLocalizations(context).newTripsAvailable,
        body: getLocalizations(context).newTripsWaiting(tripCount),
        payload: jsonEncode({
          'type': 'NEW_TRIPS_AVAILABLE',
          'count': tripCount,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        id: 1000 + tripCount, // Unique ID based on trip count
      );
    }
  }

  Future<void> _acceptTrip(TaxiRequest trip) async {
    try {
      // Use a more specific loading state instead of the general _isLoading
      setState(() {
        // Don't set _isLoading = true here to avoid showing the loading screen
        // The button will show its own loading state
      });

      // Use driver service which includes budget checking
      final updatedTaxiRequest = await _driverService.acceptTrip(trip.id);

      if (!mounted) return;

      // Refresh budget after successful acceptance
      await _loadDriverBudget();

      // Use a smoother navigation transition
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DriverHomeScreen(),
        ),
      );
    } catch (e) {
      if (mounted) {
        // Show more detailed error message for budget issues
        String errorMessage = 'Error accepting trip: $e';
        if (e.toString().contains('Insufficient budget')) {
          errorMessage = e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View Budget',
              textColor: Colors.white,
              onPressed: () => _showBudgetDetails(),
            ),
          ),
        );
      }
    }
  }

  void _showBudgetDetails() {
    if (_driverBudget != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(getLocalizations(context).budgetInformationTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Budget: ${_driverBudget!['budget']} IQD'),
              const SizedBox(height: 8),
              Text('Driver: ${_driverBudget!['driverName']}'),
              const SizedBox(height: 16),
              Text(
                getLocalizations(context).budgetDeductionNote,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(getLocalizations(context).okButton),
            ),
            // Test button to add budget
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addTestBudget();
              },
              child: Text(getLocalizations(context).addTestBudgetButton),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _addTestBudget() async {
    try {
      final result = await _apiService.addDriverBudget(1000.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizations(context)
                .budgetAddedMessage(result['newBudget'])),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh budget display
        await _loadDriverBudget();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizations(context)
                .errorAddingBudgetMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testBudgetFunctionality() async {
    try {
      setState(() {
        _isLoadingBudget = true;
      });

      final result = await _apiService.testDriverBudget();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizations(context).budgetTestMessage(
                result['message'], result['user']['currentBudget'])),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 5),
          ),
        );

        // Refresh budget display
        await _loadDriverBudget();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(getLocalizations(context).budgetTestError(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBudget = false;
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
          title: Text(getLocalizations(context).waitingTrips),
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
                onPressed: () => _loadTrips(isRetry: true),
                icon: const Icon(Icons.refresh),
                label: Text(getLocalizations(context).retry),
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
          title: Text(getLocalizations(context).waitingTrips),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _loadTrips(),
              tooltip: getLocalizations(context).refresh,
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
                getLocalizations(context).noWaitingTrips,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              if (_user?.province != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '📍 ${_user!.province}',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                getLocalizations(context).newTripsWillAppearHere,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                getLocalizations(context).youWillReceiveNotifications,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          getLocalizations(context).provinceFiltering,
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getLocalizations(context).provinceFilteringDescription,
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _loadTrips(),
                    icon: Icon(Icons.refresh),
                    label: Text(getLocalizations(context).refresh),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Language switcher
              LanguageSwitcher(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizations(context).waitingTrips),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Budget info button
          if (_driverBudget != null)
            IconButton(
              icon: Icon(
                Icons.account_balance_wallet,
                color: _driverBudget!['budget'] > 0 ? Colors.green : Colors.red,
              ),
              onPressed: _showBudgetDetails,
              tooltip: 'Budget: ${_driverBudget!['budget']} IQD',
            ),
          // Test budget button
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: _testBudgetFunctionality,
            tooltip: 'Test Budget',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTrips(),
            tooltip: getLocalizations(context).refresh,
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
                    // Budget deduction info
                    if (_driverBudget != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: 16,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Deduction: ${(trip.price * 0.12).toStringAsFixed(0)} IQD (12%)',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Your budget: ${_driverBudget!['budget']} IQD',
                                    style: TextStyle(
                                      color: Colors.orange[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _driverBudget!['budget'] >=
                                        (trip.price * 0.12)
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _driverBudget!['budget'] >= (trip.price * 0.12)
                                    ? '✓'
                                    : '✗',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        label: Text(
                          getLocalizations(context).viewTripButton,
                          style: const TextStyle(
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
