import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/trip_service.dart';
import '../models/taxi_request_model.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class UserTripsScreen extends StatefulWidget {
  const UserTripsScreen({Key? key}) : super(key: key);

  @override
  _UserTripsScreenState createState() => _UserTripsScreenState();
}

class _UserTripsScreenState extends State<UserTripsScreen> {
  final _apiService = ApiService();
  final _tripService = TripService();
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUserStatusAndLoadTrips();
  }

  Future<void> _checkUserStatusAndLoadTrips() async {
    try {
      final user = await _tripService.checkUserStatus();
      setState(() {
        _user = user;
      });

      if (user?.status != 'ACTIVE') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Your account is not active. Please contact support.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await _loadTrips();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking user status: $e')),
        );
      }
    }
  }

  Future<void> _loadTrips() async {
    try {
      final trips = await _apiService.getUserTrips();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trips: $e')),
        );
      }
    }
  }

  Future<void> _cancelTrip(String tripId) async {
    try {
      await _apiService.cancelTaxiRequest(tripId);
      await _loadTrips(); // Reload trips after cancellation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip cancelled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling trip: $e')),
        );
      }
    }
  }

  Future<void> _showCancelConfirmationDialog(String tripId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Trip'),
          content: const Text('Are you sure you want to cancel this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelTrip(tripId);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
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

    if (_user?.status != 'ACTIVE') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Trips'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 64,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Account Not Active',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please contact support to activate your account',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_trips.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Trips'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
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
                  Icons.history,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No trips yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your trip history will appear here',
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
        title: const Text('My Trips'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                          'Trip #${trip['id'].substring(0, 8)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        _buildStatusChip(trip['status']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'From',
                      trip['pickupLocation'],
                      Icons.location_on,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'To',
                      trip['dropoffLocation'],
                      Icons.location_on,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Date',
                      _formatDate(trip['createdAt']),
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Price',
                      '${trip['price']} SAR',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                    if (trip['driverName'] != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Driver',
                        trip['driverName'],
                        Icons.person,
                        Colors.purple,
                      ),
                    ],
                    if (trip['driverPhone'] != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Driver Phone',
                        trip['driverPhone'],
                        Icons.phone,
                        Colors.teal,
                      ),
                    ],
                    if (trip['carType'] != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Car Type',
                        trip['carType'],
                        Icons.directions_car,
                        Colors.blue,
                      ),
                    ],
                    if (trip['carId'] != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Car ID',
                        trip['carId'],
                        Icons.confirmation_number,
                        Colors.indigo,
                      ),
                    ],
                    if (trip['driverRate'] != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Driver Rating',
                        '${trip['driverRate'].toStringAsFixed(1)} ⭐',
                        Icons.star,
                        Colors.amber,
                      ),
                    ],
                    if (trip['status'] == 'USER_WAITING')
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _showCancelConfirmationDialog(trip['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel Trip'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
