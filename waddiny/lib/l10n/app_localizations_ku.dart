// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appTitle => 'وەدینی';

  @override
  String get appSubtitle => 'خزمەتگوزاری گواستنەوەی زیرەک';

  @override
  String get welcomeBack => 'بەخێربێیتەوە';

  @override
  String get login => 'چوونەژوورەوە';

  @override
  String get register => 'تۆمارکردن';

  @override
  String get phoneNumber => 'ژمارەی مۆبایل';

  @override
  String get password => 'وشەی نهێنی';

  @override
  String get fullName => 'ناوی تەواو';

  @override
  String get pleaseEnterPhoneNumber => 'تکایە ژمارەی مۆبایلت بنووسە';

  @override
  String get pleaseEnterPassword => 'تکایە وشەی نهێنیت بنووسە';

  @override
  String get pleaseEnterFullName => 'تکایە ناوی تەواوت بنووسە';

  @override
  String get passwordMinLength => 'وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت';

  @override
  String get dontHaveAccount => 'هەژمارت نییە؟ تۆمار بکە';

  @override
  String get chooseRegistrationType => 'جۆری تۆمارکردن هەڵبژێرە';

  @override
  String get registerAsUser => 'وەک بەکارهێنەر تۆمار بکە';

  @override
  String get registerAsDriver => 'وەک شۆفێر تۆمار بکە';

  @override
  String get carId => 'ناسنامەی ئۆتۆمبێل';

  @override
  String get carType => 'جۆری ئۆتۆمبێل';

  @override
  String get licenseId => 'ناسنامەی مۆڵەت';

  @override
  String get pleaseEnterCarId => 'تکایە ناسنامەی ئۆتۆمبێلت بنووسە';

  @override
  String get pleaseEnterCarType => 'تکایە جۆری ئۆتۆمبێلت بنووسە';

  @override
  String get pleaseEnterLicenseId => 'تکایە ناسنامەی مۆڵەتت بنووسە';

  @override
  String get verifyPhoneNumber => 'ژمارەی مۆبایل پشتڕاست بکەرەوە';

  @override
  String enterOtpSentTo(Object phoneNumber) {
    return 'کۆدی OTP بنووسە کە نێردراوە بۆ $phoneNumber';
  }

  @override
  String get otp => 'کۆدی OTP';

  @override
  String get pleaseEnterOtp => 'تکایە کۆدی OTP بنووسە';

  @override
  String get verifyOtp => 'کۆدی OTP پشتڕاست بکەرەوە';

  @override
  String get resendOtp => 'کۆدی OTP دووبارە ناردەوە';

  @override
  String get home => 'سەرەکی';

  @override
  String welcomeUser(Object name) {
    return 'بەخێربێیت، $name!';
  }

  @override
  String get whereWouldYouLikeToGo => 'دەتەوێت بچیت بۆ کوێ؟';

  @override
  String get createNewTrip => 'گەشتی نوێ دروست بکە';

  @override
  String get recentTrips => 'گەشتە دواترەکان';

  @override
  String get noTripsYet => 'هێشتا گەشت نییە';

  @override
  String errorLoadingTrips(Object error) {
    return 'هەڵە لە بارکردنی گەشتەکان: $error';
  }

  @override
  String tripTo(Object location) {
    return 'گەشت بۆ $location';
  }

  @override
  String get from => 'لە';

  @override
  String get accountStatus => 'دۆخ';

  @override
  String get price => 'نرخ';

  @override
  String get waitingTrips => 'چاوەڕوانی گەشتەکان';

  @override
  String get noWaitingTrips => 'هیچ گەشتی چاوەڕوان نییە';

  @override
  String get newTripsAvailable => 'گەشتی نوێ بەردەستە!';

  @override
  String newTripsWaiting(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count گەشتی نوێ$_temp0 چاوەڕوانت دەکەن';
  }

  @override
  String newTripAvailable(Object message) {
    return 'گەشتی نوێ بەردەستە: $message';
  }

  @override
  String get checkListBelow => 'لیستەی خوارەوە پشکنە';

  @override
  String get generalNotification => 'ئاگادارکردنەوەی گشتی وەرگیرا، گەشتەکان نوێ دەکرێنەوە...';

  @override
  String notificationTapped(Object data) {
    return 'ئاگادارکردنەوە لێدرا (پشتەوە): $data';
  }

  @override
  String appLaunchedFromNotification(Object data) {
    return 'ئەپەکە لە ئاگادارکردنەوەوە دەستی پێکرد: $data';
  }

  @override
  String get noInitialMessage => 'هیچ پەیامی سەرەتایی نەدۆزرایەوە';

  @override
  String errorGettingInitialMessage(Object error) {
    return 'هەڵە لە وەرگرتنی پەیامی سەرەتایی: $error';
  }

  @override
  String get notificationTriggeredTripRefresh => 'نوێکردنەوەی گەشت بە هۆی ئاگادارکردنەوە...';

  @override
  String tripListUpdated(Object count) {
    return 'لیستەی گەشتەکان نوێکرایەوە بە $count گەشتی چاوەڕوان';
  }

  @override
  String errorInNotificationTripRefresh(Object error) {
    return 'هەڵە لە نوێکردنەوەی گەشت بە هۆی ئاگادارکردنەوە: $error';
  }

  @override
  String get networkError => 'هەڵەی تۆڕ. تکایە دووبارە هەوڵبدە.';

  @override
  String get retry => 'دووبارە هەوڵبدە';

  @override
  String get refresh => 'نوێکردنەوە';

  @override
  String get loadingTripInformation => 'زانیاری گەشت بار دەکرێت...';

  @override
  String errorLoadingData(Object error) {
    return 'هەڵە لە بارکردنی داتا: $error';
  }

  @override
  String get requestTimeout => 'کاتی داواکاری تەواو بوو - تکایە پەیوەندی ئینتەرنێتت پشکنە';

  @override
  String errorCheckingUserStatus(Object error) {
    return 'هەڵە لە پشکنینی دۆخی بەکارهێنەر: $error';
  }

  @override
  String errorLoadingDriverBudget(Object error) {
    return 'هەڵە لە بارکردنی بودیجەی شۆفێر: $error';
  }

  @override
  String errorLoadingCarInfo(Object error) {
    return 'هەڵە لە بارکردنی زانیاری ئۆتۆمبێل: $error';
  }

  @override
  String errorLoggingOut(Object error) {
    return 'هەڵە لە چوونەدەرەوە: $error';
  }

  @override
  String errorLoadingProfile(Object error) {
    return 'هەڵە لە بارکردنی پرۆفایل: $error';
  }

  @override
  String errorLoadingUserData(Object error) {
    return 'هەڵە لە بارکردنی داتای بەکارهێنەر: $error';
  }

  @override
  String get noUserDataFound => 'هیچ داتایەکی بەکارهێنەر نەدۆزرایەوە';

  @override
  String get goToLogin => 'بڕۆ بۆ چوونەژوورەوە';

  @override
  String get notAvailable => 'بەردەست نییە';

  @override
  String get rateDriverTitle => 'هەڵسەنگاندنی شۆفێرەکەت';

  @override
  String get rateDriverSubtitle => 'سەفەرەکەت چۆن بوو؟';

  @override
  String get rateDriverDescription => 'ڕاپۆرتەکەت یارمەتی باشترکردنی خزمەتگوزاریەکان دەدات';

  @override
  String get rateDriverButton => 'ناردنی هەڵسەنگاندن';

  @override
  String get skipRatingButton => 'پشتگوێخستنی هەڵسەنگاندن';

  @override
  String get reportDriverTitle => 'ڕاپۆرتکردنی شۆفێر';

  @override
  String get reportDriverSubtitle => 'هەر کێشەیەک لەگەڵ ئەم شۆفێرە ڕاپۆرت بکە';

  @override
  String get reportDriverDescription => 'ڕاپۆرتەکەت لەلایەن تیمەکەمانەوە پێداچوونەوەی تێدا دەکرێت';

  @override
  String get reportDriverButton => 'ناردنی ڕاپۆرت';

  @override
  String get cancelReportButton => 'هەڵوەشاندنەوە';

  @override
  String get reportReasonLabel => 'هۆکاری ڕاپۆرت';

  @override
  String get reportDetailsLabel => 'وردەکاری زیاتر';

  @override
  String get reportReasonUnsafeDriving => 'شۆفێری نەگونجاو';

  @override
  String get reportReasonRudeBehavior => 'ڕەفتاری نەگونجاو';

  @override
  String get reportReasonVehicleCondition => 'دۆخی هەڵەمی ئۆتۆمبێل';

  @override
  String get reportReasonOvercharging => 'بڕینی زیاتر';

  @override
  String get reportReasonOther => 'هی تر';

  @override
  String get reportSubmittedSuccessfully => 'ڕاپۆرت بە سەرکەوتوویی نەدرا';

  @override
  String get ratingSubmittedSuccessfully => 'هەڵسەنگاندن بە سەرکەوتوویی نەدرا';

  @override
  String get thankYouForFeedback => 'سوپاس بۆ ڕاپۆرتەکەت!';

  @override
  String get budget => 'بودیجە';

  @override
  String get testBudget => 'تاقیکردنەوەی بودیجە';

  @override
  String get budgetInformation => 'زانیاری بودجە';

  @override
  String currentBudget(Object amount) {
    return 'بودیجەی ئێستا: $amount دینار';
  }

  @override
  String driverName(Object name) {
    return 'شۆفێر: $name';
  }

  @override
  String get budgetDeductionNote => 'تێبینی: ١٢٪ لە نرخی گەشت کەم دەکرێتەوە کاتێک گەشتەکە قبوڵ دەکرێت.';

  @override
  String get addTestBudget => 'زیادکردنی ١٠٠٠ دینار (تاقی)';

  @override
  String budgetAdded(Object amount) {
    return 'بودیجە زیادکرا: $amount دینار';
  }

  @override
  String errorAddingBudget(Object error) {
    return 'هەڵە لە زیادکردنی بودیجە: $error';
  }

  @override
  String budgetTest(Object currentBudget, Object message) {
    return 'تاقیکردنەوەی بودیجە: $message - ئێستا: $currentBudget دینار';
  }

  @override
  String budgetTestError(Object error) {
    return 'هەڵەی تاقیکردنەوەی بودجە: $error';
  }

  @override
  String deduction(Object amount) {
    return 'کەمکردنەوە: $amount دینار (١٢٪)';
  }

  @override
  String yourBudget(Object budget) {
    return 'بودیجەکەت: $budget دینار';
  }

  @override
  String get insufficientBudget => 'بودیجەی نەگونجاو';

  @override
  String get viewBudget => 'بودیجە ببینە';

  @override
  String get provinceFiltering => 'پاڵاوتنی پارێزگا';

  @override
  String get provinceFilteringDescription => 'تەنها گەشتەکانی بەکارهێنەرانی هەمان پارێزگا دەبینیت. ئەمە جۆرایەتی خزمەتگوزاری باشتر و کاتی وەڵامدانی خێراتر دەدات.';

  @override
  String get newTripRequestsWillAppear => 'داواکاری گەشتی نوێ بە شێوەیەکی ئۆتۆماتیکی لێرە دەردەکەون';

  @override
  String get youllReceiveNotifications => 'بۆ گەشتی نوێ لە پارێزگاکەت ئاگادارکردنەوە وەردەگریتەوە';

  @override
  String get tripDetails => 'وردەکاری گەشت';

  @override
  String get acceptTrip => 'قبوڵکردنی گەشت';

  @override
  String get viewTrip => 'بینینی گەشت';

  @override
  String tripNumber(Object id) {
    return 'گەشت #$id';
  }

  @override
  String get to => 'بۆ';

  @override
  String get distance => 'دووری';

  @override
  String get user => 'بەکارهێنەر';

  @override
  String get phone => 'تەلەفۆن';

  @override
  String errorLoadingTripDetails(Object error) {
    return 'هەڵە لە بارکردنی وردەکاری گەشت: $error';
  }

  @override
  String get invalidCoordinatesInTripData => 'ناونیشانی نادروست لە زانیاری گەشت. تکایە پەیوەندی بکە بە پشتیوانی.';

  @override
  String get accountNotActive => 'هەژمارت چالاک نییە. تکایە پەیوەندی بکە بە پشتیوانی.';

  @override
  String get invalidCoordinates => 'ناونیشانی نادروست لە زانیاری گەشت. تکایە پەیوەندی بکە بە پشتیوانی.';

  @override
  String get driverProfile => 'پرۆفایلی شۆفێر';

  @override
  String get userProfile => 'پرۆفایلی بەکارهێنەر';

  @override
  String get carInformation => 'زانیاری ئۆتۆمبێل';

  @override
  String get accountInformation => 'زانیاری هەژمار';

  @override
  String get personalInformation => 'زانیاری کەسی';

  @override
  String get accountType => 'جۆری هەژمار';

  @override
  String get memberSince => 'ئەندام لە';

  @override
  String get rating => 'هەڵسەنگاندن';

  @override
  String get province => 'پارێزگا';

  @override
  String get language => 'زمان';

  @override
  String current(Object flag, Object language) {
    return 'ئێستا: $flag $language';
  }

  @override
  String get tapLanguageToChange => 'بۆ گۆڕینی زمانی ئەپەکە کلیک لەسەر زمانێک بکە';

  @override
  String languageChangedTo(Object language) {
    return 'زمان گۆڕدرا بۆ $language';
  }

  @override
  String get languageChangedRestart => 'زمان گۆڕدرا! تکایە بۆ کاریگەری تەواو ئەپەکە دووبارە دەست پێبکەرەوە.';

  @override
  String get searchLocation => 'گەڕان بۆ شوێن';

  @override
  String get pickupLocation => 'شوێنی وەرگرتن';

  @override
  String get dropoffLocation => 'شوێنی دانان';

  @override
  String errorGettingLocation(Object error) {
    return 'هەڵە لە وەرگرتنی شوێن: $error';
  }

  @override
  String errorSearchingLocation(Object error) {
    return 'هەڵە لە گەڕان بۆ شوێن: $error';
  }

  @override
  String get pleaseSelectPickupDropoff => 'تکایە شوێنی وەرگرتن و دانان هەڵبژێرە';

  @override
  String get pleaseEnterBothAddresses => 'تکایە هەردوو ناونیشانی وەرگرتن و دانان بنووسە';

  @override
  String get yourAccountNotActive => 'هەژمارت چالاک نییە. تکایە پەیوەندی بکە بە پشتیوانی.';

  @override
  String get createTrip => 'گەشت دروست بکە';

  @override
  String distanceKm(Object distance) {
    return '$distance کیلۆمەتر';
  }

  @override
  String estimatedPrice(Object price) {
    return 'نرخی خەملاندن: $price دینار';
  }

  @override
  String get confirmTrip => 'گەشتەکە پشتڕاست بکەرەوە';

  @override
  String get tripCreated => 'گەشتەکە بە سەرکەوتوویی دروستکرا!';

  @override
  String errorCreatingTrip(Object error) {
    return 'هەڵە لە دروستکردنی گەشت: $error';
  }

  @override
  String get driverNavigation => 'ڕێنمایی شۆفێر';

  @override
  String get mapsMeStyleNavigation => 'ڕێنمایی بە شێوەی Maps.me - ڕێگە بۆ ناوچە';

  @override
  String get actualMovementTest => 'تاقیکردنەوەی جووڵەی ڕاستەقینە';

  @override
  String get ok => 'باشە';

  @override
  String get mapsMeInfo => 'زانیاری Maps.me';

  @override
  String get actualPhoneMovementTracking => 'شوێنکەوتنی جووڵەی ڕاستەقینەی مۆبایل:';

  @override
  String get movePhoneLeft => '١. مۆبایل بە چەپ بجووڵێنە → کامێرا و ئۆتۆمبێل چەپ شوێن دەکەون';

  @override
  String get movePhoneRight => '٢. مۆبایل بە ڕاست بجووڵێنە → کامێرا و ئۆتۆمبێل ڕاست شوێن دەکەن';

  @override
  String get bothFollowActualMovement => '٣. هەردووکیان شوێنی ئاراستەی جووڵەی ڕاستەقینە دەکەن';

  @override
  String get gpsBasedMovementTracking => '٤. شوێنکەوتنی جووڵە بە پێی GPS';

  @override
  String get realTimeMovementFollowing => '٥. شوێنکەوتنی جووڵە بە کاتی ڕاستەقینە';

  @override
  String gpsHeadingCameraCar(Object heading) {
    return 'ئاراستەی GPS: $heading°\nکامێرا و ئۆتۆمبێل جووڵەی ڕاستەقینە شوێن دەکەن';
  }

  @override
  String get mapsMeStyleFeatures => 'تایبەتمەندی بە شێوەی Maps.me:';

  @override
  String get routeToDestination => '• ڕێگە بۆ ناوچە';

  @override
  String get gpsBasedNavigation => '• ڕێنمایی بە پێی GPS';

  @override
  String get cleanInterface => '• ڕووکاری پاک';

  @override
  String get noDirectionControls => '• هیچ کۆنترۆڵێکی ئاراستە نییە';

  @override
  String get focusOnRoadAhead => '• سەرنج لەسەر ڕێگەی پێشەوە';

  @override
  String get actualMovementTrackingInstructions => 'شوێنکەوتنی جووڵەی ڕاستەقینەی مۆبایل:';

  @override
  String get tripStatusSuccess => 'دۆخی گەشت بە سەرکەوتوویی نوێکرایەوە';

  @override
  String get errorUpdatingTrip => 'هەڵە لە نوێکردنەوەی دۆخی گەشت';

  @override
  String get speed => 'خێرایی';

  @override
  String get debugInfo => 'زانیاری هەڵەگرتنەوە';

  @override
  String statusStatus(Object status) {
    return 'دۆخ: $status';
  }

  @override
  String distanceDistance(Object distance) {
    return 'دووری: $distance کیلۆمەتر';
  }

  @override
  String get autoArrivalAutoArrival => 'خۆکارانە گەیشتن لە ماوەی ١٥٠م';

  @override
  String get actual => 'ڕاستەقینە';

  @override
  String get movement => 'جووڵە';

  @override
  String get reset => 'سڕینەوە';

  @override
  String get north => 'باکوور';

  @override
  String get closeToPickupLocation => 'لە نزیک شوێنی وەرگرتن';

  @override
  String get iHaveArrived => 'هاتم';

  @override
  String get userPickedUp => 'بەکارهێنەر وەرگیرا';

  @override
  String get confirmPickedUp => 'وەرگرتنەکە پشتڕاست بکەرەوە';

  @override
  String get youHaveArrivedAtYourDestination => 'گەیشتیت بۆ ناوچەکەت';

  @override
  String get completeTrip => 'گەشتەکە تەواو بکە';

  @override
  String get waitingForDriver => 'چاوەڕوانی شۆفێر';

  @override
  String get driverAccepted => 'شۆفێر قبوڵی کرد';

  @override
  String get driverIsOnTheWay => 'شۆفێر لە ڕێگەدایە';

  @override
  String get driverHasArrived => 'شۆفێر هات';

  @override
  String get youArePickedUp => 'وەرگیرایت';

  @override
  String get onTheWayToDestination => 'لە ڕێگەدا بۆ ناوچە';

  @override
  String get tripCompleted => 'گەشتەکە تەواو بوو';

  @override
  String get unknownStatus => 'دۆخی نەناسراو';

  @override
  String get mapsMeNavigation => 'ڕێنمایی Maps.me';

  @override
  String get mapsMeStyleNavigationInstructions => 'ڕێنمایی بە شێوەی Maps.me:';

  @override
  String get userNavigation => 'ڕێنمایی بەکارهێنەر';

  @override
  String get arrivedAtPickup => 'گەیشت بۆ شوێنی وەرگرتن';

  @override
  String get arrivedAtDropoff => 'گەیشت بۆ شوێنی دانان';

  @override
  String get pickupPassenger => 'سەرنشین وەربگرە';

  @override
  String get cancelTrip => 'گەشتەکە هەڵوەشێنەرەوە';

  @override
  String get driverNear => 'شۆفێر لە نزیکدایە!';

  @override
  String get driverApproaching => 'شۆفێرەکەت لە نزیک شوێنەکەتە';

  @override
  String get tripCancelled => 'گەشتەکە هەڵوەشێندرایەوە';

  @override
  String get tripInProgress => 'گەشت لە پڕۆسەدایە';

  @override
  String get driverOnWay => 'شۆفێر لە ڕێگەدایە';

  @override
  String get driverArrived => 'شۆفێر هات';

  @override
  String get passengerPickedUp => 'سەرنشین وەرگیرا';

  @override
  String get arrivedAtDestination => 'گەیشت بۆ ناوچە';

  @override
  String get notifications => 'ئاگادارکردنەوەکان';

  @override
  String get noNotifications => 'هیچ ئاگادارکردنەوەیەک نییە';

  @override
  String get markAllRead => 'هەموویان وەک خوێندراوە نیشانە بکە';

  @override
  String get clearAll => 'هەموویان پاک بکەرەوە';

  @override
  String get trips => 'گەشتەکان';

  @override
  String get tripHistory => 'مێژووی گەشت';

  @override
  String get activeTrips => 'گەشتە چالاکەکان';

  @override
  String get completedTrips => 'گەشتە تەواوکراوەکان';

  @override
  String get cancelledTrips => 'گەشتە هەڵوەشێندراوەکان';

  @override
  String get noActiveTrips => 'هیچ گەشتی چالاک نییە';

  @override
  String get noCompletedTrips => 'هیچ گەشتی تەواوکراو نییە';

  @override
  String get noCancelledTrips => 'هیچ گەشتی هەڵوەشێندراو نییە';

  @override
  String get logout => 'چوونەدەرەوە';

  @override
  String get settings => 'ڕێکخستنەکان';

  @override
  String get help => 'یارمەتی';

  @override
  String get support => 'پشتیوانی';

  @override
  String get about => 'دەربارە';

  @override
  String get version => 'وەشان';

  @override
  String get privacyPolicy => 'سیاسەتی تایبەتمەندی';

  @override
  String get termsOfService => 'مەرجەکانی خزمەتگوزاری';

  @override
  String get cancel => 'هەڵوەشێنەرەوە';

  @override
  String get yes => 'بەڵێ';

  @override
  String get no => 'نەخێر';

  @override
  String get save => 'پاشەکەوت بکە';

  @override
  String get edit => 'دەستکاری بکە';

  @override
  String get delete => 'سڕینەوە';

  @override
  String get confirm => 'پشتڕاست بکەرەوە';

  @override
  String get back => 'گەڕانەوە';

  @override
  String get next => 'دواتر';

  @override
  String get previous => 'پێشوو';

  @override
  String get close => 'داخستن';

  @override
  String get done => 'تەواو';

  @override
  String get loading => 'بار دەکرێت...';

  @override
  String get error => 'هەڵە';

  @override
  String get success => 'سەرکەوتوو';

  @override
  String get warning => 'ئاگادارکردنەوە';

  @override
  String get info => 'زانیاری';

  @override
  String get permissions => 'مۆڵەتەکان';

  @override
  String get locationPermission => 'مۆڵەتی شوێن';

  @override
  String get notificationPermission => 'مۆڵەتی ئاگادارکردنەوە';

  @override
  String get cameraPermission => 'مۆڵەتی کامێرا';

  @override
  String get microphonePermission => 'مۆڵەتی مایکرۆفۆن';

  @override
  String get permissionRequired => 'مۆڵەت پێویستە';

  @override
  String get permissionDenied => 'مۆڵەت ڕەتکرایەوە';

  @override
  String get permissionGranted => 'مۆڵەت درا';

  @override
  String get enablePermissions => 'تکایە مۆڵەتە پێویستەکان لە ڕێکخستنەکانی ئامێرەکەت چالاک بکە.';

  @override
  String get network => 'تۆڕ';

  @override
  String get noInternetConnection => 'هیچ پەیوەندی ئینتەرنێت نییە';

  @override
  String get checkConnection => 'تکایە پەیوەندی ئینتەرنێتت پشکنە و دووبارە هەوڵبدە.';

  @override
  String get serverError => 'هەڵەی سێرڤەر';

  @override
  String get timeout => 'کاتی داواکاری تەواو بوو';

  @override
  String get connectionError => 'هەڵەی پەیوەندی';

  @override
  String get map => 'نەخشە';

  @override
  String get currentLocation => 'شوێنی ئێستا';

  @override
  String get destination => 'ناوچە';

  @override
  String get route => 'ڕێگە';

  @override
  String get directions => 'ئاراستەکان';

  @override
  String get navigation => 'ڕێنمایی';

  @override
  String get location => 'شوێن';

  @override
  String get address => 'ناونیشان';

  @override
  String get coordinates => 'ناونیشانەکان';

  @override
  String get time => 'کات';

  @override
  String get date => 'بەروار';

  @override
  String get duration => 'ماوە';

  @override
  String get estimatedTime => 'کاتی خەملاندن';

  @override
  String get arrivalTime => 'کاتی گەیشتن';

  @override
  String get departureTime => 'کاتی ڕۆشتن';

  @override
  String get currency => 'دینار';

  @override
  String get amount => 'بڕ';

  @override
  String get total => 'کۆی گشتی';

  @override
  String get subtotal => 'کۆی ناوەڕاست';

  @override
  String get tax => 'باج';

  @override
  String get discount => 'داشکاندن';

  @override
  String get fee => 'کرێ';

  @override
  String get cost => 'تێچوو';

  @override
  String get fare => 'کرێ';

  @override
  String get statusUserWaiting => 'بەکارهێنەر چاوەڕوانە';

  @override
  String get statusDriverAccepted => 'شۆفێر قبوڵی کرد';

  @override
  String get statusDriverInWay => 'شۆفێر لە ڕێگەدایە';

  @override
  String get statusDriverArrived => 'شۆفێر هات';

  @override
  String get statusUserPickedUp => 'بەکارهێنەر وەرگیرا';

  @override
  String get statusDriverInProgress => 'شۆفێر لە پڕۆسەدایە';

  @override
  String get statusDriverArrivedDropoff => 'شۆفێر گەیشت بۆ شوێنی دانان';

  @override
  String get statusTripCompleted => 'گەشت تەواو بوو';

  @override
  String get statusTripCancelled => 'گەشت هەڵوەشێندرایەوە';

  @override
  String get status => 'دۆخ';

  @override
  String get autoArrival => 'خۆکارانە گەیشتن لە ماوەی ١٥٠م';

  @override
  String get profile => 'پرۆفایل';

  @override
  String get trip => 'گەشت';

  @override
  String get noTripsAvailable => 'هیچ گەشتێک بەردەست نییە';

  @override
  String get newTripsWillAppearHere => 'داواکاری گەشتی نوێ بە شێوەیەکی ئۆتۆماتیکی لێرە دەردەکەون';

  @override
  String get youWillReceiveNotifications => 'بۆ گەشتی نوێ لە پارێزگاکەت ئاگادارکردنەوە وەردەگریتەوە';

  @override
  String get myTrips => 'گەشتەکانم';

  @override
  String get driverId => 'ناسنامەی شۆفێر';

  @override
  String get userId => 'ناسنامەی بەکارهێنەر';

  @override
  String get acceptedAt => 'قبوڵکرا لە';

  @override
  String get completedAt => 'تەواو بوو لە';

  @override
  String get statusCompleted => 'تەواو بوو';

  @override
  String get statusCancelled => 'هەڵوەشێندرایەوە';

  @override
  String get statusInProgress => 'لە پڕۆسەدایە';

  @override
  String get statusAccepted => 'قبوڵکرا';

  @override
  String get statusWaiting => 'چاوەڕوانە';

  @override
  String get driver => 'شۆفێر';

  @override
  String get driverPhone => 'تەلەفۆنی شۆفێر';

  @override
  String get driverRating => 'هەڵسەنگاندنی شۆفێر';

  @override
  String get cancelTripConfirmation => 'گەشتەکە هەڵوەشێنەرەوە';

  @override
  String get cancelTripMessage => 'دڵنیای لە هەڵوەشێنەرەوەی ئەم گەشتە؟';

  @override
  String get tripCancelledSuccessfully => 'گەشتەکە بە سەرکەوتوویی هەڵوەشێندرایەوە';

  @override
  String get waitingForDriverTitle => 'چاوەڕوانی شۆفێر...';

  @override
  String get tripCompletedTitle => 'گەشتەکە تەواو بوو!';

  @override
  String get thankYouForUsingService => 'سوپاس بۆ بەکارهێنانی خزمەتگوزاریمان';

  @override
  String countdownMessage(Object countdown) {
    return 'گەڕانەوە بۆ سەرەکی لە ماوەی $countdown چرکە';
  }

  @override
  String get returnToHomeNow => 'ئێستا بگەڕێرەوە بۆ سەرەکی';

  @override
  String errorCancellingTrip(Object error) {
    return 'هەڵە لە هەڵوەشێنەرەوەی گەشت: $error';
  }

  @override
  String get pickup => 'وەرگرتن';

  @override
  String get dropoff => 'داخستن';

  @override
  String get waitingTime => 'کاتی چاوەڕوانی';

  @override
  String get acceptTripButton => 'قبوڵکردنی گەشت';

  @override
  String get viewTripButton => 'گەشتەکە ببینە';

  @override
  String errorAcceptingTrip(Object error) {
    return 'هەڵە لە قبوڵکردنی گەشت: $error';
  }

  @override
  String get insufficientBudgetMessage => 'بودجە بۆ ئەم گەشتە نەماوە';

  @override
  String get viewBudgetButton => 'بینینی بودجە';

  @override
  String get budgetInformationTitle => 'زانیاری بودجە';

  @override
  String currentBudgetLabel(Object amount, Object budget) {
    return 'بودجەی ئێستا: $budget دینار';
  }

  @override
  String driverNameLabel(Object name) {
    return 'شۆفێر: $name';
  }

  @override
  String get addTestBudgetButton => '١٠٠٠ دینار زیاد بکە (تاقیکردنەوە)';

  @override
  String budgetAddedMessage(Object amount) {
    return 'بودجە زیادکرا: $amount دینار';
  }

  @override
  String errorAddingBudgetMessage(Object error) {
    return 'هەڵە لە زیادکردنی بودجە: $error';
  }

  @override
  String budgetTestMessage(Object currentBudget, Object message) {
    return 'تاقیکردنەوەی بودجە: $message - ئێستا: $currentBudget دینار';
  }

  @override
  String deductionLabel(Object amount, Object deduction) {
    return 'کەمکردنەوە (12%): $deduction دینار';
  }

  @override
  String yourBudgetLabel(Object budget) {
    return 'بودجەکەت:';
  }

  @override
  String get insufficientBudgetLabel => 'بودجە بەس نییە';

  @override
  String get viewBudgetLabel => 'بودجە ببینە';

  @override
  String get provinceFilteringTitle => 'پاڵاوتنی پارێزگا';

  @override
  String get newTripRequestsWillAppearMessage => 'داواکاری گەشتی نوێ بە شێوەیەکی ئۆتۆماتیکی لێرە دەردەکەون';

  @override
  String get youWillReceiveNotificationsMessage => 'بۆ گەشتی نوێ لە پارێزگاکەت ئاگادارکردنەوە وەردەگریتەوە';

  @override
  String get refreshButton => 'نوێکردنەوە';

  @override
  String get retryButton => 'دووبارە هەوڵبدە';

  @override
  String get loadingTripInformationMessage => 'زانیاری گەشت بار دەکرێت...';

  @override
  String get myTripsTitle => 'گەشتەکانم';

  @override
  String tripNumberLabel(Object id) {
    return 'گەشت #$id';
  }

  @override
  String get fromLabel => 'لە';

  @override
  String get toLabel => 'بۆ';

  @override
  String get dateLabel => 'بەروار';

  @override
  String get priceLabel => 'نرخ';

  @override
  String get driverIdLabel => 'ناسنامەی شۆفێر';

  @override
  String get userIdLabel => 'ناسنامەی بەکارهێنەر';

  @override
  String get provinceLabel => 'پارێزگا';

  @override
  String get acceptedAtLabel => 'قبوڵکرا لە';

  @override
  String get completedAtLabel => 'تەواو بوو لە';

  @override
  String get statusCompletedLabel => 'تەواو بوو';

  @override
  String get statusCancelledLabel => 'هەڵوەشێندرایەوە';

  @override
  String get statusInProgressLabel => 'لە پڕۆسەدایە';

  @override
  String get statusAcceptedLabel => 'قبوڵکرا';

  @override
  String get statusWaitingLabel => 'چاوەڕوانە';

  @override
  String get driverLabel => 'شۆفێر';

  @override
  String get driverPhoneLabel => 'تەلەفۆنی شۆفێر';

  @override
  String get driverRatingLabel => 'هەڵسەنگاندنی شۆفێر';

  @override
  String get cancelTripConfirmationTitle => 'گەشتەکە هەڵوەشێنەرەوە';

  @override
  String get cancelTripMessageText => 'دڵنیای لە هەڵوەشێنەرەوەی ئەم گەشتە؟';

  @override
  String get tripCancelledSuccessfullyMessage => 'گەشتەکە بە سەرکەوتوویی هەڵوەشێندرایەوە';

  @override
  String errorLoadingTripDetailsMessage(Object error) {
    return 'هەڵە لە بارکردنی وردەکاری گەشت: $error';
  }

  @override
  String get invalidCoordinatesMessage => 'ناونیشانە نادروستەکان لە داتای گەشت. تکایە پەیوەندی بە پشتگیریکردنەوە بکە.';

  @override
  String get accountNotActiveMessage => 'هەژمارەکەت چالاک نییە. تکایە پەیوەندی بە پشتگیریکردنەوە بکە.';

  @override
  String get invalidCoordinatesErrorMessage => 'ناونیشانە نادروستەکان لە داتای گەشت. تکایە پەیوەندی بە پشتگیریکردنەوە بکە.';

  @override
  String get driverProfileTitle => 'پرۆفایلی شۆفێر';

  @override
  String get userProfileTitle => 'پرۆفایلی بەکارهێنەر';

  @override
  String get carInformationTitle => 'زانیاری ئۆتۆمبێل';

  @override
  String get accountInformationTitle => 'زانیاری هەژمار';

  @override
  String get personalInformationTitle => 'زانیاری کەسی';

  @override
  String get accountTypeLabel => 'جۆری هەژمار';

  @override
  String get memberSinceLabel => 'ئەندام لە';

  @override
  String get ratingLabel => 'هەڵسەنگاندن';

  @override
  String get accountStatusLabel => 'دۆخ';

  @override
  String get languageTitle => 'زمان';

  @override
  String currentLanguage(Object flag, Object language) {
    return 'ئێستا: $flag $language';
  }

  @override
  String get tapLanguageToChangeMessage => 'لێدانی زمان بۆ گۆڕینی زمانی ئەپ';

  @override
  String languageChangedToMessage(Object language) {
    return 'زمان گۆڕدرا بۆ $language';
  }

  @override
  String get languageChangedRestartMessage => 'زمان گۆڕدرا! تکایە ئەپەکە دووبارە بەدەستەوە بکە بۆ کاریگەری تەواو.';

  @override
  String get searchLocationTitle => 'گەڕان بۆ شوێن';

  @override
  String get pickupLocationLabel => 'شوێنی وەرگرتن';

  @override
  String get dropoffLocationLabel => 'شوێنی دانان';

  @override
  String errorGettingLocationMessage(Object error) {
    return 'هەڵە لە وەرگرتنی شوێن: $error';
  }

  @override
  String errorSearchingLocationMessage(Object error) {
    return 'هەڵە لە گەڕان بۆ شوێن: $error';
  }

  @override
  String get pleaseSelectPickupDropoffMessage => 'تکایە شوێنی وەرگرتن و دانان هەڵبژێرە';

  @override
  String get pleaseEnterBothAddressesMessage => 'تکایە ناونیشانی وەرگرتن و دانان بنووسە';

  @override
  String get yourAccountNotActiveMessage => 'هەژمارەکەت چالاک نییە. تکایە پەیوەندی بە پشتگیریکردنەوە بکە.';

  @override
  String get createTripTitle => 'گەشت دروست بکە';

  @override
  String distanceKmLabel(Object distance) {
    return '$distance کیلۆمەتر';
  }

  @override
  String estimatedPriceLabel(Object price) {
    return 'نرخی خەملاندن: $price دینار';
  }

  @override
  String get confirmTripTitle => 'گەشتەکە پشتڕاست بکەرەوە';

  @override
  String get tripCreatedMessage => 'گەشتەکە بە سەرکەوتوویی دروستکرا!';

  @override
  String errorCreatingTripMessage(Object error) {
    return 'هەڵە لە دروستکردنی گەشت: $error';
  }

  @override
  String get driverNavigationTitle => 'ڕێنمایی شۆفێر';

  @override
  String get mapsMeStyleNavigationMessage => 'ڕێنمایی بە شێوەی Maps.me - ڕێگە بۆ ناوچە';

  @override
  String get actualMovementTestTitle => 'تاقیکردنەوەی جووڵەی ڕاستەقینە';

  @override
  String get okButton => 'باشە';

  @override
  String get mapsMeInfoTitle => 'زانیاری Maps.me';

  @override
  String get actualPhoneMovementTrackingTitle => 'شوێنکەوتنی جووڵەی ڕاستەقینەی مۆبایل:';

  @override
  String get movePhoneLeftMessage => '١. مۆبایل بە چەپ بجووڵێنە → کامێرا و ئۆتۆمبێل چەپ شوێن دەکەون';

  @override
  String get movePhoneRightMessage => '٢. مۆبایل بە ڕاست بجووڵێنە → کامێرا و ئۆتۆمبێل ڕاست شوێن دەکەن';

  @override
  String get bothFollowActualMovementMessage => '٣. هەردووکیان شوێنی ئاراستەی جووڵەی ڕاستەقینە دەکەن';

  @override
  String get gpsBasedMovementTrackingMessage => '٤. شوێنکەوتنی جووڵە بە پێی GPS';

  @override
  String get realTimeMovementFollowingMessage => '٥. شوێنکەوتنی جووڵە بە کاتی ڕاستەقینە';

  @override
  String gpsHeadingCameraCarMessage(Object heading) {
    return 'ئاراستەی GPS: $heading°\nکامێرا و ئۆتۆمبێل جووڵەی ڕاستەقینە شوێن دەکەن';
  }

  @override
  String get mapsMeStyleFeaturesTitle => 'تایبەتمەندی بە شێوەی Maps.me:';

  @override
  String get routeToDestinationMessage => '• ڕێگە بۆ ناوچە';

  @override
  String get gpsBasedNavigationMessage => '• ڕێنمایی بە پێی GPS';

  @override
  String get cleanInterfaceMessage => '• ڕووکاری پاک';

  @override
  String get noDirectionControlsMessage => '• هیچ کۆنترۆڵێکی ئاراستە نییە';

  @override
  String get focusOnRoadAheadMessage => '• سەرنج لەسەر ڕێگەی پێشەوە';

  @override
  String get actualMovementTrackingInstructionsTitle => 'شوێنکەوتنی جووڵەی ڕاستەقینەی مۆبایل:';

  @override
  String get tripStatusSuccessMessage => 'دۆخی گەشت بە سەرکەوتوویی نوێکرایەوە';

  @override
  String get errorUpdatingTripMessage => 'هەڵە لە نوێکردنەوەی دۆخی گەشت';

  @override
  String get speedLabel => 'خێرایی';

  @override
  String get debugInfoTitle => 'زانیاری هەڵەگرتنەوە';

  @override
  String statusStatusLabel(Object status) {
    return 'دۆخ: $status';
  }

  @override
  String distanceDistanceLabel(Object distance) {
    return 'دووری: $distance کیلۆمەتر';
  }

  @override
  String get autoArrivalAutoArrivalLabel => 'خۆکارانە گەیشتن لە ماوەی ١٥٠م';

  @override
  String get actualLabel => 'ڕاستەقینە';

  @override
  String get movementLabel => 'جووڵە';

  @override
  String get resetButton => 'سڕینەوە';

  @override
  String get northLabel => 'باکوور';

  @override
  String get closeToPickupLocationMessage => 'لە نزیک شوێنی وەرگرتن';

  @override
  String get iHaveArrivedButton => 'هاتم';

  @override
  String get userPickedUpButton => 'بەکارهێنەر وەرگیرا';

  @override
  String get confirmPickedUpButton => 'وەرگرتنەکە پشتڕاست بکەرەوە';

  @override
  String get youHaveArrivedAtYourDestinationMessage => 'گەیشتیت بۆ ناوچەکەت';

  @override
  String get completeTripButton => 'گەشتەکە تەواو بکە';

  @override
  String get waitingForDriverMessage => 'چاوەڕوانی شۆفێر';

  @override
  String get driverAcceptedMessage => 'شۆفێر قبوڵی کرد';

  @override
  String get driverIsOnTheWayMessage => 'شۆفێر لە ڕێگەدایە';

  @override
  String get driverHasArrivedMessage => 'شۆفێر هات';

  @override
  String get youArePickedUpMessage => 'وەرگیرایت';

  @override
  String get onTheWayToDestinationMessage => 'لە ڕێگەدا بۆ ناوچە';

  @override
  String get tripCompletedMessage => 'گەشتەکە تەواو بوو';

  @override
  String get unknownStatusMessage => 'دۆخی نەناسراو';

  @override
  String get mapsMeNavigationTitle => 'ڕێنمایی Maps.me';

  @override
  String get mapsMeStyleNavigationInstructionsTitle => 'ڕێنمایی بە شێوەی Maps.me:';

  @override
  String get userNavigationTitle => 'ڕێنمایی بەکارهێنەر';

  @override
  String get arrivedAtPickupMessage => 'گەیشت بۆ شوێنی وەرگرتن';

  @override
  String get arrivedAtDropoffMessage => 'گەیشت بۆ شوێنی دانان';

  @override
  String get pickupPassengerButton => 'سەرنشین وەربگرە';

  @override
  String get cancelTripButton => 'گەشتەکە هەڵوەشێنەرەوە';

  @override
  String get driverNearMessage => 'شۆفێر لە نزیکدایە!';

  @override
  String get driverApproachingMessage => 'شۆفێر لە نزیک شوێنەکەتە';

  @override
  String get tripCancelledMessage => 'گەشتەکە هەڵوەشێندرایەوە';

  @override
  String get tripInProgressMessage => 'گەشت لە پڕۆسەدایە';

  @override
  String get driverOnWayMessage => 'شۆفێر لە ڕێگەدایە';

  @override
  String get driverArrivedMessage => 'شۆفێر هات';

  @override
  String get passengerPickedUpMessage => 'سەرنشین وەرگیرا';

  @override
  String get arrivedAtDestinationMessage => 'گەیشت بۆ ناوچە';

  @override
  String get notificationsTitle => 'ئاگادارکردنەوەکان';

  @override
  String get noNotificationsMessage => 'هیچ ئاگادارکردنەوەیەک نییە';

  @override
  String get markAllReadButton => 'هەموویان وەک خوێندراوە نیشانە بکە';

  @override
  String get clearAllButton => 'هەموویان پاک بکەرەوە';

  @override
  String get tripsTitle => 'گەشتەکان';

  @override
  String get tripHistoryTitle => 'مێژووی گەشت';

  @override
  String get activeTripsTitle => 'گەشتە چالاکەکان';

  @override
  String get completedTripsTitle => 'گەشتە تەواوکراوەکان';

  @override
  String get cancelledTripsTitle => 'گەشتە هەڵوەشێندراوەکان';

  @override
  String get noActiveTripsMessage => 'هیچ گەشتی چالاک نییە';

  @override
  String get noCompletedTripsMessage => 'هیچ گەشتی تەواوکراو نییە';

  @override
  String get noCancelledTripsMessage => 'هیچ گەشتی هەڵوەشێندراو نییە';

  @override
  String get logoutButton => 'چوونەدەرەوە';

  @override
  String get settingsTitle => 'ڕێکخستنەکان';

  @override
  String get helpTitle => 'یارمەتی';

  @override
  String get supportTitle => 'پشتیوانی';

  @override
  String get aboutTitle => 'دەربارە';

  @override
  String get versionLabel => 'وەشان';

  @override
  String get privacyPolicyTitle => 'سیاسەتی تایبەتمەندی';

  @override
  String get termsOfServiceTitle => 'مەرجەکانی خزمەتگوزاری';

  @override
  String get cancelButton => 'هەڵوەشێنەرەوە';

  @override
  String get yesButton => 'بەڵێ';

  @override
  String get noButton => 'نەخێر';

  @override
  String get saveButton => 'پاشەکەوت بکە';

  @override
  String get editButton => 'دەستکاری بکە';

  @override
  String get deleteButton => 'سڕینەوە';

  @override
  String get confirmButton => 'پشتڕاست بکەرەوە';

  @override
  String get backButton => 'گەڕانەوە';

  @override
  String get nextButton => 'دواتر';

  @override
  String get previousButton => 'پێشوو';

  @override
  String get closeButton => 'داخستن';

  @override
  String get doneButton => 'تەواو';

  @override
  String get loadingMessage => 'بار دەکرێت...';

  @override
  String get errorTitle => 'هەڵە';

  @override
  String get successTitle => 'سەرکەوتوو';

  @override
  String get warningTitle => 'ئاگادارکردنەوە';

  @override
  String get infoTitle => 'زانیاری';

  @override
  String get permissionsTitle => 'مۆڵەتەکان';

  @override
  String get locationPermissionTitle => 'مۆڵەتی شوێن';

  @override
  String get notificationPermissionTitle => 'مۆڵەتی ئاگادارکردنەوە';

  @override
  String get cameraPermissionTitle => 'مۆڵەتی کامێرا';

  @override
  String get microphonePermissionTitle => 'مۆڵەتی مایکرۆفۆن';

  @override
  String get permissionRequiredTitle => 'مۆڵەت پێویستە';

  @override
  String get permissionDeniedMessage => 'مۆڵەت ڕەتکرایەوە';

  @override
  String get permissionGrantedMessage => 'مۆڵەت درا';

  @override
  String get enablePermissionsMessage => 'تکایە مۆڵەتە پێویستەکان لە ڕێکخستنەکانی ئامێرەکەت چالاک بکە.';

  @override
  String get networkTitle => 'تۆڕ';

  @override
  String get noInternetConnectionMessage => 'هیچ پەیوەندی ئینتەرنێت نییە';

  @override
  String get checkConnectionMessage => 'تکایە پەیوەندی ئینتەرنێتت پشکنە و دووبارە هەوڵبدە.';

  @override
  String get serverErrorMessage => 'هەڵەی سێرڤەر';

  @override
  String get timeoutMessage => 'کاتی داواکاری تەواو بوو';

  @override
  String get connectionErrorMessage => 'هەڵەی پەیوەندی';

  @override
  String get mapTitle => 'نەخشە';

  @override
  String get currentLocationLabel => 'شوێنی ئێستا';

  @override
  String get destinationLabel => 'ناوچە';

  @override
  String get routeLabel => 'ڕێگە';

  @override
  String get directionsLabel => 'ئاراستەکان';

  @override
  String get navigationTitle => 'ڕێنمایی';

  @override
  String get locationLabel => 'شوێن';

  @override
  String get addressLabel => 'ناونیشان';

  @override
  String get coordinatesLabel => 'ناونیشانەکان';

  @override
  String get timeLabel => 'کات';

  @override
  String get durationLabel => 'ماوە';

  @override
  String get estimatedTimeLabel => 'کاتی خەملاندن';

  @override
  String get arrivalTimeLabel => 'کاتی گەیشتن';

  @override
  String get departureTimeLabel => 'کاتی ڕۆشتن';

  @override
  String get currencyLabel => 'دینار';

  @override
  String get amountLabel => 'بڕ';

  @override
  String get totalLabel => 'کۆی گشتی';

  @override
  String get subtotalLabel => 'کۆی ناوەڕاست';

  @override
  String get taxLabel => 'باج';

  @override
  String get discountLabel => 'داشکاندن';

  @override
  String get feeLabel => 'کرێ';

  @override
  String get costLabel => 'تێچوو';

  @override
  String get fareLabel => 'کرێ';

  @override
  String get tripStartedSuccessfully => 'گەشتەکە بە سەرکەوتوویی دەستی پێکرد!';

  @override
  String errorStartingTrip(Object error) {
    return 'هەڵە لە دەستپێکردنی گەشت: $error';
  }

  @override
  String get tripAcceptedTitle => 'گەشت قبوڵکرا';

  @override
  String get userLabel => 'بەکارهێنەر';

  @override
  String get phoneLabel => 'مۆبایل';

  @override
  String get startTripButton => 'گەشتەکە دەستپێبکە';

  @override
  String get errorGettingCurrentLocation => 'هەڵە لە وەرگرتنی شوێنی ئێستا';

  @override
  String get errorGettingRoute => 'هەڵە لە وەرگرتنی ڕێڕەوی گەشت';

  @override
  String get pleaseSelectPickupAndDropoffLocations => 'تکایە شوێنی دەستپێک و کۆتایی هەڵبژێرە';

  @override
  String get userNotAuthenticated => 'بەکارهێنەر پشتڕاست نەکراوە';

  @override
  String get youAlreadyHaveAnActiveTripPleaseWaitForItToBeCompletedOrCancelled => 'تۆ پێشتر گەشتی چالاکت هەیە. تکایە چاوەڕێ بکە تا تەواو بێت یان هەڵوەشێندرێت.';

  @override
  String get unknown => 'نەناسراو';

  @override
  String get baghdad => 'بەغدا';

  @override
  String get userProfileIsIncompletePleaseUpdateYourProfileWithNameAndPhoneNumber => 'پڕۆفایلی بەکارهێنەر تەواو نییە. تکایە ناو و ژمارەی تەلەفۆن زیاد بکە.';

  @override
  String get notifyingAvailableDrivers => 'ئاگادارکردنەوەی شۆفێرە بەردەستەکان...';

  @override
  String get failedToGetPredictions => 'شکستی لە وەرگرتنی پێشنیارەکان';

  @override
  String get locationIsTooFarFromYourCurrentPositionPleaseSearchForACloserLocation => 'شوێن زۆر دوورە لە شوێنی ئێستای تۆ. تکایە شوێنێکی نزیکتر بگەڕێوە.';

  @override
  String get useAnyway => 'بەهەر حالێک بەکارهێنە';

  @override
  String get failedToGetPlaceDetails => 'شکستی لە وەرگرتنی وردەکاری شوێن';

  @override
  String get errorGettingPlaceDetails => 'هەڵە لە وەرگرتنی وردەکاری شوێن';

  @override
  String get destinationSetTo => 'ئامانج دانرا بۆ:';

  @override
  String get creatingTrip => 'گەشت دروست دەکرێت...';

  @override
  String get bookTrip => 'گەشت بکە';

  @override
  String get changeTrip => 'گۆڕینی گەشت';

  @override
  String get selectLocations => 'شوێنەکان هەڵبژێرە';

  @override
  String get selectedLocation => 'شوێنی هەڵبژێراو';

  @override
  String get searchForDestination => 'گەڕان بۆ ئامانج...';

  @override
  String get tapToSetAsDestination => 'کلیک بکە بۆ دانانی وەک ئامانج';

  @override
  String get searchForDestinationsWithin50kmOfYourCurrentPosition => 'گەڕان بۆ ئامانجەکان لە ناو ٥٠ کم لە شوێنی ئێستای تۆدا';

  @override
  String get notificationNewTripAvailable => 'گەشتێکی نوێ بەردەستە!';

  @override
  String notificationNewTripMessage(Object province) {
    return 'گەشتێکی نوێ بەردەستە لە $province. کلیک بکە بۆ بینینی وردەکاری.';
  }

  @override
  String get notificationDriverAcceptedTitle => 'شۆفێر گەشتەکەت قبوڵی کرد!';

  @override
  String get notificationDriverAcceptedMessage => 'شۆفێرێک داواکاری گەشتەکەت قبوڵی کرد. بەم زووانە لە ڕێگەدا دەبێت.';

  @override
  String get notificationDriverInWayTitle => 'شۆفێر لە ڕێگەدایە!';

  @override
  String get notificationDriverInWayMessage => 'شۆفێرەکەت بەرەو شوێنی وەرگرتن دەڕوات.';

  @override
  String get notificationDriverArrivedTitle => 'شۆفێر هات!';

  @override
  String get notificationDriverArrivedMessage => 'شۆفێرەکەت گەیشت بۆ شوێنی وەرگرتن.';

  @override
  String get notificationUserPickedUpTitle => 'گەشتەکە دەستی پێکرد!';

  @override
  String get notificationUserPickedUpMessage => 'وەرگیرایت. چێژ لە گەشتەکەت وەربگرە!';

  @override
  String get notificationTripCompletedTitle => 'گەشتەکە تەواو بوو!';

  @override
  String get notificationTripCompletedMessage => 'گەشتەکەت بە سەرکەوتوویی تەواو بوو. سوپاس بۆ بەکارهێنانی خزمەتگوزاریەکەمان!';

  @override
  String get notificationTripCancelledTitle => 'گەشتەکە هەڵوەشێندرایەوە';

  @override
  String get notificationTripCancelledMessage => 'گەشتەکەت هەڵوەشێندرایەوە.';

  @override
  String get notificationTripInProgressTitle => 'گەشت لە پڕۆسەدایە';

  @override
  String get notificationTripInProgressMessage => 'گەشتەکەت لە پڕۆسەدایە.';

  @override
  String get notificationDriverArrivedDropoffTitle => 'گەیشت بۆ ئامانج';

  @override
  String get notificationDriverArrivedDropoffMessage => 'گەیشتیت بۆ ئامانجەکەت.';

  @override
  String get notificationDriverInProgressTitle => 'لە ڕێگەدا بۆ ئامانج';

  @override
  String get notificationDriverInProgressMessage => 'شۆفێرەکەت دەتات بەرەو ئامانجەکەت.';

  @override
  String get tripDetailsTitle => 'وردەکاری گەشت';

  @override
  String get distanceLabel => 'دووری';

  @override
  String get carLabel => 'ئۆتۆمبێل';

  @override
  String get insufficientBudgetButton => 'بودجە نەماوە';

  @override
  String get tripAcceptedSuccessfully => 'گەشتەکە بە سەرکەوتوویی قبوڵکرا!';

  @override
  String tripPriceLabel(Object price) {
    return 'نرخی گەشت: $price دینار';
  }

  @override
  String get canAffordTripMessage => 'دەتوانیت نرخی ئەم گەشتە بدەیت';

  @override
  String get deductionPercentLabel => 'کەمکردنەوە (12%):';

  @override
  String get canAffordThisTripMessage => 'دەتوانرێت ئەم گەشتە بدەدرێت';

  @override
  String get insufficientBudgetShortMessage => 'بودجە نەماوە';

  @override
  String get pickupPassengerTitle => 'وەرگرتنی سەرنشین';

  @override
  String get yourLocationLabel => 'شوێنەکەت';

  @override
  String get pickupLabel => 'شوێنی وەرگرتن';

  @override
  String get dropoffLabel => 'شوێنی دانان';

  @override
  String get passengerPickedUpSuccessfully => 'سەرنشین بە سەرکەوتوویی وەرگیرا!';

  @override
  String errorDuringPickup(Object error) {
    return 'هەڵە: $error';
  }

  @override
  String get createNewTripTitle => 'گەشتی نوێ دروست بکە';

  @override
  String get selectLocationsTitle => 'شوێنەکان هەڵبژێرە';

  @override
  String get searchForDestinationsWithin50km => 'گەڕان بۆ ئامانجەکان لە ناو ٥٠ کم لە شوێنی ئێستای تۆدا';

  @override
  String get selectedLocationLabel => 'شوێنی هەڵبژێراو';

  @override
  String get searchLocationButton => 'گەڕان بۆ شوێن';

  @override
  String get changeTripButton => 'گۆڕینی گەشت';

  @override
  String get bookTripButton => 'گەشت بکە';

  @override
  String get creatingTripMessage => 'گەشت دروست دەکرێت...';

  @override
  String get youAlreadyHaveAnActiveTrip => 'تۆ پێشتر گەشتی چالاکت هەیە. تکایە چاوەڕێ بکە تا تەواو بێت یان هەڵوەشێندرێت.';

  @override
  String get userProfileIsIncomplete => 'پڕۆفایلی بەکارهێنەر تەواو نییە. تکایە ناو و ژمارەی تەلەفۆن زیاد بکە.';

  @override
  String get locationIsTooFar => 'شوێن زۆر دوورە لە شوێنی ئێستای تۆ. تکایە شوێنێکی نزیکتر بگەڕێوە.';

  @override
  String get useAnywayButton => 'بەهەر حالێک بەکارهێنە';

  @override
  String get tripInProgressTitle => 'گەشت لە پڕۆسەدایە';

  @override
  String get driverLocationLabel => 'شوێنی شۆفێر';

  @override
  String get driverIsHereMessage => 'شۆفێر لێرەیە';

  @override
  String get driverIsNearMessage => 'شۆفێر لە نزیکدایە!';

  @override
  String get routeOptions => 'بژاردەکانی ڕێگە';

  @override
  String get shortest => 'کورترین';

  @override
  String get reports => 'ڕاپۆرتەکان';

  @override
  String get createReport => 'دروستکردنی ڕاپۆرت';

  @override
  String get reportTitle => 'ناونیشانی ڕاپۆرت';

  @override
  String get reportDescription => 'وەسفی ڕاپۆرت';

  @override
  String get reportType => 'جۆری ڕاپۆرت';

  @override
  String get reportPriority => 'پێشەنگی';

  @override
  String get reportCategory => 'پۆل';

  @override
  String get submitReport => 'ناردنی ڕاپۆرت';

  @override
  String get reportSubmitted => 'ڕاپۆرت بە سەرکەوتوویی نەدرا';

  @override
  String get errorSubmittingReport => 'هەڵە لە ناردنی ڕاپۆرت';

  @override
  String get bugReport => 'ڕاپۆرتی هەڵە';

  @override
  String get featureRequest => 'داواکاری تایبەتمەندی';

  @override
  String get complaint => 'سکاڵا';

  @override
  String get suggestion => 'پێشنیار';

  @override
  String get technicalIssue => 'کێشەی تەکنیکی';

  @override
  String get other => 'هی تر';

  @override
  String get low => 'نزم';

  @override
  String get medium => 'ناوەڕاست';

  @override
  String get high => 'بەرز';

  @override
  String get urgent => 'خێرا';

  @override
  String get pending => 'چاوەڕوان';

  @override
  String get inProgress => 'لە پڕۆسەدایە';

  @override
  String get resolved => 'چارەسەرکرا';

  @override
  String get closed => 'داخراوە';

  @override
  String get userRole => 'بەکارهێنەر';

  @override
  String get driverRole => 'شۆفێر';

  @override
  String get adminRole => 'بەڕێوەبەر';

  @override
  String get activeStatus => 'چالاک';

  @override
  String get pendingStatus => 'چاوەڕوان';

  @override
  String get suspendedStatus => 'هەڵوەشێندراوە';

  @override
  String get blockedStatus => 'بلۆککراوە';
}
