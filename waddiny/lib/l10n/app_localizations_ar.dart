// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'وديني';

  @override
  String get appSubtitle => 'خدمة النقل الذكية';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'تسجيل جديد';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get pleaseEnterPhoneNumber => 'يرجى إدخال رقم الهاتف';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get pleaseEnterFullName => 'يرجى إدخال الاسم الكامل';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get chooseRegistrationType => 'اختر نوع التسجيل';

  @override
  String get registerAsUser => 'تسجيل كمستخدم';

  @override
  String get registerAsDriver => 'تسجيل كسائق';

  @override
  String get carId => 'رقم السيارة';

  @override
  String get carType => 'نوع السيارة';

  @override
  String get licenseId => 'رقم الرخصة';

  @override
  String get pleaseEnterCarId => 'يرجى إدخال رقم السيارة';

  @override
  String get pleaseEnterCarType => 'يرجى إدخال نوع السيارة';

  @override
  String get pleaseEnterLicenseId => 'يرجى إدخال رقم الرخصة';

  @override
  String get verifyPhoneNumber => 'تأكيد رقم الهاتف';

  @override
  String enterOtpSentTo(Object phoneNumber) {
    return 'أدخل رمز التحقق المرسل إلى $phoneNumber';
  }

  @override
  String get otp => 'رمز التحقق';

  @override
  String get pleaseEnterOtp => 'يرجى إدخال رمز التحقق';

  @override
  String get verifyOtp => 'تأكيد الرمز';

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String get home => 'الرئيسية';

  @override
  String welcomeUser(Object name) {
    return 'مرحبًا، $name!';
  }

  @override
  String get whereWouldYouLikeToGo => 'إلى أين تريد الذهاب؟';

  @override
  String get createNewTrip => 'إنشاء رحلة جديدة';

  @override
  String get recentTrips => 'الرحلات الأخيرة';

  @override
  String get noTripsYet => 'لا توجد رحلات بعد';

  @override
  String errorLoadingTrips(Object error) {
    return 'حدث خطأ أثناء تحميل الرحلات: $error';
  }

  @override
  String tripTo(Object location) {
    return 'رحلة إلى $location';
  }

  @override
  String get from => 'من';

  @override
  String get accountStatus => 'الحالة';

  @override
  String get price => 'السعر';

  @override
  String get waitingTrips => 'الرحلات المنتظرة';

  @override
  String get noWaitingTrips => 'لا توجد رحلات منتظرة';

  @override
  String get newTripsAvailable => 'رحلات جديدة متاحة!';

  @override
  String newTripsWaiting(num count) {
    return '$count رحلة جديدة بانتظارك';
  }

  @override
  String newTripAvailable(Object message) {
    return 'رحلة جديدة متاحة: $message';
  }

  @override
  String get checkListBelow => 'تحقق من القائمة أدناه';

  @override
  String get generalNotification => 'تم استلام إشعار عام، جاري تحديث الرحلات...';

  @override
  String notificationTapped(Object data) {
    return 'تم النقر على الإشعار (الخلفية): $data';
  }

  @override
  String appLaunchedFromNotification(Object data) {
    return 'تم تشغيل التطبيق من الإشعار: $data';
  }

  @override
  String get noInitialMessage => 'لا توجد رسالة أولية';

  @override
  String errorGettingInitialMessage(Object error) {
    return 'خطأ في الحصول على الرسالة الأولية: $error';
  }

  @override
  String get notificationTriggeredTripRefresh => 'تحديث الرحلات المحفز بالإشعار...';

  @override
  String tripListUpdated(Object count) {
    return 'تم تحديث قائمة الرحلات بـ $count رحلة منتظرة';
  }

  @override
  String errorInNotificationTripRefresh(Object error) {
    return 'خطأ في تحديث الرحلات المحفز بالإشعار: $error';
  }

  @override
  String get networkError => 'خطأ في الشبكة. اضغط لإعادة المحاولة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get refresh => 'تحديث';

  @override
  String get loadingTripInformation => 'جاري تحميل معلومات الرحلة...';

  @override
  String errorLoadingData(Object error) {
    return 'حدث خطأ أثناء تحميل البيانات: $error';
  }

  @override
  String get requestTimeout => 'انتهت مهلة الطلب - يرجى التحقق من الاتصال بالإنترنت';

  @override
  String errorCheckingUserStatus(Object error) {
    return 'خطأ في التحقق من حالة المستخدم: $error';
  }

  @override
  String errorLoadingDriverBudget(Object error) {
    return 'خطأ في تحميل رصيد السائق: $error';
  }

  @override
  String errorLoadingCarInfo(Object error) {
    return 'خطأ في تحميل معلومات السيارة: $error';
  }

  @override
  String errorLoggingOut(Object error) {
    return 'خطأ في تسجيل الخروج: $error';
  }

  @override
  String errorLoadingProfile(Object error) {
    return 'خطأ في تحميل الملف الشخصي: $error';
  }

  @override
  String errorLoadingUserData(Object error) {
    return 'خطأ في تحميل بيانات المستخدم: $error';
  }

  @override
  String get noUserDataFound => 'لم يتم العثور على بيانات المستخدم';

  @override
  String get goToLogin => 'اذهب إلى تسجيل الدخول';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get rateDriverTitle => 'قيّم سائقك';

  @override
  String get rateDriverSubtitle => 'كيف كانت تجربة رحلتك؟';

  @override
  String get rateDriverDescription => 'ملاحظاتك تساعد في تحسين خدمتنا';

  @override
  String get rateDriverButton => 'إرسال التقييم';

  @override
  String get skipRatingButton => 'تخطي التقييم';

  @override
  String get reportDriverTitle => 'الإبلاغ عن السائق';

  @override
  String get reportDriverSubtitle => 'أبلغ عن أي مشاكل مع هذا السائق';

  @override
  String get reportDriverDescription => 'سيتم مراجعة بلاغك من قبل فريقنا';

  @override
  String get reportDriverButton => 'إرسال البلاغ';

  @override
  String get cancelReportButton => 'إلغاء';

  @override
  String get reportReasonLabel => 'سبب البلاغ';

  @override
  String get reportDetailsLabel => 'تفاصيل إضافية';

  @override
  String get reportReasonUnsafeDriving => 'قيادة غير آمنة';

  @override
  String get reportReasonRudeBehavior => 'سلوك وقح';

  @override
  String get reportReasonVehicleCondition => 'حالة سيئة للمركبة';

  @override
  String get reportReasonOvercharging => 'فرض رسوم زائدة';

  @override
  String get reportReasonOther => 'أخرى';

  @override
  String get reportSubmittedSuccessfully => 'تم إرسال البلاغ بنجاح';

  @override
  String get ratingSubmittedSuccessfully => 'تم إرسال التقييم بنجاح';

  @override
  String get thankYouForFeedback => 'شكراً لك على ملاحظاتك!';

  @override
  String get budget => 'الرصيد';

  @override
  String get testBudget => 'اختبار الرصيد';

  @override
  String get budgetInformation => 'معلومات الميزانية';

  @override
  String currentBudget(Object amount) {
    return 'الرصيد الحالي: $amount دينار';
  }

  @override
  String driverName(Object name) {
    return 'السائق: $name';
  }

  @override
  String get budgetDeductionNote => 'ملاحظة: يتم خصم 12% من سعر الرحلة عند قبول الرحلة.';

  @override
  String get addTestBudget => 'إضافة 1000 دينار (اختبار)';

  @override
  String budgetAdded(Object amount) {
    return 'تمت إضافة الرصيد: $amount دينار';
  }

  @override
  String errorAddingBudget(Object error) {
    return 'خطأ في إضافة الرصيد: $error';
  }

  @override
  String budgetTest(Object currentBudget, Object message) {
    return 'اختبار الرصيد: $message - الحالي: $currentBudget دينار';
  }

  @override
  String budgetTestError(Object error) {
    return 'خطأ في اختبار الميزانية: $error';
  }

  @override
  String deduction(Object amount) {
    return 'الخصم: $amount دينار (12%)';
  }

  @override
  String yourBudget(Object budget) {
    return 'رصيدك: $budget دينار';
  }

  @override
  String get insufficientBudget => 'الرصيد غير كافٍ';

  @override
  String get viewBudget => 'عرض الرصيد';

  @override
  String get provinceFiltering => 'تصفية المحافظة';

  @override
  String get provinceFilteringDescription => 'ترى فقط الرحلات من المستخدمين في نفس المحافظة. هذا يضمن جودة خدمة أفضل وأوقات استجابة أسرع.';

  @override
  String get newTripRequestsWillAppear => 'طلبات الرحلات الجديدة ستظهر هنا تلقائيًا';

  @override
  String get youllReceiveNotifications => 'ستتلقى إشعارات بالرحلات الجديدة في محافظتك';

  @override
  String get tripDetails => 'تفاصيل الرحلة';

  @override
  String get acceptTrip => 'قبول الرحلة';

  @override
  String get viewTrip => 'عرض الرحلة';

  @override
  String tripNumber(Object id) {
    return 'رحلة #$id';
  }

  @override
  String get to => 'إلى';

  @override
  String get distance => 'المسافة';

  @override
  String get user => 'المستخدم';

  @override
  String get phone => 'الهاتف';

  @override
  String errorLoadingTripDetails(Object error) {
    return 'حدث خطأ أثناء تحميل تفاصيل الرحلة: $error';
  }

  @override
  String get invalidCoordinatesInTripData => 'إحداثيات غير صالحة في بيانات الرحلة. يرجى التواصل مع الدعم.';

  @override
  String get accountNotActive => 'حسابك غير مفعل. يرجى التواصل مع الدعم.';

  @override
  String get invalidCoordinates => 'إحداثيات غير صالحة في بيانات الرحلة. يرجى التواصل مع الدعم.';

  @override
  String get driverProfile => 'ملف السائق';

  @override
  String get userProfile => 'ملف المستخدم الشخصي';

  @override
  String get carInformation => 'معلومات السيارة';

  @override
  String get accountInformation => 'معلومات الحساب';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get memberSince => 'عضو منذ';

  @override
  String get rating => 'التقييم';

  @override
  String get province => 'المحافظة';

  @override
  String get language => 'اللغة';

  @override
  String current(Object flag, Object language) {
    return 'الحالية: $flag $language';
  }

  @override
  String get tapLanguageToChange => 'اضغط على اللغة لتغيير لغة التطبيق';

  @override
  String languageChangedTo(Object language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get languageChangedRestart => 'تم تغيير اللغة! يرجى إعادة تشغيل التطبيق لتطبيق التغيير.';

  @override
  String get searchLocation => 'بحث عن موقع';

  @override
  String get pickupLocation => 'موقع الاستلام';

  @override
  String get dropoffLocation => 'موقع النزول';

  @override
  String errorGettingLocation(Object error) {
    return 'خطأ في الحصول على الموقع: $error';
  }

  @override
  String errorSearchingLocation(Object error) {
    return 'خطأ في البحث عن الموقع: $error';
  }

  @override
  String get pleaseSelectPickupDropoff => 'يرجى اختيار مواقع الاستلام والنزول';

  @override
  String get pleaseEnterBothAddresses => 'يرجى إدخال عناوين الاستلام والنزول';

  @override
  String get yourAccountNotActive => 'حسابك غير مفعل. يرجى التواصل مع الدعم.';

  @override
  String get createTrip => 'إنشاء رحلة';

  @override
  String distanceKm(Object distance) {
    return '$distance كم';
  }

  @override
  String estimatedPrice(Object price) {
    return 'السعر المقدر: $price دينار';
  }

  @override
  String get confirmTrip => 'تأكيد الرحلة';

  @override
  String get tripCreated => 'تم إنشاء الرحلة بنجاح!';

  @override
  String errorCreatingTrip(Object error) {
    return 'خطأ في إنشاء الرحلة: $error';
  }

  @override
  String get driverNavigation => 'ملاحة السائق';

  @override
  String get mapsMeStyleNavigation => 'ملاحة Maps.me - المسار إلى الوجهة';

  @override
  String get actualMovementTest => 'اختبار الحركة الفعلية';

  @override
  String get ok => 'موافق';

  @override
  String get mapsMeInfo => 'معلومات Maps.me';

  @override
  String get actualPhoneMovementTracking => 'تتبع حركة الهاتف الفعلية:';

  @override
  String get movePhoneLeft => '1. حرّك الهاتف لليسار → الكاميرا والسيارة يتبعان اليسار';

  @override
  String get movePhoneRight => '2. حرّك الهاتف لليمين → الكاميرا والسيارة يتبعان اليمين';

  @override
  String get bothFollowActualMovement => '3. كلاهما يتبعان اتجاه الحركة الفعلية';

  @override
  String get gpsBasedMovementTracking => '4. تتبع الحركة بناءً على GPS';

  @override
  String get realTimeMovementFollowing => '5. تتبع الحركة في الوقت الفعلي';

  @override
  String gpsHeadingCameraCar(Object heading) {
    return 'اتجاه GPS: $heading°\nالكاميرا والسيارة تتبعان الحركة الفعلية';
  }

  @override
  String get mapsMeStyleFeatures => 'ميزات نمط Maps.me:';

  @override
  String get routeToDestination => '• المسار إلى الوجهة';

  @override
  String get gpsBasedNavigation => '• ملاحة تعتمد على GPS';

  @override
  String get cleanInterface => '• واجهة نظيفة';

  @override
  String get noDirectionControls => '• بدون عناصر تحكم في الاتجاه';

  @override
  String get focusOnRoadAhead => '• التركيز على الطريق أمامك';

  @override
  String get actualMovementTrackingInstructions => 'تتبع حركة الهاتف الفعلية:';

  @override
  String get tripStatusSuccess => 'تم تحديث حالة الرحلة بنجاح';

  @override
  String get errorUpdatingTrip => 'خطأ في تحديث حالة الرحلة';

  @override
  String get speed => 'السرعة';

  @override
  String get debugInfo => 'معلومات التصحيح';

  @override
  String statusStatus(Object status) {
    return 'الحالة: $status';
  }

  @override
  String distanceDistance(Object distance) {
    return 'المسافة: $distance كم';
  }

  @override
  String get autoArrivalAutoArrival => 'الوصول التلقائي ضمن 150 متر';

  @override
  String get actual => 'فعلي';

  @override
  String get movement => 'الحركة';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get north => 'الشمال';

  @override
  String get closeToPickupLocation => 'قريب من موقع الاستلام';

  @override
  String get iHaveArrived => 'لقد وصلت';

  @override
  String get userPickedUp => 'تم استلام المستخدم';

  @override
  String get confirmPickedUp => 'تأكيد الاستلام';

  @override
  String get youHaveArrivedAtYourDestination => 'لقد وصلت إلى وجهتك';

  @override
  String get completeTrip => 'إكمال الرحلة';

  @override
  String get waitingForDriver => 'في انتظار السائق';

  @override
  String get driverAccepted => 'قبل السائق';

  @override
  String get driverIsOnTheWay => 'السائق في الطريق';

  @override
  String get driverHasArrived => 'وصل السائق';

  @override
  String get youArePickedUp => 'تم استلامك';

  @override
  String get onTheWayToDestination => 'في الطريق إلى الوجهة';

  @override
  String get tripCompleted => 'اكتملت الرحلة';

  @override
  String get unknownStatus => 'حالة غير معروفة';

  @override
  String get mapsMeNavigation => 'ملاحة Maps.me';

  @override
  String get mapsMeStyleNavigationInstructions => 'تعليمات ملاحة نمط Maps.me:';

  @override
  String get userNavigation => 'ملاحة المستخدم';

  @override
  String get arrivedAtPickup => 'وصل إلى موقع الاستلام';

  @override
  String get arrivedAtDropoff => 'وصل إلى موقع النزول';

  @override
  String get pickupPassenger => 'استلام الراكب';

  @override
  String get cancelTrip => 'إلغاء الرحلة';

  @override
  String get driverNear => 'السائق قريب!';

  @override
  String get driverApproaching => 'سائقك يقترب من موقعك';

  @override
  String get tripCancelled => 'تم إلغاء الرحلة';

  @override
  String get tripInProgress => 'الرحلة قيد التنفيذ';

  @override
  String get driverOnWay => 'السائق في الطريق';

  @override
  String get driverArrived => 'وصل السائق';

  @override
  String get passengerPickedUp => 'تم استلام الراكب';

  @override
  String get arrivedAtDestination => 'وصل إلى الوجهة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get trips => 'الرحلات';

  @override
  String get tripHistory => 'سجل الرحلات';

  @override
  String get activeTrips => 'الرحلات النشطة';

  @override
  String get completedTrips => 'الرحلات المكتملة';

  @override
  String get cancelledTrips => 'الرحلات الملغاة';

  @override
  String get noActiveTrips => 'لا توجد رحلات نشطة';

  @override
  String get noCompletedTrips => 'لا توجد رحلات مكتملة';

  @override
  String get noCancelledTrips => 'لا توجد رحلات ملغاة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get settings => 'الإعدادات';

  @override
  String get help => 'المساعدة';

  @override
  String get support => 'الدعم';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get close => 'إغلاق';

  @override
  String get done => 'تم';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجح';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get permissions => 'الأذونات';

  @override
  String get locationPermission => 'إذن الموقع';

  @override
  String get notificationPermission => 'إذن الإشعارات';

  @override
  String get cameraPermission => 'إذن الكاميرا';

  @override
  String get microphonePermission => 'إذن الميكروفون';

  @override
  String get permissionRequired => 'الأذن مطلوب';

  @override
  String get permissionDenied => 'تم رفض الإذن';

  @override
  String get permissionGranted => 'تم منح الإذن';

  @override
  String get enablePermissions => 'يرجى تمكين الأذونات المطلوبة في إعدادات جهازك.';

  @override
  String get network => 'الشبكة';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkConnection => 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';

  @override
  String get serverError => 'خطأ في الخادم';

  @override
  String get timeout => 'انتهت مهلة الطلب';

  @override
  String get connectionError => 'خطأ في الاتصال';

  @override
  String get map => 'الخريطة';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get destination => 'الوجهة';

  @override
  String get route => 'المسار';

  @override
  String get directions => 'الاتجاهات';

  @override
  String get navigation => 'الملاحة';

  @override
  String get location => 'الموقع';

  @override
  String get address => 'العنوان';

  @override
  String get coordinates => 'الإحداثيات';

  @override
  String get time => 'الوقت';

  @override
  String get date => 'التاريخ';

  @override
  String get duration => 'المدة';

  @override
  String get estimatedTime => 'الوقت المقدر';

  @override
  String get arrivalTime => 'وقت الوصول';

  @override
  String get departureTime => 'وقت المغادرة';

  @override
  String get currency => 'دينار';

  @override
  String get amount => 'المبلغ';

  @override
  String get total => 'المجموع';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get tax => 'الضريبة';

  @override
  String get discount => 'الخصم';

  @override
  String get fee => 'الرسوم';

  @override
  String get cost => 'التكلفة';

  @override
  String get fare => 'الأجرة';

  @override
  String get statusUserWaiting => 'المستخدم ينتظر';

  @override
  String get statusDriverAccepted => 'تم قبول السائق';

  @override
  String get statusDriverInWay => 'السائق في الطريق';

  @override
  String get statusDriverArrived => 'وصل السائق';

  @override
  String get statusUserPickedUp => 'تم استلام المستخدم';

  @override
  String get statusDriverInProgress => 'السائق في تقدم';

  @override
  String get statusDriverArrivedDropoff => 'وصل السائق إلى نقطة النزول';

  @override
  String get statusTripCompleted => 'تمت الرحلة';

  @override
  String get statusTripCancelled => 'تم إلغاء الرحلة';

  @override
  String get status => 'الحالة';

  @override
  String get autoArrival => 'الوصول التلقائي ضمن 150 متر';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get trip => 'رحلة';

  @override
  String get noTripsAvailable => 'لا توجد رحلات متاحة';

  @override
  String get newTripsWillAppearHere => 'ستظهر طلبات الرحلات الجديدة هنا تلقائياً';

  @override
  String get youWillReceiveNotifications => 'ستتلقى إشعارات للرحلات الجديدة في محافظتك';

  @override
  String get myTrips => 'رحلاتي';

  @override
  String get driverId => 'معرف السائق';

  @override
  String get userId => 'معرف المستخدم';

  @override
  String get acceptedAt => 'تم القبول في';

  @override
  String get completedAt => 'تم الإكمال في';

  @override
  String get statusCompleted => 'مكتملة';

  @override
  String get statusCancelled => 'ملغية';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusAccepted => 'مقبولة';

  @override
  String get statusWaiting => 'في الانتظار';

  @override
  String get driver => 'السائق';

  @override
  String get driverPhone => 'هاتف السائق';

  @override
  String get driverRating => 'تقييم السائق';

  @override
  String get cancelTripConfirmation => 'إلغاء الرحلة';

  @override
  String get cancelTripMessage => 'هل أنت متأكد من أنك تريد إلغاء هذه الرحلة؟';

  @override
  String get tripCancelledSuccessfully => 'تم إلغاء الرحلة بنجاح';

  @override
  String get waitingForDriverTitle => 'في انتظار السائق...';

  @override
  String get tripCompletedTitle => 'تمت الرحلة!';

  @override
  String get thankYouForUsingService => 'شكراً لاستخدام خدمتنا';

  @override
  String countdownMessage(Object countdown) {
    return 'العودة إلى الرئيسية خلال $countdown ثانية';
  }

  @override
  String get returnToHomeNow => 'العودة إلى الرئيسية الآن';

  @override
  String errorCancellingTrip(Object error) {
    return 'خطأ في إلغاء الرحلة: $error';
  }

  @override
  String get pickup => 'الاستلام';

  @override
  String get dropoff => 'النزول';

  @override
  String get waitingTime => 'وقت الانتظار';

  @override
  String get acceptTripButton => 'قبول الرحلة';

  @override
  String get viewTripButton => 'عرض الرحلة';

  @override
  String errorAcceptingTrip(Object error) {
    return 'خطأ في قبول الرحلة: $error';
  }

  @override
  String get insufficientBudgetMessage => 'الميزانية غير كافية لهذه الرحلة';

  @override
  String get viewBudgetButton => 'عرض الميزانية';

  @override
  String get budgetInformationTitle => 'معلومات الميزانية';

  @override
  String currentBudgetLabel(Object amount, Object budget) {
    return 'الميزانية الحالية: $budget دينار عراقي';
  }

  @override
  String driverNameLabel(Object name) {
    return 'السائق: $name';
  }

  @override
  String get addTestBudgetButton => 'إضافة 1000 دينار (اختبار)';

  @override
  String budgetAddedMessage(Object amount) {
    return 'تمت إضافة الميزانية: $amount دينار';
  }

  @override
  String errorAddingBudgetMessage(Object error) {
    return 'خطأ في إضافة الميزانية: $error';
  }

  @override
  String budgetTestMessage(Object currentBudget, Object message) {
    return 'اختبار الميزانية: $message - الحالية: $currentBudget دينار';
  }

  @override
  String deductionLabel(Object amount, Object deduction) {
    return 'الخصم (12%): $deduction دينار عراقي';
  }

  @override
  String yourBudgetLabel(Object budget) {
    return 'ميزانيتك:';
  }

  @override
  String get insufficientBudgetLabel => 'الميزانية غير كافية';

  @override
  String get viewBudgetLabel => 'عرض الميزانية';

  @override
  String get provinceFilteringTitle => 'تصفية المحافظة';

  @override
  String get newTripRequestsWillAppearMessage => 'ستظهر طلبات الرحلات الجديدة هنا تلقائياً';

  @override
  String get youWillReceiveNotificationsMessage => 'ستتلقى إشعارات للرحلات الجديدة في محافظتك';

  @override
  String get refreshButton => 'تحديث';

  @override
  String get retryButton => 'إعادة المحاولة';

  @override
  String get loadingTripInformationMessage => 'جاري تحميل معلومات الرحلة...';

  @override
  String get myTripsTitle => 'رحلاتي';

  @override
  String tripNumberLabel(Object id) {
    return 'رحلة #$id';
  }

  @override
  String get fromLabel => 'من';

  @override
  String get toLabel => 'إلى';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get priceLabel => 'السعر';

  @override
  String get driverIdLabel => 'معرف السائق';

  @override
  String get userIdLabel => 'معرف المستخدم';

  @override
  String get provinceLabel => 'المحافظة';

  @override
  String get acceptedAtLabel => 'تم القبول في';

  @override
  String get completedAtLabel => 'تم الإكمال في';

  @override
  String get statusCompletedLabel => 'مكتملة';

  @override
  String get statusCancelledLabel => 'ملغية';

  @override
  String get statusInProgressLabel => 'قيد التنفيذ';

  @override
  String get statusAcceptedLabel => 'مقبولة';

  @override
  String get statusWaitingLabel => 'في الانتظار';

  @override
  String get driverLabel => 'السائق';

  @override
  String get driverPhoneLabel => 'هاتف السائق';

  @override
  String get driverRatingLabel => 'تقييم السائق';

  @override
  String get cancelTripConfirmationTitle => 'إلغاء الرحلة';

  @override
  String get cancelTripMessageText => 'هل أنت متأكد من أنك تريد إلغاء هذه الرحلة؟';

  @override
  String get tripCancelledSuccessfullyMessage => 'تم إلغاء الرحلة بنجاح';

  @override
  String errorLoadingTripDetailsMessage(Object error) {
    return 'خطأ في تحميل تفاصيل الرحلة: $error';
  }

  @override
  String get invalidCoordinatesMessage => 'إحداثيات غير صحيحة في بيانات الرحلة. يرجى الاتصال بالدعم.';

  @override
  String get accountNotActiveMessage => 'حسابك غير نشط. يرجى الاتصال بالدعم.';

  @override
  String get invalidCoordinatesErrorMessage => 'إحداثيات غير صحيحة في بيانات الرحلة. يرجى الاتصال بالدعم.';

  @override
  String get driverProfileTitle => 'ملف السائق الشخصي';

  @override
  String get userProfileTitle => 'ملف المستخدم الشخصي';

  @override
  String get carInformationTitle => 'معلومات السيارة';

  @override
  String get accountInformationTitle => 'معلومات الحساب';

  @override
  String get personalInformationTitle => 'المعلومات الشخصية';

  @override
  String get accountTypeLabel => 'نوع الحساب';

  @override
  String get memberSinceLabel => 'عضو منذ';

  @override
  String get ratingLabel => 'التقييم';

  @override
  String get accountStatusLabel => 'الحالة';

  @override
  String get languageTitle => 'اللغة';

  @override
  String currentLanguage(Object flag, Object language) {
    return 'الحالية: $flag $language';
  }

  @override
  String get tapLanguageToChangeMessage => 'انقر على لغة لتغيير لغة التطبيق';

  @override
  String languageChangedToMessage(Object language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get languageChangedRestartMessage => 'تم تغيير اللغة! يرجى إعادة تشغيل التطبيق للتأثير الكامل.';

  @override
  String get searchLocationTitle => 'البحث عن موقع';

  @override
  String get pickupLocationLabel => 'موقع الاستلام';

  @override
  String get dropoffLocationLabel => 'موقع النزول';

  @override
  String errorGettingLocationMessage(Object error) {
    return 'خطأ في الحصول على الموقع: $error';
  }

  @override
  String errorSearchingLocationMessage(Object error) {
    return 'خطأ في البحث عن الموقع: $error';
  }

  @override
  String get pleaseSelectPickupDropoffMessage => 'يرجى تحديد مواقع الاستلام والنزول';

  @override
  String get pleaseEnterBothAddressesMessage => 'يرجى إدخال عناوين الاستلام والنزول';

  @override
  String get yourAccountNotActiveMessage => 'حسابك غير نشط. يرجى الاتصال بالدعم.';

  @override
  String get createTripTitle => 'إنشاء رحلة';

  @override
  String distanceKmLabel(Object distance) {
    return '$distance كم';
  }

  @override
  String estimatedPriceLabel(Object price) {
    return 'السعر المقدر: $price دينار';
  }

  @override
  String get confirmTripTitle => 'تأكيد الرحلة';

  @override
  String get tripCreatedMessage => 'تم إنشاء الرحلة بنجاح!';

  @override
  String errorCreatingTripMessage(Object error) {
    return 'خطأ في إنشاء الرحلة: $error';
  }

  @override
  String get driverNavigationTitle => 'ملاحة السائق';

  @override
  String get mapsMeStyleNavigationMessage => 'ملاحة Maps.me - المسار إلى الوجهة';

  @override
  String get actualMovementTestTitle => 'اختبار الحركة الفعلية';

  @override
  String get okButton => 'موافق';

  @override
  String get mapsMeInfoTitle => 'معلومات Maps.me';

  @override
  String get actualPhoneMovementTrackingTitle => 'تتبع حركة الهاتف الفعلية:';

  @override
  String get movePhoneLeftMessage => '1. حرّك الهاتف لليسار → الكاميرا والسيارة يتبعان اليسار';

  @override
  String get movePhoneRightMessage => '2. حرّك الهاتف لليمين → الكاميرا والسيارة يتبعان اليمين';

  @override
  String get bothFollowActualMovementMessage => '3. كلاهما يتبعان اتجاه الحركة الفعلية';

  @override
  String get gpsBasedMovementTrackingMessage => '4. تتبع الحركة بناءً على GPS';

  @override
  String get realTimeMovementFollowingMessage => '5. تتبع الحركة في الوقت الفعلي';

  @override
  String gpsHeadingCameraCarMessage(Object heading) {
    return 'اتجاه GPS: $heading°\nالكاميرا والسيارة تتبعان الحركة الفعلية';
  }

  @override
  String get mapsMeStyleFeaturesTitle => 'ميزات نمط Maps.me:';

  @override
  String get routeToDestinationMessage => '• المسار إلى الوجهة';

  @override
  String get gpsBasedNavigationMessage => '• ملاحة تعتمد على GPS';

  @override
  String get cleanInterfaceMessage => '• واجهة نظيفة';

  @override
  String get noDirectionControlsMessage => '• بدون عناصر تحكم في الاتجاه';

  @override
  String get focusOnRoadAheadMessage => '• التركيز على الطريق أمامك';

  @override
  String get actualMovementTrackingInstructionsTitle => 'تتبع حركة الهاتف الفعلية:';

  @override
  String get tripStatusSuccessMessage => 'تم تحديث حالة الرحلة بنجاح';

  @override
  String get errorUpdatingTripMessage => 'خطأ في تحديث حالة الرحلة';

  @override
  String get speedLabel => 'السرعة';

  @override
  String get debugInfoTitle => 'معلومات التصحيح';

  @override
  String statusStatusLabel(Object status) {
    return 'الحالة: $status';
  }

  @override
  String distanceDistanceLabel(Object distance) {
    return 'المسافة: $distance كم';
  }

  @override
  String get autoArrivalAutoArrivalLabel => 'الوصول التلقائي ضمن 150 متر';

  @override
  String get actualLabel => 'فعلي';

  @override
  String get movementLabel => 'الحركة';

  @override
  String get resetButton => 'إعادة تعيين';

  @override
  String get northLabel => 'الشمال';

  @override
  String get closeToPickupLocationMessage => 'قريب من موقع الاستلام';

  @override
  String get iHaveArrivedButton => 'لقد وصلت';

  @override
  String get userPickedUpButton => 'تم استلام المستخدم';

  @override
  String get confirmPickedUpButton => 'تأكيد الاستلام';

  @override
  String get youHaveArrivedAtYourDestinationMessage => 'لقد وصلت إلى وجهتك';

  @override
  String get completeTripButton => 'إكمال الرحلة';

  @override
  String get waitingForDriverMessage => 'في انتظار السائق';

  @override
  String get driverAcceptedMessage => 'قبل السائق';

  @override
  String get driverIsOnTheWayMessage => 'السائق في الطريق';

  @override
  String get driverHasArrivedMessage => 'وصل السائق';

  @override
  String get youArePickedUpMessage => 'تم استلامك';

  @override
  String get onTheWayToDestinationMessage => 'في الطريق إلى الوجهة';

  @override
  String get tripCompletedMessage => 'اكتملت الرحلة';

  @override
  String get unknownStatusMessage => 'حالة غير معروفة';

  @override
  String get mapsMeNavigationTitle => 'ملاحة Maps.me';

  @override
  String get mapsMeStyleNavigationInstructionsTitle => 'تعليمات ملاحة نمط Maps.me:';

  @override
  String get userNavigationTitle => 'ملاحة المستخدم';

  @override
  String get arrivedAtPickupMessage => 'وصل إلى موقع الاستلام';

  @override
  String get arrivedAtDropoffMessage => 'وصل إلى موقع النزول';

  @override
  String get pickupPassengerButton => 'استلام الراكب';

  @override
  String get cancelTripButton => 'إلغاء الرحلة';

  @override
  String get driverNearMessage => 'السائق قريب!';

  @override
  String get driverApproachingMessage => 'السائق يقترب من موقعك';

  @override
  String get tripCancelledMessage => 'تم إلغاء الرحلة';

  @override
  String get tripInProgressMessage => 'الرحلة قيد التنفيذ';

  @override
  String get driverOnWayMessage => 'السائق في الطريق';

  @override
  String get driverArrivedMessage => 'وصل السائق';

  @override
  String get passengerPickedUpMessage => 'تم استلام الراكب';

  @override
  String get arrivedAtDestinationMessage => 'وصل إلى الوجهة';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get noNotificationsMessage => 'لا توجد إشعارات';

  @override
  String get markAllReadButton => 'تحديد الكل كمقروء';

  @override
  String get clearAllButton => 'مسح الكل';

  @override
  String get tripsTitle => 'الرحلات';

  @override
  String get tripHistoryTitle => 'سجل الرحلات';

  @override
  String get activeTripsTitle => 'الرحلات النشطة';

  @override
  String get completedTripsTitle => 'الرحلات المكتملة';

  @override
  String get cancelledTripsTitle => 'الرحلات الملغاة';

  @override
  String get noActiveTripsMessage => 'لا توجد رحلات نشطة';

  @override
  String get noCompletedTripsMessage => 'لا توجد رحلات مكتملة';

  @override
  String get noCancelledTripsMessage => 'لا توجد رحلات ملغاة';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get helpTitle => 'المساعدة';

  @override
  String get supportTitle => 'الدعم';

  @override
  String get aboutTitle => 'حول';

  @override
  String get versionLabel => 'الإصدار';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get termsOfServiceTitle => 'شروط الخدمة';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get yesButton => 'نعم';

  @override
  String get noButton => 'لا';

  @override
  String get saveButton => 'حفظ';

  @override
  String get editButton => 'تعديل';

  @override
  String get deleteButton => 'حذف';

  @override
  String get confirmButton => 'تأكيد';

  @override
  String get backButton => 'رجوع';

  @override
  String get nextButton => 'التالي';

  @override
  String get previousButton => 'السابق';

  @override
  String get closeButton => 'إغلاق';

  @override
  String get doneButton => 'تم';

  @override
  String get loadingMessage => 'جاري التحميل...';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get successTitle => 'نجح';

  @override
  String get warningTitle => 'تحذير';

  @override
  String get infoTitle => 'معلومات';

  @override
  String get permissionsTitle => 'الأذونات';

  @override
  String get locationPermissionTitle => 'إذن الموقع';

  @override
  String get notificationPermissionTitle => 'إذن الإشعارات';

  @override
  String get cameraPermissionTitle => 'إذن الكاميرا';

  @override
  String get microphonePermissionTitle => 'إذن الميكروفون';

  @override
  String get permissionRequiredTitle => 'الأذن مطلوب';

  @override
  String get permissionDeniedMessage => 'تم رفض الإذن';

  @override
  String get permissionGrantedMessage => 'تم منح الإذن';

  @override
  String get enablePermissionsMessage => 'يرجى تمكين الأذونات المطلوبة في إعدادات جهازك.';

  @override
  String get networkTitle => 'الشبكة';

  @override
  String get noInternetConnectionMessage => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkConnectionMessage => 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';

  @override
  String get serverErrorMessage => 'خطأ في الخادم';

  @override
  String get timeoutMessage => 'انتهت مهلة الطلب';

  @override
  String get connectionErrorMessage => 'خطأ في الاتصال';

  @override
  String get mapTitle => 'الخريطة';

  @override
  String get currentLocationLabel => 'الموقع الحالي';

  @override
  String get destinationLabel => 'الوجهة';

  @override
  String get routeLabel => 'المسار';

  @override
  String get directionsLabel => 'الاتجاهات';

  @override
  String get navigationTitle => 'الملاحة';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get coordinatesLabel => 'الإحداثيات';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get durationLabel => 'المدة';

  @override
  String get estimatedTimeLabel => 'الوقت المقدر';

  @override
  String get arrivalTimeLabel => 'وقت الوصول';

  @override
  String get departureTimeLabel => 'وقت المغادرة';

  @override
  String get currencyLabel => 'دينار';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get totalLabel => 'المجموع';

  @override
  String get subtotalLabel => 'المجموع الفرعي';

  @override
  String get taxLabel => 'الضريبة';

  @override
  String get discountLabel => 'الخصم';

  @override
  String get feeLabel => 'الرسوم';

  @override
  String get costLabel => 'التكلفة';

  @override
  String get fareLabel => 'الأجرة';

  @override
  String get tripStartedSuccessfully => 'تم بدء الرحلة بنجاح!';

  @override
  String errorStartingTrip(Object error) {
    return 'خطأ في بدء الرحلة: $error';
  }

  @override
  String get tripAcceptedTitle => 'تم قبول الرحلة';

  @override
  String get userLabel => 'المستخدم';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get startTripButton => 'ابدأ الرحلة';

  @override
  String get errorGettingCurrentLocation => 'خطأ في الحصول على الموقع الحالي';

  @override
  String get errorGettingRoute => 'خطأ في الحصول على المسار';

  @override
  String get pleaseSelectPickupAndDropoffLocations => 'يرجى اختيار مواقع الاستلام والنزول';

  @override
  String get userNotAuthenticated => 'المستخدم غير مصدق';

  @override
  String get youAlreadyHaveAnActiveTripPleaseWaitForItToBeCompletedOrCancelled => 'لديك بالفعل رحلة نشطة. يرجى الانتظار حتى تكتمل أو تُلغى.';

  @override
  String get unknown => 'غير معروف';

  @override
  String get baghdad => 'بغداد';

  @override
  String get userProfileIsIncompletePleaseUpdateYourProfileWithNameAndPhoneNumber => 'ملف المستخدم غير مكتمل. يرجى تحديث ملفك بالاسم ورقم الهاتف.';

  @override
  String get notifyingAvailableDrivers => 'يتم إشعار السائقين المتاحين...';

  @override
  String get failedToGetPredictions => 'فشل في الحصول على الاقتراحات';

  @override
  String get locationIsTooFarFromYourCurrentPositionPleaseSearchForACloserLocation => 'الموقع بعيد جدًا عن موقعك الحالي. يرجى البحث عن موقع أقرب.';

  @override
  String get useAnyway => 'استخدم على أي حال';

  @override
  String get failedToGetPlaceDetails => 'فشل في الحصول على تفاصيل الموقع';

  @override
  String get errorGettingPlaceDetails => 'خطأ في الحصول على تفاصيل الموقع';

  @override
  String get destinationSetTo => 'تم تعيين الوجهة:';

  @override
  String get creatingTrip => 'جاري إنشاء الرحلة...';

  @override
  String get bookTrip => 'احجز الرحلة';

  @override
  String get changeTrip => 'تغيير الرحلة';

  @override
  String get selectLocations => 'اختر المواقع';

  @override
  String get selectedLocation => 'الموقع المحدد';

  @override
  String get searchForDestination => 'ابحث عن وجهة...';

  @override
  String get tapToSetAsDestination => 'اضغط لتعيين كوجهة';

  @override
  String get searchForDestinationsWithin50kmOfYourCurrentPosition => 'ابحث عن وجهات ضمن 50 كم من موقعك الحالي';

  @override
  String get notificationNewTripAvailable => 'رحلة جديدة متاحة!';

  @override
  String notificationNewTripMessage(Object province) {
    return 'رحلة جديدة متاحة في $province. اضغط لعرض التفاصيل.';
  }

  @override
  String get notificationDriverAcceptedTitle => 'قبل السائق رحلتك!';

  @override
  String get notificationDriverAcceptedMessage => 'قبل سائق طلب رحلتك. سيكون في الطريق قريباً.';

  @override
  String get notificationDriverInWayTitle => 'السائق في الطريق!';

  @override
  String get notificationDriverInWayMessage => 'سائقك متجه إلى موقع الاستلام.';

  @override
  String get notificationDriverArrivedTitle => 'وصل السائق!';

  @override
  String get notificationDriverArrivedMessage => 'وصل سائقك إلى موقع الاستلام.';

  @override
  String get notificationUserPickedUpTitle => 'بدأت الرحلة!';

  @override
  String get notificationUserPickedUpMessage => 'تم استلامك. استمتع برحلتك!';

  @override
  String get notificationTripCompletedTitle => 'اكتملت الرحلة!';

  @override
  String get notificationTripCompletedMessage => 'اكتملت رحلتك بنجاح. شكراً لاستخدام خدمتنا!';

  @override
  String get notificationTripCancelledTitle => 'تم إلغاء الرحلة';

  @override
  String get notificationTripCancelledMessage => 'تم إلغاء رحلتك.';

  @override
  String get notificationTripInProgressTitle => 'الرحلة قيد التنفيذ';

  @override
  String get notificationTripInProgressMessage => 'رحلتك قيد التنفيذ حالياً.';

  @override
  String get notificationDriverArrivedDropoffTitle => 'وصل إلى الوجهة';

  @override
  String get notificationDriverArrivedDropoffMessage => 'وصلت إلى وجهتك.';

  @override
  String get notificationDriverInProgressTitle => 'في الطريق إلى الوجهة';

  @override
  String get notificationDriverInProgressMessage => 'سائقك يأخذك إلى وجهتك.';

  @override
  String get tripDetailsTitle => 'تفاصيل الرحلة';

  @override
  String get distanceLabel => 'المسافة';

  @override
  String get carLabel => 'السيارة';

  @override
  String get insufficientBudgetButton => 'الميزانية غير كافية';

  @override
  String get tripAcceptedSuccessfully => 'تم قبول الرحلة بنجاح!';

  @override
  String tripPriceLabel(Object price) {
    return 'سعر الرحلة: $price دينار عراقي';
  }

  @override
  String get canAffordTripMessage => 'يمكنك تحمل تكلفة هذه الرحلة';

  @override
  String get deductionPercentLabel => 'الخصم (12%):';

  @override
  String get canAffordThisTripMessage => 'يمكن تحمل هذه الرحلة';

  @override
  String get insufficientBudgetShortMessage => 'الميزانية غير كافية';

  @override
  String get pickupPassengerTitle => 'استلام الراكب';

  @override
  String get yourLocationLabel => 'موقعك';

  @override
  String get pickupLabel => 'نقطة الاستلام';

  @override
  String get dropoffLabel => 'نقطة النزول';

  @override
  String get passengerPickedUpSuccessfully => 'تم استلام الراكب بنجاح!';

  @override
  String errorDuringPickup(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get createNewTripTitle => 'إنشاء رحلة جديدة';

  @override
  String get selectLocationsTitle => 'اختر المواقع';

  @override
  String get searchForDestinationsWithin50km => 'ابحث عن وجهات ضمن 50 كم من موقعك الحالي';

  @override
  String get selectedLocationLabel => 'الموقع المحدد';

  @override
  String get searchLocationButton => 'بحث عن موقع';

  @override
  String get changeTripButton => 'تغيير الرحلة';

  @override
  String get bookTripButton => 'احجز الرحلة';

  @override
  String get creatingTripMessage => 'جاري إنشاء الرحلة...';

  @override
  String get youAlreadyHaveAnActiveTrip => 'لديك بالفعل رحلة نشطة. يرجى الانتظار حتى تكتمل أو تُلغى.';

  @override
  String get userProfileIsIncomplete => 'ملف المستخدم غير مكتمل. يرجى تحديث ملفك بالاسم ورقم الهاتف.';

  @override
  String get locationIsTooFar => 'الموقع بعيد جدًا عن موقعك الحالي. يرجى البحث عن موقع أقرب.';

  @override
  String get useAnywayButton => 'استخدم على أي حال';

  @override
  String get tripInProgressTitle => 'الرحلة قيد التنفيذ';

  @override
  String get driverLocationLabel => 'موقع السائق';

  @override
  String get driverIsHereMessage => 'السائق هنا';

  @override
  String get driverIsNearMessage => 'السائق قريب!';

  @override
  String get routeOptions => 'خيارات المسار';

  @override
  String get shortest => 'الأقصر';
}
