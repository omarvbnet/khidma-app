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

  // Initialize Firebase for background
  await Firebase.initializeApp();

  // Initialize local notifications for background
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await localNotifications.initialize(initializationSettings);

  // Show local notification for background messages
  if (message.notification != null) {
    try {
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
        message.notification!.title ?? 'New Trip',
        message.notification!.body ?? '',
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );

      print('✅ Background notification displayed from main.dart');
      print('Notification ID: $notificationId');
      print('Payload: ${jsonEncode(message.data)}');
    } catch (e) {
      print('❌ Error showing background notification: $e');
      print('Error details: ${e.toString()}');
    }
  } else {
    print('⚠️ No notification content in message');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully in main.dart');

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Background message handler registered');
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
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
