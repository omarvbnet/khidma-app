import 'package:flutter/material.dart';
import '../services/trip_service.dart';
import '../services/auth_service.dart';
import '../models/trip_model.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper

class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({Key? key}) : super(key: key);

  @override
  _DriverTripsScreenState createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  final _tripService = TripService();
  final _authService = AuthService();
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      print('Starting to load trips...'); // Debug start
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final trips = await _tripService.getDriverTrips(user['id']);
      print('Received ${trips.length} trips from service'); // Debug trip count

      if (mounted) {
        setState(() {
          _trips = trips;
          _isLoading = false;
        });
        print(
            'Updated state with ${_trips.length} trips'); // Debug state update
      }
    } catch (e) {
      print('Error in _loadTrips: $e'); // Debug error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trips: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    if (_trips.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(getLocalizations(context).tripHistory),
          centerTitle: true,
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
                getLocalizations(context).noTripsAvailable,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                getLocalizations(context).tripHistory,
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
        title: Text(getLocalizations(context).tripHistory),
        centerTitle: true,
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
                          '${getLocalizations(context).trip} #${trip.id.substring(0, 8)}',
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
                      getLocalizations(context).from,
                      trip.pickupLocation,
                      Icons.location_on,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      getLocalizations(context).to,
                      trip.dropoffLocation,
                      Icons.location_on,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      getLocalizations(context).date,
                      _formatDate(trip.createdAt),
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      getLocalizations(context).price,
                      '${trip.fare} IQD',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                    if (trip.driverId != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        getLocalizations(context).driverId,
                        trip.driverId!,
                        Icons.person,
                        Colors.purple,
                      ),
                    ],
                    if (trip.userId != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        getLocalizations(context).userId,
                        trip.userId,
                        Icons.person,
                        Colors.purple,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      getLocalizations(context).province,
                      trip.userProvince,
                      Icons.location_city,
                      Colors.blue,
                    ),
                    if (trip.acceptedAt != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        getLocalizations(context).acceptedAt,
                        _formatDate(trip.acceptedAt!),
                        Icons.access_time,
                        Colors.green,
                      ),
                    ],
                    if (trip.completedAt != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        getLocalizations(context).completedAt,
                        _formatDate(trip.completedAt!),
                        Icons.check_circle,
                        Colors.blue,
                      ),
                    ],
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
    String displayStatus;
    switch (status.toUpperCase()) {
      case 'TRIP_COMPLETED':
        color = Colors.green;
        displayStatus = getLocalizations(context).statusCompleted;
        break;
      case 'TRIP_CANCELLED':
        color = Colors.red;
        displayStatus = getLocalizations(context).statusCancelled;
        break;
      case 'DRIVER_IN_PROGRESS':
        color = Colors.blue;
        displayStatus = getLocalizations(context).statusInProgress;
        break;
      case 'DRIVER_ACCEPTED':
        color = Colors.orange;
        displayStatus = getLocalizations(context).statusAccepted;
        break;
      case 'USER_WAITING':
        color = Colors.orangeAccent;
        displayStatus = getLocalizations(context).statusWaiting;
        break;
      default:
        color = Colors.grey;
        displayStatus = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
