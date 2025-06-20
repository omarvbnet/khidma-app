import 'package:flutter/material.dart';
import 'driver_home_screen.dart';
import 'driver_trips_screen.dart';
import 'driver_profile_screen.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({Key? key}) : super(key: key);

  @override
  _DriverMainScreenState createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _selectedIndex = 0;
  Widget? _currentScreen;

  final List<Widget> _screens = [
    const DriverHomeScreen(),
    const DriverTripsScreen(),
    const DriverProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentScreen = _screens[_selectedIndex];
  }

  void _onScreenChanged(Widget newScreen) {
    setState(() {
      _currentScreen = newScreen;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentScreen = _screens[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentScreen ?? _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
