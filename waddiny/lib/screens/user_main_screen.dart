import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'user_trips_screen.dart';
import 'user_profile_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({Key? key}) : super(key: key);

  @override
  _UserMainScreenState createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const UserTripsScreen(),
    const UserProfileScreen(),
  ];

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
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car),
                activeIcon: Icon(Icons.directions_car, color: Colors.blue),
                label: 'Trip',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history, color: Colors.blue),
                label: 'Trips',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                activeIcon: Icon(Icons.person, color: Colors.blue),
                label: 'Profile',
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
