// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Waddiny';

  @override
  String get appSubtitle => 'Smart Transportation Service';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get chooseRegistrationType => 'Choose Registration Type';

  @override
  String get registerAsUser => 'Register as User';

  @override
  String get registerAsDriver => 'Register as Driver';

  @override
  String get carId => 'Car ID';

  @override
  String get carType => 'Car Type';

  @override
  String get licenseId => 'License ID';

  @override
  String get pleaseEnterCarId => 'Please enter your car ID';

  @override
  String get pleaseEnterCarType => 'Please enter your car type';

  @override
  String get pleaseEnterLicenseId => 'Please enter your license ID';

  @override
  String get verifyPhoneNumber => 'Verify Phone Number';

  @override
  String enterOtpSentTo(Object phoneNumber) {
    return 'Enter the OTP sent to $phoneNumber';
  }

  @override
  String get otp => 'OTP';

  @override
  String get pleaseEnterOtp => 'Please enter the OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get home => 'Home';

  @override
  String welcomeUser(Object name) {
    return 'Welcome, $name!';
  }

  @override
  String get whereWouldYouLikeToGo => 'Where would you like to go?';

  @override
  String get createNewTrip => 'Create New Trip';

  @override
  String get recentTrips => 'Recent Trips';

  @override
  String get noTripsYet => 'No trips yet';

  @override
  String errorLoadingTrips(Object error) {
    return 'Error loading trips: $error';
  }

  @override
  String tripTo(Object location) {
    return 'Trip to $location';
  }

  @override
  String get from => 'From';

  @override
  String get accountStatus => 'Status';

  @override
  String get price => 'Price';

  @override
  String get waitingTrips => 'Waiting Trips';

  @override
  String get noWaitingTrips => 'No waiting trips';

  @override
  String get newTripsAvailable => 'New Trips Available!';

  @override
  String newTripsWaiting(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count new trip$_temp0 waiting for you';
  }

  @override
  String newTripAvailable(Object message) {
    return 'New trip available: $message';
  }

  @override
  String get checkListBelow => 'Check the list below';

  @override
  String get generalNotification => 'General notification received, refreshing trips...';

  @override
  String notificationTapped(Object data) {
    return 'Notification tapped (background): $data';
  }

  @override
  String appLaunchedFromNotification(Object data) {
    return 'App launched from notification: $data';
  }

  @override
  String get noInitialMessage => 'No initial message found';

  @override
  String errorGettingInitialMessage(Object error) {
    return 'Error getting initial message: $error';
  }

  @override
  String get notificationTriggeredTripRefresh => 'Notification-triggered trip refresh...';

  @override
  String tripListUpdated(Object count) {
    return 'Trip list updated with $count waiting trips';
  }

  @override
  String errorInNotificationTripRefresh(Object error) {
    return 'Error in notification-triggered trip refresh: $error';
  }

  @override
  String get networkError => 'Network error. Tap to retry.';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get loadingTripInformation => 'Loading trip information...';

  @override
  String errorLoadingData(Object error) {
    return 'Error loading data: $error';
  }

  @override
  String get requestTimeout => 'Request timeout - please check your internet connection';

  @override
  String errorCheckingUserStatus(Object error) {
    return 'Error checking user status: $error';
  }

  @override
  String errorLoadingDriverBudget(Object error) {
    return 'Error loading driver budget: $error';
  }

  @override
  String errorLoadingCarInfo(Object error) {
    return 'Error loading car info: $error';
  }

  @override
  String errorLoggingOut(Object error) {
    return 'Error logging out: $error';
  }

  @override
  String errorLoadingProfile(Object error) {
    return 'Error loading profile: $error';
  }

  @override
  String errorLoadingUserData(Object error) {
    return 'Error loading user data: $error';
  }

  @override
  String get noUserDataFound => 'No user data found';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get budget => 'Budget';

  @override
  String get testBudget => 'Test Budget';

  @override
  String get budgetInformation => 'Budget Information';

  @override
  String currentBudget(Object amount) {
    return 'Current Budget: $amount IQD';
  }

  @override
  String driverName(Object name) {
    return 'Driver: $name';
  }

  @override
  String get budgetDeductionNote => 'Note: 12% of trip price is deducted when accepting a trip.';

  @override
  String get addTestBudget => 'Add 1000 IQD (Test)';

  @override
  String budgetAdded(Object amount) {
    return 'Budget added: $amount IQD';
  }

  @override
  String errorAddingBudget(Object error) {
    return 'Error adding budget: $error';
  }

  @override
  String budgetTest(Object currentBudget, Object message) {
    return 'Budget test: $message - Current: $currentBudget IQD';
  }

  @override
  String budgetTestError(Object error) {
    return 'Budget test error: $error';
  }

  @override
  String deduction(Object amount) {
    return 'Deduction: $amount IQD (12%)';
  }

  @override
  String yourBudget(Object budget) {
    return 'Your budget: $budget IQD';
  }

  @override
  String get insufficientBudget => 'Insufficient budget';

  @override
  String get viewBudget => 'View Budget';

  @override
  String get provinceFiltering => 'Province Filtering';

  @override
  String get provinceFilteringDescription => 'You only see trips from users in the same province as you. This ensures better service quality and faster response times.';

  @override
  String get newTripRequestsWillAppear => 'New trip requests will appear here automatically';

  @override
  String get youllReceiveNotifications => 'You\'ll receive notifications for new trips in your province';

  @override
  String get tripDetails => 'Trip Details';

  @override
  String get acceptTrip => 'Accept Trip';

  @override
  String get viewTrip => 'View Trip';

  @override
  String tripNumber(Object id) {
    return 'Trip #$id';
  }

  @override
  String get to => 'To';

  @override
  String get distance => 'Distance';

  @override
  String get user => 'User';

  @override
  String get phone => 'Phone';

  @override
  String errorLoadingTripDetails(Object error) {
    return 'Error loading trip details: $error';
  }

  @override
  String get invalidCoordinatesInTripData => 'Invalid coordinates in trip data. Please contact support.';

  @override
  String get accountNotActive => 'Your account is not active. Please contact support.';

  @override
  String get invalidCoordinates => 'Invalid coordinates in trip data. Please contact support.';

  @override
  String get driverProfile => 'Driver Profile';

  @override
  String get userProfile => 'User Profile';

  @override
  String get carInformation => 'Car Information';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get accountType => 'Account Type';

  @override
  String get memberSince => 'Member Since';

  @override
  String get rating => 'Rating';

  @override
  String get province => 'Province';

  @override
  String get language => 'Language';

  @override
  String current(Object flag, Object language) {
    return 'Current: $flag $language';
  }

  @override
  String get tapLanguageToChange => 'Tap a language to change the app language';

  @override
  String languageChangedTo(Object language) {
    return 'Language changed to $language';
  }

  @override
  String get languageChangedRestart => 'Language changed! Please restart the app for full effect.';

  @override
  String get searchLocation => 'Search Location';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get dropoffLocation => 'Dropoff Location';

  @override
  String errorGettingLocation(Object error) {
    return 'Error getting location: $error';
  }

  @override
  String errorSearchingLocation(Object error) {
    return 'Error searching location: $error';
  }

  @override
  String get pleaseSelectPickupDropoff => 'Please select pickup and dropoff locations';

  @override
  String get pleaseEnterBothAddresses => 'Please enter both pickup and dropoff addresses';

  @override
  String get yourAccountNotActive => 'Your account is not active. Please contact support.';

  @override
  String get createTrip => 'Create Trip';

  @override
  String distanceKm(Object distance) {
    return '$distance km';
  }

  @override
  String estimatedPrice(Object price) {
    return 'Estimated Price: $price IQD';
  }

  @override
  String get confirmTrip => 'Confirm Trip';

  @override
  String get tripCreated => 'Trip created successfully!';

  @override
  String errorCreatingTrip(Object error) {
    return 'Error creating trip: $error';
  }

  @override
  String get driverNavigation => 'Driver Navigation';

  @override
  String get mapsMeStyleNavigation => 'Maps.me style navigation - route to destination';

  @override
  String get actualMovementTest => 'Actual Movement Test';

  @override
  String get ok => 'OK';

  @override
  String get mapsMeInfo => 'Maps.me Info';

  @override
  String get actualPhoneMovementTracking => 'Actual phone movement tracking:';

  @override
  String get movePhoneLeft => '1. Move phone LEFT → Camera and car follow LEFT';

  @override
  String get movePhoneRight => '2. Move phone RIGHT → Camera and car follow RIGHT';

  @override
  String get bothFollowActualMovement => '3. Both follow actual movement direction';

  @override
  String get gpsBasedMovementTracking => '4. GPS-based movement tracking';

  @override
  String get realTimeMovementFollowing => '5. Real-time movement following';

  @override
  String gpsHeadingCameraCar(Object heading) {
    return 'GPS heading: $heading°\nCamera & car follow actual movement';
  }

  @override
  String get mapsMeStyleFeatures => 'Maps.me style features:';

  @override
  String get routeToDestination => '• Route to destination';

  @override
  String get gpsBasedNavigation => '• GPS-based navigation';

  @override
  String get cleanInterface => '• Clean interface';

  @override
  String get noDirectionControls => '• No direction controls';

  @override
  String get focusOnRoadAhead => '• Focus on the road ahead';

  @override
  String get actualMovementTrackingInstructions => 'Actual phone movement tracking:';

  @override
  String get tripStatusSuccess => 'Trip status updated successfully';

  @override
  String get errorUpdatingTrip => 'Error updating trip status';

  @override
  String get speed => 'Speed';

  @override
  String get debugInfo => 'Debug Info';

  @override
  String statusStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String distanceDistance(Object distance) {
    return 'Distance: $distance km';
  }

  @override
  String get autoArrivalAutoArrival => 'Auto-arrival within 150m';

  @override
  String get actual => 'Actual';

  @override
  String get movement => 'Movement';

  @override
  String get reset => 'Reset';

  @override
  String get north => 'North';

  @override
  String get closeToPickupLocation => 'Close to pickup location';

  @override
  String get iHaveArrived => 'I have arrived';

  @override
  String get userPickedUp => 'User picked up';

  @override
  String get confirmPickedUp => 'Confirm picked up';

  @override
  String get youHaveArrivedAtYourDestination => 'You have arrived at your destination';

  @override
  String get completeTrip => 'Complete Trip';

  @override
  String get waitingForDriver => 'Waiting for driver';

  @override
  String get driverAccepted => 'Driver accepted';

  @override
  String get driverIsOnTheWay => 'Driver is on the way';

  @override
  String get driverHasArrived => 'Driver has arrived';

  @override
  String get youArePickedUp => 'You are picked up';

  @override
  String get onTheWayToDestination => 'On the way to destination';

  @override
  String get tripCompleted => 'Trip completed';

  @override
  String get unknownStatus => 'Unknown status';

  @override
  String get mapsMeNavigation => 'Maps.me Navigation';

  @override
  String get mapsMeStyleNavigationInstructions => 'Maps.me style navigation instructions:';

  @override
  String get userNavigation => 'User Navigation';

  @override
  String get arrivedAtPickup => 'Arrived at Pickup';

  @override
  String get arrivedAtDropoff => 'Arrived at Dropoff';

  @override
  String get pickupPassenger => 'Pickup Passenger';

  @override
  String get cancelTrip => 'Cancel Trip';

  @override
  String get driverNear => 'Driver is near!';

  @override
  String get driverApproaching => 'Your driver is approaching your location';

  @override
  String get tripCancelled => 'Trip Cancelled';

  @override
  String get tripInProgress => 'Trip in Progress';

  @override
  String get driverOnWay => 'Driver on the way';

  @override
  String get driverArrived => 'Driver arrived';

  @override
  String get passengerPickedUp => 'Passenger picked up';

  @override
  String get arrivedAtDestination => 'Arrived at destination';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get clearAll => 'Clear all';

  @override
  String get trips => 'Trips';

  @override
  String get tripHistory => 'Trip History';

  @override
  String get activeTrips => 'Active Trips';

  @override
  String get completedTrips => 'Completed Trips';

  @override
  String get cancelledTrips => 'Cancelled Trips';

  @override
  String get noActiveTrips => 'No active trips';

  @override
  String get noCompletedTrips => 'No completed trips';

  @override
  String get noCancelledTrips => 'No cancelled trips';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get support => 'Support';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get permissions => 'Permissions';

  @override
  String get locationPermission => 'Location Permission';

  @override
  String get notificationPermission => 'Notification Permission';

  @override
  String get cameraPermission => 'Camera Permission';

  @override
  String get microphonePermission => 'Microphone Permission';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get permissionGranted => 'Permission Granted';

  @override
  String get enablePermissions => 'Please enable the required permissions in your device settings.';

  @override
  String get network => 'Network';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get checkConnection => 'Please check your internet connection and try again.';

  @override
  String get serverError => 'Server error';

  @override
  String get timeout => 'Request timeout';

  @override
  String get connectionError => 'Connection error';

  @override
  String get map => 'Map';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get destination => 'Destination';

  @override
  String get route => 'Route';

  @override
  String get directions => 'Directions';

  @override
  String get navigation => 'Navigation';

  @override
  String get location => 'Location';

  @override
  String get address => 'Address';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get time => 'Time';

  @override
  String get date => 'Date';

  @override
  String get duration => 'Duration';

  @override
  String get estimatedTime => 'Estimated Time';

  @override
  String get arrivalTime => 'Arrival Time';

  @override
  String get departureTime => 'Departure Time';

  @override
  String get currency => 'IQD';

  @override
  String get amount => 'Amount';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tax => 'Tax';

  @override
  String get discount => 'Discount';

  @override
  String get fee => 'Fee';

  @override
  String get cost => 'Cost';

  @override
  String get fare => 'Fare';

  @override
  String get statusUserWaiting => 'User Waiting';

  @override
  String get statusDriverAccepted => 'Driver Accepted';

  @override
  String get statusDriverInWay => 'Driver on the way';

  @override
  String get statusDriverArrived => 'Driver Arrived';

  @override
  String get statusUserPickedUp => 'User Picked Up';

  @override
  String get statusDriverInProgress => 'Driver in Progress';

  @override
  String get statusDriverArrivedDropoff => 'Driver Arrived at Dropoff';

  @override
  String get statusTripCompleted => 'Trip Completed';

  @override
  String get statusTripCancelled => 'Trip Cancelled';

  @override
  String get status => 'Status';

  @override
  String get autoArrival => 'Auto-arrival within 150m';

  @override
  String get profile => 'Profile';

  @override
  String get trip => 'Trip';

  @override
  String get noTripsAvailable => 'No trips available';

  @override
  String get newTripsWillAppearHere => 'New trip requests will appear here automatically';

  @override
  String get youWillReceiveNotifications => 'You\'ll receive notifications for new trips in your province';

  @override
  String get myTrips => 'My Trips';

  @override
  String get driverId => 'Driver ID';

  @override
  String get userId => 'User ID';

  @override
  String get acceptedAt => 'Accepted At';

  @override
  String get completedAt => 'Completed At';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get driver => 'Driver';

  @override
  String get driverPhone => 'Driver Phone';

  @override
  String get driverRating => 'Driver Rating';

  @override
  String get cancelTripConfirmation => 'Cancel Trip';

  @override
  String get cancelTripMessage => 'Are you sure you want to cancel this trip?';

  @override
  String get tripCancelledSuccessfully => 'Trip cancelled successfully';

  @override
  String get waitingForDriverTitle => 'Waiting for driver...';

  @override
  String get tripCompletedTitle => 'Trip Completed!';

  @override
  String get thankYouForUsingService => 'Thank you for using our service';

  @override
  String countdownMessage(Object countdown) {
    return 'Returning to home in $countdown seconds';
  }

  @override
  String get returnToHomeNow => 'Return to Home Now';

  @override
  String errorCancellingTrip(Object error) {
    return 'Error cancelling trip: $error';
  }

  @override
  String get pickup => 'Pickup';

  @override
  String get dropoff => 'Dropoff';

  @override
  String get waitingTime => 'Waiting Time';

  @override
  String get acceptTripButton => 'Accept Trip';

  @override
  String get viewTripButton => 'View Trip';

  @override
  String errorAcceptingTrip(Object error) {
    return 'Error accepting trip: $error';
  }

  @override
  String get insufficientBudgetMessage => 'Insufficient budget for this trip';

  @override
  String get viewBudgetButton => 'View Budget';

  @override
  String get budgetInformationTitle => 'Budget Information';

  @override
  String currentBudgetLabel(Object amount, Object budget) {
    return 'Current Budget: $budget IQD';
  }

  @override
  String driverNameLabel(Object name) {
    return 'Driver: $name';
  }

  @override
  String get addTestBudgetButton => 'Add 1000 IQD (Test)';

  @override
  String budgetAddedMessage(Object amount) {
    return 'Budget added: $amount IQD';
  }

  @override
  String errorAddingBudgetMessage(Object error) {
    return 'Error adding budget: $error';
  }

  @override
  String budgetTestMessage(Object currentBudget, Object message) {
    return 'Budget test: $message - Current: $currentBudget IQD';
  }

  @override
  String deductionLabel(Object amount, Object deduction) {
    return 'Deduction (12%): $deduction IQD';
  }

  @override
  String yourBudgetLabel(Object budget) {
    return 'Your Budget:';
  }

  @override
  String get insufficientBudgetLabel => 'Insufficient budget';

  @override
  String get viewBudgetLabel => 'View Budget';

  @override
  String get provinceFilteringTitle => 'Province Filtering';

  @override
  String get newTripRequestsWillAppearMessage => 'New trip requests will appear here automatically';

  @override
  String get youWillReceiveNotificationsMessage => 'You\'ll receive notifications for new trips in your province';

  @override
  String get refreshButton => 'Refresh';

  @override
  String get retryButton => 'Retry';

  @override
  String get loadingTripInformationMessage => 'Loading trip information...';

  @override
  String get myTripsTitle => 'My Trips';

  @override
  String tripNumberLabel(Object id) {
    return 'Trip #$id';
  }

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get dateLabel => 'Date';

  @override
  String get priceLabel => 'Price';

  @override
  String get driverIdLabel => 'Driver ID';

  @override
  String get userIdLabel => 'User ID';

  @override
  String get provinceLabel => 'Province';

  @override
  String get acceptedAtLabel => 'Accepted At';

  @override
  String get completedAtLabel => 'Completed At';

  @override
  String get statusCompletedLabel => 'Completed';

  @override
  String get statusCancelledLabel => 'Cancelled';

  @override
  String get statusInProgressLabel => 'In Progress';

  @override
  String get statusAcceptedLabel => 'Accepted';

  @override
  String get statusWaitingLabel => 'Waiting';

  @override
  String driverLabel(Object driverName) {
    return 'Driver: $driverName';
  }

  @override
  String get driverPhoneLabel => 'Driver Phone';

  @override
  String get driverRatingLabel => 'Driver Rating';

  @override
  String get cancelTripConfirmationTitle => 'Cancel Trip';

  @override
  String get cancelTripMessageText => 'Are you sure you want to cancel this trip?';

  @override
  String get tripCancelledSuccessfullyMessage => 'Trip cancelled successfully';

  @override
  String errorLoadingTripDetailsMessage(Object error) {
    return 'Error loading trip details: $error';
  }

  @override
  String get invalidCoordinatesMessage => 'Invalid coordinates in trip data. Please contact support.';

  @override
  String get accountNotActiveMessage => 'Your account is not active. Please contact support.';

  @override
  String get invalidCoordinatesErrorMessage => 'Invalid coordinates in trip data. Please contact support.';

  @override
  String get driverProfileTitle => 'Driver Profile';

  @override
  String get userProfileTitle => 'User Profile';

  @override
  String get carInformationTitle => 'Car Information';

  @override
  String get accountInformationTitle => 'Account Information';

  @override
  String get personalInformationTitle => 'Personal Information';

  @override
  String get accountTypeLabel => 'Account Type';

  @override
  String get memberSinceLabel => 'Member Since';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get accountStatusLabel => 'Status';

  @override
  String get languageTitle => 'Language';

  @override
  String currentLanguage(Object flag, Object language) {
    return 'Current: $flag $language';
  }

  @override
  String get tapLanguageToChangeMessage => 'Tap a language to change the app language';

  @override
  String languageChangedToMessage(Object language) {
    return 'Language changed to $language';
  }

  @override
  String get languageChangedRestartMessage => 'Language changed! Please restart the app for full effect.';

  @override
  String get searchLocationTitle => 'Search Location';

  @override
  String get pickupLocationLabel => 'Pickup Location';

  @override
  String get dropoffLocationLabel => 'Dropoff Location';

  @override
  String errorGettingLocationMessage(Object error) {
    return 'Error getting location: $error';
  }

  @override
  String errorSearchingLocationMessage(Object error) {
    return 'Error searching location: $error';
  }

  @override
  String get pleaseSelectPickupDropoffMessage => 'Please select pickup and dropoff locations';

  @override
  String get pleaseEnterBothAddressesMessage => 'Please enter both pickup and dropoff addresses';

  @override
  String get yourAccountNotActiveMessage => 'Your account is not active. Please contact support.';

  @override
  String get createTripTitle => 'Create Trip';

  @override
  String distanceKmLabel(Object distance) {
    return '$distance km';
  }

  @override
  String estimatedPriceLabel(Object price) {
    return 'Estimated Price: $price IQD';
  }

  @override
  String get confirmTripTitle => 'Confirm Trip';

  @override
  String get tripCreatedMessage => 'Trip created successfully!';

  @override
  String errorCreatingTripMessage(Object error) {
    return 'Error creating trip: $error';
  }

  @override
  String get driverNavigationTitle => 'Driver Navigation';

  @override
  String get mapsMeStyleNavigationMessage => 'Maps.me style navigation - route to destination';

  @override
  String get actualMovementTestTitle => 'Actual Movement Test';

  @override
  String get okButton => 'OK';

  @override
  String get mapsMeInfoTitle => 'Maps.me Info';

  @override
  String get actualPhoneMovementTrackingTitle => 'Actual phone movement tracking:';

  @override
  String get movePhoneLeftMessage => '1. Move phone LEFT → Camera and car follow LEFT';

  @override
  String get movePhoneRightMessage => '2. Move phone RIGHT → Camera and car follow RIGHT';

  @override
  String get bothFollowActualMovementMessage => '3. Both follow actual movement direction';

  @override
  String get gpsBasedMovementTrackingMessage => '4. GPS-based movement tracking';

  @override
  String get realTimeMovementFollowingMessage => '5. Real-time movement following';

  @override
  String gpsHeadingCameraCarMessage(Object heading) {
    return 'GPS heading: $heading°\nCamera & car follow actual movement';
  }

  @override
  String get mapsMeStyleFeaturesTitle => 'Maps.me style features:';

  @override
  String get routeToDestinationMessage => '• Route to destination';

  @override
  String get gpsBasedNavigationMessage => '• GPS-based navigation';

  @override
  String get cleanInterfaceMessage => '• Clean interface';

  @override
  String get noDirectionControlsMessage => '• No direction controls';

  @override
  String get focusOnRoadAheadMessage => '• Focus on the road ahead';

  @override
  String get actualMovementTrackingInstructionsTitle => 'Actual phone movement tracking:';

  @override
  String get tripStatusSuccessMessage => 'Trip status updated successfully';

  @override
  String get errorUpdatingTripMessage => 'Error updating trip status';

  @override
  String get speedLabel => 'Speed';

  @override
  String get debugInfoTitle => 'Debug Info';

  @override
  String statusStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String distanceDistanceLabel(Object distance) {
    return 'Distance: $distance km';
  }

  @override
  String get autoArrivalAutoArrivalLabel => 'Auto-arrival within 150m';

  @override
  String get actualLabel => 'Actual';

  @override
  String get movementLabel => 'Movement';

  @override
  String get resetButton => 'Reset';

  @override
  String get northLabel => 'North';

  @override
  String get closeToPickupLocationMessage => 'Close to pickup location';

  @override
  String get iHaveArrivedButton => 'I have arrived';

  @override
  String get userPickedUpButton => 'User Picked Up';

  @override
  String get confirmPickedUpButton => 'Confirm picked up';

  @override
  String get youHaveArrivedAtYourDestinationMessage => 'You have arrived at your destination';

  @override
  String get completeTripButton => 'Complete Trip';

  @override
  String get waitingForDriverMessage => 'Waiting for driver';

  @override
  String get driverAcceptedMessage => 'Driver accepted';

  @override
  String get driverIsOnTheWayMessage => 'Driver is on the way';

  @override
  String get driverHasArrivedMessage => 'Driver has arrived';

  @override
  String get youArePickedUpMessage => 'You are picked up';

  @override
  String get onTheWayToDestinationMessage => 'On the way to destination';

  @override
  String get tripCompletedMessage => 'Trip completed';

  @override
  String get unknownStatusMessage => 'Unknown status';

  @override
  String get mapsMeNavigationTitle => 'Maps.me Navigation';

  @override
  String get mapsMeStyleNavigationInstructionsTitle => 'Maps.me style navigation instructions:';

  @override
  String get userNavigationTitle => 'User Navigation';

  @override
  String get arrivedAtPickupMessage => 'Arrived at Pickup';

  @override
  String get arrivedAtDropoffMessage => 'Arrived at Dropoff';

  @override
  String get pickupPassengerButton => 'Pickup Passenger';

  @override
  String get cancelTripButton => 'Cancel Trip';

  @override
  String get driverNearMessage => 'Driver is near!';

  @override
  String get driverApproachingMessage => 'Your driver is approaching your location';

  @override
  String get tripCancelledMessage => 'Trip Cancelled';

  @override
  String get tripInProgressMessage => 'Trip in Progress';

  @override
  String get driverOnWayMessage => 'Driver on the way';

  @override
  String get driverArrivedMessage => 'Driver arrived';

  @override
  String get passengerPickedUpMessage => 'Passenger picked up';

  @override
  String get arrivedAtDestinationMessage => 'Arrived at destination';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotificationsMessage => 'No notifications';

  @override
  String get markAllReadButton => 'Mark all as read';

  @override
  String get clearAllButton => 'Clear all';

  @override
  String get tripsTitle => 'Trips';

  @override
  String get tripHistoryTitle => 'Trip History';

  @override
  String get activeTripsTitle => 'Active Trips';

  @override
  String get completedTripsTitle => 'Completed Trips';

  @override
  String get cancelledTripsTitle => 'Cancelled Trips';

  @override
  String get noActiveTripsMessage => 'No active trips';

  @override
  String get noCompletedTripsMessage => 'No completed trips';

  @override
  String get noCancelledTripsMessage => 'No cancelled trips';

  @override
  String get logoutButton => 'Logout';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get helpTitle => 'Help';

  @override
  String get supportTitle => 'Support';

  @override
  String get aboutTitle => 'About';

  @override
  String get versionLabel => 'Version';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get yesButton => 'Yes';

  @override
  String get noButton => 'No';

  @override
  String get saveButton => 'Save';

  @override
  String get editButton => 'Edit';

  @override
  String get deleteButton => 'Delete';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get backButton => 'Back';

  @override
  String get nextButton => 'Next';

  @override
  String get previousButton => 'Previous';

  @override
  String get closeButton => 'Close';

  @override
  String get doneButton => 'Done';

  @override
  String get loadingMessage => 'Loading...';

  @override
  String get errorTitle => 'Error';

  @override
  String get successTitle => 'Success';

  @override
  String get warningTitle => 'Warning';

  @override
  String get infoTitle => 'Information';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get locationPermissionTitle => 'Location Permission';

  @override
  String get notificationPermissionTitle => 'Notification Permission';

  @override
  String get cameraPermissionTitle => 'Camera Permission';

  @override
  String get microphonePermissionTitle => 'Microphone Permission';

  @override
  String get permissionRequiredTitle => 'Permission Required';

  @override
  String get permissionDeniedMessage => 'Permission Denied';

  @override
  String get permissionGrantedMessage => 'Permission Granted';

  @override
  String get enablePermissionsMessage => 'Please enable the required permissions in your device settings.';

  @override
  String get networkTitle => 'Network';

  @override
  String get noInternetConnectionMessage => 'No internet connection';

  @override
  String get checkConnectionMessage => 'Please check your internet connection and try again.';

  @override
  String get serverErrorMessage => 'Server error';

  @override
  String get timeoutMessage => 'Request timeout';

  @override
  String get connectionErrorMessage => 'Connection error';

  @override
  String get mapTitle => 'Map';

  @override
  String get currentLocationLabel => 'Current Location';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get routeLabel => 'Route';

  @override
  String get directionsLabel => 'Directions';

  @override
  String get navigationTitle => 'Navigation';

  @override
  String get locationLabel => 'Location';

  @override
  String get addressLabel => 'Address';

  @override
  String get coordinatesLabel => 'Coordinates';

  @override
  String get timeLabel => 'Time';

  @override
  String get durationLabel => 'Duration';

  @override
  String get estimatedTimeLabel => 'Estimated Time';

  @override
  String get arrivalTimeLabel => 'Arrival Time';

  @override
  String get departureTimeLabel => 'Departure Time';

  @override
  String get currencyLabel => 'IQD';

  @override
  String get amountLabel => 'Amount';

  @override
  String get totalLabel => 'Total';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String get taxLabel => 'Tax';

  @override
  String get discountLabel => 'Discount';

  @override
  String get feeLabel => 'Fee';

  @override
  String get costLabel => 'Cost';

  @override
  String get fareLabel => 'Fare';

  @override
  String get tripStartedSuccessfully => 'Trip started successfully!';

  @override
  String errorStartingTrip(Object error) {
    return 'Error starting trip: $error';
  }

  @override
  String get tripAcceptedTitle => 'Trip Accepted';

  @override
  String get userLabel => 'User';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get startTripButton => 'Start Trip';

  @override
  String get errorGettingCurrentLocation => 'Error getting current location';

  @override
  String get errorGettingRoute => 'Error getting route';

  @override
  String get pleaseSelectPickupAndDropoffLocations => 'Please select pickup and dropoff locations';

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String get youAlreadyHaveAnActiveTripPleaseWaitForItToBeCompletedOrCancelled => 'You already have an active trip. Please wait for it to be completed or cancelled.';

  @override
  String get unknown => 'Unknown';

  @override
  String get baghdad => 'Baghdad';

  @override
  String get userProfileIsIncompletePleaseUpdateYourProfileWithNameAndPhoneNumber => 'User profile is incomplete. Please update your profile with name and phone number.';

  @override
  String get notifyingAvailableDrivers => 'Notifying available drivers...';

  @override
  String get failedToGetPredictions => 'Failed to get predictions';

  @override
  String get locationIsTooFarFromYourCurrentPositionPleaseSearchForACloserLocation => 'Location is too far from your current position. Please search for a closer location.';

  @override
  String get useAnyway => 'Use Anyway';

  @override
  String get failedToGetPlaceDetails => 'Failed to get place details';

  @override
  String get errorGettingPlaceDetails => 'Error getting place details';

  @override
  String get destinationSetTo => 'Destination set to:';

  @override
  String get creatingTrip => 'Creating Trip...';

  @override
  String get bookTrip => 'Book Trip';

  @override
  String get changeTrip => 'Change Trip';

  @override
  String get selectLocations => 'Select Locations';

  @override
  String get selectedLocation => 'Selected Location';

  @override
  String get searchForDestination => 'Search for destination...';

  @override
  String get tapToSetAsDestination => 'Tap to set as destination';

  @override
  String get searchForDestinationsWithin50kmOfYourCurrentPosition => 'Search for destinations within 50km of your current position';

  @override
  String get notificationNewTripAvailable => 'New Trip Available!';

  @override
  String notificationNewTripMessage(Object province) {
    return 'A new trip request is available in $province. Tap to view details.';
  }

  @override
  String get notificationDriverAcceptedTitle => 'Driver Accepted Your Trip!';

  @override
  String get notificationDriverAcceptedMessage => 'A driver has accepted your trip request. They will be on their way soon.';

  @override
  String get notificationDriverInWayTitle => 'Driver is on the Way!';

  @override
  String get notificationDriverInWayMessage => 'Your driver is heading to your pickup location.';

  @override
  String get notificationDriverArrivedTitle => 'Driver Has Arrived!';

  @override
  String get notificationDriverArrivedMessage => 'Your driver has arrived at the pickup location.';

  @override
  String get notificationUserPickedUpTitle => 'Trip Started!';

  @override
  String get notificationUserPickedUpMessage => 'You have been picked up. Enjoy your ride!';

  @override
  String get notificationTripCompletedTitle => 'Trip Completed!';

  @override
  String get notificationTripCompletedMessage => 'Your trip has been completed successfully. Thank you for using our service!';

  @override
  String get notificationTripCancelledTitle => 'Trip Cancelled';

  @override
  String get notificationTripCancelledMessage => 'Your trip has been cancelled.';

  @override
  String get notificationTripInProgressTitle => 'Trip in Progress';

  @override
  String get notificationTripInProgressMessage => 'Your trip is currently in progress.';

  @override
  String get notificationDriverArrivedDropoffTitle => 'Arrived at Destination';

  @override
  String get notificationDriverArrivedDropoffMessage => 'You have arrived at your destination.';

  @override
  String get notificationDriverInProgressTitle => 'On the Way to Destination';

  @override
  String get notificationDriverInProgressMessage => 'Your driver is taking you to your destination.';

  @override
  String get tripDetailsTitle => 'Trip Details';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get insufficientBudgetButton => 'Insufficient Budget';

  @override
  String get tripAcceptedSuccessfully => 'Trip accepted successfully!';

  @override
  String tripPriceLabel(Object price) {
    return 'Trip Price: $price IQD';
  }

  @override
  String get canAffordTripMessage => 'You can afford this trip';

  @override
  String get deductionPercentLabel => 'Deduction (12%):';

  @override
  String get canAffordThisTripMessage => 'Can afford this trip';

  @override
  String get insufficientBudgetShortMessage => 'Insufficient budget';

  @override
  String get pickupPassengerTitle => 'Pick up Passenger';

  @override
  String get yourLocationLabel => 'Your Location';

  @override
  String get pickupLabel => 'Pickup';

  @override
  String get dropoffLabel => 'Dropoff';

  @override
  String get passengerPickedUpSuccessfully => 'Passenger picked up successfully!';

  @override
  String errorDuringPickup(Object error) {
    return 'Error: $error';
  }

  @override
  String get createNewTripTitle => 'Create New Trip';

  @override
  String get selectLocationsTitle => 'Select Locations';

  @override
  String get searchForDestinationsWithin50km => 'Search for destinations within 50km of your current position';

  @override
  String get selectedLocationLabel => 'Selected Location';

  @override
  String get searchLocationButton => 'Search Location';

  @override
  String get changeTripButton => 'Change Trip';

  @override
  String get bookTripButton => 'Book Trip';

  @override
  String get creatingTripMessage => 'Creating Trip...';

  @override
  String get youAlreadyHaveAnActiveTrip => 'You already have an active trip. Please wait for it to be completed or cancelled.';

  @override
  String get userProfileIsIncomplete => 'User profile is incomplete. Please update your profile with name and phone number.';

  @override
  String get locationIsTooFar => 'Location is too far from your current position. Please search for a closer location.';

  @override
  String get useAnywayButton => 'Use Anyway';

  @override
  String get tripInProgressTitle => 'Trip in Progress';

  @override
  String get driverLocationLabel => 'Driver Location';

  @override
  String get driverIsHereMessage => 'Your driver is here';

  @override
  String get driverIsNearMessage => 'Driver is near!';
}
