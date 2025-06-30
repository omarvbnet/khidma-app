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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'contexts/language_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_wrapper.dart';

// Background notification handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('🔔 Background notification received:');
  print('  - Title: ${message.notification?.title}');
  print('  - Body: ${message.notification?.body}');
  print('  - Data: ${message.data}');
  print('  - Message ID: ${message.messageId}');

  // Get user role from shared preferences
  final prefs = await SharedPreferences.getInstance();
  final userRole = prefs.getString('userRole') ?? 'USER';
  final userId = prefs.getString('userId');

  print('👤 User context:');
  print('  - Role: $userRole');
  print('  - User ID: $userId');

  // Only process notifications that match the user's role
  final notificationType = message.data['type'] ?? '';
  final isDriverNotification = notificationType == 'NEW_TRIP_AVAILABLE';
  final isUserNotification = [
    'TRIP_STATUS_CHANGE',
    'DRIVER_ACCEPTED',
    'DRIVER_ARRIVED',
    'USER_PICKED_UP',
    'TRIP_COMPLETED',
    'TRIP_CANCELLED'
  ].contains(notificationType);

  print('📋 Notification analysis:');
  print('  - Type: $notificationType');
  print('  - Is driver notification: $isDriverNotification');
  print('  - Is user notification: $isUserNotification');
  print('  - User role: $userRole');

  // Filter notifications based on role
  if (userRole == 'DRIVER' && !isDriverNotification) {
    print('❌ Skipping notification - driver received non-driver notification');
    return;
  }

  if (userRole == 'USER' && !isUserNotification) {
    print('❌ Skipping notification - user received non-user notification');
    return;
  }

  if (userRole == 'DRIVER' && isDriverNotification) {
    print('✅ Processing driver notification');
    // Handle driver notification (new trip available)
    // You can add specific logic here for driver notifications
  }

  if (userRole == 'USER' && isUserNotification) {
    print('✅ Processing user notification');
    // Handle user notification (trip status updates)
    // You can add specific logic here for user notifications
  }

  print('✅ Background notification processed successfully');
}

// Helper function to fetch trips in background
Future<void> _fetchTripsInBackground(
  FlutterLocalNotificationsPlugin localNotifications,
) async {
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
      '📡 API Response Body: ${response.body.substring(0, 200)}...',
    ); // Log first 200 chars

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final trips = data['trips'] as List;
      final waitingTrips =
          trips.where((trip) => trip['status'] == 'USER_WAITING').toList();

      print(
        '📊 Found ${waitingTrips.length} waiting trips in background fetch',
      );
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
  // Initialize Firebase and other setup as before
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully in main.dart');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Background message handler registered');
    final messaging = FirebaseMessaging.instance;
    print('✅ Firebase messaging instance created');
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
  await NotificationService.initialize();
  await NotificationService.loadDeviceToken();
  await NotificationService.getDeviceToken();

  // Note: Firebase message handling is now done in NotificationService with role-based filtering
  // No need for duplicate listener here

  if (Platform.isIOS) {
    final hasPermissions =
        await NotificationService.checkNotificationPermissions();
    print(
      '📱 iOS Notification Permissions: ${hasPermissions ? "Granted" : "Not Granted"}',
    );
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Provider<AuthService>(
          create: (_) => AuthService(),
          child: MaterialApp(
            title: 'Waddiny',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'), // Arabic (RTL)
              Locale('en'), // English (LTR)
              Locale('ku'), // Kurdish (RTL)
              Locale('tr'), // Turkish (LTR)
            ],
            locale: languageProvider.locale,
            localeResolutionCallback: (locale, supportedLocales) {
              // For Kurdish, fallback to English for Material/Cupertino widgets
              if (locale?.languageCode == 'ku') {
                return const Locale(
                    'en'); // Fallback to English for system widgets
              }

              // Normal resolution for other locales
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            builder: (context, child) {
              // Handle RTL for Kurdish and Arabic
              final languageProvider =
                  Provider.of<LanguageProvider>(context, listen: false);
              final isRTL = languageProvider.locale.languageCode == 'ku' ||
                  languageProvider.locale.languageCode == 'ar';

              return Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              );
            },
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
            home: AuthWrapper(),
            routes: {
              '/': (context) => const AuthWrapper(),
              '/login': (context) => const LoginScreen(),
              '/register-user': (context) => const RegisterScreen(),
              '/register-driver': (context) => const RegisterScreen(),
              '/verify-otp': (context) => const OTPVerificationScreen(),
              '/user-main': (context) => const UserMainScreen(),
              '/driver-main': (context) => const DriverMainScreen(),
              '/search_trip': (context) => const SearchTripScreen(),
            },
            debugShowCheckedModeBanner: false,
          ),
        );
      },
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const LoginScreen();
    }

    return _user!['role'] == 'DRIVER'
        ? const DriverMainScreen()
        : const UserMainScreen();
  }
}

// Helper function to get AppLocalizations with the correct locale
AppLocalizations getLocalizations(BuildContext context) {
  final languageProvider =
      Provider.of<LanguageProvider>(context, listen: false);
  final actualLocale = languageProvider.locale;

  // Use the lookup function from generated AppLocalizations
  return lookupAppLocalizations(actualLocale);
}
