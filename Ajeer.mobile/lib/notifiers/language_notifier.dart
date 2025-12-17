import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  bool get isArabic => _appLocale.languageCode == 'ar';

  LanguageNotifier() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langCode = prefs.getString('language_code');
    if (langCode != null) {
      if (langCode == 'ar') {
        _appLocale = const Locale('ar', 'EG');
      } else {
        _appLocale = Locale(langCode);
      }
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Locale type) async {
    _appLocale = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', type.languageCode);
  }

  void toggleLanguage() {
    if (_appLocale.languageCode == 'en') {
      changeLanguage(const Locale('ar', 'EG'));
    } else {
      changeLanguage(const Locale('en'));
    }
  }

  String convertNumbers(String input) {
    if (!isArabic) return input;
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  String getFormattedDate(DateTime date) {
    if (!isArabic) {
      return DateFormat('MMMM d, y').format(date);
    }

    // Custom Arabic formatting
    final String day = convertNumbers(date.day.toString());
    final String year = convertNumbers(date.year.toString());
    final String month = _arabicMonths[date.month] ?? '';

    return '$month $day، $year';
  }

  String translateCityArea(String input) {
    if (!isArabic) return input;

    List<String> parts = input.split(',');
    List<String> translatedParts = parts.map((part) {
      return translate(part.trim());
    }).toList();

    return translatedParts.join('، ');
  }

  /// Splits a comma-separated string of services, translates each, and rejoins them.
  String translateServices(String input) {
    // Split by comma
    List<String> parts = input.split(',');

    // Translate each part
    List<String> translatedParts = parts.map((part) {
      return translate(part.trim());
    }).toList();

    // Join with appropriate separator
    return translatedParts.join(isArabic ? '، ' : ', ');
  }

  String translateAddress(String input) {
    if (!isArabic) return input;

    String translated = input
        .replaceAll(RegExp(r'\bStreet\b', caseSensitive: false), 'شارع')
        .replaceAll(RegExp(r'\bSt\b', caseSensitive: false), 'شارع')
        .replaceAll(RegExp(r'\bDistrict\b', caseSensitive: false), 'حي');

    return convertNumbers(translated);
  }

  static final Map<int, String> _arabicMonths = {
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'أبريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'darkMode': 'Enable Dark Mode',
      'ajeerInfo': 'Ajeer Info',
      'notifications': 'Notifications',
      'noNotifications': 'No new notifications.',
      'signOut': 'Sign Out',
      'signOutTitle': 'Sign Out',
      'signOutMsg': 'Are you sure you want to sign out?',
      'no': 'No',
      'close': 'Close',
      'infoTitle': 'Ajeer Info',
      'infoMsg':
          'Ajeer connects customers with professional service providers for a seamless experience.',
      'profile': 'Profile',
      'chat': 'Chat',
      'bookings': 'Bookings',
      'home': 'Home',
      'appName': 'Ajeer',
      'selectService': 'Select a service',
      'searchHint': 'Search for a service',
      'fetchingError': 'Error fetching services: ',

      'selectUnitType': 'Select unit type(s)',
      'selectAtLeastOne': 'Please select at least one unit type first.',
      'noUnitsAvailable': 'No unit types available for this service.',
      'estTime': 'Est. Time',
      'hr': 'hr',
      'hrs': 'hrs',
      'min': 'min',
      'mins': 'mins',
      'jod': 'JOD',

      'selectDateTime': 'Select date & time',
      'custom': 'Custom',
      'instant': 'Instant',
      'selectDate': 'Select Date',
      'selectTime': 'Select Time',
      'instantBookingMsg':
          'An Ajeer will be assigned to you as soon as possible based on availability.',

      'pickLocation': 'Pick a location',
      'selectAreaInstruction':
          'Select your area. This will be used to determine your Ajeer!',
      'cityPicker': 'City Picker',
      'areaPicker': 'Area Picker',
      'selectCityFirst': 'Select a city first.',
      'noAreas': 'No areas available.',
      'selectAreaWarning':
          'Please select an area and ensure location is picked.',
      'errorValidating': 'Error validating area selection.',
      'unnamedLocation': 'Unnamed location',

      'uploadMedia': 'Upload media',
      'mediaDescription':
          'Add a photo, video, or audio recording describing your problem',
      'photo': 'Photo',
      'video': 'Video',
      'audio': 'Audio',
      'selectFromGallery': 'Select from Gallery',
      'recordAudio': 'Record Audio',
      'camera': 'Camera',
      'addPhoto': 'Add Photo',
      'addVideo': 'Add Video',
      'addAudio': 'Add Audio',
      'descriptionHint': 'Write a description of your problem (Optional)',
      'save': 'Save',
      'descriptionSaved': 'Description Saved',
      'audioNotImplemented': 'Audio from files not implemented in simulation.',
      'audioSimulated': 'Audio recording is simulated.',

      'confirmBooking': 'Confirm your booking',
      'estimatedCost': 'Estimated Cost',
      'estDuration': 'Est. Duration',
      'customerNote': 'Customer Note',
      'uploadedMedia': 'Uploaded Media',
      'noImages': 'No images uploaded.',
      'noVideos': 'No videos uploaded.',
      'noAudio': 'No audio uploaded.',
      'instantBooking': 'Instant Booking',

      'Plumbing': 'Plumbing',
      'Electrical': 'Electrical',
      'Cleaning': 'Cleaning',
      'Painting': 'Painting',
      'Carpentry': 'Carpentry',
      'Appliance Repair': 'Appliance Repair',
      'Gardening': 'Gardening',
      'IT Support': 'IT Support',
      'Moving & Delivery': 'Moving & Delivery',

      'Leak Repair': 'Leak Repair',
      'Pipe Installation': 'Pipe Installation',
      'Drain Cleaning': 'Drain Cleaning',
      'Light Fixture Installation': 'Light Fixture Installation',
      'Wiring Maintenance': 'Wiring Maintenance',
      'Home Deep Cleaning': 'Home Deep Cleaning',
      'Office Cleaning': 'Office Cleaning',
      'Carpet Cleaning': 'Carpet Cleaning',
      'Interior Painting': 'Interior Painting',
      'Exterior Painting': 'Exterior Painting',
      'Door Installation': 'Door Installation',
      'Furniture Repair': 'Furniture Repair',
      'AC Repair': 'AC Repair',
      'Fridge Maintenance': 'Fridge Maintenance',
      'Washing Machine Repair': 'Washing Machine Repair',
      'Grass Cutting': 'Grass Cutting',
      'Garden Design': 'Garden Design',
      'Laptop Repair': 'Laptop Repair',
      'Network Setup': 'Network Setup',
      'Software Installation': 'Software Installation',
      'Home Moving': 'Home Moving',
      'Office Relocation': 'Office Relocation',
      'Furniture Delivery': 'Furniture Delivery',

      'Amman': 'Amman',
      'Abdoun': 'Abdoun',
      'Jabal Al-Weibdeh': 'Jabal Al-Weibdeh',
      'Shmeisani': 'Shmeisani',
      'Al-Rabieh': 'Al-Rabieh',
      'Dabouq': 'Dabouq',
      'Al-Jubeiha': 'Al-Jubeiha',
      'Al-Bayader': 'Al-Bayader',
      "Tla' Al-Ali": "Tla' Al-Ali",

      // Client Bookings Screen
      'active': 'Active',
      'pending': 'Pending',
      'closed': 'Closed',
      'noBookings': 'No bookings here.',
      'cancel': 'Cancel',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'rejected': 'Rejected',
      'cancelBooking': 'Cancel Booking',
      'cancelBookingMsg': 'Are you sure you want to cancel this booking?',
      'confirm': 'Confirm',
      'back': 'Back',
      'messageProvider': 'Message Provider',
      'messageProviderMsg': 'Would you like to message',
      'message': 'Message',
      'review': 'Review',
      'yourReview': 'Your Review',
      'leaveComment': 'Leave a comment...',
      'submit': 'Submit',
      'details': 'Details',
      'serviceLabel': 'Service(s)',
      'providerLabel': 'Provider',
      'phoneLabel': 'Phone',
      'areaLabel': 'Area',
      'addressLabel': 'Address',
      'dateLabel': 'Date',
      'timeLabel': 'Time',
      'priceLabel': 'Price',
      'notesLabel': 'Notes',
      'attachmentsLabel': 'Attachments',
      'bookingCancelled': 'Booking cancelled successfully',
      'cancelFailed': 'Failed to cancel booking',
      'loadDetailsFailed': 'Could not load booking details',
      'loadLocationFailed': 'Could not load location data',
      'am': 'AM',
      'pm': 'PM',

      // Provider Bookings Screen
      'noJobs': 'No jobs found.',
      'actionFailed': 'Action failed. Please try again.',
      'bookingActionCancelled': 'Booking cancelled.',
      'bookingActionAccepted': 'Booking accepted.',
      'bookingActionRejected': 'Booking rejected.',
      'bookingActionCompleted': 'Booking completed.',
      'accept': 'Accept',
      'reject': 'Reject',
      'complete': 'Complete',
      'rejectBooking': 'Reject Booking',
      'rejectBookingMsg': 'Reject this request?',
      'completeJob': 'Complete Job',
      'completeJobMsg': 'Mark this job as completed?',
      'messageCustomer': 'Message Customer',
      'customerLabel': 'Customer',
    },
    'ar': {
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'darkMode': 'الوضع الليلي',
      'ajeerInfo': 'معلومات أجير',
      'notifications': 'الإشعارات',
      'noNotifications': 'لا توجد إشعارات جديدة.',
      'signOut': 'تسجيل الخروج',
      'signOutTitle': 'تسجيل الخروج',
      'signOutMsg': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'no': 'لا',
      'close': 'إغلاق',
      'infoTitle': 'معلومات أجير',
      'infoMsg': 'أجير يربط العملاء بمقدمي الخدمات المحترفين لتجربة سلسة.',
      'profile': 'الملف الشخصي',
      'chat': 'المحادثات',
      'bookings': 'الحجوزات',
      'home': 'الرئيسية',
      'appName': 'أجير',
      'selectService': 'اختر خدمة',
      'searchHint': 'ابحث عن خدمة',
      'fetchingError': 'خطأ في جلب الخدمات: ',

      'selectUnitType': 'اختر نوع الخدمة',
      'selectAtLeastOne': 'الرجاء اختيار نوع وحدة واحد على الأقل.',
      'noUnitsAvailable': 'لا توجد أنواع وحدات متاحة لهذه الخدمة.',
      'estTime': 'الوقت المقدر',
      'hr': 'ساعة',
      'hrs': 'ساعة',
      'min': 'دقيقة',
      'mins': 'دقيقة',
      'jod': 'دينار',

      'selectDateTime': 'اختر التاريخ والوقت',
      'custom': 'مخصص',
      'instant': 'فوري',
      'selectDate': 'اختر التاريخ',
      'selectTime': 'اختر الوقت',
      'instantBookingMsg':
          'سيتم تعيين أجير لك في أقرب وقت ممكن بناءً على التوفر.',

      'pickLocation': 'اختر موقعاً',
      'selectAreaInstruction': 'اختر منطقتك. سيتم استخدام هذا لتحديد أجيرك!',
      'cityPicker': 'اختر المدينة',
      'areaPicker': 'اختر المنطقة',
      'selectCityFirst': 'اختر مدينة أولاً.',
      'noAreas': 'لا توجد مناطق متاحة.',
      'selectAreaWarning': 'الرجاء اختيار منطقة والتأكد من تحديد الموقع.',
      'errorValidating': 'خطأ في التحقق من اختيار المنطقة.',
      'unnamedLocation': 'موقع غير مسمى',

      'uploadMedia': 'تحميل الوسائط',
      'mediaDescription': 'أضف صورة أو فيديو أو تسجيل صوتي يصف مشكلتك',
      'photo': 'صورة',
      'video': 'فيديو',
      'audio': 'صوت',
      'selectFromGallery': 'اختر من المعرض',
      'recordAudio': 'تسجيل صوت',
      'camera': 'الكاميرا',
      'addPhoto': 'إضافة صورة',
      'addVideo': 'إضافة فيديو',
      'addAudio': 'إضافة صوت',
      'descriptionHint': 'اكتب وصفاً لمشكلتك (اختياري)',
      'save': 'حفظ',
      'descriptionSaved': 'تم حفظ الوصف',
      'audioNotImplemented': 'الصوت من الملفات غير متاح في المحاكاة.',
      'audioSimulated': 'تسجيل الصوت محاكى.',

      'confirmBooking': 'تأكيد الحجز',
      'estimatedCost': 'التكلفة التقديرية',
      'estDuration': 'الوقت المقدر',
      'customerNote': 'ملاحظات العميل',
      'uploadedMedia': 'الوسائط المرفوعة',
      'noImages': 'لا يوجد صور مرفوعة.',
      'noVideos': 'لا يوجد فيديو مرفوع.',
      'noAudio': 'لا يوجد صوت مرفوع.',
      'instantBooking': 'حجز فوري',

      'Plumbing': 'سباكة',
      'Electrical': 'كهرباء',
      'Cleaning': 'تنظيف',
      'Painting': 'دهان',
      'Carpentry': 'نجارة',
      'Appliance Repair': 'تصليح أجهزة',
      'Gardening': 'بستنة',
      'IT Support': 'دعم تقني',
      'Moving & Delivery': 'نقل وتوصيل',

      'Leak Repair': 'إصلاح التسريب',
      'Pipe Installation': 'تركيب الأنابيب',
      'Drain Cleaning': 'تنظيف المصارف',
      'Light Fixture Installation': 'تركيب وحدات الإضاءة',
      'Wiring Maintenance': 'صيانة الأسلاك',
      'Home Deep Cleaning': 'تنظيف منزلي عميق',
      'Office Cleaning': 'تنظيف مكاتب',
      'Carpet Cleaning': 'تنظيف سجاد',
      'Interior Painting': 'دهان داخلي',
      'Exterior Painting': 'دهان خارجي',
      'Door Installation': 'تركيب أبواب',
      'Furniture Repair': 'إصلاح أثاث',
      'AC Repair': 'تصليح مكيفات',
      'Fridge Maintenance': 'صيانة ثلاجات',
      'Washing Machine Repair': 'تصليح غسالات',
      'Grass Cutting': 'قص العشب',
      'Garden Design': 'تصميم حدائق',
      'Laptop Repair': 'تصليح لابتوب',
      'Network Setup': 'إعداد الشبكة',
      'Software Installation': 'تنصيب برامج',
      'Home Moving': 'نقل أثاث منزلي',
      'Office Relocation': 'نقل مكاتب',
      'Furniture Delivery': 'توصيل أثاث',

      'Amman': 'عمان',
      'Abdoun': 'عبدون',
      'Jabal Al-Weibdeh': 'جبل اللويبدة',
      'Shmeisani': 'الشميساني',
      'Al-Rabieh': 'الرابية',
      'Dabouq': 'دابوق',
      'Al-Jubeiha': 'الجبيهة',
      'Al-Bayader': 'البيادر',
      "Tla' Al-Ali": 'تلاع العلي',

      // Client Bookings Screen
      'active': 'نشط',
      'pending': 'معلق',
      'closed': 'مغلق',
      'noBookings': 'لا توجد حجوزات.',
      'cancel': 'إلغاء',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
      'rejected': 'مرفوض',
      'cancelBooking': 'إلغاء الحجز',
      'cancelBookingMsg': 'هل أنت متأكد أنك تريد إلغاء هذا الحجز؟',
      'confirm': 'تأكيد',
      'back': 'رجوع',
      'messageProvider': 'مراسلة المزود',
      'messageProviderMsg': 'هل تود مراسلة',
      'message': 'مراسلة',
      'review': 'تقييم',
      'yourReview': 'تقييمك',
      'leaveComment': 'أترك تعليقاً...',
      'submit': 'إرسال',
      'details': 'التفاصيل',
      'serviceLabel': 'الخدمة/الخدمات',
      'providerLabel': 'المزود',
      'phoneLabel': 'الهاتف',
      'areaLabel': 'المنطقة',
      'addressLabel': 'العنوان',
      'dateLabel': 'التاريخ',
      'timeLabel': 'الوقت',
      'priceLabel': 'السعر',
      'notesLabel': 'ملاحظات',
      'attachmentsLabel': 'المرفقات',
      'bookingCancelled': 'تم إلغاء الحجز بنجاح',
      'cancelFailed': 'فشل إلغاء الحجز',
      'loadDetailsFailed': 'تعذر تحميل تفاصيل الحجز',
      'loadLocationFailed': 'تعذر تحميل بيانات الموقع',
      'am': 'صباحاً',
      'pm': 'مساءً',

      // Provider Bookings Screen
      'noJobs': 'لا توجد وظائف.',
      'actionFailed': 'فشل الإجراء. حاول مرة أخرى.',
      'bookingActionCancelled': 'تم إلغاء الحجز.',
      'bookingActionAccepted': 'تم قبول الحجز.',
      'bookingActionRejected': 'تم رفض الحجز.',
      'bookingActionCompleted': 'تم إكمال الحجز.',
      'accept': 'قبول',
      'reject': 'رفض',
      'complete': 'إكمال',
      'rejectBooking': 'رفض الحجز',
      'rejectBookingMsg': 'هل تود رفض هذا الطلب؟',
      'completeJob': 'إكمال العمل',
      'completeJobMsg': 'هل تود تحديد هذا العمل كمكتمل؟',
      'messageCustomer': 'مراسلة العميل',
      'customerLabel': 'العميل',
    },
  };

  String translate(String key) {
    return _localizedValues[_appLocale.languageCode]![key] ?? key;
  }
}
