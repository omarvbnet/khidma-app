import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/api_service.dart';
import 'services/taxi_request_service.dart';
import 'services/driver_service.dart';
import 'services/notification_service.dart';
import 'constants/api_constants.dart';
import 'dart:io' show Platform;
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_main_screen.dart';
import 'screens/driver_main_screen.dart';
import 'services/auth_service.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/search_trip_screen.dart';
import 'screens/notification_debug_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

// Top-level background message handler (must be outside any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('\n📨 BACKGROUND MESSAGE RECEIVED IN MAIN');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('Message ID: ${message.messageId}');
  print('From: ${message.from}');
  print('Sent Time: ${message.sentTime}');
  print('Collapse Key: ${message.collapseKey}');
  print('TTL: ${message.ttl}');

  try {
    // Initialize Firebase for background
    await Firebase.initializeApp();
    print('✅ Firebase initialized in background handler');

    // Initialize local notifications for background
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false, // Don't request in background
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await localNotifications.initialize(initializationSettings);
    print('✅ Local notifications initialized in background handler');

    // ALWAYS show a test notification to verify the handler is working
    final testNotificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Show a test notification to verify the handler is working
    await localNotifications.show(
      testNotificationId,
      'Background Handler Test',
      'Background message handler is working! Data: ${jsonEncode(message.data)}',
      NotificationDetails(
        android: AndroidNotificationDetails(
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
          timeoutAfter: 30000, // 30 seconds timeout
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: 1,
          categoryIdentifier: 'trip_notifications',
          threadIdentifier: 'trip_notifications',
          sound: 'default',
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      payload: jsonEncode(message.data),
    );

    print('✅ Test background notification displayed');
    print('Test Notification ID: $testNotificationId');

    // Check if this is ANY kind of trip-related notification
    bool isTripNotification = false;
    String notificationType = '';

    // Check notification object first
    if (message.notification != null) {
      final title = message.notification!.title?.toLowerCase() ?? '';
      final body = message.notification!.body?.toLowerCase() ?? '';

      if (title.contains('trip') ||
          body.contains('trip') ||
          title.contains('new') ||
          body.contains('available')) {
        isTripNotification = true;
        notificationType = 'notification_object';
        print('📨 Trip notification detected from notification object');
      }
    }

    // Check data payload
    if (!isTripNotification && message.data.isNotEmpty) {
      final dataType = message.data['type']?.toString().toLowerCase() ?? '';
      final dataKeys =
          message.data.keys.map((k) => k.toString().toLowerCase()).toList();

      if (dataType.contains('trip') ||
          dataType.contains('new') ||
          dataKeys.any((key) =>
              key.contains('trip') ||
              key.contains('pickup') ||
              key.contains('dropoff'))) {
        isTripNotification = true;
        notificationType = 'data_payload';
        print('📨 Trip notification detected from data payload');
      }
    }

    // Also check for specific notification types we know about
    if (!isTripNotification) {
      final knownTypes = [
        'NEW_TRIP_AVAILABLE',
        'NEW_TRIPS_AVAILABLE',
        'trip_created',
        'new_trip',
        'TEST_DRIVER_NOTIFICATION'
      ];

      final messageType = message.data['type']?.toString() ?? '';
      if (knownTypes.contains(messageType)) {
        isTripNotification = true;
        notificationType = 'known_type';
        print('📨 Trip notification detected from known type: $messageType');
      }
    }

    if (isTripNotification) {
      print(
          '🚗 Trip notification detected in background, fetching latest trips...');
      print('Detection method: $notificationType');

      // Fetch latest trips from backend
      await _fetchTripsInBackground(localNotifications);
      return; // Exit early since we handled the trip notification
    }

    // Process other messages as before
    String title = 'New Notification';
    String body = 'You have a new notification';

    // Use notification object if available
    if (message.notification != null) {
      title = message.notification!.title ?? title;
      body = message.notification!.body ?? body;
      print('📨 Using notification object for title/body');
    } else {
      // Fallback to data payload for data-only messages
      if (message.data['title'] != null) {
        title = message.data['title'];
      }
      if (message.data['body'] != null) {
        body = message.data['body'];
      } else if (message.data['message'] != null) {
        body = message.data['message'];
      }

      // Generate title/body based on message type if not provided
      if (message.data['type'] == 'NEW_TRIP_AVAILABLE' ||
          message.data['type'] == 'NEW_TRIPS_AVAILABLE') {
        title = 'New Trip Available!';
        body = 'A new trip request is waiting for you';
      } else if (message.data['type'] == 'trip_created' ||
          message.data['type'] == 'new_trip') {
        title = 'New Trip Request';
        body = 'A customer has requested a trip';
      }
      print('📨 Using data payload for title/body');
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
      timeoutAfter: 30000, // 30 seconds timeout
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      categoryIdentifier: 'trip_notifications',
      threadIdentifier: 'trip_notifications',
      sound: 'default',
      interruptionLevel: InterruptionLevel.active,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Generate unique notification ID
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await localNotifications.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );

    print('✅ Background notification displayed from main.dart');
    print('Notification ID: $notificationId');
    print('Title: $title');
    print('Body: $body');
    print('Payload: ${jsonEncode(message.data)}');
  } catch (e) {
    print('❌ Error in background message handler: $e');
    print('Error details: ${e.toString()}');
    print('Stack trace: ${StackTrace.current}');
  }
}

// Helper function to fetch trips in background
Future<void> _fetchTripsInBackground(
    FlutterLocalNotificationsPlugin localNotifications) async {
  try {
    print('🔄 Fetching trips in background...');

    // Get stored token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('❌ No auth token found in background');
      return;
    }

    print('✅ Auth token found, making API request...');

    // Make direct HTTP request to fetch trips using the correct API URL
    final response = await http.get(
      Uri.parse('https://khidma-app1.vercel.app/api/flutter/driver/trips'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    print('📡 API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final trips = data['trips'] as List;
      final waitingTrips =
          trips.where((trip) => trip['status'] == 'USER_WAITING').toList();

      print(
          '📊 Found ${waitingTrips.length} waiting trips in background fetch');

      if (waitingTrips.isNotEmpty) {
        // Show notification with trip count
        final notificationData = {
          'type': 'NEW_TRIPS_AVAILABLE',
          'tripCount': waitingTrips.length,
          'timestamp': DateTime.now().toIso8601String(),
        };

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
          timeoutAfter: 30000,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
        );

        final DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: waitingTrips.length,
          categoryIdentifier: 'trip_notifications',
          threadIdentifier: 'trip_notifications',
          sound: 'default',
          interruptionLevel: InterruptionLevel.active,
        );

        final NotificationDetails platformChannelSpecifics =
            NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

        final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        await localNotifications.show(
          notificationId,
          'New Trips Available!',
          'You have ${waitingTrips.length} new trip${waitingTrips.length > 1 ? 's' : ''} waiting. Tap to view.',
          platformChannelSpecifics,
          payload: jsonEncode(notificationData),
        );

        print('✅ Background trip notification displayed');
        print('Trip count: ${waitingTrips.length}');
      } else {
        print('ℹ️ No waiting trips found in background fetch');
      }
    } else {
      print('❌ API request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('❌ Error fetching trips in background: $e');
    print('Error details: ${e.toString()}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first with error handling
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully in main.dart');

    // Register background message handler BEFORE any other Firebase operations
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Background message handler registered');

    // Verify Firebase messaging is working
    final messaging = FirebaseMessaging.instance;
    print('✅ Firebase messaging instance created');

    // Check if we can get the token (this tests the connection)
    try {
      final token = await messaging.getToken();
      print('✅ FCM token available: ${token != null ? "Yes" : "No"}');
    } catch (e) {
      print('⚠️ FCM token check failed: $e');
    }
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('📱 Continuing without Firebase');
  }

  // Try to load .env file, but continue if it fails
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final storage = const FlutterSecureStorage();
  final apiService = ApiService();
  final taxiRequestService = TaxiRequestService(apiService);
  final driverService = DriverService(apiService);

  // Initialize notifications only for mobile platforms
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  if (Platform.isAndroid || Platform.isIOS) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print('✅ Local notifications initialized in main');
  }

  // Initialize notification service
  await NotificationService.initialize();

  // Load and get device token for push notifications
  await NotificationService.loadDeviceToken();
  await NotificationService.getDeviceToken();

  // Test notification permissions on iOS
  if (Platform.isIOS) {
    final hasPermissions =
        await NotificationService.checkNotificationPermissions();
    print(
        '📱 iOS Notification Permissions: ${hasPermissions ? "Granted" : "Not Granted"}');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<TaxiRequestService>.value(value: taxiRequestService),
        Provider<DriverService>.value(value: driverService),
        Provider<SharedPreferences>.value(value: prefs),
        Provider<FlutterSecureStorage>.value(value: storage),
        if (flutterLocalNotificationsPlugin != null)
          Provider<FlutterLocalNotificationsPlugin>.value(
            value: flutterLocalNotificationsPlugin,
          ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Waddiny',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            elevation: 0,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/register-user': (context) => const RegisterScreen(),
          '/register-driver': (context) => const RegisterScreen(),
          '/verify-otp': (context) => const OTPVerificationScreen(),
          '/user-main': (context) => const UserMainScreen(),
          '/driver-main': (context) => const DriverMainScreen(),
          '/search_trip': (context) => const SearchTripScreen(),
          '/notification-debug': (context) => const NotificationDebugScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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

    if (_user == null) {
      return const LoginScreen();
    }

    return _user!['role'] == 'DRIVER'
        ? const DriverMainScreen()
        : const UserMainScreen();
  }
}
