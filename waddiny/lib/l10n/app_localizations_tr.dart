// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Waddiny';

  @override
  String get appSubtitle => 'Akıllı Ulaşım Hizmeti';

  @override
  String get welcomeBack => 'Tekrar Hoş Geldiniz';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get phoneNumber => 'Telefon Numarası';

  @override
  String get password => 'Şifre';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get pleaseEnterPhoneNumber => 'Lütfen telefon numaranızı girin';

  @override
  String get pleaseEnterPassword => 'Lütfen şifrenizi girin';

  @override
  String get pleaseEnterFullName => 'Lütfen ad soyadınızı girin';

  @override
  String get passwordMinLength => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu? Kayıt olun';

  @override
  String get chooseRegistrationType => 'Kayıt Türünü Seçin';

  @override
  String get registerAsUser => 'Kullanıcı Olarak Kayıt Ol';

  @override
  String get registerAsDriver => 'Sürücü Olarak Kayıt Ol';

  @override
  String get carId => 'Araç ID';

  @override
  String get carType => 'Araç Türü';

  @override
  String get licenseId => 'Lisans ID';

  @override
  String get pleaseEnterCarId => 'Lütfen araç ID\'nizi girin';

  @override
  String get pleaseEnterCarType => 'Lütfen araç türünüzü girin';

  @override
  String get pleaseEnterLicenseId => 'Lütfen lisans ID\'nizi girin';

  @override
  String get verifyPhoneNumber => 'Telefon Numarasını Doğrula';

  @override
  String enterOtpSentTo(Object phoneNumber) {
    return '$phoneNumber numarasına gönderilen OTP\'yi girin';
  }

  @override
  String get otp => 'OTP';

  @override
  String get pleaseEnterOtp => 'Lütfen OTP\'yi girin';

  @override
  String get verifyOtp => 'OTP\'yi Doğrula';

  @override
  String get resendOtp => 'OTP\'yi Tekrar Gönder';

  @override
  String get home => 'Ana Sayfa';

  @override
  String welcomeUser(Object name) {
    return 'Hoş geldiniz, $name!';
  }

  @override
  String get whereWouldYouLikeToGo => 'Nereye gitmek istiyorsunuz?';

  @override
  String get createNewTrip => 'Yeni Yolculuk Oluştur';

  @override
  String get recentTrips => 'Son Yolculuklar';

  @override
  String get noTripsYet => 'Henüz yolculuk yok';

  @override
  String errorLoadingTrips(Object error) {
    return 'Yolculuklar yüklenirken hata: $error';
  }

  @override
  String tripTo(Object location) {
    return '$location yolculuğu';
  }

  @override
  String get from => 'Nereden';

  @override
  String get accountStatus => 'Durum';

  @override
  String get price => 'Fiyat';

  @override
  String get waitingTrips => 'Bekleyen Yolculuklar';

  @override
  String get noWaitingTrips => 'Bekleyen yolculuk yok';

  @override
  String get newTripsAvailable => 'Yeni Yolculuklar Mevcut!';

  @override
  String newTripsWaiting(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'lar',
      one: '',
    );
    return 'Sizin için $count yeni yolculuk$_temp0 bekliyor';
  }

  @override
  String newTripAvailable(Object message) {
    return 'Yeni yolculuk mevcut: $message';
  }

  @override
  String get checkListBelow => 'Aşağıdaki listeyi kontrol edin';

  @override
  String get generalNotification => 'Genel bildirim alındı, yolculuklar yenileniyor...';

  @override
  String notificationTapped(Object data) {
    return 'Bildirim dokunuldu (arka plan): $data';
  }

  @override
  String appLaunchedFromNotification(Object data) {
    return 'Uygulama bildirimden başlatıldı: $data';
  }

  @override
  String get noInitialMessage => 'İlk mesaj bulunamadı';

  @override
  String errorGettingInitialMessage(Object error) {
    return 'İlk mesaj alınırken hata: $error';
  }

  @override
  String get notificationTriggeredTripRefresh => 'Bildirim tetiklemeli yolculuk yenileme...';

  @override
  String tripListUpdated(Object count) {
    return 'Yolculuk listesi $count bekleyen yolculukla güncellendi';
  }

  @override
  String errorInNotificationTripRefresh(Object error) {
    return 'Bildirim tetiklemeli yolculuk yenilemede hata: $error';
  }

  @override
  String get networkError => 'Ağ hatası. Tekrar denemek için dokunun.';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get refresh => 'Yenile';

  @override
  String get loadingTripInformation => 'Yolculuk bilgileri yükleniyor...';

  @override
  String errorLoadingData(Object error) {
    return 'Veri yüklenirken hata: $error';
  }

  @override
  String get requestTimeout => 'İstek zaman aşımı - lütfen internet bağlantınızı kontrol edin';

  @override
  String errorCheckingUserStatus(Object error) {
    return 'Kullanıcı durumu kontrol edilirken hata: $error';
  }

  @override
  String errorLoadingDriverBudget(Object error) {
    return 'Sürücü bütçesi yüklenirken hata: $error';
  }

  @override
  String errorLoadingCarInfo(Object error) {
    return 'Araç bilgileri yüklenirken hata: $error';
  }

  @override
  String errorLoggingOut(Object error) {
    return 'Çıkış yapılırken hata: $error';
  }

  @override
  String errorLoadingProfile(Object error) {
    return 'Profil yüklenirken hata: $error';
  }

  @override
  String errorLoadingUserData(Object error) {
    return 'Kullanıcı verileri yüklenirken hata: $error';
  }

  @override
  String get noUserDataFound => 'Kullanıcı verisi bulunamadı';

  @override
  String get goToLogin => 'Giriş Sayfasına Git';

  @override
  String get notAvailable => 'Mevcut Değil';

  @override
  String get rateDriverTitle => 'Sürücünüzü Değerlendirin';

  @override
  String get rateDriverSubtitle => 'Yolculuk deneyiminiz nasıldı?';

  @override
  String get rateDriverDescription => 'Geri bildiriminiz hizmetimizi iyileştirmemize yardımcı olur';

  @override
  String get rateDriverButton => 'Değerlendirmeyi Gönder';

  @override
  String get skipRatingButton => 'Değerlendirmeyi Atla';

  @override
  String get reportDriverTitle => 'Sürücüyü Bildir';

  @override
  String get reportDriverSubtitle => 'Bu sürücü ile ilgili sorunları bildirin';

  @override
  String get reportDriverDescription => 'Bildiriminiz ekibimiz tarafından incelenecektir';

  @override
  String get reportDriverButton => 'Bildirimi Gönder';

  @override
  String get cancelReportButton => 'İptal';

  @override
  String get reportReasonLabel => 'Bildirim Nedeni';

  @override
  String get reportDetailsLabel => 'Ek Detaylar';

  @override
  String get reportReasonUnsafeDriving => 'Güvensiz Sürüş';

  @override
  String get reportReasonRudeBehavior => 'Kaba Davranış';

  @override
  String get reportReasonVehicleCondition => 'Kötü Araç Durumu';

  @override
  String get reportReasonOvercharging => 'Aşırı Ücretlendirme';

  @override
  String get reportReasonOther => 'Diğer';

  @override
  String get reportSubmittedSuccessfully => 'Bildirim başarıyla gönderildi';

  @override
  String get ratingSubmittedSuccessfully => 'Değerlendirme başarıyla gönderildi';

  @override
  String get thankYouForFeedback => 'Geri bildiriminiz için teşekkürler!';

  @override
  String get budget => 'Bütçe';

  @override
  String get testBudget => 'Bütçe Testi';

  @override
  String get budgetInformation => 'Bütçe Bilgileri';

  @override
  String currentBudget(Object amount) {
    return 'Mevcut Bütçe: $amount IQD';
  }

  @override
  String driverName(Object name) {
    return 'Sürücü: $name';
  }

  @override
  String get budgetDeductionNote => 'Not: Yolculuk kabul edildiğinde yolculuk fiyatının %12\'si kesilir.';

  @override
  String get addTestBudget => '1000 IQD Ekle (Test)';

  @override
  String budgetAdded(Object amount) {
    return 'Bütçe eklendi: $amount IQD';
  }

  @override
  String errorAddingBudget(Object error) {
    return 'Bütçe eklenirken hata: $error';
  }

  @override
  String budgetTest(Object currentBudget, Object message) {
    return 'Bütçe testi: $message - Mevcut: $currentBudget IQD';
  }

  @override
  String budgetTestError(Object error) {
    return 'Bütçe test hatası: $error';
  }

  @override
  String deduction(Object amount) {
    return 'Kesinti: $amount IQD (%12)';
  }

  @override
  String yourBudget(Object budget) {
    return 'Bütçeniz: $budget IQD';
  }

  @override
  String get insufficientBudget => 'Yetersiz bütçe';

  @override
  String get viewBudget => 'Bütçeyi Görüntüle';

  @override
  String get provinceFiltering => 'İl Filtresi';

  @override
  String get provinceFilteringDescription => 'Sadece aynı ildeki kullanıcılardan gelen yolculukları görürsünüz. Bu, daha iyi hizmet kalitesi ve daha hızlı yanıt süreleri sağlar.';

  @override
  String get newTripRequestsWillAppear => 'Yeni yolculuk talepleri burada otomatik olarak görünecek';

  @override
  String get youllReceiveNotifications => 'İlinizdeki yeni yolculuklar için bildirim alacaksınız';

  @override
  String get tripDetails => 'Yolculuk Detayları';

  @override
  String get acceptTrip => 'Yolculuğu Kabul Et';

  @override
  String get viewTrip => 'Yolculuğu Görüntüle';

  @override
  String tripNumber(Object id) {
    return 'Yolculuk #$id';
  }

  @override
  String get to => 'Nereye';

  @override
  String get distance => 'Mesafe';

  @override
  String get user => 'Kullanıcı';

  @override
  String get phone => 'Telefon';

  @override
  String errorLoadingTripDetails(Object error) {
    return 'Yolculuk detayları yüklenirken hata: $error';
  }

  @override
  String get invalidCoordinatesInTripData => 'Yolculuk verilerinde geçersiz koordinatlar. Lütfen destek ile iletişime geçin.';

  @override
  String get accountNotActive => 'Hesabınız aktif değil. Lütfen destek ile iletişime geçin.';

  @override
  String get invalidCoordinates => 'Yolculuk verilerinde geçersiz koordinatlar. Lütfen destek ile iletişime geçin.';

  @override
  String get driverProfile => 'Sürücü Profili';

  @override
  String get userProfile => 'Kullanıcı Profili';

  @override
  String get carInformation => 'Araç Bilgileri';

  @override
  String get accountInformation => 'Hesap Bilgileri';

  @override
  String get personalInformation => 'Kişisel Bilgiler';

  @override
  String get accountType => 'Hesap Türü';

  @override
  String get memberSince => 'Üyelik Tarihi';

  @override
  String get rating => 'Değerlendirme';

  @override
  String get province => 'İl';

  @override
  String get language => 'Dil';

  @override
  String current(Object flag, Object language) {
    return 'Mevcut: $flag $language';
  }

  @override
  String get tapLanguageToChange => 'Uygulama dilini değiştirmek için bir dile dokunun';

  @override
  String languageChangedTo(Object language) {
    return 'Dil $language olarak değiştirildi';
  }

  @override
  String get languageChangedRestart => 'Dil değiştirildi! Tam etki için lütfen uygulamayı yeniden başlatın.';

  @override
  String get searchLocation => 'Konum Ara';

  @override
  String get pickupLocation => 'Alış Konumu';

  @override
  String get dropoffLocation => 'Bırakış Konumu';

  @override
  String errorGettingLocation(Object error) {
    return 'Konum alınırken hata: $error';
  }

  @override
  String errorSearchingLocation(Object error) {
    return 'Konum aranırken hata: $error';
  }

  @override
  String get pleaseSelectPickupDropoff => 'Lütfen alış ve bırakış konumlarını seçin';

  @override
  String get pleaseEnterBothAddresses => 'Lütfen hem alış hem de bırakış adreslerini girin';

  @override
  String get yourAccountNotActive => 'Hesabınız aktif değil. Lütfen destek ile iletişime geçin.';

  @override
  String get createTrip => 'Yolculuk Oluştur';

  @override
  String distanceKm(Object distance) {
    return '$distance km';
  }

  @override
  String estimatedPrice(Object price) {
    return 'Tahmini Fiyat: $price IQD';
  }

  @override
  String get confirmTrip => 'Yolculuğu Onayla';

  @override
  String get tripCreated => 'Yolculuk başarıyla oluşturuldu!';

  @override
  String errorCreatingTrip(Object error) {
    return 'Yolculuk oluşturulurken hata';
  }

  @override
  String get driverNavigation => 'Sürücü Navigasyonu';

  @override
  String get mapsMeStyleNavigation => 'Maps.me tarzı navigasyon - hedefe rota';

  @override
  String get actualMovementTest => 'Gerçek Hareket Testi';

  @override
  String get ok => 'Tamam';

  @override
  String get mapsMeInfo => 'Maps.me Bilgisi';

  @override
  String get actualPhoneMovementTracking => 'Gerçek telefon hareket takibi:';

  @override
  String get movePhoneLeft => '1. Telefonu SOLA hareket ettir → Kamera ve araç SOLA takip eder';

  @override
  String get movePhoneRight => '2. Telefonu SAĞA hareket ettir → Kamera ve araç SAĞA takip eder';

  @override
  String get bothFollowActualMovement => '3. Her ikisi de gerçek hareket yönünü takip eder';

  @override
  String get gpsBasedMovementTracking => '4. GPS tabanlı hareket takibi';

  @override
  String get realTimeMovementFollowing => '5. Gerçek zamanlı hareket takibi';

  @override
  String gpsHeadingCameraCar(Object heading) {
    return 'GPS yönü: $heading°\nKamera ve araç gerçek hareketi takip eder';
  }

  @override
  String get mapsMeStyleFeatures => 'Maps.me tarzı özellikler:';

  @override
  String get routeToDestination => '• Hedefe rota';

  @override
  String get gpsBasedNavigation => '• GPS tabanlı navigasyon';

  @override
  String get cleanInterface => '• Temiz arayüz';

  @override
  String get noDirectionControls => '• Yön kontrolleri yok';

  @override
  String get focusOnRoadAhead => '• Öndeki yola odaklan';

  @override
  String get actualMovementTrackingInstructions => 'Gerçek telefon hareket takibi:';

  @override
  String get tripStatusSuccess => 'Yolculuk durumu başarıyla güncellendi';

  @override
  String get errorUpdatingTrip => 'Yolculuk durumu güncellenirken hata';

  @override
  String get speed => 'Hız';

  @override
  String get debugInfo => 'Hata Ayıklama Bilgisi';

  @override
  String statusStatus(Object status) {
    return 'Durum: $status';
  }

  @override
  String distanceDistance(Object distance) {
    return 'Mesafe: $distance km';
  }

  @override
  String get autoArrivalAutoArrival => '150m içinde otomatik varış';

  @override
  String get actual => 'Gerçek';

  @override
  String get movement => 'Hareket';

  @override
  String get reset => 'Sıfırla';

  @override
  String get north => 'Kuzey';

  @override
  String get closeToPickupLocation => 'Alış konumuna yakın';

  @override
  String get iHaveArrived => 'Vardım';

  @override
  String get userPickedUp => 'Kullanıcı alındı';

  @override
  String get confirmPickedUp => 'Alındığını onayla';

  @override
  String get youHaveArrivedAtYourDestination => 'Hedefinize vardınız';

  @override
  String get completeTrip => 'Yolculuğu Tamamla';

  @override
  String get waitingForDriver => 'Sürücü bekleniyor';

  @override
  String get driverAccepted => 'Sürücü kabul etti';

  @override
  String get driverIsOnTheWay => 'Sürücü yolda';

  @override
  String get driverHasArrived => 'Sürücü vardı';

  @override
  String get youArePickedUp => 'Alındınız';

  @override
  String get onTheWayToDestination => 'Hedefe giderken';

  @override
  String get tripCompleted => 'Yolculuk tamamlandı';

  @override
  String get unknownStatus => 'Bilinmeyen durum';

  @override
  String get mapsMeNavigation => 'Maps.me Navigasyonu';

  @override
  String get mapsMeStyleNavigationInstructions => 'Maps.me tarzı navigasyon talimatları:';

  @override
  String get userNavigation => 'Kullanıcı Navigasyonu';

  @override
  String get arrivedAtPickup => 'Alış Noktasına Vardı';

  @override
  String get arrivedAtDropoff => 'Bırakış Noktasına Vardı';

  @override
  String get pickupPassenger => 'Yolcu Al';

  @override
  String get cancelTrip => 'Yolculuğu İptal Et';

  @override
  String get driverNear => 'Sürücü yakın!';

  @override
  String get driverApproaching => 'Sürücünüz konumunuza yaklaşıyor';

  @override
  String get tripCancelled => 'Yolculuk İptal Edildi';

  @override
  String get tripInProgress => 'Yolculuk Devam Ediyor';

  @override
  String get driverOnWay => 'Sürücü yolda';

  @override
  String get driverArrived => 'Sürücü vardı';

  @override
  String get passengerPickedUp => 'Yolcu alındı';

  @override
  String get arrivedAtDestination => 'Hedefe vardı';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get noNotifications => 'Bildirim yok';

  @override
  String get markAllRead => 'Tümünü okundu olarak işaretle';

  @override
  String get clearAll => 'Tümünü temizle';

  @override
  String get trips => 'Yolculuklar';

  @override
  String get tripHistory => 'Yolculuk Geçmişi';

  @override
  String get activeTrips => 'Aktif Yolculuklar';

  @override
  String get completedTrips => 'Tamamlanan Yolculuklar';

  @override
  String get cancelledTrips => 'İptal Edilen Yolculuklar';

  @override
  String get noActiveTrips => 'Aktif yolculuk yok';

  @override
  String get noCompletedTrips => 'Tamamlanan yolculuk yok';

  @override
  String get noCancelledTrips => 'İptal edilen yolculuk yok';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get settings => 'Ayarlar';

  @override
  String get help => 'Yardım';

  @override
  String get support => 'Destek';

  @override
  String get about => 'Hakkında';

  @override
  String get version => 'Sürüm';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsOfService => 'Kullanım Şartları';

  @override
  String get cancel => 'İptal';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get save => 'Kaydet';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get confirm => 'Onayla';

  @override
  String get back => 'Geri';

  @override
  String get next => 'İleri';

  @override
  String get previous => 'Önceki';

  @override
  String get close => 'Kapat';

  @override
  String get done => 'Tamam';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get warning => 'Uyarı';

  @override
  String get info => 'Bilgi';

  @override
  String get permissions => 'İzinler';

  @override
  String get locationPermission => 'Konum İzni';

  @override
  String get notificationPermission => 'Bildirim İzni';

  @override
  String get cameraPermission => 'Kamera İzni';

  @override
  String get microphonePermission => 'Mikrofon İzni';

  @override
  String get permissionRequired => 'İzin Gerekli';

  @override
  String get permissionDenied => 'İzin Reddedildi';

  @override
  String get permissionGranted => 'İzin Verildi';

  @override
  String get enablePermissions => 'Lütfen gerekli izinleri cihaz ayarlarınızda etkinleştirin.';

  @override
  String get network => 'Ağ';

  @override
  String get noInternetConnection => 'İnternet bağlantısı yok';

  @override
  String get checkConnection => 'Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get serverError => 'Sunucu hatası';

  @override
  String get timeout => 'İstek zaman aşımı';

  @override
  String get connectionError => 'Bağlantı hatası';

  @override
  String get map => 'Harita';

  @override
  String get currentLocation => 'Mevcut Konum';

  @override
  String get destination => 'Hedef';

  @override
  String get route => 'Rota';

  @override
  String get directions => 'Yönler';

  @override
  String get navigation => 'Navigasyon';

  @override
  String get location => 'Konum';

  @override
  String get address => 'Adres';

  @override
  String get coordinates => 'Koordinatlar';

  @override
  String get time => 'Zaman';

  @override
  String get date => 'Tarih';

  @override
  String get duration => 'Süre';

  @override
  String get estimatedTime => 'Tahmini Süre';

  @override
  String get arrivalTime => 'Varış Zamanı';

  @override
  String get departureTime => 'Kalkış Zamanı';

  @override
  String get currency => 'IQD';

  @override
  String get amount => 'Miktar';

  @override
  String get total => 'Toplam';

  @override
  String get subtotal => 'Ara Toplam';

  @override
  String get tax => 'Vergi';

  @override
  String get discount => 'İndirim';

  @override
  String get fee => 'Ücret';

  @override
  String get cost => 'Maliyet';

  @override
  String get fare => 'Ücret';

  @override
  String get statusUserWaiting => 'Kullanıcı Bekliyor';

  @override
  String get statusDriverAccepted => 'Sürücü Kabul Etti';

  @override
  String get statusDriverInWay => 'Sürücü Yolda';

  @override
  String get statusDriverArrived => 'Sürücü Vardı';

  @override
  String get statusUserPickedUp => 'Kullanıcı Alındı';

  @override
  String get statusDriverInProgress => 'Sürücü Devam Ediyor';

  @override
  String get statusDriverArrivedDropoff => 'Sürücü Bırakış Noktasına Vardı';

  @override
  String get statusTripCompleted => 'Yolculuk Tamamlandı';

  @override
  String get statusTripCancelled => 'Yolculuk İptal Edildi';

  @override
  String get status => 'Durum';

  @override
  String get autoArrival => '150m içinde otomatik varış';

  @override
  String get profile => 'Profil';

  @override
  String get trip => 'Yolculuk';

  @override
  String get noTripsAvailable => 'Yolculuk mevcut değil';

  @override
  String get newTripsWillAppearHere => 'Yeni yolculuk talepleri burada otomatik olarak görünecek';

  @override
  String get youWillReceiveNotifications => 'İlinizdeki yeni yolculuklar için bildirim alacaksınız';

  @override
  String get myTrips => 'Yolculuklarım';

  @override
  String get driverId => 'Sürücü ID';

  @override
  String get userId => 'Kullanıcı ID';

  @override
  String get acceptedAt => 'Kabul Edildi';

  @override
  String get completedAt => 'Tamamlandı';

  @override
  String get statusCompleted => 'Tamamlandı';

  @override
  String get statusCancelled => 'İptal Edildi';

  @override
  String get statusInProgress => 'Devam Ediyor';

  @override
  String get statusAccepted => 'Kabul Edildi';

  @override
  String get statusWaiting => 'Bekliyor';

  @override
  String get driver => 'Sürücü';

  @override
  String get driverPhone => 'Sürücü Telefonu';

  @override
  String get driverRating => 'Sürücü Değerlendirmesi';

  @override
  String get cancelTripConfirmation => 'Yolculuğu İptal Et';

  @override
  String get cancelTripMessage => 'Bu yolculuğu iptal etmek istediğinizden emin misiniz?';

  @override
  String get tripCancelledSuccessfully => 'Yolculuk başarıyla iptal edildi';

  @override
  String get waitingForDriverTitle => 'Sürücü bekleniyor...';

  @override
  String get tripCompletedTitle => 'Yolculuk Tamamlandı!';

  @override
  String get thankYouForUsingService => 'Hizmetimizi kullandığınız için teşekkürler';

  @override
  String countdownMessage(Object countdown) {
    return 'Ana sayfaya $countdown saniye içinde dönülüyor';
  }

  @override
  String get returnToHomeNow => 'Şimdi Ana Sayfaya Dön';

  @override
  String errorCancellingTrip(Object error) {
    return 'Yolculuk iptal edilirken hata: $error';
  }

  @override
  String get pickup => 'Alış';

  @override
  String get dropoff => 'Bırakış';

  @override
  String get waitingTime => 'Bekleme Süresi';

  @override
  String get acceptTripButton => 'Yolculuğu Kabul Et';

  @override
  String get viewTripButton => 'Yolculuğu Görüntüle';

  @override
  String errorAcceptingTrip(Object error) {
    return 'Yolculuk kabul edilirken hata: $error';
  }

  @override
  String get insufficientBudgetMessage => 'Yetersiz bütçe';

  @override
  String get viewBudgetButton => 'Bütçeyi Görüntüle';

  @override
  String get budgetInformationTitle => 'Bütçe Bilgisi';

  @override
  String currentBudgetLabel(Object amount, Object budget) {
    return 'Mevcut Bütçe: $amount IQD';
  }

  @override
  String driverNameLabel(Object name) {
    return 'Sürücü: $name';
  }

  @override
  String get addTestBudgetButton => '1000 IQD Ekle (Test)';

  @override
  String budgetAddedMessage(Object amount) {
    return 'Bütçe eklendi: $amount IQD';
  }

  @override
  String errorAddingBudgetMessage(Object error) {
    return 'Bütçe eklenirken hata: $error';
  }

  @override
  String budgetTestMessage(Object currentBudget, Object message) {
    return 'Bütçe testi: $message - Mevcut: $currentBudget IQD';
  }

  @override
  String deductionLabel(Object amount, Object deduction) {
    return 'Kesinti: $amount IQD (%12)';
  }

  @override
  String yourBudgetLabel(Object budget) {
    return 'Bütçeniz: $budget IQD';
  }

  @override
  String get insufficientBudgetLabel => 'Yetersiz bütçe';

  @override
  String get viewBudgetLabel => 'Bütçeyi Görüntüle';

  @override
  String get provinceFilteringTitle => 'İl Filtresi';

  @override
  String get newTripRequestsWillAppearMessage => 'Yeni yolculuk talepleri burada otomatik olarak görünecek';

  @override
  String get youWillReceiveNotificationsMessage => 'İlinizdeki yeni yolculuklar için bildirim alacaksınız';

  @override
  String get refreshButton => 'Yenile';

  @override
  String get retryButton => 'Tekrar Dene';

  @override
  String get loadingTripInformationMessage => 'Yolculuk bilgileri yükleniyor...';

  @override
  String get myTripsTitle => 'Yolculuklarım';

  @override
  String tripNumberLabel(Object id) {
    return 'Yolculuk #$id';
  }

  @override
  String get fromLabel => 'Nereden';

  @override
  String get toLabel => 'Nereye';

  @override
  String get dateLabel => 'Tarih';

  @override
  String get priceLabel => 'Fiyat';

  @override
  String get driverIdLabel => 'Sürücü ID';

  @override
  String get userIdLabel => 'Kullanıcı ID';

  @override
  String get provinceLabel => 'İl';

  @override
  String get acceptedAtLabel => 'Kabul Edildi';

  @override
  String get completedAtLabel => 'Tamamlandı';

  @override
  String get statusCompletedLabel => 'Tamamlandı';

  @override
  String get statusCancelledLabel => 'İptal Edildi';

  @override
  String get statusInProgressLabel => 'Devam Ediyor';

  @override
  String get statusAcceptedLabel => 'Kabul Edildi';

  @override
  String get statusWaitingLabel => 'Bekliyor';

  @override
  String get driverLabel => 'Sürücü';

  @override
  String get driverPhoneLabel => 'Sürücü Telefonu';

  @override
  String get driverRatingLabel => 'Sürücü Değerlendirmesi';

  @override
  String get cancelTripConfirmationTitle => 'Yolculuğu İptal Et';

  @override
  String get cancelTripMessageText => 'Bu yolculuğu iptal etmek istediğinizden emin misiniz?';

  @override
  String get tripCancelledSuccessfullyMessage => 'Yolculuk başarıyla iptal edildi';

  @override
  String errorLoadingTripDetailsMessage(Object error) {
    return 'Yolculuk detayları yüklenirken hata: $error';
  }

  @override
  String get invalidCoordinatesMessage => 'Yolculuk verilerinde geçersiz koordinatlar. Lütfen destek ile iletişime geçin.';

  @override
  String get accountNotActiveMessage => 'Hesabınız aktif değil. Lütfen destek ile iletişime geçin.';

  @override
  String get invalidCoordinatesErrorMessage => 'Yolculuk verilerinde geçersiz koordinatlar. Lütfen destek ile iletişime geçin.';

  @override
  String get driverProfileTitle => 'Sürücü Profili';

  @override
  String get userProfileTitle => 'Kullanıcı Profili';

  @override
  String get carInformationTitle => 'Araç Bilgisi';

  @override
  String get accountInformationTitle => 'Hesap Bilgisi';

  @override
  String get personalInformationTitle => 'Kişisel Bilgi';

  @override
  String get accountTypeLabel => 'Hesap Türü';

  @override
  String get memberSinceLabel => 'Üye Olma Tarihi';

  @override
  String get ratingLabel => 'Değerlendirme';

  @override
  String get accountStatusLabel => 'Durum';

  @override
  String get languageTitle => 'Dil';

  @override
  String currentLanguage(Object flag, Object language) {
    return 'Mevcut: $flag $language';
  }

  @override
  String get tapLanguageToChangeMessage => 'Uygulama dilini değiştirmek için bir dile dokunun';

  @override
  String languageChangedToMessage(Object language) {
    return 'Dil $language olarak değiştirildi';
  }

  @override
  String get languageChangedRestartMessage => 'Dil değiştirildi! Tam etki için lütfen uygulamayı yeniden başlatın.';

  @override
  String get searchLocationTitle => 'Konum Ara';

  @override
  String get pickupLocationLabel => 'Alış Konumu';

  @override
  String get dropoffLocationLabel => 'Bırakış Konumu';

  @override
  String errorGettingLocationMessage(Object error) {
    return 'Konum alınırken hata: $error';
  }

  @override
  String errorSearchingLocationMessage(Object error) {
    return 'Konum aranırken hata: $error';
  }

  @override
  String get pleaseSelectPickupDropoffMessage => 'Lütfen alış ve bırakış konumlarını seçin';

  @override
  String get pleaseEnterBothAddressesMessage => 'Lütfen alış ve bırakış adreslerini girin';

  @override
  String get yourAccountNotActiveMessage => 'Hesabınız aktif değil. Lütfen destek ile iletişime geçin.';

  @override
  String get createTripTitle => 'Yolculuk Oluştur';

  @override
  String distanceKmLabel(Object distance) {
    return '$distance km';
  }

  @override
  String estimatedPriceLabel(Object price) {
    return 'Tahmini Fiyat: $price IQD';
  }

  @override
  String get confirmTripTitle => 'Yolculuğu Onayla';

  @override
  String get tripCreatedMessage => 'Yolculuk başarıyla oluşturuldu!';

  @override
  String errorCreatingTripMessage(Object error) {
    return 'Yolculuk oluşturulurken hata: $error';
  }

  @override
  String get driverNavigationTitle => 'Sürücü Navigasyonu';

  @override
  String get mapsMeStyleNavigationMessage => 'Maps.me tarzı navigasyon - hedefe rota';

  @override
  String get actualMovementTestTitle => 'Gerçek Hareket Testi';

  @override
  String get okButton => 'Tamam';

  @override
  String get mapsMeInfoTitle => 'Maps.me Bilgisi';

  @override
  String get actualPhoneMovementTrackingTitle => 'Gerçek telefon hareket takibi:';

  @override
  String get movePhoneLeftMessage => '1. Telefonu SOLA hareket ettir → Kamera ve araç SOLA takip eder';

  @override
  String get movePhoneRightMessage => '2. Telefonu SAĞA hareket ettir → Kamera ve araç SAĞA takip eder';

  @override
  String get bothFollowActualMovementMessage => '3. Her ikisi de gerçek hareket yönünü takip eder';

  @override
  String get gpsBasedMovementTrackingMessage => '4. GPS tabanlı hareket takibi';

  @override
  String get realTimeMovementFollowingMessage => '5. Gerçek zamanlı hareket takibi';

  @override
  String gpsHeadingCameraCarMessage(Object heading) {
    return 'GPS yönü: $heading°\nKamera ve araç gerçek hareketi takip eder';
  }

  @override
  String get mapsMeStyleFeaturesTitle => 'Maps.me tarzı özellikler:';

  @override
  String get routeToDestinationMessage => '• Hedefe rota';

  @override
  String get gpsBasedNavigationMessage => '• GPS tabanlı navigasyon';

  @override
  String get cleanInterfaceMessage => '• Temiz arayüz';

  @override
  String get noDirectionControlsMessage => '• Yön kontrolleri yok';

  @override
  String get focusOnRoadAheadMessage => '• Öndeki yola odaklan';

  @override
  String get actualMovementTrackingInstructionsTitle => 'Gerçek telefon hareket takibi:';

  @override
  String get tripStatusSuccessMessage => 'Yolculuk durumu başarıyla güncellendi';

  @override
  String get errorUpdatingTripMessage => 'Yolculuk durumu güncellenirken hata';

  @override
  String get speedLabel => 'Hız';

  @override
  String get debugInfoTitle => 'Hata Ayıklama Bilgisi';

  @override
  String statusStatusLabel(Object status) {
    return 'Durum: $status';
  }

  @override
  String distanceDistanceLabel(Object distance) {
    return 'Mesafe: $distance km';
  }

  @override
  String get autoArrivalAutoArrivalLabel => '150m içinde otomatik varış';

  @override
  String get actualLabel => 'Gerçek';

  @override
  String get movementLabel => 'Hareket';

  @override
  String get resetButton => 'Sıfırla';

  @override
  String get northLabel => 'Kuzey';

  @override
  String get closeToPickupLocationMessage => 'Alış konumuna yakın';

  @override
  String get iHaveArrivedButton => 'Vardım';

  @override
  String get userPickedUpButton => 'Kullanıcı alındı';

  @override
  String get confirmPickedUpButton => 'Alındığını onayla';

  @override
  String get youHaveArrivedAtYourDestinationMessage => 'Hedefinize vardınız';

  @override
  String get completeTripButton => 'Yolculuğu Tamamla';

  @override
  String get waitingForDriverMessage => 'Sürücü bekleniyor';

  @override
  String get driverAcceptedMessage => 'Sürücü kabul etti';

  @override
  String get driverIsOnTheWayMessage => 'Sürücü yolda';

  @override
  String get driverHasArrivedMessage => 'Sürücü vardı';

  @override
  String get youArePickedUpMessage => 'Alındınız';

  @override
  String get onTheWayToDestinationMessage => 'Hedefe giderken';

  @override
  String get tripCompletedMessage => 'Yolculuk tamamlandı';

  @override
  String get unknownStatusMessage => 'Bilinmeyen durum';

  @override
  String get mapsMeNavigationTitle => 'Maps.me Navigasyonu';

  @override
  String get mapsMeStyleNavigationInstructionsTitle => 'Maps.me tarzı navigasyon talimatları:';

  @override
  String get userNavigationTitle => 'Kullanıcı Navigasyonu';

  @override
  String get arrivedAtPickupMessage => 'Alış Noktasına Vardı';

  @override
  String get arrivedAtDropoffMessage => 'Bırakış Noktasına Vardı';

  @override
  String get pickupPassengerButton => 'Yolcu Al';

  @override
  String get cancelTripButton => 'Yolculuğu İptal Et';

  @override
  String get driverNearMessage => 'Sürücü yakın!';

  @override
  String get driverApproachingMessage => 'Sürücünüz konumunuza yaklaşıyor';

  @override
  String get tripCancelledMessage => 'Yolculuk İptal Edildi';

  @override
  String get tripInProgressMessage => 'Yolculuk Devam Ediyor';

  @override
  String get driverOnWayMessage => 'Sürücü yolda';

  @override
  String get driverArrivedMessage => 'Sürücü vardı';

  @override
  String get passengerPickedUpMessage => 'Yolcu alındı';

  @override
  String get arrivedAtDestinationMessage => 'Hedefe vardı';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get noNotificationsMessage => 'Bildirim yok';

  @override
  String get markAllReadButton => 'Tümünü okundu olarak işaretle';

  @override
  String get clearAllButton => 'Tümünü temizle';

  @override
  String get tripsTitle => 'Yolculuklar';

  @override
  String get tripHistoryTitle => 'Yolculuk Geçmişi';

  @override
  String get activeTripsTitle => 'Aktif Yolculuklar';

  @override
  String get completedTripsTitle => 'Tamamlanan Yolculuklar';

  @override
  String get cancelledTripsTitle => 'İptal Edilen Yolculuklar';

  @override
  String get noActiveTripsMessage => 'Aktif yolculuk yok';

  @override
  String get noCompletedTripsMessage => 'Tamamlanan yolculuk yok';

  @override
  String get noCancelledTripsMessage => 'İptal edilen yolculuk yok';

  @override
  String get logoutButton => 'Çıkış Yap';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get helpTitle => 'Yardım';

  @override
  String get supportTitle => 'Destek';

  @override
  String get aboutTitle => 'Hakkında';

  @override
  String get versionLabel => 'Sürüm';

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get termsOfServiceTitle => 'Kullanım Şartları';

  @override
  String get cancelButton => 'İptal';

  @override
  String get yesButton => 'Evet';

  @override
  String get noButton => 'Hayır';

  @override
  String get saveButton => 'Kaydet';

  @override
  String get editButton => 'Düzenle';

  @override
  String get deleteButton => 'Sil';

  @override
  String get confirmButton => 'Onayla';

  @override
  String get backButton => 'Geri';

  @override
  String get nextButton => 'İleri';

  @override
  String get previousButton => 'Önceki';

  @override
  String get closeButton => 'Kapat';

  @override
  String get doneButton => 'Tamam';

  @override
  String get loadingMessage => 'Yükleniyor...';

  @override
  String get errorTitle => 'Hata';

  @override
  String get successTitle => 'Başarılı';

  @override
  String get warningTitle => 'Uyarı';

  @override
  String get infoTitle => 'Bilgi';

  @override
  String get permissionsTitle => 'İzinler';

  @override
  String get locationPermissionTitle => 'Konum İzni';

  @override
  String get notificationPermissionTitle => 'Bildirim İzni';

  @override
  String get cameraPermissionTitle => 'Kamera İzni';

  @override
  String get microphonePermissionTitle => 'Mikrofon İzni';

  @override
  String get permissionRequiredTitle => 'İzin Gerekli';

  @override
  String get permissionDeniedMessage => 'İzin Reddedildi';

  @override
  String get permissionGrantedMessage => 'İzin Verildi';

  @override
  String get enablePermissionsMessage => 'Lütfen gerekli izinleri cihaz ayarlarınızda etkinleştirin.';

  @override
  String get networkTitle => 'Ağ';

  @override
  String get noInternetConnectionMessage => 'İnternet bağlantısı yok';

  @override
  String get checkConnectionMessage => 'Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get serverErrorMessage => 'Sunucu hatası';

  @override
  String get timeoutMessage => 'İstek zaman aşımı';

  @override
  String get connectionErrorMessage => 'Bağlantı hatası';

  @override
  String get mapTitle => 'Harita';

  @override
  String get currentLocationLabel => 'Mevcut Konum';

  @override
  String get destinationLabel => 'Hedef';

  @override
  String get routeLabel => 'Rota';

  @override
  String get directionsLabel => 'Yönler';

  @override
  String get navigationTitle => 'Navigasyon';

  @override
  String get locationLabel => 'Konum';

  @override
  String get addressLabel => 'Adres';

  @override
  String get coordinatesLabel => 'Koordinatlar';

  @override
  String get timeLabel => 'Zaman';

  @override
  String get durationLabel => 'Süre';

  @override
  String get estimatedTimeLabel => 'Tahmini Süre';

  @override
  String get arrivalTimeLabel => 'Varış Zamanı';

  @override
  String get departureTimeLabel => 'Kalkış Zamanı';

  @override
  String get currencyLabel => 'IQD';

  @override
  String get amountLabel => 'Miktar';

  @override
  String get totalLabel => 'Toplam';

  @override
  String get subtotalLabel => 'Ara Toplam';

  @override
  String get taxLabel => 'Vergi';

  @override
  String get discountLabel => 'İndirim';

  @override
  String get feeLabel => 'Ücret';

  @override
  String get costLabel => 'Maliyet';

  @override
  String get fareLabel => 'Ücret';

  @override
  String get tripStartedSuccessfully => 'Yolculuk başarıyla başlatıldı!';

  @override
  String errorStartingTrip(Object error) {
    return 'Yolculuk başlatılırken hata: $error';
  }

  @override
  String get tripAcceptedTitle => 'Yolculuk Kabul Edildi';

  @override
  String get userLabel => 'Kullanıcı';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get startTripButton => 'Yolculuğu Başlat';

  @override
  String get errorGettingCurrentLocation => 'Mevcut konum alınırken hata';

  @override
  String get errorGettingRoute => 'Rota alınırken hata';

  @override
  String get pleaseSelectPickupAndDropoffLocations => 'Lütfen alış ve bırakış konumlarını seçin';

  @override
  String get userNotAuthenticated => 'Kullanıcı doğrulanmadı';

  @override
  String get youAlreadyHaveAnActiveTripPleaseWaitForItToBeCompletedOrCancelled => 'Zaten aktif bir yolculuğunuz var. Lütfen tamamlanmasını veya iptal edilmesini bekleyin.';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get baghdad => 'Bağdat';

  @override
  String get userProfileIsIncompletePleaseUpdateYourProfileWithNameAndPhoneNumber => 'Kullanıcı profili eksik. Lütfen adınızı ve telefon numaranızı güncelleyin.';

  @override
  String get notifyingAvailableDrivers => 'Mevcut sürücüler bilgilendiriliyor...';

  @override
  String get failedToGetPredictions => 'Tahminler alınamadı';

  @override
  String get locationIsTooFarFromYourCurrentPositionPleaseSearchForACloserLocation => 'Konum mevcut konumunuzdan çok uzakta. Lütfen daha yakın bir konum arayın.';

  @override
  String get useAnyway => 'Yine de kullan';

  @override
  String get failedToGetPlaceDetails => 'Yer detayları alınamadı';

  @override
  String get errorGettingPlaceDetails => 'Yer detayları alınırken hata';

  @override
  String get destinationSetTo => 'Hedef ayarlandı:';

  @override
  String get creatingTrip => 'Yolculuk oluşturuluyor...';

  @override
  String get bookTrip => 'Yolculuk Yap';

  @override
  String get changeTrip => 'Yolculuğu Değiştir';

  @override
  String get selectLocations => 'Konumları Seç';

  @override
  String get selectedLocation => 'Seçilen Konum';

  @override
  String get searchForDestination => 'Hedef ara...';

  @override
  String get tapToSetAsDestination => 'Hedef olarak ayarla';

  @override
  String get searchForDestinationsWithin50kmOfYourCurrentPosition => 'Mevcut konumunuzdan 50km içinde hedefler arayın';

  @override
  String get notificationNewTripAvailable => 'Yeni Yolculuk Mevcut!';

  @override
  String notificationNewTripMessage(Object province) {
    return '$province bölgesinde yeni bir yolculuk talebi mevcut. Detayları görmek için dokunun.';
  }

  @override
  String get notificationDriverAcceptedTitle => 'Sürücü Yolculuğunuzu Kabul Etti!';

  @override
  String get notificationDriverAcceptedMessage => 'Bir sürücü yolculuk talebinizi kabul etti. Yakında yolda olacaklar.';

  @override
  String get notificationDriverInWayTitle => 'Sürücü Yolda!';

  @override
  String get notificationDriverInWayMessage => 'Sürücünüz alış noktanıza doğru yolda.';

  @override
  String get notificationDriverArrivedTitle => 'Sürücü Vardı!';

  @override
  String get notificationDriverArrivedMessage => 'Sürücünüz alış noktasına vardı.';

  @override
  String get notificationUserPickedUpTitle => 'Yolculuk Başladı!';

  @override
  String get notificationUserPickedUpMessage => 'Alındınız. Yolculuğunuzun tadını çıkarın!';

  @override
  String get notificationTripCompletedTitle => 'Yolculuk Tamamlandı!';

  @override
  String get notificationTripCompletedMessage => 'Yolculuğunuz başarıyla tamamlandı. Hizmetimizi kullandığınız için teşekkürler!';

  @override
  String get notificationTripCancelledTitle => 'Yolculuk İptal Edildi';

  @override
  String get notificationTripCancelledMessage => 'Yolculuğunuz iptal edildi.';

  @override
  String get notificationTripInProgressTitle => 'Yolculuk Devam Ediyor';

  @override
  String get notificationTripInProgressMessage => 'Yolculuğunuz şu anda devam ediyor.';

  @override
  String get notificationDriverArrivedDropoffTitle => 'Hedefe Vardı';

  @override
  String get notificationDriverArrivedDropoffMessage => 'Hedefinize vardınız.';

  @override
  String get notificationDriverInProgressTitle => 'Hedefe Giderken';

  @override
  String get notificationDriverInProgressMessage => 'Sürücünüz sizi hedefinize götürüyor.';

  @override
  String get tripDetailsTitle => 'Yolculuk Detayları';

  @override
  String get distanceLabel => 'Mesafe';

  @override
  String get carLabel => 'Araba';

  @override
  String get insufficientBudgetButton => 'Yetersiz Bütçe';

  @override
  String get tripAcceptedSuccessfully => 'Yolculuk başarıyla kabul edildi!';

  @override
  String tripPriceLabel(Object price) {
    return 'Yolculuk Fiyatı: $price IQD';
  }

  @override
  String get canAffordTripMessage => 'Bu yolculuğun fiyatını karşılayabilirsiniz';

  @override
  String get deductionPercentLabel => 'Kesinti (12%):';

  @override
  String get canAffordThisTripMessage => 'Bu yolculuk karşılanabilir';

  @override
  String get insufficientBudgetShortMessage => 'Yetersiz bütçe';

  @override
  String get pickupPassengerTitle => 'Yolcu Alma';

  @override
  String get yourLocationLabel => 'Konumunuz';

  @override
  String get pickupLabel => 'Alış Konumu';

  @override
  String get dropoffLabel => 'Bırakış Konumu';

  @override
  String get passengerPickedUpSuccessfully => 'Yolcu başarıyla alındı!';

  @override
  String errorDuringPickup(Object error) {
    return 'Hata: $error';
  }

  @override
  String get createNewTripTitle => 'Yeni Yolculuk Oluştur';

  @override
  String get selectLocationsTitle => 'Konumları Seç';

  @override
  String get searchForDestinationsWithin50km => 'Mevcut konumunuzdan 50km içinde hedefler arayın';

  @override
  String get selectedLocationLabel => 'Seçilen Konum';

  @override
  String get searchLocationButton => 'Konum Ara';

  @override
  String get changeTripButton => 'Yolculuğu Değiştir';

  @override
  String get bookTripButton => 'Yolculuk Yap';

  @override
  String get creatingTripMessage => 'Yolculuk oluşturuluyor...';

  @override
  String get youAlreadyHaveAnActiveTrip => 'Zaten aktif bir yolculuğunuz var. Lütfen tamamlanmasını veya iptal edilmesini bekleyin.';

  @override
  String get userProfileIsIncomplete => 'Kullanıcı profili eksik. Lütfen adınızı ve telefon numaranızı güncelleyin.';

  @override
  String get locationIsTooFar => 'Konum mevcut konumunuzdan çok uzakta. Lütfen daha yakın bir konum arayın.';

  @override
  String get useAnywayButton => 'Yine de kullan';

  @override
  String get tripInProgressTitle => 'Yolculuk Devam Ediyor';

  @override
  String get driverLocationLabel => 'Sürücü Konumu';

  @override
  String get driverIsHereMessage => 'Sürücü burada';

  @override
  String get driverIsNearMessage => 'Sürücü yakın!';

  @override
  String get routeOptions => 'Rota Seçenekleri';

  @override
  String get shortest => 'En Kısa';

  @override
  String get reports => 'Raporlar';

  @override
  String get createReport => 'Rapor Oluştur';

  @override
  String get reportTitle => 'Rapor Başlığı';

  @override
  String get reportDescription => 'Rapor Açıklaması';

  @override
  String get reportType => 'Rapor Türü';

  @override
  String get reportPriority => 'Öncelik';

  @override
  String get reportCategory => 'Kategori';

  @override
  String get submitReport => 'Raporu Gönder';

  @override
  String get reportSubmitted => 'Rapor başarıyla gönderildi';

  @override
  String get errorSubmittingReport => 'Rapor gönderilirken hata oluştu';

  @override
  String get bugReport => 'Hata Raporu';

  @override
  String get featureRequest => 'Özellik Talebi';

  @override
  String get complaint => 'Şikayet';

  @override
  String get suggestion => 'Öneri';

  @override
  String get technicalIssue => 'Teknik Sorun';

  @override
  String get other => 'Diğer';

  @override
  String get low => 'Düşük';

  @override
  String get medium => 'Orta';

  @override
  String get high => 'Yüksek';

  @override
  String get urgent => 'Acil';

  @override
  String get pending => 'Beklemede';

  @override
  String get inProgress => 'İşlemde';

  @override
  String get resolved => 'Çözüldü';

  @override
  String get closed => 'Kapalı';
}
