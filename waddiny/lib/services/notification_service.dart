import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import '../constants/api_constants.dart';
import '../models/trip_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Initialize local notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    final bool? initialized = await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (initialized == true) {
      print('✅ Local notifications initialized successfully');

      // Request permissions on iOS
      if (Platform.isIOS) {
        await _requestIOSPermissions();
      }
    } else {
      print('❌ Failed to initialize local notifications');
    }

    _isInitialized = true;
  }

  // Request iOS permissions
  static Future<void> _requestIOSPermissions() async {
    try {
      final bool? alertPermission = await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      print('iOS Alert Permission: $alertPermission');

      // Check current permission status
      final bool? isAlertPermissionGranted = await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      print('iOS Permission Status: $isAlertPermissionGranted');
    } catch (e) {
      print('Error requesting iOS permissions: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // Show local notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'trip_notifications',
      'Trip Notifications',
      channelDescription: 'Notifications for trip status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      attachments: null,
      categoryIdentifier: 'trip_notifications',
      threadIdentifier: 'trip_notifications',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      await _localNotifications.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      print('✅ Local notification shown: $title');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  // Get token for API calls
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Send notification to server
  static Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/send-simple'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'type': type,
          'title': title,
          'message': message,
          'data': data,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to send notification: ${response.body}');
      } else {
        print('Notification sent successfully to user: $userId');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Get user notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications({
    int limit = 20,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (unreadOnly) 'unread': 'true',
      };

      final uri = Uri.parse('${ApiConstants.baseUrl}/notifications')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['notifications']);
      } else {
        throw Exception('Failed to fetch notifications: ${response.body}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark notifications as read
  static Future<void> markNotificationsAsRead({
    List<String>? notificationIds,
    bool markAllAsRead = false,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (notificationIds != null) 'notificationIds': notificationIds,
          'markAllAsRead': markAllAsRead,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to mark notifications as read: ${response.body}');
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  // Handle trip status change for users
  static Future<void> handleTripStatusChangeForUser({
    required Trip trip,
    required String previousStatus,
    required String newStatus,
  }) async {
    try {
      print('\n=== HANDLING TRIP STATUS CHANGE FOR USER ===');
      print('Trip ID: ${trip.id}');
      print('Previous Status: $previousStatus');
      print('New Status: $newStatus');

      String title = '';
      String body = '';

      switch (newStatus.toUpperCase()) {
        case 'DRIVER_ACCEPTED':
          title = 'Driver Accepted Your Trip!';
          body =
              'A driver has accepted your trip request. They will be on their way soon.';
          break;
        case 'DRIVER_IN_WAY':
          title = 'Driver is on the Way!';
          body = 'Your driver is heading to your pickup location.';
          break;
        case 'DRIVER_ARRIVED':
          title = 'Driver Has Arrived!';
          body = 'Your driver has arrived at your pickup location.';
          break;
        case 'USER_PICKED_UP':
          title = 'Trip Started!';
          body = 'You have been picked up. Enjoy your ride!';
          break;
        case 'TRIP_COMPLETED':
          title = 'Trip Completed!';
          body = 'Your trip has been completed successfully.';
          break;
        case 'TRIP_CANCELLED':
          title = 'Trip Cancelled';
          body = 'Your trip has been cancelled.';
          break;
        default:
          print('No notification for status: $newStatus');
          return;
      }

      await showLocalNotification(
        title: title,
        body: body,
        payload: jsonEncode({
          'tripId': trip.id,
          'type': newStatus.toUpperCase(),
          'previousStatus': previousStatus,
        }),
        id: _generateNotificationId(trip.id, newStatus),
      );

      // Save notification to server
      await sendNotification(
        userId: trip.userId,
        type: newStatus.toUpperCase(),
        title: title,
        message: body,
        data: {
          'tripId': trip.id,
          'previousStatus': previousStatus,
          'newStatus': newStatus,
          'pickupLocation': trip.pickupLocation,
          'dropoffLocation': trip.dropoffLocation,
        },
      );

      print('✅ User notification sent for status: $newStatus');
    } catch (e) {
      print('❌ Error handling trip status change for user: $e');
    }
  }

  // Handle trip status change for drivers
  static Future<void> handleTripStatusChangeForDriver({
    required Trip trip,
    required String previousStatus,
    required String newStatus,
  }) async {
    try {
      print('\n=== HANDLING TRIP STATUS CHANGE FOR DRIVER ===');
      print('Trip ID: ${trip.id}');
      print('Previous Status: $previousStatus');
      print('New Status: $newStatus');

      String title = '';
      String body = '';

      switch (newStatus.toUpperCase()) {
        case 'DRIVER_IN_WAY':
          title = 'Trip Status Updated';
          body = 'You are now heading to the pickup location.';
          break;
        case 'DRIVER_ARRIVED':
          title = 'Arrived at Pickup';
          body = 'You have arrived at the pickup location.';
          break;
        case 'USER_PICKED_UP':
          title = 'Passenger Picked Up';
          body = 'Passenger has been picked up. Proceed to destination.';
          break;
        case 'TRIP_COMPLETED':
          title = 'Trip Completed';
          body = 'Trip has been completed successfully.';
          break;
        default:
          print('No notification for status: $newStatus');
          return;
      }

      await showLocalNotification(
        title: title,
        body: body,
        payload: jsonEncode({
          'tripId': trip.id,
          'type': newStatus.toUpperCase(),
          'previousStatus': previousStatus,
        }),
        id: _generateNotificationId(trip.id, newStatus),
      );

      print('✅ Driver notification sent for status: $newStatus');
    } catch (e) {
      print('❌ Error handling trip status change for driver: $e');
    }
  }

  // Handle new trip available notification for drivers
  static Future<void> handleNewTripAvailableForDriver({
    required Trip trip,
    required String driverId,
  }) async {
    const title = 'New Trip Available!';
    const message =
        'A new trip request is available in your area. Tap to view details.';
    const notificationType = 'NEW_TRIP_AVAILABLE';

    // Show local notification
    await showLocalNotification(
      title: title,
      body: message,
      payload: jsonEncode({
        'tripId': trip.id,
        'type': notificationType,
        'pickupLocation': trip.pickupLocation,
        'dropoffLocation': trip.dropoffLocation,
        'fare': trip.fare,
      }),
      id: _generateNotificationId(trip.id, 'NEW_TRIP'),
    );

    // Send notification to server
    await sendNotification(
      userId: driverId,
      type: notificationType,
      title: title,
      message: message,
      data: {
        'tripId': trip.id,
        'pickupLocation': trip.pickupLocation,
        'dropoffLocation': trip.dropoffLocation,
        'fare': trip.fare,
        'distance': trip.distance,
        'userFullName': trip.userFullName,
        'userPhone': trip.userPhone,
      },
    );
  }

  // Generate unique notification ID
  static int _generateNotificationId(String tripId, String status) {
    final hash = tripId.hashCode + status.hashCode;
    return hash.abs() %
        1000000; // Ensure positive number within reasonable range
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    await _localNotifications.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    await _localNotifications.cancel(id);
  }

  // Test notification for debugging
  static Future<void> testNotification() async {
    print('🧪 Testing notification...');
    await showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification to verify iOS permissions',
      payload: jsonEncode({'type': 'test'}),
      id: 999,
    );
  }

  // Check notification permissions
  static Future<void> checkPermissions() async {
    if (Platform.isIOS) {
      try {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        if (iosImplementation != null) {
          final bool? alertPermission =
              await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

          print('📱 iOS Notification Permissions:');
          print('- Alert: $alertPermission');
          print('- Badge: $alertPermission');
          print('- Sound: $alertPermission');
        }
      } catch (e) {
        print('❌ Error checking iOS permissions: $e');
      }
    } else {
      print('📱 Android platform - permissions handled automatically');
    }
  }

  // Notify drivers about new available trips
  static Future<void> notifyDriversAboutNewTrip(Trip trip) async {
    try {
      print('\n=== NOTIFYING DRIVERS ABOUT NEW TRIP ===');
      print('Trip ID: ${trip.id}');
      print('Pickup: ${trip.pickupLocation}');
      print('Dropoff: ${trip.dropoffLocation}');
      print('Fare: ${trip.fare}');

      await showLocalNotification(
        title: 'New Trip Available!',
        body: 'A new trip is available near you. Tap to view details.',
        payload: jsonEncode({
          'tripId': trip.id,
          'type': 'NEW_TRIP_AVAILABLE',
          'pickupLocation': trip.pickupLocation,
          'dropoffLocation': trip.dropoffLocation,
          'fare': trip.fare,
        }),
        id: _generateNotificationId(trip.id, 'NEW_TRIP'),
      );

      print('✅ New trip notification sent to drivers');
    } catch (e) {
      print('❌ Error notifying drivers about new trip: $e');
    }
  }
}
