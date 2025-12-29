import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  bool get isArabic => _appLocale.languageCode == 'ar';

  String? get currentFontFamily {
    if (isArabic) {
      return 'font';
    }
    return null;
  }

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

    final String day = convertNumbers(date.day.toString());
    final String year = convertNumbers(date.year.toString());
    final String month = _arabicMonths[date.month] ?? '';

    return '$month $day، $year';
  }

  String getNumericDate(DateTime date) {
    final formatter = DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(date);
    return convertNumbers(formatted);
  }

  String translateCityArea(String input) {
    if (!isArabic) return input;
    List<String> parts = input.split(',');
    List<String> translatedParts = parts.map((part) {
      return translate(part.trim());
    }).toList();
    return translatedParts.join('، ');
  }

  String translateServices(String input) {
    if (input.isEmpty) return input;

    List<String> parts = input.split(',');

    List<String> translatedParts = parts.map((part) {
      String serviceKey = part.trim();
      return translate(serviceKey);
    }).toList();

    return translatedParts.join(isArabic ? '، ' : ', ');
  }

  String translateStringList(List<String> items) {
    List<String> translated = items
        .map((item) => translate(item.trim()))
        .toList();
    return translated.join(isArabic ? '، ' : ', ');
  }

  String translateAddress(String input) {
    if (!isArabic) return input;
    String translated = input
        .replaceAll(RegExp(r'\bStreet\b', caseSensitive: false), 'شارع')
        .replaceAll(RegExp(r'\bSt\b', caseSensitive: false), 'شارع')
        .replaceAll(RegExp(r'\bDistrict\b', caseSensitive: false), 'حي');
    return convertNumbers(translated);
  }

  String translateDay(String day) {
    return translate(day);
  }

  String translateTimeRange(String timeRange) {
    if (!isArabic) return timeRange;
    String translated = timeRange
        .replaceAll('AM', translate('am'))
        .replaceAll('PM', translate('pm'));
    return convertNumbers(translated);
  }

  String translateTimeAgo(String input) {
    if (!isArabic) return input;

    final lowerInput = input.toLowerCase().trim();

    if (lowerInput == 'just now') return translate('justNow');
    if (lowerInput == 'yesterday') return translate('yesterday');

    final daysRegex = RegExp(r'(\d+)\s+days?\s+ago', caseSensitive: false);
    final hoursRegex = RegExp(
      r'(\d+)\s+(hours?|hrs?)\s+ago',
      caseSensitive: false,
    );
    final minutesRegex = RegExp(
      r'(\d+)\s+(minutes?|mins?)\s+ago',
      caseSensitive: false,
    );

    if (daysRegex.hasMatch(input)) {
      final match = daysRegex.firstMatch(input);
      final count = match!.group(1);
      return 'منذ ${convertNumbers(count!)} ${translate('days')}';
    }
    if (hoursRegex.hasMatch(input)) {
      final match = hoursRegex.firstMatch(input);
      final count = match!.group(1);
      return 'منذ ${convertNumbers(count!)} ${translate('hours')}';
    }
    if (minutesRegex.hasMatch(input)) {
      final match = minutesRegex.firstMatch(input);
      final count = match!.group(1);
      return 'منذ ${convertNumbers(count!)} ${translate('minutes')}';
    }

    String translated = input;
    final monthMap = {
      'Jan': 'يناير',
      'Feb': 'فبراير',
      'Mar': 'مارس',
      'Apr': 'أبريل',
      'May': 'مايو',
      'Jun': 'يونيو',
      'Jul': 'يوليو',
      'Aug': 'أغسطس',
      'Sep': 'سبتمبر',
      'Oct': 'أكتوبر',
      'Nov': 'نوفمبر',
      'Dec': 'ديسمبر',
    };

    monthMap.forEach((en, ar) {
      translated = translated.replaceAll(en, ar);
    });

    return convertNumbers(translateTimeRange(translated));
  }

  String translateAuthError(String message) {
    if (!isArabic) return message;

    if (message.contains("Invalid identifier or password")) {
      return translate('invalidCredentials');
    }
    if (message.contains("User with this email or phone already exists")) {
      return translate('userAlreadyExists');
    }
    if (message.contains("User with this email or phone already exists")) {
      return translate('userAlreadyExists');
    }
    if (message.contains("SocketConnection failed") ||
        message.contains("Network is unreachable")) {
      return translate('networkError');
    }

    return message;
  }

  String translateBackendError(String message) {
    if (!isArabic) return message;
    final cleanMessage = message.replaceAll("Exception:", "").trim();
    if (cleanMessage.contains("User not found")) {
      return translate('user_not_found');
    }
    if (cleanMessage.contains(
      "User is already registered as a service provider",
    )) {
      return translate('provider_already_registered');
    }
    if (cleanMessage.contains("Provider profile not found")) {
      return translate('provider_profile_not_found');
    }
    if (cleanMessage.contains("Provider application not found")) {
      return translate('provider_application_not_found');
    }
    if (cleanMessage.contains("Provider not found")) {
      return translate('provider_not_found');
    }
    return translateAuthError(cleanMessage);
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
      'paymentFailed': 'Payment failed. Please try again.',
      'failedToLoadPlans': 'Failed to load subscription plans.',
      'networkError':
          'Could not connect to server. Please check your internet connection.',
      'invalidCredentials': 'Login failed: Invalid identifier or password.',
      'userAlreadyExists':
          'Registration failed: User with this email or phone already exists.',
      'settings': 'Settings',
      'language': 'Language',
      'darkMode': 'Dark Mode',
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
      'am': 'AM',
      'pm': 'PM',
      'jod': 'JOD',
      'USD': 'USD',
      'confirm': 'Confirm',
      'back': 'Back',
      'cancel': 'Cancel',
      'save': 'Save',
      'error': 'Error: ',
      'retry': 'Retry',
      'loginTitle': 'Login',
      'emailOrPhoneHint': 'Email or phone number',
      'passwordHint': 'Password',
      'forgotPassword': 'Forgot?',
      'dontHaveAccount': "Don't have an account? ",
      'signUp': 'Sign up',
      'signUpGoogle': 'Sign up using Google',
      'loginButton': 'LOGIN',
      'emailOrPhoneRequired': 'Email Or Phone is required.',
      'emailOrPhoneTooLong': 'Email Or Phone cannot exceed 100 characters.',
      'passwordRequired': 'Password is required.',
      'passwordTooShort': 'Password must be at least 8 characters.',
      'createAccount': 'Create Account',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'nameRequired': 'Name is required.',
      'phoneNumber': 'Phone Number',
      'phoneRequired': 'Phone number is required.',
      'phoneTooLong': 'Phone number cannot exceed 20 characters.',
      'email': 'Email',
      'emailRequired': 'Email is required.',
      'emailTooLong': 'Email cannot exceed 100 characters.',
      'emailInvalid': 'A valid email address is required.',
      'confirmPassword': 'Confirm Password',
      'passwordsDoNotMatch': 'Passwords do not match',
      'signUpButton': 'SIGN UP',
      'alreadyHaveAccount': 'Already have an account? ',
      'logIn': 'Log in',
      'fullNameTooLong': 'Full name cannot exceed 100 characters.',
      'accountCreated': 'Account created successfully! Please login.',
      'resetPasswordTitle': 'Reset Password',
      'resetMethodDesc': 'How would you like to reset your password?',
      'resetUsingEmail': 'Reset using Email',
      'resetUsingPhone': 'Reset using Phone',
      'enterEmailTitle': 'Enter Email',
      'enterPhoneTitle': 'Enter Phone Number',
      'emailHintExample': 'your-email@example.com',
      'phoneHintExample': '+962 7XXXXXXXX',
      'enterYourEmail': 'Please enter your email.',
      'enterYourPhone': 'Please enter your phone number.',
      'newPassword': 'New Password',
      'confirmNewPassword': 'Confirm New Password',
      'enterNewPassword': 'Please enter a new password.',
      'passwordTooShortReset': 'Password must be at least 6 characters long.',
      'confirmYourPassword': 'Please confirm your password.',
      'continueBtn': 'Continue',
      'conversations': 'Conversations',
      'searchChats': 'Search chats...',
      'errorLoadingChats': 'Error loading chats',
      'noConversations': 'No conversations found.',
      'typeMessage': 'Type a message...',
      'messageCopied': 'Message copied!',
      'sendFailed': 'Failed to send message',
      'deleteFailed': 'Failed to delete message',
      'justNow': 'Just now',
      'yesterday': 'Yesterday',
      'days': 'days',
      'hours': 'hours',
      'minutes': 'minutes',
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
      'Studio': 'Studio',
      '1 Bedroom': '1 Bedroom',
      '2 Bedrooms': '2 Bedrooms',
      '3 Bedrooms': '3 Bedrooms',
      'Villa': 'Villa',
      'Small': 'Small',
      'Medium': 'Medium',
      'Large': 'Large',
      'Standard': 'Standard',
      'Deep Clean': 'Deep Clean',
      'Regular Clean': 'Regular Clean',
      'Full Service': 'Full Service',
      'Basic': 'Basic',
      'Premium': 'Premium',
      'myProfile': 'My Profile',
      'fullName': 'Full Name',
      'mobileNumber': 'Mobile Number',
      'email': 'Email',
      'password': 'Password',
      'changePassword': 'Change Password',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'required': 'Required',
      'min6Chars': 'Min 6 chars',
      'update': 'Update',
      'edit': 'Edit',
      'becomeAjeer': 'Become an Ajeer!',
      'switchToCustomer': 'Switch to Customer Mode',
      'switchToProvider': 'Switch to Provider Mode',
      'providerInfo': 'Provider Information',
      'myServices': 'My Services',
      'myLocations': 'My Locations',
      'mySchedule': 'My Schedule',
      'noServices': 'No services.',
      'noLocations': 'No locations.',
      'noSchedule': 'No schedule.',
      'profileUpdated': 'Profile updated successfully!',
      'updateFailed': 'Update failed: ',
      'passwordChanged': 'Password changed successfully!',
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
      'Amman': 'Amman',
      'Abdoun': 'Abdoun',
      'Jabal Al-Weibdeh': 'Jabal Al-Weibdeh',
      'Shmeisani': 'Shmeisani',
      'Al-Rabieh': 'Al-Rabieh',
      'Dabouq': 'Dabouq',
      'Al-Jubeiha': 'Al-Jubeiha',
      'Al-Bayader': 'Al-Bayader',
      "Tla' Al-Ali": "Tla' Al-Ali",
      'pickLocationPlural': 'Pick location(s)',
      'locationSelectionDesc':
          'Select the cities and areas where you will be providing your services.',
      'selectedLocations': 'Selected Locations',
      'addLocation': 'Add Location',
      'selectAreasToAdd': 'Select Areas to Add',
      'noCitiesAvailable': 'No cities available\nor all added.',
      'noCitySelection': 'No city available for selection.',
      'noAreasFound': 'No areas found for',
      'search': 'Search',
      'selectServiceTitle': 'Select service',
      'selectServiceDesc': 'Select the service category you want to provide.',
      'searchService': 'Search for a service',
      'loadServicesFailed':
          'Failed to load services. Please check your connection.',
      'selectUnitTypesFor': 'Select unit type(s) for',
      'timeSlotsFor': 'Time Slots for',
      'selectDayToSchedule': 'Select a Day to Schedule Time',
      'startTime': 'Start Time',
      'endTime': 'End Time',
      'startTimeError': 'Start time must be before end time.',
      'overlapError':
          'The selected time slot overlaps with an existing one or is a duplicate.',
      'saveScheduleFor': 'Save Schedule for',
      'addTimeSlotsToSave': 'Add Time Slots to Save',
      'workDaysHours': 'Work Days & Hours',
      'scheduleDesc': 'Schedule your work days and hours.',
      'allDaysScheduled': 'All days have been scheduled!',
      'saveChanges': 'Save Changes?',
      'freeTrialMsg':
          'Start providing your services to customers and using the Ajeer App for free for 30 days. After this period, you will need to subscribe to continue.',
      'unexpectedError': 'An unexpected error occurred.',
      'confirmBooking': 'Confirm your booking',
      'estimatedCost': 'Estimated Cost',
      'estDuration': 'Est. Duration',
      'customerNote': 'Customer Note',
      'uploadedMedia': 'Uploaded Media',
      'noImages': 'No images uploaded.',
      'noVideos': 'No videos uploaded.',
      'noAudio': 'No audio uploaded.',
      'uploadMedia': 'Upload media',
      'mediaDescription': 'Add a photo or a video describing your problem',
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
      'descriptionSaved': 'Description Saved',
      'audioNotImplemented': 'Audio from files not implemented in simulation.',
      'audioSimulated': 'Audio recording is simulated.',
      'active': 'Active',
      'pending': 'Pending',
      'closed': 'Closed',
      'noBookings': 'No bookings here.',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'rejected': 'Rejected',
      'cancelBooking': 'Cancel Booking',
      'cancelBookingMsg': 'Are you sure you want to cancel this booking?',
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
      'customerLabel': 'Customer',
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
      'Monday': 'Monday',
      'Tuesday': 'Tuesday',
      'Wednesday': 'Wednesday',
      'Thursday': 'Thursday',
      'Friday': 'Friday',
      'Saturday': 'Saturday',
      'Sunday': 'Sunday',
      'newBookingConf': 'New Booking Confirmation',
      'bookingConfMsg': 'Your booking #1023 is confirmed.',
      'providerAssigned': 'Provider Assigned',
      'providerAssignedMsg': 'John Doe has been assigned.',
      'paymentReminder': 'Payment Reminder',
      'paymentReminderMsg': 'Service fee due tomorrow.',
      'providerSubscription': 'Provider Subscription',
      'noActivePlan': 'No active plan',
      'expiresOn': 'Expires on',
      'renewOrUpgrade': 'Renew or Upgrade',
      'choosePlan': 'Choose Plan',
      'paymentSuccess': 'Payment successful!',
      '1 Month Plan': '1 Month Plan',
      '3 Month Plan': '3 Month Plan',
      'days_duration': 'days',

      // Notifications
      'notifNewRequestTitle': 'New Booking Request',
      'notifNewRequestMsg': 'You have received a new booking request.',
      'notifAcceptedTitle': 'Booking Accepted',
      'notifAcceptedMsg': 'Your booking has been accepted.',
      'notifAcceptedByMsg': 'Your booking has been accepted by {name}.',
      'notifCancelledTitle': 'Booking Cancelled',
      'notifCancelledMsg': 'The booking was cancelled by the customer.',
      'notifCancelledByMsg': 'Booking cancelled by {name}.',
      'notifReassignedTitle': 'Booking Reassigned',
      'notifReassignedMsg': 'We found a new provider for your request.',
      'notifReassignedAutoMsg':
          'Your provider {name} cancelled. We found a new provider for you automatically.',
      'notifCompletedTitle': 'Booking Completed',
      'notifCompletedMsg':
          'Your service has been completed. Please leave a review!',
      'notifReviewTitle': 'New Review Received!',
      'notifReviewMsg': 'A customer has left a review for your service.',
      'notifReviewStarsMsg':
          'A customer has rated your service. You received {rating} stars!',
      'notifDefaultTitle': 'Notification',
      'notifDefaultMsg': 'You have a new notification.',
      'sendFailed': 'Failed to send message',
      'reviewSubmitted': 'Review submitted successfully!',
      'reviewFailed': 'Failed to submit review.',
      'noReviewFound': 'No review found for this booking.',
      'searchService': 'Search for a service',
      'loadServicesFailed':
          'Failed to load services. Please check your connection.',
      'selectUnitTypesFor': 'Select unit type(s) for',
      'locationError': 'Error loading location data',
      'fetchingServiceAreas': 'Fetching available service areas...',
      'startTimeError': 'Start time must be before end time.',
      'overlapError': 'The selected time slot overlaps with an existing one.',
      'unexpectedError': 'An unexpected error occurred. Please try again.',
      'fetchingError': 'Error fetching services:',
      'selectAtLeastOne': 'Please select at least one unit type first.',
      'custom': 'Custom',
      'instant': 'Instant',
      'selectDate': 'Select Date',
      'selectTime': 'Select Time',
      'instantBookingMsg':
          'An Ajeer will be assigned to you as soon as possible based on availability.',
      'errorValidating': 'Error validating area selection.',
      'bookingSuccess': 'Your booking has been created successfully!',
      'bookingFailed': 'Failed to create booking. Please try again.',
      'serviceAreaUnavailable': 'The requested Service Area is not available.',
      'noProvidersAvailable':
          'No service providers are currently available for these services in your area at this time.',
      'bookingNotFound': 'Booking not found.',
      'unauthorizedBookingView':
          'You are not authorized to view these booking details.',
      'noReplacementFound': 'You cannot cancel, no replacement found',
      'The requested Service Area is not available.':
          'The requested Service Area is not available.',
      'No service providers are currently available for these services in your area at this time.':
          'No service providers are currently available for these services in your area at this time.',
      'selectFutureTime': 'Please select a future time',
      'timeErrorTitle': 'Time Error',
      'uploadId': 'Upload ID',
      'uploadIdDesc':
          'Please upload a clear photo of your ID card for verification.',
      'tapToUpload': 'Tap to upload',
      'applicationPending': 'Application Pending',
      'user_not_found': 'User not found.',
      'provider_already_registered':
          'User is already registered as a service provider.',
      'provider_profile_not_found': 'Provider profile not found.',
      'provider_not_found': 'Provider not found.',
      'provider_application_not_found': 'Provider application not found.',
      'applicationPendingMsg': 'Your application is currently under review.',
    },
    'ar': {
      'applicationPendingMsg': 'طلبك حالياً قيد المراجعة.',
      'user_not_found': 'المستخدم غير موجود.',
      'provider_already_registered': 'المستخدم مسجل بالفعل كمزود خدمة.',
      'provider_profile_not_found': 'ملف مزود الخدمة غير موجود.',
      'provider_not_found': 'مزود الخدمة غير موجود.',
      'provider_application_not_found': 'طلب مزود الخدمة غير موجود.',
      'applicationPending': 'الطلب قيد الانتظار',
      'uploadId': 'تحميل الهوية',
      'uploadIdDesc': 'يرجى تحميل صورة واضحة لهويتك للتحقق.',
      'tapToUpload': 'اضغط للتحميل',
      'selectFutureTime': 'يرجى اختيار وقت في المستقبل',
      'timeErrorTitle': 'خطأ في الوقت',
      'The requested Service Area is not available.':
          'منطقة الخدمة المطلوبة غير متوفرة حالياً.',
      'No service providers are currently available for these services in your area at this time.':
          'لا يوجد مزودو خدمة متاحون لهذه الخدمات في منطقتك في الوقت الحالي.',
      'serviceAreaUnavailable': 'منطقة الخدمة المطلوبة غير متوفرة حالياً.',
      'noProvidersAvailable':
          'لا يوجد مزودو خدمة متاحون لهذه الخدمات في منطقتك في الوقت الحالي.',
      'bookingNotFound': 'تعذر العثور على الحجز.',
      'unauthorizedBookingView': 'ليس لديك صلاحية لعرض تفاصيل هذا الحجز.',
      'noReplacementFound': 'لا يمكن الإلغاء، لم يتم العثور على مزود بديل.',
      'bookingSuccess': 'تم إنشاء حجزك بنجاح!',
      'bookingFailed': 'فشل إنشاء الحجز. يرجى المحاولة مرة أخرى.',
      'errorValidating': 'خطأ في التحقق من اختيار المنطقة.',
      'custom': 'مخصص',
      'instant': 'فوري',
      'selectDate': 'اختر التاريخ',
      'selectTime': 'اختر الوقت',
      'instantBookingMsg':
          'سيتم تعيين أجير لك في أقرب وقت ممكن بناءً على التوفر.',
      'selectAtLeastOne': 'الرجاء اختيار نوع وحدة واحد على الأقل.',
      'fetchingError': 'خطأ في جلب الخدمات:',
      'startTimeError': 'يجب أن يكون وقت البدء قبل وقت الانتهاء.',
      'overlapError': 'الفترة الزمنية المختارة تتداخل مع فترة موجودة.',
      'unexpectedError': 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      'locationError': 'خطأ في تحميل بيانات الموقع',
      'fetchingServiceAreas': 'جاري جلب مناطق الخدمة المتاحة...',
      'searchService': 'ابحث عن خدمة',
      'loadServicesFailed': 'فشل تحميل الخدمات. يرجى التحقق من الاتصال.',
      'selectUnitTypesFor': 'اختر أنواع الوحدات لـ',
      'noReviewFound': 'لم يتم العثور على تقييم لهذا الحجز.',
      'reviewSubmitted': 'تم إرسال التقييم بنجاح!',
      'reviewFailed': 'فشل إرسال التقييم.',
      'sendFailed': 'فشل إرسال الرسالة',
      'paymentFailed': 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.',
      'failedToLoadPlans': 'فشل تحميل خطط الاشتراك.',
      'networkError': 'تعذر الاتصال بالخادم. يرجى التأكد من اتصالك بالإنترنت.',
      'invalidCredentials':
          'فشل تسجيل الدخول: اسم المستخدم أو كلمة المرور غير صحيحة',
      'userAlreadyExists':
          'فشل التسجيل: المستخدم موجود بالفعل بهذا البريد أو الهاتف',
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
      'am': 'صباحاً',
      'pm': 'مساءً',
      'jod': 'دينار',
      'USD': 'دولار',
      'confirm': 'تأكيد',
      'back': 'رجوع',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'error': 'خطأ: ',
      'retry': 'إعادة المحاولة',
      'loginTitle': 'تسجيل الدخول',
      'emailOrPhoneHint': 'البريد الإلكتروني أو رقم الهاتف',
      'passwordHint': 'كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'dontHaveAccount': 'ليس لديك حساب؟ ',
      'signUp': 'إنشاء حساب',
      'signUpGoogle': 'التسجيل باستخدام Google',
      'loginButton': 'تسجيل الدخول',
      'emailOrPhoneRequired': 'البريد الإلكتروني أو الهاتف مطلوب.',
      'emailOrPhoneTooLong':
          'البريد الإلكتروني أو الهاتف لا يمكن أن يتجاوز 100 حرف.',
      'passwordRequired': 'كلمة المرور مطلوبة.',
      'passwordTooShort': 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.',
      'createAccount': 'إنشاء حساب',
      'firstName': 'الاسم الأول',
      'lastName': 'اسم العائلة',
      'nameRequired': 'الاسم مطلوب.',
      'phoneNumber': 'رقم الهاتف',
      'phoneRequired': 'رقم الهاتف مطلوب.',
      'phoneTooLong': 'رقم الهاتف لا يمكن أن يتجاوز 20 حرفاً.',
      'email': 'البريد الإلكتروني',
      'emailRequired': 'البريد الإلكتروني مطلوب.',
      'emailTooLong': 'البريد الإلكتروني لا يمكن أن يتجاوز 100 حرف.',
      'emailInvalid': 'بريد إلكتروني صالح مطلوب.',
      'confirmPassword': 'تأكيد كلمة المرور',
      'passwordsDoNotMatch': 'كلمات المرور غير متطابقة',
      'signUpButton': 'إنشاء حساب',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
      'logIn': 'تسجيل الدخول',
      'fullNameTooLong': 'الاسم الكامل لا يمكن أن يتجاوز 100 حرف.',
      'accountCreated': 'تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول.',
      'resetPasswordTitle': 'إعادة تعيين كلمة المرور',
      'resetMethodDesc': 'كيف تود إعادة تعيين كلمة المرور؟',
      'resetUsingEmail': 'إعادة تعيين عبر البريد',
      'resetUsingPhone': 'إعادة تعيين عبر الهاتف',
      'enterEmailTitle': 'أدخل البريد الإلكتروني',
      'enterPhoneTitle': 'أدخل رقم الهاتف',
      'emailHintExample': 'your-email@example.com',
      'phoneHintExample': '+962 7XXXXXXXX',
      'enterYourEmail': 'الرجاء إدخال بريدك الإلكتروني.',
      'enterYourPhone': 'الرجاء إدخال رقم هاتفك.',
      'newPassword': 'كلمة المرور الجديدة',
      'confirmNewPassword': 'تأكيد كلمة المرور الجديدة',
      'enterNewPassword': 'الرجاء إدخال كلمة مرور جديدة.',
      'passwordTooShortReset': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.',
      'confirmYourPassword': 'الرجاء تأكيد كلمة المرور.',
      'continueBtn': 'متابعة',
      'conversations': 'المحادثات',
      'searchChats': 'البحث في المحادثات...',
      'errorLoadingChats': 'خطأ في تحميل المحادثات',
      'noConversations': 'لا توجد محادثات.',
      'typeMessage': 'اكتب رسالة...',
      'messageCopied': 'تم نسخ الرسالة!',
      'sendFailed': 'فشل إرسال الرسالة',
      'deleteFailed': 'فشل حذف الرسالة',
      'justNow': 'الآن',
      'yesterday': 'أمس',
      'days': 'أيام',
      'hours': 'ساعات',
      'minutes': 'دقائق',
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
      'Studio': 'استوديو',
      '1 Bedroom': 'غرفة وصالة',
      '2 Bedrooms': 'غرفتين وصالة',
      '3 Bedrooms': '3 غرف وصالة',
      'Villa': 'فيلا',
      'Small': 'صغير',
      'Medium': 'متوسط',
      'Large': 'كبير',
      'Standard': 'قياسي',
      'Deep Clean': 'تنظيف عميق',
      'Regular Clean': 'تنظيف عادي',
      'Full Service': 'خدمة شاملة',
      'Basic': 'أساسي',
      'Premium': 'مميز',
      'myProfile': 'ملفي الشخصي',
      'fullName': 'الاسم الكامل',
      'mobileNumber': 'رقم الهاتف',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'changePassword': 'تغيير كلمة المرور',
      'currentPassword': 'كلمة المرور الحالية',
      'newPassword': 'كلمة المرور الجديدة',
      'required': 'مطلوب',
      'min6Chars': '6 حروف على الأقل',
      'update': 'تحديث',
      'edit': 'تعديل',
      'becomeAjeer': 'كن أجيراً!',
      'switchToCustomer': 'التبديل لوضع العميل',
      'switchToProvider': 'التبديل لوضع المزود',
      'providerInfo': 'معلومات المزود',
      'myServices': 'خدماتي',
      'myLocations': 'مواقعي',
      'mySchedule': 'جدولي',
      'noServices': 'لا توجد خدمات.',
      'noLocations': 'لا توجد مواقع.',
      'noSchedule': 'لا يوجد جدول.',
      'profileUpdated': 'تم تحديث الملف الشخصي بنجاح!',
      'updateFailed': 'فشل التحديث: ',
      'passwordChanged': 'تم تغيير كلمة المرور بنجاح!',
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
      'Amman': 'عمان',
      'Abdoun': 'عبدون',
      'Jabal Al-Weibdeh': 'جبل اللويبدة',
      'Shmeisani': 'الشميساني',
      'Al-Rabieh': 'الرابية',
      'Dabouq': 'دابوق',
      'Al-Jubeiha': 'الجبيهة',
      'Al-Bayader': 'البيادر',
      "Tla' Al-Ali": 'تلاع العلي',
      'pickLocationPlural': 'الموقع',
      'locationSelectionDesc': 'حدد المدن والمناطق التي ستقدم خدماتك فيها.',
      'selectedLocations': 'المواقع المحددة',
      'addLocation': 'إضافة موقع',
      'selectAreasToAdd': 'اختر مناطق للإضافة',
      'noCitiesAvailable': 'لا توجد مدن متاحة\nأو تمت إضافتها جميعاً.',
      'noCitySelection': 'لا توجد مدينة متاحة للاختيار.',
      'noAreasFound': 'لا توجد مناطق تطابق',
      'search': 'بحث',
      'selectServiceTitle': 'الخدمات',
      'selectServiceDesc': 'اختر فئة الخدمة التي تريد تقديمها.',
      'searchService': 'ابحث عن خدمة',
      'loadServicesFailed': 'فشل تحميل الخدمات. يرجى التحقق من الاتصال.',
      'selectUnitTypesFor': 'اختر أنواع الوحدات لـ',
      'timeSlotsFor': 'فترات العمل لـ',
      'selectDayToSchedule': 'اختر يوماً لجدولة الوقت',
      'startTime': 'وقت البدء',
      'endTime': 'وقت الانتهاء',
      'startTimeError': 'وقت البدء يجب أن يكون قبل وقت الانتهاء.',
      'overlapError': 'الفترة الزمنية المحددة تتداخل مع فترة موجودة أو مكررة.',
      'saveScheduleFor': 'حفظ الجدول لـ',
      'addTimeSlotsToSave': 'أضف فترات زمنية للحفظ',
      'workDaysHours': 'أيام وساعات العمل',
      'scheduleDesc': 'قم بجدولة أيام وساعات عملك.',
      'allDaysScheduled': 'تم جدولة جميع الأيام!',
      'saveChanges': 'حفظ التغييرات؟',
      'freeTrialMsg':
          'ابدأ بتقديم خدماتك للعملاء واستخدم تطبيق أجير مجانًا لمدة 30 يومًا. بعد هذه الفترة، ستحتاج إلى الاشتراك للمتابعة.',
      'unexpectedError': 'حدث خطأ غير متوقع.',
      'confirmBooking': 'تأكيد الحجز',
      'estimatedCost': 'التكلفة التقديرية',
      'estDuration': 'الوقت المقدر',
      'customerNote': 'ملاحظات العميل',
      'uploadedMedia': 'الوسائط المرفوعة',
      'noImages': 'لا يوجد صور مرفوعة.',
      'noVideos': 'لا يوجد فيديو مرفوع.',
      'noAudio': 'لا يوجد صوت مرفوع.',
      'instantBooking': 'حجز فوري',
      'uploadMedia': 'تحميل الوسائط',
      'mediaDescription': 'أضف صورة أو فيديو يصف مشكلتك',
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
      'descriptionSaved': 'تم حفظ الوصف',
      'audioNotImplemented': 'الصوت من الملفات غير متاح في المحاكاة.',
      'audioSimulated': 'تسجيل الصوت محاكى.',
      'active': 'نشط',
      'pending': 'معلق',
      'closed': 'مغلق',
      'noBookings': 'لا توجد حجوزات.',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
      'rejected': 'مرفوض',
      'cancelBooking': 'إلغاء الحجز',
      'cancelBookingMsg': 'هل أنت متأكد أنك تريد إلغاء هذا الحجز؟',
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
      'customerLabel': 'العميل',
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
      'Monday': 'الاثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
      'newBookingConf': 'تأكيد حجز جديد',
      'bookingConfMsg': 'تم تأكيد حجزك #1023.',
      'providerAssigned': 'تم تعيين مزود',
      'providerAssignedMsg': 'تم تعيين جون دو.',
      'paymentReminder': 'تذكير بالدفع',
      'paymentReminderMsg': 'رسوم الخدمة مستحقة غداً.',
      'providerSubscription': 'اشتراك المزود',
      'noActivePlan': 'لا يوجد اشتراك نشط',
      'expiresOn': 'ينتهي في',
      'renewOrUpgrade': 'تجديد أو ترقية',
      'choosePlan': 'اختر خطة',
      'paymentSuccess': 'تم الدفع بنجاح!',
      '1 Month Plan': 'خطة ١ شهر',
      '3 Month Plan': 'خطة ٣ شهر',
      'days_duration': 'يوم',

      // Notifications
      'notifNewRequestTitle': 'طلب حجز جديد',
      'notifNewRequestMsg': 'لقد تلقيت طلب حجز جديد.',
      'notifAcceptedTitle': 'تم قبول الحجز',
      'notifAcceptedMsg': 'تم قبول حجزك.',
      'notifAcceptedByMsg': 'تم قبول حجزك من قبل {name}.',
      'notifCancelledTitle': 'تم إلغاء الحجز',
      'notifCancelledMsg': 'تم إلغاء الحجز من قبل العميل.',
      'notifCancelledByMsg': 'تم إلغاء الحجز من قبل {name}.',
      'notifReassignedTitle': 'إعادة تعيين الحجز',
      'notifReassignedMsg': 'لقد وجدنا مزود خدمة جديد لطلبك.',
      'notifReassignedAutoMsg':
          'قام المزود {name} بالإلغاء. وجدنا لك مزوداً جديداً تلقائياً.',
      'notifCompletedTitle': 'اكتمل الحجز',
      'notifCompletedMsg': 'تم إكمال خدمتك. يرجى ترك تقييم!',
      'notifReviewTitle': 'تم استلام تقييم جديد!',
      'notifReviewMsg': 'قام عميل بترك تقييم لخدمتك.',
      'notifReviewStarsMsg': 'قام عميل بتقييم خدمتك. حصلت على {rating} نجوم!',
      'notifDefaultTitle': 'إشعار',
      'notifDefaultMsg': 'لديك إشعار جديد.',
    },
  };

  String translate(String key) {
    return _localizedValues[_appLocale.languageCode]![key] ?? key;
  }

  // NEW: Helper to parse dynamic backend notification messages
  String translateNotificationMessage(String message) {
    if (!isArabic) return message;

    // 1. Handle Review: "A customer has rated your service. You received [X] stars!"
    // We use startsWith/endsWith instead of Regex to be safer against decimals or missing numbers
    const String reviewPrefix =
        'A customer has rated your service. You received ';
    const String reviewSuffix = ' stars!';

    if (message.startsWith(reviewPrefix) && message.endsWith(reviewSuffix)) {
      // Extract whatever is between the prefix and suffix
      String rating = message.substring(
        reviewPrefix.length,
        message.length - reviewSuffix.length,
      );
      return translate(
        'notifReviewStarsMsg',
      ).replaceAll('{rating}', convertNumbers(rating.trim()));
    }

    // 2. Handle dynamic names: "Booking cancelled by [Name]."
    if (message.startsWith('Booking cancelled by ')) {
      String name = message
          .replaceFirst('Booking cancelled by ', '')
          .replaceAll('.', '');
      return translate('notifCancelledByMsg').replaceAll('{name}', name);
    }

    // 3. Handle dynamic names: "Your booking has been accepted by [Name]."
    if (message.startsWith('Your booking has been accepted by ')) {
      String name = message
          .replaceFirst('Your booking has been accepted by ', '')
          .replaceAll('.', '');
      return translate('notifAcceptedByMsg').replaceAll('{name}', name);
    }

    // 4. Handle: "Your provider [Name] cancelled. We found a new provider for you automatically."
    if (message.startsWith('Your provider ') &&
        message.contains(
          ' cancelled. We found a new provider for you automatically.',
        )) {
      String name = message.substring(
        'Your provider '.length,
        message.indexOf(' cancelled.'),
      );
      return translate('notifReassignedAutoMsg').replaceAll('{name}', name);
    }

    // 5. Handle specific static messages
    Map<String, String> staticMap = {
      "New Booking Request": "notifNewRequestTitle",
      "You have received a new booking request.": "notifNewRequestMsg",
      "Booking Accepted": "notifAcceptedTitle",
      "Your booking has been accepted.": "notifAcceptedMsg",
      "Booking Cancelled": "notifCancelledTitle",
      "The booking was cancelled by the customer.": "notifCancelledMsg",
      "Booking Reassigned": "notifReassignedTitle",
      "We found a new provider for your request.": "notifReassignedMsg",
      "Booking Completed": "notifCompletedTitle",
      "Your service has been completed. Please leave a review!":
          "notifCompletedMsg",
      "New Review Received!": "notifReviewTitle",
      "A customer has left a review for your service.": "notifReviewMsg",
      "Notification": "notifDefaultTitle",
      "You have a new notification.": "notifDefaultMsg",
    };

    if (staticMap.containsKey(message)) {
      return translate(staticMap[message]!);
    }

    // Fallback
    return message;
  }
}
