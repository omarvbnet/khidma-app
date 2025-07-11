import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Waddiny';
  static const String appVersion = '1.0.0';
  static const String currency = 'IQD';
  static const Color primaryColor = Color(0xFF1E88E5); // Material Blue 600

  // Trip costs based on distance ranges (in kilometers)
  static const Map<String, int> tripCosts = {
    '0-3': 2000,
    '3-6': 3000,
    '6-8': 3500,
    '8-11': 4000,
    '11-14': 5500,
    '14-18': 6000,
    '18-20': 6500,
    '20-25': 8000,
    '25-30': 11000,
    '30-35': 15000,
    '35-40': 20000,
    '40-45': 25000,
    '45-50': 30000,
    '50-55': 33000,
    '55-60': 35000,
    '60-65': 37000,
    '65-70': 40000,
    '70-75': 43000,
    '75-80': 45000,
    '80-85': 47000,
    '85-90': 50000,
  };

  static const int costPerKm = 350; // For distances over 90km
  static const double driverDeduction = 0.12; // 12% driver deduction
}
