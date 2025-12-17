import 'package:flutter/material.dart';
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
    },
  };

  String translate(String key) {
    return _localizedValues[_appLocale.languageCode]![key] ?? key;
  }
}
