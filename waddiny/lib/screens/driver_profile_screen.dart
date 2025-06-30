import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import '../components/language_switcher.dart';
import '../l10n/app_localizations.dart';
import '../main.dart'; // Import to use getLocalizations helper

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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizations(context).profile),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
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
                      getLocalizations(context).carInformation,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(getLocalizations(context).carId,
                        _carInfo?['carId'] ?? 'N/A'),
                    _buildInfoRow(getLocalizations(context).carType,
                        _carInfo?['carType'] ?? 'N/A'),
                    _buildInfoRow(getLocalizations(context).licenseId,
                        _carInfo?['licenseId'] ?? 'N/A'),
                    _buildInfoRow(getLocalizations(context).rating,
                        '${_carInfo?['rate'] ?? 0}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Account Information Card
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
                      getLocalizations(context).accountInformation,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(getLocalizations(context).budget,
                        '${_userData?['budget']?.toStringAsFixed(2) ?? '0.00'} IQD'),
                    _buildInfoRow(getLocalizations(context).province,
                        _userData?['province'] ?? 'N/A'),
                    _buildInfoRow(getLocalizations(context).accountStatus,
                        _userData?['status'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Language Switcher
            LanguageSwitcher(),
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
