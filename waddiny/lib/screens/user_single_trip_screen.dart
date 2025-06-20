import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../constants/app_constants.dart';

class UserSingleTripScreen extends StatefulWidget {
  final String tripId;

  const UserSingleTripScreen({
    Key? key,
    required this.tripId,
  }) : super(key: key);

  @override
  _UserSingleTripScreenState createState() => _UserSingleTripScreenState();
}

class _UserSingleTripScreenState extends State<UserSingleTripScreen> {
  final TripService _tripService = TripService();
  Map<String, dynamic>? _trip;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final trip = await _tripService.getTripById(widget.tripId);

      if (mounted) {
        setState(() {
          _trip = trip;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading trip: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTrip,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _trip == null
                  ? const Center(
                      child: Text('Trip not found'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 16),
                          _buildLocationCard(),
                          if (_trip!['driver'] != null) ...[
                            const SizedBox(height: 16),
                            _buildDriverCard(),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStatusCard() {
    final status = _trip!['status'] as String;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'USER_WAITING':
        statusColor = Colors.orange;
        statusText = 'Waiting for driver';
        break;
      case 'DRIVER_ACCEPTED':
        statusColor = Colors.blue;
        statusText = 'Driver accepted';
        break;
      case 'DRIVER_IN_WAY':
        statusColor = Colors.purple;
        statusText = 'Driver is on the way';
        break;
      case 'DRIVER_ARRIVED':
        statusColor = Colors.green;
        statusText = 'Driver has arrived';
        break;
      case 'USER_PICKED_UP':
        statusColor = Colors.teal;
        statusText = 'You are picked up';
        break;
      case 'DRIVER_IN_PROGRESS':
        statusColor = Colors.indigo;
        statusText = 'On the way to destination';
        break;
      case 'DRIVER_ARRIVED_DROPOFF':
        statusColor = Colors.amber;
        statusText = 'Arrived at destination';
        break;
      case 'TRIP_COMPLETED':
        statusColor = Colors.green;
        statusText = 'Trip completed';
        break;
      case 'TRIP_CANCELLED':
        statusColor = Colors.red;
        statusText = 'Trip cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown status';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLocationRow(
              'Pickup',
              _trip!['pickupLocation'] ?? 'Not specified',
              Icons.location_on,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              'Dropoff',
              _trip!['dropoffLocation'] ?? 'Not specified',
              Icons.location_on,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              'Distance',
              '${_trip!['distance'] ?? 0} km',
              Icons.straighten,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              'Price',
              '${_trip!['price'] ?? 0} IQD',
              Icons.attach_money,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard() {
    final driver = _trip!['driver'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', driver['fullName'] ?? 'Not specified'),
            const SizedBox(height: 8),
            _buildInfoRow('Phone', driver['phoneNumber'] ?? 'Not specified'),
            const SizedBox(height: 8),
            _buildInfoRow('Car Type', driver['carType'] ?? 'Not specified'),
            const SizedBox(height: 8),
            _buildInfoRow('Car ID', driver['carId'] ?? 'Not specified'),
            const SizedBox(height: 8),
            _buildInfoRow('License ID', driver['licenseId'] ?? 'Not specified'),
            const SizedBox(height: 8),
            _buildInfoRow('Rate', '${driver['rate'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
