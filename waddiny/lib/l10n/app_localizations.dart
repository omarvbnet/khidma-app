import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku'),
    Locale('tr')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Waddiny'**
  String get appTitle;

  /// The subtitle shown on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Smart Transportation Service'**
  String get appSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @chooseRegistrationType.
  ///
  /// In en, this message translates to:
  /// **'Choose Registration Type'**
  String get chooseRegistrationType;

  /// No description provided for @registerAsUser.
  ///
  /// In en, this message translates to:
  /// **'Register as User'**
  String get registerAsUser;

  /// No description provided for @registerAsDriver.
  ///
  /// In en, this message translates to:
  /// **'Register as Driver'**
  String get registerAsDriver;

  /// No description provided for @carId.
  ///
  /// In en, this message translates to:
  /// **'Car ID'**
  String get carId;

  /// No description provided for @carType.
  ///
  /// In en, this message translates to:
  /// **'Car Type'**
  String get carType;

  /// No description provided for @licenseId.
  ///
  /// In en, this message translates to:
  /// **'License ID'**
  String get licenseId;

  /// No description provided for @pleaseEnterCarId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your car ID'**
  String get pleaseEnterCarId;

  /// No description provided for @pleaseEnterCarType.
  ///
  /// In en, this message translates to:
  /// **'Please enter your car type'**
  String get pleaseEnterCarType;

  /// No description provided for @pleaseEnterLicenseId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your license ID'**
  String get pleaseEnterLicenseId;

  /// No description provided for @verifyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhoneNumber;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to {phoneNumber}'**
  String enterOtpSentTo(Object phoneNumber);

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @pleaseEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP'**
  String get pleaseEnterOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeUser(Object name);

  /// No description provided for @whereWouldYouLikeToGo.
  ///
  /// In en, this message translates to:
  /// **'Where would you like to go?'**
  String get whereWouldYouLikeToGo;

  /// No description provided for @createNewTrip.
  ///
  /// In en, this message translates to:
  /// **'Create New Trip'**
  String get createNewTrip;

  /// No description provided for @recentTrips.
  ///
  /// In en, this message translates to:
  /// **'Recent Trips'**
  String get recentTrips;

  /// No description provided for @noTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get noTripsYet;

  /// No description provided for @errorLoadingTrips.
  ///
  /// In en, this message translates to:
  /// **'Error loading trips: {error}'**
  String errorLoadingTrips(Object error);

  /// No description provided for @tripTo.
  ///
  /// In en, this message translates to:
  /// **'Trip to {location}'**
  String tripTo(Object location);

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get accountStatus;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @waitingTrips.
  ///
  /// In en, this message translates to:
  /// **'Waiting Trips'**
  String get waitingTrips;

  /// No description provided for @noWaitingTrips.
  ///
  /// In en, this message translates to:
  /// **'No waiting trips'**
  String get noWaitingTrips;

  /// No description provided for @newTripsAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Trips Available!'**
  String get newTripsAvailable;

  /// No description provided for @newTripsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} new trip{count, plural, one {} other {s}} waiting for you'**
  String newTripsWaiting(num count);

  /// No description provided for @newTripAvailable.
  ///
  /// In en, this message translates to:
  /// **'New trip available: {message}'**
  String newTripAvailable(Object message);

  /// No description provided for @checkListBelow.
  ///
  /// In en, this message translates to:
  /// **'Check the list below'**
  String get checkListBelow;

  /// No description provided for @generalNotification.
  ///
  /// In en, this message translates to:
  /// **'General notification received, refreshing trips...'**
  String get generalNotification;

  /// No description provided for @notificationTapped.
  ///
  /// In en, this message translates to:
  /// **'Notification tapped (background): {data}'**
  String notificationTapped(Object data);

  /// No description provided for @appLaunchedFromNotification.
  ///
  /// In en, this message translates to:
  /// **'App launched from notification: {data}'**
  String appLaunchedFromNotification(Object data);

  /// No description provided for @noInitialMessage.
  ///
  /// In en, this message translates to:
  /// **'No initial message found'**
  String get noInitialMessage;

  /// No description provided for @errorGettingInitialMessage.
  ///
  /// In en, this message translates to:
  /// **'Error getting initial message: {error}'**
  String errorGettingInitialMessage(Object error);

  /// No description provided for @notificationTriggeredTripRefresh.
  ///
  /// In en, this message translates to:
  /// **'Notification-triggered trip refresh...'**
  String get notificationTriggeredTripRefresh;

  /// No description provided for @tripListUpdated.
  ///
  /// In en, this message translates to:
  /// **'Trip list updated with {count} waiting trips'**
  String tripListUpdated(Object count);

  /// No description provided for @errorInNotificationTripRefresh.
  ///
  /// In en, this message translates to:
  /// **'Error in notification-triggered trip refresh: {error}'**
  String errorInNotificationTripRefresh(Object error);

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Tap to retry.'**
  String get networkError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loadingTripInformation.
  ///
  /// In en, this message translates to:
  /// **'Loading trip information...'**
  String get loadingTripInformation;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(Object error);

  /// No description provided for @requestTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout - please check your internet connection'**
  String get requestTimeout;

  /// No description provided for @errorCheckingUserStatus.
  ///
  /// In en, this message translates to:
  /// **'Error checking user status: {error}'**
  String errorCheckingUserStatus(Object error);

  /// No description provided for @errorLoadingDriverBudget.
  ///
  /// In en, this message translates to:
  /// **'Error loading driver budget: {error}'**
  String errorLoadingDriverBudget(Object error);

  /// No description provided for @errorLoadingCarInfo.
  ///
  /// In en, this message translates to:
  /// **'Error loading car info: {error}'**
  String errorLoadingCarInfo(Object error);

  /// No description provided for @errorLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Error logging out: {error}'**
  String errorLoggingOut(Object error);

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile: {error}'**
  String errorLoadingProfile(Object error);

  /// No description provided for @errorLoadingUserData.
  ///
  /// In en, this message translates to:
  /// **'Error loading user data: {error}'**
  String errorLoadingUserData(Object error);

  /// No description provided for @noUserDataFound.
  ///
  /// In en, this message translates to:
  /// **'No user data found'**
  String get noUserDataFound;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @testBudget.
  ///
  /// In en, this message translates to:
  /// **'Test Budget'**
  String get testBudget;

  /// No description provided for @budgetInformation.
  ///
  /// In en, this message translates to:
  /// **'Budget Information'**
  String get budgetInformation;

  /// No description provided for @currentBudget.
  ///
  /// In en, this message translates to:
  /// **'Current Budget: {amount} IQD'**
  String currentBudget(Object amount);

  /// No description provided for @driverName.
  ///
  /// In en, this message translates to:
  /// **'Driver: {name}'**
  String driverName(Object name);

  /// No description provided for @budgetDeductionNote.
  ///
  /// In en, this message translates to:
  /// **'Note: 12% of trip price is deducted when accepting a trip.'**
  String get budgetDeductionNote;

  /// No description provided for @addTestBudget.
  ///
  /// In en, this message translates to:
  /// **'Add 1000 IQD (Test)'**
  String get addTestBudget;

  /// No description provided for @budgetAdded.
  ///
  /// In en, this message translates to:
  /// **'Budget added: {amount} IQD'**
  String budgetAdded(Object amount);

  /// No description provided for @errorAddingBudget.
  ///
  /// In en, this message translates to:
  /// **'Error adding budget: {error}'**
  String errorAddingBudget(Object error);

  /// No description provided for @budgetTest.
  ///
  /// In en, this message translates to:
  /// **'Budget test: {message} - Current: {currentBudget} IQD'**
  String budgetTest(Object currentBudget, Object message);

  /// No description provided for @budgetTestError.
  ///
  /// In en, this message translates to:
  /// **'Budget test error: {error}'**
  String budgetTestError(Object error);

  /// No description provided for @deduction.
  ///
  /// In en, this message translates to:
  /// **'Deduction: {amount} IQD (12%)'**
  String deduction(Object amount);

  /// No description provided for @yourBudget.
  ///
  /// In en, this message translates to:
  /// **'Your budget: {budget} IQD'**
  String yourBudget(Object budget);

  /// No description provided for @insufficientBudget.
  ///
  /// In en, this message translates to:
  /// **'Insufficient budget'**
  String get insufficientBudget;

  /// No description provided for @viewBudget.
  ///
  /// In en, this message translates to:
  /// **'View Budget'**
  String get viewBudget;

  /// No description provided for @provinceFiltering.
  ///
  /// In en, this message translates to:
  /// **'Province Filtering'**
  String get provinceFiltering;

  /// No description provided for @provinceFilteringDescription.
  ///
  /// In en, this message translates to:
  /// **'You only see trips from users in the same province as you. This ensures better service quality and faster response times.'**
  String get provinceFilteringDescription;

  /// No description provided for @newTripRequestsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'New trip requests will appear here automatically'**
  String get newTripRequestsWillAppear;

  /// No description provided for @youllReceiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive notifications for new trips in your province'**
  String get youllReceiveNotifications;

  /// No description provided for @tripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// No description provided for @acceptTrip.
  ///
  /// In en, this message translates to:
  /// **'Accept Trip'**
  String get acceptTrip;

  /// No description provided for @viewTrip.
  ///
  /// In en, this message translates to:
  /// **'View Trip'**
  String get viewTrip;

  /// No description provided for @tripNumber.
  ///
  /// In en, this message translates to:
  /// **'Trip #{id}'**
  String tripNumber(Object id);

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @errorLoadingTripDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading trip details: {error}'**
  String errorLoadingTripDetails(Object error);

  /// No description provided for @invalidCoordinatesInTripData.
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinates in trip data. Please contact support.'**
  String get invalidCoordinatesInTripData;

  /// No description provided for @accountNotActive.
  ///
  /// In en, this message translates to:
  /// **'Your account is not active. Please contact support.'**
  String get accountNotActive;

  /// No description provided for @invalidCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinates in trip data. Please contact support.'**
  String get invalidCoordinates;

  /// No description provided for @driverProfile.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile'**
  String get driverProfile;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @carInformation.
  ///
  /// In en, this message translates to:
  /// **'Car Information'**
  String get carInformation;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current: {flag} {language}'**
  String current(Object flag, Object language);

  /// No description provided for @tapLanguageToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap a language to change the app language'**
  String get tapLanguageToChange;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedTo(Object language);

  /// No description provided for @languageChangedRestart.
  ///
  /// In en, this message translates to:
  /// **'Language changed! Please restart the app for full effect.'**
  String get languageChangedRestart;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocation;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @dropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Dropoff Location'**
  String get dropoffLocation;

  /// No description provided for @errorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting location: {error}'**
  String errorGettingLocation(Object error);

  /// No description provided for @errorSearchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error searching location: {error}'**
  String errorSearchingLocation(Object error);

  /// No description provided for @pleaseSelectPickupDropoff.
  ///
  /// In en, this message translates to:
  /// **'Please select pickup and dropoff locations'**
  String get pleaseSelectPickupDropoff;

  /// No description provided for @pleaseEnterBothAddresses.
  ///
  /// In en, this message translates to:
  /// **'Please enter both pickup and dropoff addresses'**
  String get pleaseEnterBothAddresses;

  /// No description provided for @yourAccountNotActive.
  ///
  /// In en, this message translates to:
  /// **'Your account is not active. Please contact support.'**
  String get yourAccountNotActive;

  /// No description provided for @createTrip.
  ///
  /// In en, this message translates to:
  /// **'Create Trip'**
  String get createTrip;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(Object distance);

  /// No description provided for @estimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated Price: {price} IQD'**
  String estimatedPrice(Object price);

  /// No description provided for @confirmTrip.
  ///
  /// In en, this message translates to:
  /// **'Confirm Trip'**
  String get confirmTrip;

  /// No description provided for @tripCreated.
  ///
  /// In en, this message translates to:
  /// **'Trip created successfully!'**
  String get tripCreated;

  /// No description provided for @errorCreatingTrip.
  ///
  /// In en, this message translates to:
  /// **'Error creating trip: {error}'**
  String errorCreatingTrip(Object error);

  /// No description provided for @driverNavigation.
  ///
  /// In en, this message translates to:
  /// **'Driver Navigation'**
  String get driverNavigation;

  /// No description provided for @mapsMeStyleNavigation.
  ///
  /// In en, this message translates to:
  /// **'Maps.me style navigation - route to destination'**
  String get mapsMeStyleNavigation;

  /// No description provided for @actualMovementTest.
  ///
  /// In en, this message translates to:
  /// **'Actual Movement Test'**
  String get actualMovementTest;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @mapsMeInfo.
  ///
  /// In en, this message translates to:
  /// **'Maps.me Info'**
  String get mapsMeInfo;

  /// No description provided for @actualPhoneMovementTracking.
  ///
  /// In en, this message translates to:
  /// **'Actual phone movement tracking:'**
  String get actualPhoneMovementTracking;

  /// No description provided for @movePhoneLeft.
  ///
  /// In en, this message translates to:
  /// **'1. Move phone LEFT → Camera and car follow LEFT'**
  String get movePhoneLeft;

  /// No description provided for @movePhoneRight.
  ///
  /// In en, this message translates to:
  /// **'2. Move phone RIGHT → Camera and car follow RIGHT'**
  String get movePhoneRight;

  /// No description provided for @bothFollowActualMovement.
  ///
  /// In en, this message translates to:
  /// **'3. Both follow actual movement direction'**
  String get bothFollowActualMovement;

  /// No description provided for @gpsBasedMovementTracking.
  ///
  /// In en, this message translates to:
  /// **'4. GPS-based movement tracking'**
  String get gpsBasedMovementTracking;

  /// No description provided for @realTimeMovementFollowing.
  ///
  /// In en, this message translates to:
  /// **'5. Real-time movement following'**
  String get realTimeMovementFollowing;

  /// No description provided for @gpsHeadingCameraCar.
  ///
  /// In en, this message translates to:
  /// **'GPS heading: {heading}°\nCamera & car follow actual movement'**
  String gpsHeadingCameraCar(Object heading);

  /// No description provided for @mapsMeStyleFeatures.
  ///
  /// In en, this message translates to:
  /// **'Maps.me style features:'**
  String get mapsMeStyleFeatures;

  /// No description provided for @routeToDestination.
  ///
  /// In en, this message translates to:
  /// **'• Route to destination'**
  String get routeToDestination;

  /// No description provided for @gpsBasedNavigation.
  ///
  /// In en, this message translates to:
  /// **'• GPS-based navigation'**
  String get gpsBasedNavigation;

  /// No description provided for @cleanInterface.
  ///
  /// In en, this message translates to:
  /// **'• Clean interface'**
  String get cleanInterface;

  /// No description provided for @noDirectionControls.
  ///
  /// In en, this message translates to:
  /// **'• No direction controls'**
  String get noDirectionControls;

  /// No description provided for @focusOnRoadAhead.
  ///
  /// In en, this message translates to:
  /// **'• Focus on the road ahead'**
  String get focusOnRoadAhead;

  /// No description provided for @actualMovementTrackingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Actual phone movement tracking:'**
  String get actualMovementTrackingInstructions;

  /// No description provided for @tripStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip status updated successfully'**
  String get tripStatusSuccess;

  /// No description provided for @errorUpdatingTrip.
  ///
  /// In en, this message translates to:
  /// **'Error updating trip status'**
  String get errorUpdatingTrip;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @debugInfo.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get debugInfo;

  /// No description provided for @statusStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusStatus(Object status);

  /// No description provided for @distanceDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance} km'**
  String distanceDistance(Object distance);

  /// No description provided for @autoArrivalAutoArrival.
  ///
  /// In en, this message translates to:
  /// **'Auto-arrival within 150m'**
  String get autoArrivalAutoArrival;

  /// No description provided for @actual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// No description provided for @movement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movement;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get north;

  /// No description provided for @closeToPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Close to pickup location'**
  String get closeToPickupLocation;

  /// No description provided for @iHaveArrived.
  ///
  /// In en, this message translates to:
  /// **'I have arrived'**
  String get iHaveArrived;

  /// No description provided for @userPickedUp.
  ///
  /// In en, this message translates to:
  /// **'User picked up'**
  String get userPickedUp;

  /// No description provided for @confirmPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Confirm picked up'**
  String get confirmPickedUp;

  /// No description provided for @youHaveArrivedAtYourDestination.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination'**
  String get youHaveArrivedAtYourDestination;

  /// No description provided for @completeTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete Trip'**
  String get completeTrip;

  /// No description provided for @waitingForDriver.
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver'**
  String get waitingForDriver;

  /// No description provided for @driverAccepted.
  ///
  /// In en, this message translates to:
  /// **'Driver accepted'**
  String get driverAccepted;

  /// No description provided for @driverIsOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way'**
  String get driverIsOnTheWay;

  /// No description provided for @driverHasArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get driverHasArrived;

  /// No description provided for @youArePickedUp.
  ///
  /// In en, this message translates to:
  /// **'You are picked up'**
  String get youArePickedUp;

  /// No description provided for @onTheWayToDestination.
  ///
  /// In en, this message translates to:
  /// **'On the way to destination'**
  String get onTheWayToDestination;

  /// No description provided for @tripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get tripCompleted;

  /// No description provided for @unknownStatus.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get unknownStatus;

  /// No description provided for @mapsMeNavigation.
  ///
  /// In en, this message translates to:
  /// **'Maps.me Navigation'**
  String get mapsMeNavigation;

  /// No description provided for @mapsMeStyleNavigationInstructions.
  ///
  /// In en, this message translates to:
  /// **'Maps.me style navigation instructions:'**
  String get mapsMeStyleNavigationInstructions;

  /// No description provided for @userNavigation.
  ///
  /// In en, this message translates to:
  /// **'User Navigation'**
  String get userNavigation;

  /// No description provided for @arrivedAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Pickup'**
  String get arrivedAtPickup;

  /// No description provided for @arrivedAtDropoff.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Dropoff'**
  String get arrivedAtDropoff;

  /// No description provided for @pickupPassenger.
  ///
  /// In en, this message translates to:
  /// **'Pickup Passenger'**
  String get pickupPassenger;

  /// No description provided for @cancelTrip.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTrip;

  /// No description provided for @driverNear.
  ///
  /// In en, this message translates to:
  /// **'Driver is near!'**
  String get driverNear;

  /// No description provided for @driverApproaching.
  ///
  /// In en, this message translates to:
  /// **'Your driver is approaching your location'**
  String get driverApproaching;

  /// No description provided for @tripCancelled.
  ///
  /// In en, this message translates to:
  /// **'Trip Cancelled'**
  String get tripCancelled;

  /// No description provided for @tripInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in Progress'**
  String get tripInProgress;

  /// No description provided for @driverOnWay.
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get driverOnWay;

  /// No description provided for @driverArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver arrived'**
  String get driverArrived;

  /// No description provided for @passengerPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Passenger picked up'**
  String get passengerPickedUp;

  /// No description provided for @arrivedAtDestination.
  ///
  /// In en, this message translates to:
  /// **'Arrived at destination'**
  String get arrivedAtDestination;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// No description provided for @tripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get tripHistory;

  /// No description provided for @activeTrips.
  ///
  /// In en, this message translates to:
  /// **'Active Trips'**
  String get activeTrips;

  /// No description provided for @completedTrips.
  ///
  /// In en, this message translates to:
  /// **'Completed Trips'**
  String get completedTrips;

  /// No description provided for @cancelledTrips.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Trips'**
  String get cancelledTrips;

  /// No description provided for @noActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'No active trips'**
  String get noActiveTrips;

  /// No description provided for @noCompletedTrips.
  ///
  /// In en, this message translates to:
  /// **'No completed trips'**
  String get noCompletedTrips;

  /// No description provided for @noCancelledTrips.
  ///
  /// In en, this message translates to:
  /// **'No cancelled trips'**
  String get noCancelledTrips;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermission;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get cameraPermission;

  /// No description provided for @microphonePermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission'**
  String get microphonePermission;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Permission Granted'**
  String get permissionGranted;

  /// No description provided for @enablePermissions.
  ///
  /// In en, this message translates to:
  /// **'Please enable the required permissions in your device settings.'**
  String get enablePermissions;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkConnection;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout'**
  String get timeout;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// No description provided for @arrivalTime.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTime;

  /// No description provided for @departureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'IQD'**
  String get currency;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @statusUserWaiting.
  ///
  /// In en, this message translates to:
  /// **'User Waiting'**
  String get statusUserWaiting;

  /// No description provided for @statusDriverAccepted.
  ///
  /// In en, this message translates to:
  /// **'Driver Accepted'**
  String get statusDriverAccepted;

  /// No description provided for @statusDriverInWay.
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get statusDriverInWay;

  /// No description provided for @statusDriverArrived.
  ///
  /// In en, this message translates to:
  /// **'Driver Arrived'**
  String get statusDriverArrived;

  /// No description provided for @statusUserPickedUp.
  ///
  /// In en, this message translates to:
  /// **'User Picked Up'**
  String get statusUserPickedUp;

  /// No description provided for @statusDriverInProgress.
  ///
  /// In en, this message translates to:
  /// **'Driver in Progress'**
  String get statusDriverInProgress;

  /// No description provided for @statusDriverArrivedDropoff.
  ///
  /// In en, this message translates to:
  /// **'Driver Arrived at Dropoff'**
  String get statusDriverArrivedDropoff;

  /// No description provided for @statusTripCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed'**
  String get statusTripCompleted;

  /// No description provided for @statusTripCancelled.
  ///
  /// In en, this message translates to:
  /// **'Trip Cancelled'**
  String get statusTripCancelled;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @autoArrival.
  ///
  /// In en, this message translates to:
  /// **'Auto-arrival within 150m'**
  String get autoArrival;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @trip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// No description provided for @noTripsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No trips available'**
  String get noTripsAvailable;

  /// No description provided for @newTripsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'New trip requests will appear here automatically'**
  String get newTripsWillAppearHere;

  /// No description provided for @youWillReceiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive notifications for new trips in your province'**
  String get youWillReceiveNotifications;

  /// No description provided for @myTrips.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// No description provided for @driverId.
  ///
  /// In en, this message translates to:
  /// **'Driver ID'**
  String get driverId;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @acceptedAt.
  ///
  /// In en, this message translates to:
  /// **'Accepted At'**
  String get acceptedAt;

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed At'**
  String get completedAt;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaiting;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @driverPhone.
  ///
  /// In en, this message translates to:
  /// **'Driver Phone'**
  String get driverPhone;

  /// No description provided for @driverRating.
  ///
  /// In en, this message translates to:
  /// **'Driver Rating'**
  String get driverRating;

  /// No description provided for @cancelTripConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTripConfirmation;

  /// No description provided for @cancelTripMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this trip?'**
  String get cancelTripMessage;

  /// No description provided for @tripCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled successfully'**
  String get tripCancelledSuccessfully;

  /// No description provided for @waitingForDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver...'**
  String get waitingForDriverTitle;

  /// No description provided for @tripCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get tripCompletedTitle;

  /// No description provided for @thankYouForUsingService.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using our service'**
  String get thankYouForUsingService;

  /// No description provided for @countdownMessage.
  ///
  /// In en, this message translates to:
  /// **'Returning to home in {countdown} seconds'**
  String countdownMessage(Object countdown);

  /// No description provided for @returnToHomeNow.
  ///
  /// In en, this message translates to:
  /// **'Return to Home Now'**
  String get returnToHomeNow;

  /// No description provided for @errorCancellingTrip.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling trip: {error}'**
  String errorCancellingTrip(Object error);

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @dropoff.
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get dropoff;

  /// No description provided for @waitingTime.
  ///
  /// In en, this message translates to:
  /// **'Waiting Time'**
  String get waitingTime;

  /// No description provided for @acceptTripButton.
  ///
  /// In en, this message translates to:
  /// **'Accept Trip'**
  String get acceptTripButton;

  /// No description provided for @viewTripButton.
  ///
  /// In en, this message translates to:
  /// **'View Trip'**
  String get viewTripButton;

  /// No description provided for @errorAcceptingTrip.
  ///
  /// In en, this message translates to:
  /// **'Error accepting trip: {error}'**
  String errorAcceptingTrip(Object error);

  /// No description provided for @insufficientBudgetMessage.
  ///
  /// In en, this message translates to:
  /// **'Insufficient budget for this trip'**
  String get insufficientBudgetMessage;

  /// No description provided for @viewBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'View Budget'**
  String get viewBudgetButton;

  /// No description provided for @budgetInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Information'**
  String get budgetInformationTitle;

  /// No description provided for @currentBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Budget: {budget} IQD'**
  String currentBudgetLabel(Object amount, Object budget);

  /// No description provided for @driverNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver: {name}'**
  String driverNameLabel(Object name);

  /// No description provided for @addTestBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'Add 1000 IQD (Test)'**
  String get addTestBudgetButton;

  /// No description provided for @budgetAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Budget added: {amount} IQD'**
  String budgetAddedMessage(Object amount);

  /// No description provided for @errorAddingBudgetMessage.
  ///
  /// In en, this message translates to:
  /// **'Error adding budget: {error}'**
  String errorAddingBudgetMessage(Object error);

  /// No description provided for @budgetTestMessage.
  ///
  /// In en, this message translates to:
  /// **'Budget test: {message} - Current: {currentBudget} IQD'**
  String budgetTestMessage(Object currentBudget, Object message);

  /// No description provided for @deductionLabel.
  ///
  /// In en, this message translates to:
  /// **'Deduction (12%): {deduction} IQD'**
  String deductionLabel(Object amount, Object deduction);

  /// No description provided for @yourBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Budget:'**
  String yourBudgetLabel(Object budget);

  /// No description provided for @insufficientBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Insufficient budget'**
  String get insufficientBudgetLabel;

  /// No description provided for @viewBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'View Budget'**
  String get viewBudgetLabel;

  /// No description provided for @provinceFilteringTitle.
  ///
  /// In en, this message translates to:
  /// **'Province Filtering'**
  String get provinceFilteringTitle;

  /// No description provided for @newTripRequestsWillAppearMessage.
  ///
  /// In en, this message translates to:
  /// **'New trip requests will appear here automatically'**
  String get newTripRequestsWillAppearMessage;

  /// No description provided for @youWillReceiveNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive notifications for new trips in your province'**
  String get youWillReceiveNotificationsMessage;

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @loadingTripInformationMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading trip information...'**
  String get loadingTripInformationMessage;

  /// No description provided for @myTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTripsTitle;

  /// No description provided for @tripNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip #{id}'**
  String tripNumberLabel(Object id);

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @driverIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver ID'**
  String get driverIdLabel;

  /// No description provided for @userIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userIdLabel;

  /// No description provided for @provinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get provinceLabel;

  /// No description provided for @acceptedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Accepted At'**
  String get acceptedAtLabel;

  /// No description provided for @completedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed At'**
  String get completedAtLabel;

  /// No description provided for @statusCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompletedLabel;

  /// No description provided for @statusCancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelledLabel;

  /// No description provided for @statusInProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgressLabel;

  /// No description provided for @statusAcceptedLabel.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAcceptedLabel;

  /// No description provided for @statusWaitingLabel.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaitingLabel;

  /// No description provided for @driverLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver: {driverName}'**
  String driverLabel(Object driverName);

  /// No description provided for @driverPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver Phone'**
  String get driverPhoneLabel;

  /// No description provided for @driverRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver Rating'**
  String get driverRatingLabel;

  /// No description provided for @cancelTripConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTripConfirmationTitle;

  /// No description provided for @cancelTripMessageText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this trip?'**
  String get cancelTripMessageText;

  /// No description provided for @tripCancelledSuccessfullyMessage.
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled successfully'**
  String get tripCancelledSuccessfullyMessage;

  /// No description provided for @errorLoadingTripDetailsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading trip details: {error}'**
  String errorLoadingTripDetailsMessage(Object error);

  /// No description provided for @invalidCoordinatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinates in trip data. Please contact support.'**
  String get invalidCoordinatesMessage;

  /// No description provided for @accountNotActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is not active. Please contact support.'**
  String get accountNotActiveMessage;

  /// No description provided for @invalidCoordinatesErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid coordinates in trip data. Please contact support.'**
  String get invalidCoordinatesErrorMessage;

  /// No description provided for @driverProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile'**
  String get driverProfileTitle;

  /// No description provided for @userProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfileTitle;

  /// No description provided for @carInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Car Information'**
  String get carInformationTitle;

  /// No description provided for @accountInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformationTitle;

  /// No description provided for @personalInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformationTitle;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountTypeLabel;

  /// No description provided for @memberSinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSinceLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @accountStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get accountStatusLabel;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current: {flag} {language}'**
  String currentLanguage(Object flag, Object language);

  /// No description provided for @tapLanguageToChangeMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap a language to change the app language'**
  String get tapLanguageToChangeMessage;

  /// No description provided for @languageChangedToMessage.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedToMessage(Object language);

  /// No description provided for @languageChangedRestartMessage.
  ///
  /// In en, this message translates to:
  /// **'Language changed! Please restart the app for full effect.'**
  String get languageChangedRestartMessage;

  /// No description provided for @searchLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocationTitle;

  /// No description provided for @pickupLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocationLabel;

  /// No description provided for @dropoffLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Dropoff Location'**
  String get dropoffLocationLabel;

  /// No description provided for @errorGettingLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Error getting location: {error}'**
  String errorGettingLocationMessage(Object error);

  /// No description provided for @errorSearchingLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Error searching location: {error}'**
  String errorSearchingLocationMessage(Object error);

  /// No description provided for @pleaseSelectPickupDropoffMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select pickup and dropoff locations'**
  String get pleaseSelectPickupDropoffMessage;

  /// No description provided for @pleaseEnterBothAddressesMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter both pickup and dropoff addresses'**
  String get pleaseEnterBothAddressesMessage;

  /// No description provided for @yourAccountNotActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is not active. Please contact support.'**
  String get yourAccountNotActiveMessage;

  /// No description provided for @createTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Trip'**
  String get createTripTitle;

  /// No description provided for @distanceKmLabel.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKmLabel(Object distance);

  /// No description provided for @estimatedPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Price: {price} IQD'**
  String estimatedPriceLabel(Object price);

  /// No description provided for @confirmTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Trip'**
  String get confirmTripTitle;

  /// No description provided for @tripCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Trip created successfully!'**
  String get tripCreatedMessage;

  /// No description provided for @errorCreatingTripMessage.
  ///
  /// In en, this message translates to:
  /// **'Error creating trip: {error}'**
  String errorCreatingTripMessage(Object error);

  /// No description provided for @driverNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Navigation'**
  String get driverNavigationTitle;

  /// No description provided for @mapsMeStyleNavigationMessage.
  ///
  /// In en, this message translates to:
  /// **'Maps.me style navigation - route to destination'**
  String get mapsMeStyleNavigationMessage;

  /// No description provided for @actualMovementTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Actual Movement Test'**
  String get actualMovementTestTitle;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @mapsMeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Maps.me Info'**
  String get mapsMeInfoTitle;

  /// No description provided for @actualPhoneMovementTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Actual phone movement tracking:'**
  String get actualPhoneMovementTrackingTitle;

  /// No description provided for @movePhoneLeftMessage.
  ///
  /// In en, this message translates to:
  /// **'1. Move phone LEFT → Camera and car follow LEFT'**
  String get movePhoneLeftMessage;

  /// No description provided for @movePhoneRightMessage.
  ///
  /// In en, this message translates to:
  /// **'2. Move phone RIGHT → Camera and car follow RIGHT'**
  String get movePhoneRightMessage;

  /// No description provided for @bothFollowActualMovementMessage.
  ///
  /// In en, this message translates to:
  /// **'3. Both follow actual movement direction'**
  String get bothFollowActualMovementMessage;

  /// No description provided for @gpsBasedMovementTrackingMessage.
  ///
  /// In en, this message translates to:
  /// **'4. GPS-based movement tracking'**
  String get gpsBasedMovementTrackingMessage;

  /// No description provided for @realTimeMovementFollowingMessage.
  ///
  /// In en, this message translates to:
  /// **'5. Real-time movement following'**
  String get realTimeMovementFollowingMessage;

  /// No description provided for @gpsHeadingCameraCarMessage.
  ///
  /// In en, this message translates to:
  /// **'GPS heading: {heading}°\nCamera & car follow actual movement'**
  String gpsHeadingCameraCarMessage(Object heading);

  /// No description provided for @mapsMeStyleFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Maps.me style features:'**
  String get mapsMeStyleFeaturesTitle;

  /// No description provided for @routeToDestinationMessage.
  ///
  /// In en, this message translates to:
  /// **'• Route to destination'**
  String get routeToDestinationMessage;

  /// No description provided for @gpsBasedNavigationMessage.
  ///
  /// In en, this message translates to:
  /// **'• GPS-based navigation'**
  String get gpsBasedNavigationMessage;

  /// No description provided for @cleanInterfaceMessage.
  ///
  /// In en, this message translates to:
  /// **'• Clean interface'**
  String get cleanInterfaceMessage;

  /// No description provided for @noDirectionControlsMessage.
  ///
  /// In en, this message translates to:
  /// **'• No direction controls'**
  String get noDirectionControlsMessage;

  /// No description provided for @focusOnRoadAheadMessage.
  ///
  /// In en, this message translates to:
  /// **'• Focus on the road ahead'**
  String get focusOnRoadAheadMessage;

  /// No description provided for @actualMovementTrackingInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actual phone movement tracking:'**
  String get actualMovementTrackingInstructionsTitle;

  /// No description provided for @tripStatusSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Trip status updated successfully'**
  String get tripStatusSuccessMessage;

  /// No description provided for @errorUpdatingTripMessage.
  ///
  /// In en, this message translates to:
  /// **'Error updating trip status'**
  String get errorUpdatingTripMessage;

  /// No description provided for @speedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speedLabel;

  /// No description provided for @debugInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get debugInfoTitle;

  /// No description provided for @statusStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusStatusLabel(Object status);

  /// No description provided for @distanceDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance} km'**
  String distanceDistanceLabel(Object distance);

  /// No description provided for @autoArrivalAutoArrivalLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-arrival within 150m'**
  String get autoArrivalAutoArrivalLabel;

  /// No description provided for @actualLabel.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actualLabel;

  /// No description provided for @movementLabel.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movementLabel;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButton;

  /// No description provided for @northLabel.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get northLabel;

  /// No description provided for @closeToPickupLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Close to pickup location'**
  String get closeToPickupLocationMessage;

  /// No description provided for @iHaveArrivedButton.
  ///
  /// In en, this message translates to:
  /// **'I have arrived'**
  String get iHaveArrivedButton;

  /// No description provided for @userPickedUpButton.
  ///
  /// In en, this message translates to:
  /// **'User Picked Up'**
  String get userPickedUpButton;

  /// No description provided for @confirmPickedUpButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm picked up'**
  String get confirmPickedUpButton;

  /// No description provided for @youHaveArrivedAtYourDestinationMessage.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination'**
  String get youHaveArrivedAtYourDestinationMessage;

  /// No description provided for @completeTripButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Trip'**
  String get completeTripButton;

  /// No description provided for @waitingForDriverMessage.
  ///
  /// In en, this message translates to:
  /// **'Waiting for driver'**
  String get waitingForDriverMessage;

  /// No description provided for @driverAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver accepted'**
  String get driverAcceptedMessage;

  /// No description provided for @driverIsOnTheWayMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way'**
  String get driverIsOnTheWayMessage;

  /// No description provided for @driverHasArrivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver has arrived'**
  String get driverHasArrivedMessage;

  /// No description provided for @youArePickedUpMessage.
  ///
  /// In en, this message translates to:
  /// **'You are picked up'**
  String get youArePickedUpMessage;

  /// No description provided for @onTheWayToDestinationMessage.
  ///
  /// In en, this message translates to:
  /// **'On the way to destination'**
  String get onTheWayToDestinationMessage;

  /// No description provided for @tripCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get tripCompletedMessage;

  /// No description provided for @unknownStatusMessage.
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get unknownStatusMessage;

  /// No description provided for @mapsMeNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Maps.me Navigation'**
  String get mapsMeNavigationTitle;

  /// No description provided for @mapsMeStyleNavigationInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Maps.me style navigation instructions:'**
  String get mapsMeStyleNavigationInstructionsTitle;

  /// No description provided for @userNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'User Navigation'**
  String get userNavigationTitle;

  /// No description provided for @arrivedAtPickupMessage.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Pickup'**
  String get arrivedAtPickupMessage;

  /// No description provided for @arrivedAtDropoffMessage.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Dropoff'**
  String get arrivedAtDropoffMessage;

  /// No description provided for @pickupPassengerButton.
  ///
  /// In en, this message translates to:
  /// **'Pickup Passenger'**
  String get pickupPassengerButton;

  /// No description provided for @cancelTripButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTripButton;

  /// No description provided for @driverNearMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver is near!'**
  String get driverNearMessage;

  /// No description provided for @driverApproachingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your driver is approaching your location'**
  String get driverApproachingMessage;

  /// No description provided for @tripCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Trip Cancelled'**
  String get tripCancelledMessage;

  /// No description provided for @tripInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Trip in Progress'**
  String get tripInProgressMessage;

  /// No description provided for @driverOnWayMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get driverOnWayMessage;

  /// No description provided for @driverArrivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver arrived'**
  String get driverArrivedMessage;

  /// No description provided for @passengerPickedUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Passenger picked up'**
  String get passengerPickedUpMessage;

  /// No description provided for @arrivedAtDestinationMessage.
  ///
  /// In en, this message translates to:
  /// **'Arrived at destination'**
  String get arrivedAtDestinationMessage;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotificationsMessage;

  /// No description provided for @markAllReadButton.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllReadButton;

  /// No description provided for @clearAllButton.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllButton;

  /// No description provided for @tripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tripsTitle;

  /// No description provided for @tripHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get tripHistoryTitle;

  /// No description provided for @activeTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Trips'**
  String get activeTripsTitle;

  /// No description provided for @completedTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed Trips'**
  String get completedTripsTitle;

  /// No description provided for @cancelledTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Trips'**
  String get cancelledTripsTitle;

  /// No description provided for @noActiveTripsMessage.
  ///
  /// In en, this message translates to:
  /// **'No active trips'**
  String get noActiveTripsMessage;

  /// No description provided for @noCompletedTripsMessage.
  ///
  /// In en, this message translates to:
  /// **'No completed trips'**
  String get noCompletedTripsMessage;

  /// No description provided for @noCancelledTripsMessage.
  ///
  /// In en, this message translates to:
  /// **'No cancelled trips'**
  String get noCancelledTripsMessage;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @yesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesButton;

  /// No description provided for @noButton.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @previousButton.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @loadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get infoTitle;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermissionTitle;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermissionTitle;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get cameraPermissionTitle;

  /// No description provided for @microphonePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission'**
  String get microphonePermissionTitle;

  /// No description provided for @permissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequiredTitle;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDeniedMessage;

  /// No description provided for @permissionGrantedMessage.
  ///
  /// In en, this message translates to:
  /// **'Permission Granted'**
  String get permissionGrantedMessage;

  /// No description provided for @enablePermissionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enable the required permissions in your device settings.'**
  String get enablePermissionsMessage;

  /// No description provided for @networkTitle.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkTitle;

  /// No description provided for @noInternetConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnectionMessage;

  /// No description provided for @checkConnectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkConnectionMessage;

  /// No description provided for @serverErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverErrorMessage;

  /// No description provided for @timeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Request timeout'**
  String get timeoutMessage;

  /// No description provided for @connectionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionErrorMessage;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @currentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocationLabel;

  /// No description provided for @destinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destinationLabel;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @directionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsLabel;

  /// No description provided for @navigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigationTitle;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @coordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinatesLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @estimatedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTimeLabel;

  /// No description provided for @arrivalTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTimeLabel;

  /// No description provided for @departureTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTimeLabel;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'IQD'**
  String get currencyLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotalLabel;

  /// No description provided for @taxLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxLabel;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discountLabel;

  /// No description provided for @feeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get feeLabel;

  /// No description provided for @costLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get costLabel;

  /// No description provided for @fareLabel.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fareLabel;

  /// No description provided for @tripStartedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Trip started successfully!'**
  String get tripStartedSuccessfully;

  /// No description provided for @errorStartingTrip.
  ///
  /// In en, this message translates to:
  /// **'Error starting trip: {error}'**
  String errorStartingTrip(Object error);

  /// No description provided for @tripAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Accepted'**
  String get tripAcceptedTitle;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @startTripButton.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get startTripButton;

  /// No description provided for @errorGettingCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting current location'**
  String get errorGettingCurrentLocation;

  /// No description provided for @errorGettingRoute.
  ///
  /// In en, this message translates to:
  /// **'Error getting route'**
  String get errorGettingRoute;

  /// No description provided for @pleaseSelectPickupAndDropoffLocations.
  ///
  /// In en, this message translates to:
  /// **'Please select pickup and dropoff locations'**
  String get pleaseSelectPickupAndDropoffLocations;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @youAlreadyHaveAnActiveTripPleaseWaitForItToBeCompletedOrCancelled.
  ///
  /// In en, this message translates to:
  /// **'You already have an active trip. Please wait for it to be completed or cancelled.'**
  String get youAlreadyHaveAnActiveTripPleaseWaitForItToBeCompletedOrCancelled;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @baghdad.
  ///
  /// In en, this message translates to:
  /// **'Baghdad'**
  String get baghdad;

  /// No description provided for @userProfileIsIncompletePleaseUpdateYourProfileWithNameAndPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'User profile is incomplete. Please update your profile with name and phone number.'**
  String get userProfileIsIncompletePleaseUpdateYourProfileWithNameAndPhoneNumber;

  /// No description provided for @notifyingAvailableDrivers.
  ///
  /// In en, this message translates to:
  /// **'Notifying available drivers...'**
  String get notifyingAvailableDrivers;

  /// No description provided for @failedToGetPredictions.
  ///
  /// In en, this message translates to:
  /// **'Failed to get predictions'**
  String get failedToGetPredictions;

  /// No description provided for @locationIsTooFarFromYourCurrentPositionPleaseSearchForACloserLocation.
  ///
  /// In en, this message translates to:
  /// **'Location is too far from your current position. Please search for a closer location.'**
  String get locationIsTooFarFromYourCurrentPositionPleaseSearchForACloserLocation;

  /// No description provided for @useAnyway.
  ///
  /// In en, this message translates to:
  /// **'Use Anyway'**
  String get useAnyway;

  /// No description provided for @failedToGetPlaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to get place details'**
  String get failedToGetPlaceDetails;

  /// No description provided for @errorGettingPlaceDetails.
  ///
  /// In en, this message translates to:
  /// **'Error getting place details'**
  String get errorGettingPlaceDetails;

  /// No description provided for @destinationSetTo.
  ///
  /// In en, this message translates to:
  /// **'Destination set to:'**
  String get destinationSetTo;

  /// No description provided for @creatingTrip.
  ///
  /// In en, this message translates to:
  /// **'Creating Trip...'**
  String get creatingTrip;

  /// No description provided for @bookTrip.
  ///
  /// In en, this message translates to:
  /// **'Book Trip'**
  String get bookTrip;

  /// No description provided for @changeTrip.
  ///
  /// In en, this message translates to:
  /// **'Change Trip'**
  String get changeTrip;

  /// No description provided for @selectLocations.
  ///
  /// In en, this message translates to:
  /// **'Select Locations'**
  String get selectLocations;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// No description provided for @searchForDestination.
  ///
  /// In en, this message translates to:
  /// **'Search for destination...'**
  String get searchForDestination;

  /// No description provided for @tapToSetAsDestination.
  ///
  /// In en, this message translates to:
  /// **'Tap to set as destination'**
  String get tapToSetAsDestination;

  /// No description provided for @searchForDestinationsWithin50kmOfYourCurrentPosition.
  ///
  /// In en, this message translates to:
  /// **'Search for destinations within 50km of your current position'**
  String get searchForDestinationsWithin50kmOfYourCurrentPosition;

  /// No description provided for @notificationNewTripAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Trip Available!'**
  String get notificationNewTripAvailable;

  /// No description provided for @notificationNewTripMessage.
  ///
  /// In en, this message translates to:
  /// **'A new trip request is available in {province}. Tap to view details.'**
  String notificationNewTripMessage(Object province);

  /// No description provided for @notificationDriverAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Accepted Your Trip!'**
  String get notificationDriverAcceptedTitle;

  /// No description provided for @notificationDriverAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'A driver has accepted your trip request. They will be on their way soon.'**
  String get notificationDriverAcceptedMessage;

  /// No description provided for @notificationDriverInWayTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the Way!'**
  String get notificationDriverInWayTitle;

  /// No description provided for @notificationDriverInWayMessage.
  ///
  /// In en, this message translates to:
  /// **'Your driver is heading to your pickup location.'**
  String get notificationDriverInWayMessage;

  /// No description provided for @notificationDriverArrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Has Arrived!'**
  String get notificationDriverArrivedTitle;

  /// No description provided for @notificationDriverArrivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your driver has arrived at the pickup location.'**
  String get notificationDriverArrivedMessage;

  /// No description provided for @notificationUserPickedUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Started!'**
  String get notificationUserPickedUpTitle;

  /// No description provided for @notificationUserPickedUpMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been picked up. Enjoy your ride!'**
  String get notificationUserPickedUpMessage;

  /// No description provided for @notificationTripCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed!'**
  String get notificationTripCompletedTitle;

  /// No description provided for @notificationTripCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your trip has been completed successfully. Thank you for using our service!'**
  String get notificationTripCompletedMessage;

  /// No description provided for @notificationTripCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Cancelled'**
  String get notificationTripCancelledTitle;

  /// No description provided for @notificationTripCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your trip has been cancelled.'**
  String get notificationTripCancelledMessage;

  /// No description provided for @notificationTripInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip in Progress'**
  String get notificationTripInProgressTitle;

  /// No description provided for @notificationTripInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Your trip is currently in progress.'**
  String get notificationTripInProgressMessage;

  /// No description provided for @notificationDriverArrivedDropoffTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Destination'**
  String get notificationDriverArrivedDropoffTitle;

  /// No description provided for @notificationDriverArrivedDropoffMessage.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination.'**
  String get notificationDriverArrivedDropoffMessage;

  /// No description provided for @notificationDriverInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'On the Way to Destination'**
  String get notificationDriverInProgressTitle;

  /// No description provided for @notificationDriverInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Your driver is taking you to your destination.'**
  String get notificationDriverInProgressMessage;

  /// No description provided for @tripDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetailsTitle;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @insufficientBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Budget'**
  String get insufficientBudgetButton;

  /// No description provided for @tripAcceptedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Trip accepted successfully!'**
  String get tripAcceptedSuccessfully;

  /// No description provided for @tripPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip Price: {price} IQD'**
  String tripPriceLabel(Object price);

  /// No description provided for @canAffordTripMessage.
  ///
  /// In en, this message translates to:
  /// **'You can afford this trip'**
  String get canAffordTripMessage;

  /// No description provided for @deductionPercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Deduction (12%):'**
  String get deductionPercentLabel;

  /// No description provided for @canAffordThisTripMessage.
  ///
  /// In en, this message translates to:
  /// **'Can afford this trip'**
  String get canAffordThisTripMessage;

  /// No description provided for @insufficientBudgetShortMessage.
  ///
  /// In en, this message translates to:
  /// **'Insufficient budget'**
  String get insufficientBudgetShortMessage;

  /// No description provided for @pickupPassengerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick up Passenger'**
  String get pickupPassengerTitle;

  /// No description provided for @yourLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocationLabel;

  /// No description provided for @pickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickupLabel;

  /// No description provided for @dropoffLabel.
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get dropoffLabel;

  /// No description provided for @passengerPickedUpSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Passenger picked up successfully!'**
  String get passengerPickedUpSuccessfully;

  /// No description provided for @errorDuringPickup.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorDuringPickup(Object error);

  /// No description provided for @createNewTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Trip'**
  String get createNewTripTitle;

  /// No description provided for @selectLocationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Locations'**
  String get selectLocationsTitle;

  /// No description provided for @searchForDestinationsWithin50km.
  ///
  /// In en, this message translates to:
  /// **'Search for destinations within 50km of your current position'**
  String get searchForDestinationsWithin50km;

  /// No description provided for @selectedLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocationLabel;

  /// No description provided for @searchLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Search Location'**
  String get searchLocationButton;

  /// No description provided for @changeTripButton.
  ///
  /// In en, this message translates to:
  /// **'Change Trip'**
  String get changeTripButton;

  /// No description provided for @bookTripButton.
  ///
  /// In en, this message translates to:
  /// **'Book Trip'**
  String get bookTripButton;

  /// No description provided for @creatingTripMessage.
  ///
  /// In en, this message translates to:
  /// **'Creating Trip...'**
  String get creatingTripMessage;

  /// No description provided for @youAlreadyHaveAnActiveTrip.
  ///
  /// In en, this message translates to:
  /// **'You already have an active trip. Please wait for it to be completed or cancelled.'**
  String get youAlreadyHaveAnActiveTrip;

  /// No description provided for @userProfileIsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'User profile is incomplete. Please update your profile with name and phone number.'**
  String get userProfileIsIncomplete;

  /// No description provided for @locationIsTooFar.
  ///
  /// In en, this message translates to:
  /// **'Location is too far from your current position. Please search for a closer location.'**
  String get locationIsTooFar;

  /// No description provided for @useAnywayButton.
  ///
  /// In en, this message translates to:
  /// **'Use Anyway'**
  String get useAnywayButton;

  /// No description provided for @tripInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip in Progress'**
  String get tripInProgressTitle;

  /// No description provided for @driverLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver Location'**
  String get driverLocationLabel;

  /// No description provided for @driverIsHereMessage.
  ///
  /// In en, this message translates to:
  /// **'Your driver is here'**
  String get driverIsHereMessage;

  /// No description provided for @driverIsNearMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver is near!'**
  String get driverIsNearMessage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'ku', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'ku': return AppLocalizationsKu();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
