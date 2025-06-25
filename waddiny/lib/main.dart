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

    // ENHANCED TRIP NOTIFICATION DETECTION
    bool isTripNotification = false;
    String detectionReason = '';

    // Method 1: Check notification object content
    if (message.notification != null) {
      final title = message.notification!.title?.toLowerCase() ?? '';
      final body = message.notification!.body?.toLowerCase() ?? '';

      print('🔍 Checking notification object:');
      print('  Title: "$title"');
      print('  Body: "$body"');

      if (title.contains('trip') ||
          body.contains('trip') ||
          title.contains('new') ||
          body.contains('available') ||
          title.contains('available') ||
          body.contains('new')) {
        isTripNotification = true;
        detectionReason = 'notification_object_content';
        print('📨 Trip notification detected from notification object content');
      }
    }

    // Method 2: Check data payload
    if (!isTripNotification && message.data.isNotEmpty) {
      final dataType = message.data['type']?.toString().toLowerCase() ?? '';
      final dataKeys =
          message.data.keys.map((k) => k.toString().toLowerCase()).toList();

      print('🔍 Checking data payload:');
      print('  Type: "$dataType"');
      print('  Keys: $dataKeys');

      if (dataType.contains('trip') ||
          dataType.contains('new') ||
          dataKeys.any((key) =>
              key.contains('trip') ||
              key.contains('pickup') ||
              key.contains('dropoff'))) {
        isTripNotification = true;
        detectionReason = 'data_payload_content';
        print('📨 Trip notification detected from data payload content');
      }
    }

    // Method 3: Check for specific known types
    if (!isTripNotification) {
      final knownTypes = [
        'NEW_TRIP_AVAILABLE',
        'NEW_TRIPS_AVAILABLE',
        'trip_created',
        'new_trip',
        'TEST_DRIVER_NOTIFICATION'
      ];

      final messageType = message.data['type']?.toString() ?? '';
      print('🔍 Checking known types:');
      print('  Message type: "$messageType"');
      print('  Known types: $knownTypes');

      if (knownTypes.contains(messageType)) {
        isTripNotification = true;
        detectionReason = 'known_type_match';
        print('📨 Trip notification detected from known type: $messageType');
      }
    }

    // Method 4: Check for any trip-related keywords in the entire message
    if (!isTripNotification) {
      final allText = [
        message.notification?.title ?? '',
        message.notification?.body ?? '',
        ...message.data.values.map((v) => v.toString()),
        ...message.data.keys.map((k) => k.toString()),
      ].join(' ').toLowerCase();

      print('🔍 Checking all text for trip keywords:');
      print('  All text: "$allText"');

      if (allText.contains('trip') ||
          allText.contains('pickup') ||
          allText.contains('dropoff') ||
          allText.contains('fare') ||
          allText.contains('driver') ||
          allText.contains('passenger')) {
        isTripNotification = true;
        detectionReason = 'keyword_search';
        print('📨 Trip notification detected from keyword search');
      }
    }

    // Method 5: If it's from our backend, assume it's trip-related
    if (!isTripNotification && message.from != null) {
      if (message.from!.contains('fcm.googleapis.com') ||
          message.from!.contains('khidma-app1.vercel.app')) {
        isTripNotification = true;
        detectionReason = 'backend_source';
        print(
            '📨 Trip notification detected from backend source: ${message.from}');
      }
    }

    // Method 6: If we have any data, assume it's important
    if (!isTripNotification && message.data.isNotEmpty) {
      isTripNotification = true;
      detectionReason = 'has_data_payload';
      print('📨 Trip notification detected because it has data payload');
    }

    print('🎯 FINAL DETECTION RESULT:');
    print('  Is trip notification: $isTripNotification');
    print('  Detection reason: $detectionReason');

    if (isTripNotification) {
      print(
          '🚗 Trip notification detected in background, fetching latest trips...');
      print('Detection method: $detectionReason');

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

    // Show the actual notification
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await localNotifications.show(
      notificationId,
      title,
      body,
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
          timeoutAfter: 30000,
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
      // Show a notification about the missing token
      await localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Background Fetch Failed',
        'Authentication token not found. Please log in again.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_notifications',
            'Trip Notifications',
            channelDescription: 'Notifications for trip status updates',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
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
    ).timeout(const Duration(seconds: 15)); // Increased timeout

    print('📡 API Response Status: ${response.statusCode}');
    print(
        '📡 API Response Body: ${response.body.substring(0, 200)}...'); // Log first 200 chars

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final trips = data['trips'] as List;
      final waitingTrips =
          trips.where((trip) => trip['status'] == 'USER_WAITING').toList();

      print(
          '📊 Found ${waitingTrips.length} waiting trips in background fetch');
      print('📊 Total trips: ${trips.length}');

      if (waitingTrips.isNotEmpty) {
        // Show notification with trip count
        final notificationData = {
          'type': 'NEW_TRIPS_AVAILABLE',
          'tripCount': waitingTrips.length,
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'background_fetch',
        };

        final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        await localNotifications.show(
          notificationId,
          'New Trips Available!',
          'You have ${waitingTrips.length} new trip${waitingTrips.length > 1 ? 's' : ''} waiting. Tap to view.',
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
              timeoutAfter: 30000,
              category: AndroidNotificationCategory.message,
              visibility: NotificationVisibility.public,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              badgeNumber: waitingTrips.length,
              categoryIdentifier: 'trip_notifications',
              threadIdentifier: 'trip_notifications',
              sound: 'default',
              interruptionLevel: InterruptionLevel.active,
            ),
          ),
          payload: jsonEncode(notificationData),
        );

        print('✅ Background trip notification displayed');
        print('Trip count: ${waitingTrips.length}');
        print('Notification ID: $notificationId');
      } else {
        print('ℹ️ No waiting trips found in background fetch');
        // Show a notification that no trips are available
        await localNotifications.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'No Trips Available',
          'No new trips are currently waiting for drivers.',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'trip_notifications',
              'Trip Notifications',
              channelDescription: 'Notifications for trip status updates',
              importance: Importance.low,
              priority: Priority.low,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: false,
              presentSound: false,
            ),
          ),
        );
      }
    } else if (response.statusCode == 401) {
      print('❌ Authentication failed (401)');
      await localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Authentication Required',
        'Please log in again to receive trip notifications.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_notifications',
            'Trip Notifications',
            channelDescription: 'Notifications for trip status updates',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } else {
      print('❌ API request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Show error notification
      await localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Network Error',
        'Unable to fetch latest trips. Please check your connection.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_notifications',
            'Trip Notifications',
            channelDescription: 'Notifications for trip status updates',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
    }
  } catch (e) {
    print('❌ Error fetching trips in background: $e');
    print('Error details: ${e.toString()}');

    // Show error notification
    try {
      await localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'Background Fetch Error',
        'Error: ${e.toString().substring(0, 50)}...',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_notifications',
            'Trip Notifications',
            channelDescription: 'Notifications for trip status updates',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
    } catch (notificationError) {
      print('❌ Failed to show error notification: $notificationError');
    }
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

  // Set up foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('\n📨 FOREGROUND MESSAGE RECEIVED');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Show local notification even in foreground
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    String title = 'New Notification';
    String body = 'You have a new notification';

    // Use notification object if available
    if (message.notification != null) {
      title = message.notification!.title ?? title;
      body = message.notification!.body ?? body;
    } else {
      // Fallback to data payload
      if (message.data['title'] != null) {
        title = message.data['title'];
      }
      if (message.data['body'] != null) {
        body = message.data['body'];
      } else if (message.data['message'] != null) {
        body = message.data['message'];
      }
    }

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await localNotifications.show(
      notificationId,
      title,
      body,
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
          timeoutAfter: 30000,
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

    print('✅ Foreground notification displayed');
  });

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
