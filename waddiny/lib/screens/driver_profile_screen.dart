import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _carInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      print('Loading user data...'); // Debug print
      final userData = await _authService.getCurrentUser();
      print('User data loaded: $userData'); // Debug print
      setState(() {
        _userData = userData;
      });
      await _loadCarInfo();
    } catch (e) {
      print('Error loading user data: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCarInfo() async {
    try {
      print('Loading car info...'); // Debug print
      final carInfo = await _apiService.getDriverCarInfo();
      print('Car info loaded: $carInfo'); // Debug print
      setState(() {
        _carInfo = carInfo;
      });
    } catch (e) {
      print('Error loading car info: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading car info: $e')),
        );
      }
      // Set default values if car info fails to load
      setState(() {
        _carInfo = {
          'carId': 'N/A',
          'carType': 'N/A',
          'licenseId': 'N/A',
          'rate': 0,
        };
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building profile with car info: $_carInfo'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userData?['fullName'] ?? 'N/A',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          _userData?['phoneNumber'] ?? 'N/A',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Car Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Car Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Car ID', _carInfo?['carId'] ?? 'N/A'),
                          _buildInfoRow(
                              'Car Type', _carInfo?['carType'] ?? 'N/A'),
                          _buildInfoRow(
                              'License ID', _carInfo?['licenseId'] ?? 'N/A'),
                          _buildInfoRow('Rating', '${_carInfo?['rate'] ?? 0}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Account Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Budget',
                              '${_userData?['budget']?.toStringAsFixed(2) ?? '0.00'} IQD'),
                          _buildInfoRow(
                              'Province', _userData?['province'] ?? 'N/A'),
                          _buildInfoRow(
                              'Status', _userData?['status'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Debug Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Tools',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/notification-debug');
                              },
                              icon: const Icon(Icons.bug_report),
                              label: const Text('Notification Debug'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
