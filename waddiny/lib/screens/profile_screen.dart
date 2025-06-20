import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocationService _locationService = LocationService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateProvince();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userData = {
        'fullName': prefs.getString('fullName'),
        'phoneNumber': prefs.getString('phoneNumber'),
        'province': prefs.getString('province'),
        'role': prefs.getString('role'),
      };
      _isLoading = false;
    });
  }

  Future<void> _updateProvince() async {
    await _locationService.updateProvinceOnAppStart();
    _loadUserData();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _userData?['fullName'] ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _userData?['role'] ?? 'User',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.phone,
                    title: 'Phone Number',
                    value: _userData?['phoneNumber'] ?? 'Not set',
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard(
                    icon: Icons.location_city,
                    title: 'Province',
                    value: _userData?['province'] ?? 'Not set',
                    onTap: _updateProvince,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _updateProvince,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Update Location'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
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
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
