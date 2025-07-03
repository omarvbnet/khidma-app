export interface LocalizedNotification {
  title: string;
  message: string;
}

export interface NotificationLocalizationData {
  province?: string;
  pickupLocation?: string;
  dropoffLocation?: string;
  price?: number;
  distance?: number;
  userFullName?: string;
  userPhone?: string;
  [key: string]: any;
}

// Notification localization service
export class NotificationLocalizationService {
  private static readonly SUPPORTED_LANGUAGES = ['en', 'ar', 'ku', 'tr'];
  private static readonly DEFAULT_LANGUAGE = 'en';

  /**
   * Get localized notification message based on user's language preference
   */
  static getLocalizedNotification(
    notificationType: string,
    language: string = 'en',
    data: NotificationLocalizationData = {}
  ): LocalizedNotification {
    // Validate and normalize language
    const normalizedLanguage = this.normalizeLanguage(language);
    
    // Get the appropriate localization function
    const localizer = this.getLocalizer(normalizedLanguage);
    
    return localizer(notificationType, data);
  }

  /**
   * Normalize language code to supported format
   */
  private static normalizeLanguage(language: string): string {
    const lang = language.toLowerCase().trim();
    return this.SUPPORTED_LANGUAGES.includes(lang) ? lang : this.DEFAULT_LANGUAGE;
  }

  /**
   * Get the appropriate localizer function for the language
   */
  private static getLocalizer(language: string) {
    switch (language) {
      case 'ar':
        return this.arabicLocalizer;
      case 'ku':
        return this.kurdishLocalizer;
      case 'tr':
        return this.turkishLocalizer;
      case 'en':
      default:
        return this.englishLocalizer;
    }
  }

  /**
   * English localizer
   */
  private static englishLocalizer(
    notificationType: string,
    data: NotificationLocalizationData
  ): LocalizedNotification {
    switch (notificationType) {
      case 'NEW_TRIP_AVAILABLE':
        return {
          title: 'New Trip Available!',
          message: `A new trip request is available in ${data.province || 'your area'}. Tap to view details.`
        };

      case 'DRIVER_ACCEPTED':
        return {
          title: 'Driver Accepted Your Trip!',
          message: 'A driver has accepted your trip request. They will be on their way soon.'
        };

      case 'DRIVER_IN_WAY':
        return {
          title: 'Driver is on the Way!',
          message: 'Your driver is heading to your pickup location.'
        };

      case 'DRIVER_ARRIVED':
        return {
          title: 'Driver Has Arrived!',
          message: 'Your driver has arrived at the pickup location.'
        };

      case 'DRIVER_IN_PROGRESS':
        return {
          title: 'On the Way to Destination',
          message: 'Your driver is taking you to your destination.'
        };

      case 'USER_PICKED_UP':
        return {
          title: 'Trip Started!',
          message: 'You have been picked up. Enjoy your ride!'
        };



      case 'TRIP_COMPLETED':
        return {
          title: 'Trip Completed!',
          message: 'Your trip has been completed successfully. Thank you for using our service!'
        };

      case 'TRIP_CANCELLED':
        return {
          title: 'Trip Cancelled',
          message: 'Your trip has been cancelled.'
        };

      case 'TRIP_IN_PROGRESS':
        return {
          title: 'Trip in Progress',
          message: 'Your trip is currently in progress.'
        };

      default:
        return {
          title: 'Notification',
          message: 'You have a new notification.'
        };
    }
  }

  /**
   * Arabic localizer
   */
  private static arabicLocalizer(
    notificationType: string,
    data: NotificationLocalizationData
  ): LocalizedNotification {
    switch (notificationType) {
      case 'NEW_TRIP_AVAILABLE':
        return {
          title: 'رحلة جديدة متاحة!',
          message: `رحلة جديدة متاحة في ${data.province || 'منطقتك'}. اضغط لعرض التفاصيل.`
        };

      case 'DRIVER_ACCEPTED':
        return {
          title: 'قبل السائق رحلتك!',
          message: 'قبل سائق طلب رحلتك. سيكون في الطريق قريباً.'
        };

      case 'DRIVER_IN_WAY':
        return {
          title: 'السائق في الطريق!',
          message: 'سائقك متجه إلى موقع الاستلام.'
        };

      case 'DRIVER_ARRIVED':
        return {
          title: 'وصل السائق!',
          message: 'وصل سائقك إلى موقع الاستلام.'
        };

      case 'DRIVER_IN_PROGRESS':
        return {
          title: 'في الطريق إلى الوجهة',
          message: 'سائقك يأخذك إلى وجهتك.'
        };

      case 'USER_PICKED_UP':
        return {
          title: 'بدأت الرحلة!',
          message: 'تم استلامك. استمتع برحلتك!'
        };



      case 'TRIP_COMPLETED':
        return {
          title: 'اكتملت الرحلة!',
          message: 'اكتملت رحلتك بنجاح. شكراً لاستخدام خدمتنا!'
        };

      case 'TRIP_CANCELLED':
        return {
          title: 'تم إلغاء الرحلة',
          message: 'تم إلغاء رحلتك.'
        };

      case 'TRIP_IN_PROGRESS':
        return {
          title: 'الرحلة قيد التنفيذ',
          message: 'رحلتك قيد التنفيذ حالياً.'
        };

      default:
        return {
          title: 'إشعار',
          message: 'لديك إشعار جديد.'
        };
    }
  }

  /**
   * Kurdish localizer
   */
  private static kurdishLocalizer(
    notificationType: string,
    data: NotificationLocalizationData
  ): LocalizedNotification {
    switch (notificationType) {
      case 'NEW_TRIP_AVAILABLE':
        return {
          title: 'گەشتێکی نوێ بەردەستە!',
          message: `گەشتێکی نوێ بەردەستە لە ${data.province || 'ناوچەکەت'}. کلیک بکە بۆ بینینی وردەکاری.`
        };

      case 'DRIVER_ACCEPTED':
        return {
          title: 'شۆفێر گەشتەکەت قبوڵی کرد!',
          message: 'شۆفێرێک داواکاری گەشتەکەت قبوڵی کرد. بەم زووانە لە ڕێگەدا دەبێت.'
        };

      case 'DRIVER_IN_WAY':
        return {
          title: 'شۆفێر لە ڕێگەدایە!',
          message: 'شۆفێرەکەت بەرەو شوێنی وەرگرتن دەڕوات.'
        };

      case 'DRIVER_ARRIVED':
        return {
          title: 'شۆفێر هات!',
          message: 'شۆفێرەکەت گەیشت بۆ شوێنی وەرگرتن.'
        };

      case 'DRIVER_IN_PROGRESS':
        return {
          title: 'لە ڕێگەدا بۆ ئامانج',
          message: 'شۆفێرەکەت دەتات بەرەو ئامانجەکەت.'
        };

      case 'USER_PICKED_UP':
        return {
          title: 'گەشتەکە دەستی پێکرد!',
          message: 'وەرگیرایت. چێژ لە گەشتەکەت وەربگرە!'
        };



      case 'TRIP_COMPLETED':
        return {
          title: 'گەشتەکە تەواو بوو!',
          message: 'گەشتەکەت بە سەرکەوتوویی تەواو بوو. سوپاس بۆ بەکارهێنانی خزمەتگوزاریەکەمان!'
        };

      case 'TRIP_CANCELLED':
        return {
          title: 'گەشتەکە هەڵوەشێندرایەوە',
          message: 'گەشتەکەت هەڵوەشێندرایەوە.'
        };

      case 'TRIP_IN_PROGRESS':
        return {
          title: 'گەشت لە پڕۆسەدایە',
          message: 'گەشتەکەت لە پڕۆسەدایە.'
        };

      default:
        return {
          title: 'ئاگادارکردنەوە',
          message: 'ئاگادارکردنەوەیەکی نوێت هەیە.'
        };
    }
  }

  /**
   * Turkish localizer
   */
  private static turkishLocalizer(
    notificationType: string,
    data: NotificationLocalizationData
  ): LocalizedNotification {
    switch (notificationType) {
      case 'NEW_TRIP_AVAILABLE':
        return {
          title: 'Yeni Yolculuk Mevcut!',
          message: `${data.province || 'bölgenizde'} yeni bir yolculuk talebi mevcut. Detayları görmek için dokunun.`
        };

      case 'DRIVER_ACCEPTED':
        return {
          title: 'Sürücü Yolculuğunuzu Kabul Etti!',
          message: 'Bir sürücü yolculuk talebinizi kabul etti. Yakında yolda olacaklar.'
        };

      case 'DRIVER_IN_WAY':
        return {
          title: 'Sürücü Yolda!',
          message: 'Sürücünüz alış noktanıza doğru yolda.'
        };

      case 'DRIVER_ARRIVED':
        return {
          title: 'Sürücü Vardı!',
          message: 'Sürücünüz alış noktasına vardı.'
        };

      case 'DRIVER_IN_PROGRESS':
        return {
          title: 'Hedefe Giderken',
          message: 'Sürücünüz sizi hedefinize götürüyor.'
        };

      case 'USER_PICKED_UP':
        return {
          title: 'Yolculuk Başladı!',
          message: 'Alındınız. Yolculuğunuzun tadını çıkarın!'
        };



      case 'TRIP_COMPLETED':
        return {
          title: 'Yolculuk Tamamlandı!',
          message: 'Yolculuğunuz başarıyla tamamlandı. Hizmetimizi kullandığınız için teşekkürler!'
        };

      case 'TRIP_CANCELLED':
        return {
          title: 'Yolculuk İptal Edildi',
          message: 'Yolculuğunuz iptal edildi.'
        };

      case 'TRIP_IN_PROGRESS':
        return {
          title: 'Yolculuk Devam Ediyor',
          message: 'Yolculuğunuz şu anda devam ediyor.'
        };

      default:
        return {
          title: 'Bildirim',
          message: 'Yeni bir bildiriminiz var.'
        };
    }
  }

  /**
   * Get user's preferred language
   */
  static getUserLanguage(user: any): string {
    console.log('🔍 Getting user language for:', {
      userId: user?.id,
      language: user?.language,
      phoneNumber: user?.phoneNumber
    });

    // First check if user has a language field set
    if (user?.language && typeof user.language === 'string') {
      const lang = user.language.toLowerCase().trim();
      console.log(`🌍 User has explicit language setting: ${lang}`);
      
      if (this.SUPPORTED_LANGUAGES.includes(lang)) {
        console.log(`✅ Using user's language preference: ${lang}`);
        return lang;
      } else {
        console.log(`⚠️ User's language '${lang}' is not supported, falling back to phone number heuristic`);
      }
    }

    // Fallback to phone number heuristic for Iraqi users
    if (user?.phoneNumber && user.phoneNumber.startsWith('+964')) {
      console.log('🇮🇶 Iraqi phone number detected, using Arabic');
      return 'ar'; // Arabic for Iraqi phone numbers
    }

    // Check for Kurdish phone numbers (Iraqi Kurdistan)
    if (user?.phoneNumber && (
      user.phoneNumber.startsWith('+9647') || // Mobile numbers in Kurdistan
      user.phoneNumber.startsWith('+9646')    // Mobile numbers in Kurdistan
    )) {
      console.log('🇰🇷 Kurdish region phone number detected, using Kurdish');
      return 'ku'; // Kurdish for Kurdish region phone numbers
    }

    // Default to English
    console.log('🇺🇸 No language preference detected, using English as default');
    return this.DEFAULT_LANGUAGE;
  }
} 