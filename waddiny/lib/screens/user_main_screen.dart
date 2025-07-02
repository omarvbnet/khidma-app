import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'user_trips_screen.dart';
import 'user_profile_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({Key? key}) : super(key: key);

  @override
  _UserMainScreenState createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;
  final LocationService _locationService = LocationService();

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const UserTripsScreen(),
    const UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProvinceChecking();
  }

  Future<void> _initializeProvinceChecking() async {
    try {
      // Initialize last known province from stored data
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        final savedProvince = userData['province'];
        if (savedProvince != null) {
          _locationService.setLastKnownProvince(savedProvince);
        }
      }

      // Start frequent province checking every 2 minutes
      _locationService.startFrequentProvinceChecking();
      print('✅ Started frequent province checking for user (every 2 minutes)');
    } catch (e) {
      print('❌ Error initializing province checking: $e');
    }
  }

  @override
  void dispose() {
    _locationService.stopFrequentProvinceChecking();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car),
                activeIcon: Icon(Icons.directions_car, color: Colors.blue),
                label: AppLocalizations.of(context)!.trip,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history, color: Colors.blue),
                label: AppLocalizations.of(context)!.trips,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                activeIcon: Icon(Icons.person, color: Colors.blue),
                label: AppLocalizations.of(context)!.profile,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            elevation: 0,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
  }
}
