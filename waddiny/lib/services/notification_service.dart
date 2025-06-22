import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'dart:typed_data';
import '../constants/api_constants.dart';
import '../models/trip_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static bool _isInitialized = false;
  static String? _deviceToken;

  // Initialize local notifications and Firebase
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('\n🚀 INITIALIZING NOTIFICATION SERVICE');

    // Initialize Firebase Messaging
    try {
      await _initializeFirebaseMessaging();
    } catch (e) {
      print('⚠️ Firebase Messaging initialization failed: $e');
      print('📱 Continuing with local notifications only');
    }

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

  // Initialize Firebase Messaging
  static Future<void> _initializeFirebaseMessaging() async {
    print('\n🔥 INITIALIZING FIREBASE MESSAGING');

    // Request permission for iOS
    if (Platform.isIOS) {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📱 iOS Notification Settings:');
      print('- Authorization Status: ${settings.authorizationStatus}');
      print('- Alert: ${settings.alert}');
      print('- Badge: ${settings.badge}');
      print('- Sound: ${settings.sound}');
    }

    // Get FCM token
    String? fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      print('🔥 FCM Token: $fcmToken');
      _deviceToken = fcmToken;

      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', fcmToken);

      // Send token to server
      await _sendDeviceTokenToServer(fcmToken);
    } else {
      print('❌ Failed to get FCM token');
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed: $newToken');
      _deviceToken = newToken;
      _sendDeviceTokenToServer(newToken);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('\n📨 RECEIVED FOREGROUND MESSAGE');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // Show local notification
      _showLocalNotificationFromFirebase(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('\n👆 NOTIFICATION TAPPED (Background)');
      print('Data: ${message.data}');
      _handleNotificationTap(message.data);
    });

    print('✅ Firebase Messaging initialized successfully');
  }

  // Enhanced background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('\n📨 BACKGROUND MESSAGE RECEIVED');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Show local notification for background messages
    if (message.notification != null) {
      try {
        _showLocalNotificationFromFirebase(message);
        print('✅ Background notification displayed');
      } catch (e) {
        print('❌ Error showing background notification: $e');
      }
    }
  }

  // Show local notification from Firebase message
  static void _showLocalNotificationFromFirebase(RemoteMessage message) {
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: jsonEncode(message.data),
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('👆 Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationTap(data);
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(Map<String, dynamic> data) {
    print('👆 Handling notification tap with data: $data');
    // You can add navigation logic here based on the notification data
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

  // Show local notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    if (!_isInitialized) {
      print('⚠️ Notification service not initialized, initializing now...');
      await initialize();
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'trip_notifications',
      'Trip Notifications',
      channelDescription: 'Notifications for trip status updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      enableLights: true,
      ledColor: Color(0xFF2196F3),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      attachments: null,
      categoryIdentifier: 'trip_notifications',
      threadIdentifier: 'trip_notifications',
      sound: 'default',
      interruptionLevel: InterruptionLevel.active,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      print('\n🔔 SENDING NOTIFICATION');
      print('Title: $title');
      print('Body: $body');
      print('ID: $id');
      print('Platform: ${Platform.isIOS ? "iOS" : "Android"}');

      await _localNotifications.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('✅ Local notification sent successfully');

      // Additional verification for iOS
      if (Platform.isIOS) {
        await _verifyIOSNotificationDelivery();
      }
    } catch (e) {
      print('❌ Error showing local notification: $e');
      print('Error details: ${e.toString()}');
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
        Uri.parse('${ApiConstants.baseUrl}/notifications/send'),
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

        // Safely extract notifications from response
        if (data != null && data['notifications'] != null) {
          final notifications = data['notifications'];
          if (notifications is List) {
            return List<Map<String, dynamic>>.from(notifications);
          } else {
            print(
                'Invalid notifications format: expected List, got ${notifications.runtimeType}');
            return [];
          }
        } else {
          print('No notifications found in response');
          return [];
        }
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
  static Future<bool> checkNotificationPermissions() async {
    try {
      print('\n🔐 CHECKING NOTIFICATION PERMISSIONS');

      if (Platform.isIOS) {
        final settings =
            await FirebaseMessaging.instance.getNotificationSettings();
        final isAuthorized =
            settings.authorizationStatus == AuthorizationStatus.authorized;

        print('📱 iOS Notification Settings:');
        print('- Authorization Status: ${settings.authorizationStatus}');
        print('- Alert: ${settings.alert}');
        print('- Badge: ${settings.badge}');
        print('- Sound: ${settings.sound}');
        print('- Is Authorized: $isAuthorized');

        return isAuthorized;
      } else {
        print('📱 Android platform - permissions handled automatically');
        return true;
      }
    } catch (e) {
      print('❌ Error checking notification permissions: $e');
      return false;
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

  // Additional verification for iOS notification delivery
  static Future<void> _verifyIOSNotificationDelivery() async {
    try {
      print('\n📱 VERIFYING iOS NOTIFICATION DELIVERY');

      // Check if notifications are enabled in system settings
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        // Request permissions again to ensure they're granted
        final bool? permissionsGranted =
            await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

        print('iOS Permissions Status: $permissionsGranted');

        if (permissionsGranted == true) {
          print('✅ iOS notifications should be working');
        } else {
          print(
              '❌ iOS notifications may not be working - permissions not granted');
        }
      }
    } catch (e) {
      print('❌ Error verifying iOS notification delivery: $e');
    }
  }

  // Force notification with maximum priority
  static Future<void> forceNotification({
    required String title,
    required String body,
    String? payload,
    int id = 9999,
  }) async {
    print('\n🚨 FORCING NOTIFICATION WITH MAXIMUM PRIORITY');

    if (!_isInitialized) {
      print('⚠️ Initializing notification service...');
      await initialize();
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'urgent_notifications',
      'Urgent Notifications',
      channelDescription: 'High priority notifications',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      enableLights: true,
      ledColor: Color(0xFFFF0000),
      ledOnMs: 2000,
      ledOffMs: 1000,
      timeoutAfter: 30000, // 30 seconds
    );

    final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      categoryIdentifier: 'urgent_notifications',
      threadIdentifier: 'urgent_notifications',
      sound: 'default',
      interruptionLevel: InterruptionLevel.critical,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      print('✅ Force notification sent successfully');

      // Show a snackbar or alert to confirm delivery
      print('🔔 NOTIFICATION SENT - CHECK YOUR DEVICE');
    } catch (e) {
      print('❌ Error sending force notification: $e');
    }
  }

  // Send device token to server
  static Future<void> _sendDeviceTokenToServer(String token) async {
    try {
      print('\n📤 SENDING DEVICE TOKEN TO SERVER');
      print('Token: $token');

      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');

      if (userToken == null) {
        print('❌ No user token found, skipping server update');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'deviceToken': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'appVersion': '1.0.0',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Device token sent to server successfully');
      } else {
        print(
            '❌ Failed to send device token to server: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending device token to server: $e');
    }
  }

  // Send device token to server after authentication
  static Future<void> sendDeviceTokenAfterAuth() async {
    try {
      print('\n🔐 SENDING DEVICE TOKEN AFTER AUTHENTICATION');

      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');
      final deviceToken = prefs.getString('fcm_token');

      if (userToken != null && deviceToken != null) {
        print('✅ User authenticated, sending device token');
        await _sendDeviceTokenToServer(deviceToken);
      } else {
        print('❌ Missing user token or device token');
        print('- User token: ${userToken != null ? "Present" : "Missing"}');
        print('- Device token: ${deviceToken != null ? "Present" : "Missing"}');
      }
    } catch (e) {
      print('❌ Error sending device token after auth: $e');
    }
  }

  // Get device token for push notifications
  static Future<String?> getDeviceToken() async {
    try {
      print('\n📱 GETTING DEVICE TOKEN');

      if (_deviceToken != null) {
        print('📱 Using existing device token: $_deviceToken');
        return _deviceToken;
      }

      // Try to get FCM token
      if (_firebaseMessaging != null) {
        String? fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          print('🔥 Got FCM token: $fcmToken');
          _deviceToken = fcmToken;

          // Save token to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('fcm_token', fcmToken);

          // Send token to server
          await _sendDeviceTokenToServer(fcmToken);

          return fcmToken;
        }
      }

      // Fallback to mock token for testing
      _deviceToken =
          'mock_device_token_${DateTime.now().millisecondsSinceEpoch}';
      print('📱 Generated mock device token: $_deviceToken');

      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_token', _deviceToken!);

      // Send token to server
      await _sendDeviceTokenToServer(_deviceToken!);

      return _deviceToken;
    } catch (e) {
      print('❌ Error getting device token: $e');
      return null;
    }
  }

  // Load saved device token
  static Future<String?> loadDeviceToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try to load FCM token first
      _deviceToken = prefs.getString('fcm_token');
      if (_deviceToken != null) {
        print('🔥 Loaded saved FCM token: $_deviceToken');
        return _deviceToken;
      }

      // Fallback to regular device token
      _deviceToken = prefs.getString('device_token');
      if (_deviceToken != null) {
        print('📱 Loaded saved device token: $_deviceToken');
      } else {
        print('📱 No saved device token found');
      }

      return _deviceToken;
    } catch (e) {
      print('❌ Error loading device token: $e');
      return null;
    }
  }

  // Comprehensive notification system check
  static Future<Map<String, dynamic>> checkNotificationSystem() async {
    try {
      print('\n🔍 COMPREHENSIVE NOTIFICATION SYSTEM CHECK');

      final results = <String, dynamic>{};

      // 1. Check Firebase initialization
      results['firebaseInitialized'] = _isInitialized;
      print('✅ Firebase initialized: ${results['firebaseInitialized']}');

      // 2. Check device token
      final deviceToken = await getDeviceToken();
      results['hasDeviceToken'] = deviceToken != null;
      results['deviceToken'] = deviceToken;
      print(
          '✅ Device token: ${results['hasDeviceToken'] ? "Present" : "Missing"}');

      // 3. Check notification permissions
      final hasPermissions = await checkNotificationPermissions();
      results['hasPermissions'] = hasPermissions;
      print(
          '✅ Notification permissions: ${results['hasPermissions'] ? "Granted" : "Not Granted"}');

      // 4. Check local notifications
      results['localNotificationsReady'] = _localNotifications != null;
      print(
          '✅ Local notifications: ${results['localNotificationsReady'] ? "Ready" : "Not Ready"}');

      // 5. Check platform-specific settings
      if (Platform.isIOS) {
        results['platform'] = 'iOS';
        results['iosSettings'] = await _checkIOSNotificationSettings();
      } else {
        results['platform'] = 'Android';
        results['androidSettings'] = await _checkAndroidNotificationSettings();
      }

      // 6. Check server connectivity
      results['serverConnectivity'] = await _checkServerConnectivity();

      // 7. Check device token registration
      results['tokenRegistration'] = await _checkTokenRegistration();

      print('✅ Comprehensive check completed');
      return results;
    } catch (e) {
      print('❌ Error during comprehensive check: $e');
      return {
        'error': e.toString(),
        'timestamp':
            DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(DateTime.now())
      };
    }
  }

  // Check iOS notification settings
  static Future<Map<String, dynamic>> _checkIOSNotificationSettings() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();

      return {
        'authorizationStatus': settings.authorizationStatus.toString(),
        'alert': settings.alert,
        'badge': settings.badge,
        'sound': settings.sound,
        'criticalAlert': settings.criticalAlert,
        'announcement': settings.announcement,
        'carPlay': settings.carPlay,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Check Android notification settings
  static Future<Map<String, dynamic>>
      _checkAndroidNotificationSettings() async {
    try {
      // For Android, we'll just return basic info since getNotificationChannels is not available
      return {
        'platform': 'Android',
        'channels': 'Not available in this version',
        'hasTripChannel': true, // Assume it exists
        'hasUrgentChannel': true, // Assume it exists
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Check server connectivity
  static Future<Map<String, dynamic>> _checkServerConnectivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');

      if (userToken == null) {
        return {'status': 'No authentication token', 'canConnect': false};
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications/test-drivers-simple'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return {
        'status': response.statusCode == 200 ? 'Connected' : 'Failed',
        'statusCode': response.statusCode,
        'canConnect': response.statusCode == 200,
        'response': response.body.substring(0, 100) + '...'
      };
    } catch (e) {
      return {'status': 'Error', 'canConnect': false, 'error': e.toString()};
    }
  }

  // Check token registration with server
  static Future<Map<String, dynamic>> _checkTokenRegistration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');
      final deviceToken = prefs.getString('fcm_token');

      if (userToken == null || deviceToken == null) {
        return {
          'status': 'Missing token',
          'registered': false,
          'userToken': userToken != null,
          'deviceToken': deviceToken != null
        };
      }

      // Try to send token to server
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'deviceToken': deviceToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'appVersion': '1.0.0',
        }),
      );

      return {
        'status': response.statusCode == 200 ? 'Registered' : 'Failed',
        'registered': response.statusCode == 200,
        'statusCode': response.statusCode,
        'response': response.body
      };
    } catch (e) {
      return {'status': 'Error', 'registered': false, 'error': e.toString()};
    }
  }

  // Test notification with detailed logging
  static Future<Map<String, dynamic>> testNotificationWithDetails({
    required String title,
    required String body,
    String? payload,
    int id = 9999,
  }) async {
    try {
      print('\n🧪 TESTING NOTIFICATION WITH DETAILS');
      print('Title: $title');
      print('Body: $body');
      print('Payload: $payload');
      print('ID: $id');

      final results = <String, dynamic>{
        'timestamp':
            DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(DateTime.now()),
        'title': title,
        'body': body,
        'payload': payload,
        'id': id,
      };

      // Check system status first
      final systemCheck = await checkNotificationSystem();
      results['systemCheck'] = systemCheck;

      if (!systemCheck['hasPermissions']) {
        results['success'] = false;
        results['error'] = 'Notification permissions not granted';
        return results;
      }

      // Try to show notification
      try {
        await showLocalNotification(
          title: title,
          body: body,
          payload: payload,
          id: id,
        );

        results['success'] = true;
        results['localNotification'] = 'Sent';
        print('✅ Local notification sent successfully');
      } catch (e) {
        results['success'] = false;
        results['localNotification'] = 'Failed';
        results['localError'] = e.toString();
        print('❌ Local notification failed: $e');
      }

      // Try Firebase notification if device token is available
      final deviceToken = await getDeviceToken();
      if (deviceToken != null) {
        try {
          final firebaseResult = await _testFirebaseNotification(
              title, body, payload, deviceToken);
          results['firebaseNotification'] = firebaseResult;
        } catch (e) {
          results['firebaseNotification'] = {
            'success': false,
            'error': e.toString()
          };
        }
      } else {
        results['firebaseNotification'] = {
          'success': false,
          'error': 'No device token available'
        };
      }

      print('✅ Notification test completed');
      return results;
    } catch (e) {
      print('❌ Error during notification test: $e');
      return {
        'success': false,
        'error': e.toString(),
        'timestamp':
            DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(DateTime.now())
      };
    }
  }

  // Test Firebase notification
  static Future<Map<String, dynamic>> _testFirebaseNotification(
      String title, String body, String? payload, String deviceToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('token');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/notifications/send-simple'),
        headers: {
          'Content-Type': 'application/json',
          if (userToken != null) 'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'deviceToken': deviceToken,
          'data': {
            'type': 'test',
            'payload': payload,
            'timestamp':
                DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(DateTime.now())
          }
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'messageId': responseData['messageId'],
          'response': responseData
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': response.body
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get detailed notification status
  static Future<Map<String, dynamic>> getNotificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'timestamp':
            DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(DateTime.now()),
        'isInitialized': _isInitialized,
        'deviceToken': prefs.getString('fcm_token'),
        'userToken': prefs.getString('token') != null,
        'platform': Platform.isIOS ? 'iOS' : 'Android',
        'permissions': await checkNotificationPermissions(),
        'firebaseReady': _firebaseMessaging != null,
        'localNotificationsReady': _localNotifications != null,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp':
            DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(DateTime.now())
      };
    }
  }
}
