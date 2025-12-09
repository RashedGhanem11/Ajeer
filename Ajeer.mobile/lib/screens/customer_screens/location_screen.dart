import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'media_screen.dart';
import '../shared_screens/profile_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationScreen extends StatefulWidget {
  final String serviceName;
  final String unitType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectionMode;
  final int totalTimeMinutes;
  final double totalPrice;

  const LocationScreen({
    super.key,
    required this.serviceName,
    required this.unitType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectionMode,
    required this.totalTimeMinutes,
    required this.totalPrice,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  int _selectedIndex = 3;
  LatLng? _customerLocation;
  String? _resolvedAddress;
  String? _fullResolvedAddress;
  bool _isEditingLocation = false;
  MapController _mapController = MapController();
  LatLng? _mapCenterDuringEdit;

  // --- START NEW CUSTOMER LOCATION STATE ---
  String? _selectedCity;
  String? _selectedArea;
  // Hardcoded data based on the requirements (Amman and the 8 areas from 1.jpg)
  final List<String> _customerCities = ['Amman'];
  final Map<String, List<String>> _customerCityAreas = {
    'Amman': [
      'Tla\' Al-Ali',
      'Al-Bayader',
      'Al-Jubeiha',
      'Dabouq',
      'Al-Rabieh',
      'Shmeisani',
      'Jabal Al-Weibdeh',
      'Abdoun',
    ],
  };
  // --- END NEW CUSTOMER LOCATION STATE ---

  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color _secondaryBlue = Color(0xFF57b2ff);
  static const Color _subtleLighterDark = Color(
    0xFF2C2C2C,
  ); // Added for map container background
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _mapBorderRadius = 25.0;
  static const double _horizontalPadding = 20.0;
  static const double _cityAreaBoxHeight = 250.0; // Adjusted for better fit
  // 📐 FIX 2: Reduced map height by changing the aspect ratio
  static const double _mapAspectRatio = 1.17; // Adjusted to be wider than tall

  final List<Map<String, dynamic>> _navItems = const [
    {
      'label': 'Profile',
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
    },
    {
      'label': 'Chat',
      'icon': Icons.chat_bubble_outline,
      'activeIcon': Icons.chat_bubble,
    },
    {
      'label': 'Bookings',
      'icon': Icons.book_outlined,
      'activeIcon': Icons.book,
      'notificationCount': 3,
    },
    {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
  ];

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    // 💡 FIX 3: Retrieve ThemeNotifier via Provider for navigation
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // Correctly pass the retrieved themeNotifier
            builder: (context) => ProfileScreen(themeNotifier: themeNotifier),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookingsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(themeNotifier: themeNotifier),
          ),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _getCustomerLocation();
    // Set 'Amman' as the initial selected city since it's the only one available
    _selectedCity = _customerCities.first;
  }

  Future<void> _getCustomerLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _customerLocation = LatLng(position.latitude, position.longitude);
    });
    await _resolveAddressFromCoordinates(_customerLocation!);
  }

  Future<void> _resolveAddressFromCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final city = place.locality?.trim();
        String? area = place.subLocality?.trim();

        // 🔄 fallback if area is missing
        if (area == null || area.isEmpty) {
          area = place.subAdministrativeArea?.trim();
        }

        // 🔍 Try Google Geocoding API for more accurate city/area
        // NOTE: The API key here is a placeholder/example. A real, valid key must be used.
        final googleData = await getAreaFromCoordinates(
          location,
          'AIzaSyCXvl-cyD8q4HwtM7QblvHOe45d_83su9I',
        );

        String? googleCity = googleData['city'];
        String? googleArea = googleData['area'];
        String? googleGovernorate = googleData['governorate'];

        // ✅ Use Google’s data to fix wrong city names or missing area
        String finalCity = (googleCity != null && googleCity.isNotEmpty)
            ? googleCity
            : (city ?? '');
        String finalArea = (googleArea != null && googleArea.isNotEmpty)
            ? googleArea
            : (area ?? '');
        String finalGovernorate =
            (googleGovernorate != null && googleGovernorate.isNotEmpty)
            ? googleGovernorate
            : '';

        final street = place.street?.trim();
        final building = place.name?.trim();

        String visibleAddress = '';
        if (finalCity.isNotEmpty) visibleAddress += finalCity;
        if (finalArea.isNotEmpty)
          visibleAddress += ', $finalArea';
        else if (finalGovernorate.isNotEmpty)
          visibleAddress += ', $finalGovernorate';
        else
          visibleAddress += ', Unnamed location';

        String fullAddress = '';

        if (street != null && street.isNotEmpty) {
          fullAddress = street;
        }

        if (building != null &&
            building.isNotEmpty &&
            (street == null || !building.contains(street))) {
          fullAddress += ' $building';
        }
        fullAddress = fullAddress.trim().replaceAll(RegExp(r',\s+'), ', ');

        setState(() {
          _resolvedAddress = visibleAddress; // Amman, Area
          _fullResolvedAddress = fullAddress;
        });

        debugPrint('📍 Visible: $_resolvedAddress');
        debugPrint('🏠 Full: $_fullResolvedAddress');
      }
    } catch (e) {
      debugPrint('❌ Failed to resolve address: $e');
    }
  }

  void _onBackTap() {
    Navigator.pop(context);
  }

  // Check if both a city and an area have been selected manually
  bool get _isNextEnabled => _selectedCity != null && _selectedArea != null;

  void _onNextTap() {
    if (!_isNextEnabled) {
      // Prevent navigation if location is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an area before proceeding.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Combine selected city and area for the resolvedCityArea variable
    final String finalCityArea = '$_selectedCity, $_selectedArea';

    // Combine current resolved full address with the selected area for final address
    // This logic ensures that the manually selected area is included in the final address sent.
    // Just use the geocoded street name (fullResolvedAddress)
    String finalAddress = _fullResolvedAddress ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaScreen(
          serviceName: widget.serviceName,
          unitType: widget.unitType,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          selectionMode: widget.selectionMode,
          totalTimeMinutes: widget.totalTimeMinutes,
          totalPrice: widget.totalPrice,
          resolvedAddress: finalAddress, // Use the full address
          resolvedCityArea:
              finalCityArea, // Use the manually selected city/area
        ),
      ),
    );
  }

  // --- START NEW CUSTOMER LOCATION METHODS ---
  void _onCitySelected(String city) {
    setState(() {
      _selectedCity = city;
      _selectedArea = null; // Reset area when city changes
    });
  }

  void _onAreaTapped(String area) {
    setState(() {
      _selectedArea = area;
    });
  }
  // --- END NEW CUSTOMER LOCATION METHODS ---

  void _showMaximizedMap(BuildContext context, bool isDarkMode) async {
    if (_customerLocation == null) return;

    final updatedLocation = await Navigator.of(context).push<LatLng>(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: true,
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _MaximizedMapDialog(
              mapBorderRadius: _mapBorderRadius,
              primaryColor: _primaryBlue,
              isDarkMode: isDarkMode,
              customerLocation: _customerLocation!,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (updatedLocation != null) {
      setState(() {
        _customerLocation = updatedLocation;
      });
      _mapController.move(updatedLocation, 15.0);
      await _resolveAddressFromCoordinates(updatedLocation);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated'),
          backgroundColor: Color(0xFF1976D2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Retrieve ThemeNotifier via Provider for build
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bool isDarkMode = themeNotifier.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
    );

    final screenHeight = MediaQuery.of(context).size.height;

    // 📐 FIX 1: Reverted back to 0.30 so the container stays at the Red Arrow
    final double whiteContainerTop = screenHeight * 0.30;

    final double logoTopPosition =
        whiteContainerTop - _logoHeight + _overlapAdjustment;
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildLocationIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
          ),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            isDarkMode: isDarkMode,
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _NavigationHeader(
            onBackTap: _onBackTap,
            onNextTap: _onNextTap,
            isNextEnabled: _isNextEnabled, // Pass the check for next button
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavItemTapped,
      ),
    );
  }

  Future<Map<String, String?>> getAreaFromCoordinates(
    LatLng location,
    String apiKey,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey&language=en';

    String? city;
    String? area;
    String? governorate;

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;

          for (final result in results) {
            for (final component in result['address_components']) {
              final types = List<String>.from(component['types']);

              // ✅ Prioritize most specific area
              if (area == null &&
                  (types.contains('point_of_interest') ||
                      types.contains('premise') ||
                      types.contains('neighborhood') ||
                      types.contains('sublocality'))) {
                area = component['long_name'];
              }

              // ✅ City: prefer locality, fall back to level_2
              if (city == null &&
                  (types.contains('locality') ||
                      types.contains('administrative_area_level_2'))) {
                city = component['long_name'];
              }

              // ✅ Governorate: level 1
              if (governorate == null &&
                  types.contains('administrative_area_level_1')) {
                governorate = component['long_name'];
              }
            }
          }
        } else {
          debugPrint('⚠️ Geocoding API error: ${data['status']}');
        }
      } else {
        debugPrint('❌ HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
    }

    return {'city': city, 'area': area, 'governorate': governorate};
  }

  Widget _buildBackgroundGradient(double containerTop) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: containerTop + 50,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightBlue, _primaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationIcon(double containerTop, double statusBarHeight) {
    final double headerHeight = statusBarHeight + 60;
    final double availableHeight = containerTop - headerHeight;
    final double iconTopPosition = headerHeight + (availableHeight / 2) - 70;

    return Positioned(
      top: iconTopPosition,
      right: 25.0,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [_secondaryLightBlue, _secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 5.0,
              color: Colors.black38,
              offset: Offset(2.0, 2.0),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: const Icon(
          Icons.location_on_outlined,
          size: 55.0,
          color: _LocationScreenState._primaryBlue,
        ),
      ),
    );
  }

  Widget _buildHomeImage(double logoTopPosition, bool isDarkMode) {
    final String imagePath = isDarkMode
        ? 'assets/image/home_dark.png'
        : 'assets/image/home.png';
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          imagePath,
          width: 140,
          height: _logoHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildWhiteContainer({
    required double containerTop,
    required double bottomNavClearance,
    required bool isDarkMode,
  }) {
    return Positioned(
      top: containerTop,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        // ✂ FIX 2: Added Clip.hardEdge to prevent content from overflowing the rounded corners
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black45 : Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomNavClearance),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📐 FIX 3: Increased top spacing from 15.0 to 50.0
              // This pushes the content down to the Yellow Arrow while keeping the container at the Red Arrow
              const SizedBox(height: 15.0),

              Padding(
                padding: const EdgeInsets.only(
                  left: _horizontalPadding,
                  top:
                      20.0, // This pushes the title down slightly from the curve
                ),
                child: Text(
                  'Pick a location',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),

              // 🚫 DELETED: The text widget that showed _resolvedAddress is removed here.

              // Map Section
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  10.0,
                  _horizontalPadding,
                  0,
                ),
                child: Center(
                  child: AspectRatio(
                    // 📐 FIX 2: Use the new, smaller aspect ratio
                    aspectRatio: _mapAspectRatio,
                    child: _buildMapPlaceholder(isDarkMode),
                  ),
                ),
              ),

              const SizedBox(height: 22.0), // Separator
              // New: City/Area Picker Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: _CustomerLocationSelector(
                  city: _selectedCity,
                  area: _selectedArea,
                  cities: _customerCities,
                  cityAreas: _customerCityAreas,
                  onCitySelected: _onCitySelected,
                  onAreaTapped: _onAreaTapped,
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(height: 30.0), // Padding at the end
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(bool isDarkMode) {
    final Color mapBgColor = isDarkMode
        ? _subtleLighterDark
        : Colors.grey[100]!;
    final Color mapBorderColor = isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[400]!;

    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: mapBgColor,
          borderRadius: BorderRadius.circular(_mapBorderRadius),
          border: Border.all(color: mapBorderColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(_mapBorderRadius),
              child: _customerLocation == null
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _isEditingLocation
                            ? _mapCenterDuringEdit ?? _customerLocation
                            : _customerLocation,
                        zoom: 15.0,
                        onPositionChanged: _isEditingLocation
                            ? (MapPosition pos, _) {
                                setState(() {
                                  _mapCenterDuringEdit = pos.center!;
                                });
                              }
                            : null,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        if (!_isEditingLocation)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _customerLocation!,
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
            ),

            // 📍 Center pin when editing
            if (_isEditingLocation)
              const Align(
                alignment: Alignment.center,
                child: IgnorePointer(
                  child: Icon(Icons.location_pin, size: 50, color: Colors.red),
                ),
              ),

            // 🔁 Top-right button cluster (Save, Edit, Maximize)
            Positioned(
              top: 15,
              right: 15,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Save (only in edit mode)
                  if (_isEditingLocation)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.green,
                        onPressed: () async {
                          setState(() {
                            _customerLocation = _mapCenterDuringEdit!;
                            _isEditingLocation = false;
                          });

                          await _resolveAddressFromCoordinates(
                            _customerLocation!,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Location updated',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Color(0xFF1976D2),
                              behavior: SnackBarBehavior.fixed,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ),

                  // ✏ Edit
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: _primaryBlue,
                      onPressed: () {
                        setState(() {
                          _isEditingLocation = true;
                          _mapCenterDuringEdit = _customerLocation;
                          _mapController.move(_customerLocation!, 15.0);
                        });
                      },
                      child: const Icon(
                        Icons.edit_location_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // ⛶ Maximize
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: _primaryBlue,
                    onPressed: () => _showMaximizedMap(context, isDarkMode),
                    child: const Icon(Icons.open_in_full, color: Colors.white),
                  ),
                ],
              ),
            ),
            // 🔍 Zoom buttons (bottom right)
            Positioned(
              bottom: 15,
              right: 15,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      _mapController.move(
                        _mapController.center,
                        _mapController.zoom + 1,
                      );
                    },
                    child: const Icon(Icons.zoom_in, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      _mapController.move(
                        _mapController.center,
                        _mapController.zoom - 1,
                      );
                    },
                    child: const Icon(Icons.zoom_out, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaximizedMapDialog extends StatefulWidget {
  final double mapBorderRadius;
  final Color primaryColor;
  final bool isDarkMode;
  final LatLng customerLocation;

  const _MaximizedMapDialog({
    required this.mapBorderRadius,
    required this.primaryColor,
    required this.isDarkMode,
    required this.customerLocation,
  });

  @override
  State<_MaximizedMapDialog> createState() => _MaximizedMapDialogState();
}

class _MaximizedMapDialogState extends State<_MaximizedMapDialog> {
  late MapController _mapController;
  bool _isEditing = false;
  late LatLng _editingCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _editingCenter = widget.customerLocation;
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isDarkMode
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _editingCenter,
                zoom: 16.0,
                onPositionChanged: _isEditing
                    ? (pos, _) {
                        setState(() {
                          _editingCenter = pos.center!;
                        });
                      }
                    : null,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (!_isEditing)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: widget.customerLocation,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          if (_isEditing)
            const Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Icon(Icons.location_pin, size: 50, color: Colors.red),
              ),
            ),

          // Top-right button row
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.green,
                      onPressed: () {
                        Navigator.of(context).pop(_editingCenter);
                      },
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: widget.primaryColor,
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                        _editingCenter = widget.customerLocation;
                      });
                    },
                    child: const Icon(
                      Icons.edit_location_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: widget.primaryColor,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close_fullscreen,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // 🔍 Zoom buttons in maximized map
          Positioned(
            bottom: 20,
            right: 15,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'max_zoom_in',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom + 1,
                    );
                  },
                  child: const Icon(Icons.zoom_in, color: Colors.black),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: 'max_zoom_out',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _mapController.move(
                      _mapController.center,
                      _mapController.zoom - 1,
                    );
                  },
                  child: const Icon(Icons.zoom_out, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final bool isNextEnabled;

  const _NavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    required this.isNextEnabled,
  });

  Widget _buildAjeerTitle() {
    return const Text(
      'Ajeer',
      style: TextStyle(
        color: Colors.white,
        fontSize: 34,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(
            blurRadius: 2.0,
            color: Colors.black26,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            iconSize: 28.0,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: onBackTap,
          ),
          _buildAjeerTitle(),
          IconButton(
            iconSize: 28.0,
            icon: Icon(
              Icons.arrow_forward_ios,
              // Change color based on selection status
              color: Colors.white.withOpacity(isNextEnabled ? 1.0 : 0.5),
            ),
            onPressed: isNextEnabled
                ? onNextTap
                : null, // Disable if not enabled
          ),
        ],
      ),
    );
  }
}

// --- START NEW WIDGETS FOR CUSTOMER CITY/AREA PICKER ---

class _CustomerLocationSelector extends StatelessWidget {
  final String? city;
  final String? area;
  final List<String> cities;
  final Map<String, List<String>> cityAreas;
  final ValueChanged<String> onCitySelected;
  final ValueChanged<String> onAreaTapped;
  final bool isDarkMode;

  const _CustomerLocationSelector({
    required this.city,
    required this.area,
    required this.cities,
    required this.cityAreas,
    required this.onCitySelected,
    required this.onAreaTapped,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
          child: Text(
            'Select your area',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: _LocationScreenState._cityAreaBoxHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LocationBox(
                  title: 'City Picker',
                  isDarkMode: isDarkMode,
                  child: _CustomerCityList(
                    cities: cities,
                    selectedCity: city,
                    onCitySelected: onCitySelected,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _LocationBox(
                  title: 'Area Picker',
                  isDarkMode: isDarkMode,
                  child: _CustomerAreaList(
                    selectedCity: city,
                    selectedArea: area,
                    cityAreas: cityAreas,
                    onAreaTapped: onAreaTapped,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationBox extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDarkMode;

  const _LocationBox({
    required this.title,
    required this.child,
    required this.isDarkMode,
  });

  static const Color kPrimaryBlue = Color(0xFF1976D2);
  static const double kBoxRadius = 15.0;
  static const double kHeaderRadius = 13.0;

  @override
  Widget build(BuildContext context) {
    const Color headerBgColor = kPrimaryBlue;
    const Color headerTextColor = Colors.white;
    final Color listBgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final Color borderColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: listBgColor,
        borderRadius: BorderRadius.circular(kBoxRadius),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: headerBgColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(kHeaderRadius),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: headerTextColor,
              ),
            ),
          ),
          Divider(height: 1, color: borderColor),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CustomerCityList extends StatelessWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String> onCitySelected;
  final bool isDarkMode;

  const _CustomerCityList({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
    required this.isDarkMode,
  });

  static const Color kPrimaryBlue = Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    final Color selectedBgColor = kPrimaryBlue.withOpacity(0.1);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final bool isSelected = city == selectedCity;

        final Color itemTextColor = isSelected
            ? kPrimaryBlue
            : (isDarkMode ? Colors.white70 : Colors.black87);

        return ListTile(
          onTap: () => onCitySelected(city),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 0,
          ),
          visualDensity: const VisualDensity(vertical: -4),
          dense: true,
          minVerticalPadding: 0,
          title: Text(
            city,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: itemTextColor,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check, color: kPrimaryBlue, size: 20)
              : null,
          tileColor: isSelected ? selectedBgColor : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
      },
    );
  }
}

class _CustomerAreaList extends StatelessWidget {
  final String? selectedCity;
  final String? selectedArea;
  final Map<String, List<String>> cityAreas;
  final ValueChanged<String> onAreaTapped;
  final bool isDarkMode;

  const _CustomerAreaList({
    required this.selectedCity,
    required this.selectedArea,
    required this.cityAreas,
    required this.onAreaTapped,
    required this.isDarkMode,
  });

  static const Color kPrimaryBlue = Color(0xFF1976D2);
  static const Color kSelectedGreen = Colors.green;

  @override
  Widget build(BuildContext context) {
    if (selectedCity == null) {
      return Center(
        child: Text(
          'Select a city first.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    final List<String> availableAreas = cityAreas[selectedCity] ?? [];

    if (availableAreas.isEmpty) {
      return Center(
        child: Text(
          'No areas available in $selectedCity.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: availableAreas.length,
      itemBuilder: (context, index) {
        final area = availableAreas[index];
        final bool isSelected = area == selectedArea;

        final Color itemBgColor = isSelected
            ? kPrimaryBlue.withOpacity(0.1)
            : (isDarkMode ? Colors.transparent : Colors.transparent);
        final Color itemTextColor = isDarkMode
            ? (isSelected ? kPrimaryBlue : Colors.white70)
            : (isSelected ? kPrimaryBlue : Colors.black87);

        return ListTile(
          onTap: () => onAreaTapped(area),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 0,
          ),
          visualDensity: const VisualDensity(vertical: -4),
          dense: true,
          minVerticalPadding: 0,
          title: Text(
            area,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: itemTextColor,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: kSelectedGreen, size: 20)
              : Icon(
                  Icons.radio_button_unchecked,
                  color: isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                  size: 20,
                ),
          tileColor: itemBgColor,
        );
      },
    );
  }
}
// --- END NEW WIDGETS FOR CUSTOMER CITY/AREA PICKER ---