import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';

import '../../themes/theme_notifier.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'bookings_screen.dart';
import 'media_screen.dart';
import '../shared_screens/profile_screen.dart';
import '../shared_screens/chat_screen.dart';
import 'home_screen.dart';

class LocationScreen extends StatefulWidget {
  // --- ADDED: Receive Service IDs from previous screen ---
  final List<int> serviceIds;

  final String serviceName;
  final String unitType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectionMode;
  final int totalTimeMinutes;
  final double totalPrice;

  const LocationScreen({
    super.key,
    required this.serviceIds, // Add this
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

  // --- CUSTOMER LOCATION STATE ---
  String? _selectedCity;
  String? _selectedArea;

  // DYNAMIC DATA VARIABLES
  List<String> _customerCities = [];
  Map<String, List<String>> _customerCityAreas = {};

  // Keep the full object list so we can lookup IDs later
  List<CityResponse> _apiData = [];
  bool _isLoadingAreas = true;

  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _secondaryLightBlue = Color(0xFFc2e3ff);
  static const Color _secondaryBlue = Color(0xFF57b2ff);
  static const Color _subtleLighterDark = Color(0xFF2C2C2C);
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _mapBorderRadius = 25.0;
  static const double _horizontalPadding = 20.0;
  static const double _mapAspectRatio = 1.17;

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

  @override
  void initState() {
    super.initState();
    _getCustomerLocation();
    _fetchServiceAreas();
  }

  Future<void> _fetchServiceAreas() async {
    final url = Uri.parse('${AppConfig.apiUrl}/service-areas');

    try {
      // NOTE: If your backend allows anonymous fetching of areas, you can remove the token check.
      // Otherwise ensure user is logged in.
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

      // If fetching fails without token, comment this block out temporarily for testing
      if (token == null) {
        debugPrint('⛔ No auth token found.');
        // setState(() => _isLoadingAreas = false);
        // return;
      }

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _apiData = data.map((json) => CityResponse.fromJson(json)).toList();

          _customerCities = _apiData.map((city) => city.cityName).toList();
          _customerCityAreas = {
            for (var city in _apiData)
              city.cityName: city.areas.map((area) => area.name).toList(),
          };

          if (_customerCities.isNotEmpty && _selectedCity == null) {
            _selectedCity = _customerCities.first;
          }

          _isLoadingAreas = false;
        });
      } else {
        debugPrint('❌ Error fetching areas: ${response.statusCode}');
        setState(() => _isLoadingAreas = false);
      }
    } catch (e) {
      debugPrint('❌ Exception fetching areas: $e');
      setState(() => _isLoadingAreas = false);
    }
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

        if (area == null || area.isEmpty) {
          area = place.subAdministrativeArea?.trim();
        }

        // Simulating Google lookup or using geocoding package result
        // Replace API key logic if strictly needed
        String finalCity = city ?? '';
        String finalArea = area ?? '';
        String finalGovernorate = place.administrativeArea ?? '';

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
          _resolvedAddress = visibleAddress;
          _fullResolvedAddress = fullAddress;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to resolve address: $e');
    }
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
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

  void _onBackTap() {
    Navigator.pop(context);
  }

  bool get _isNextEnabled =>
      _selectedCity != null &&
      _selectedArea != null &&
      _customerLocation != null;

  void _onNextTap() {
    if (!_isNextEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an area and ensure location is picked.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // --- LOOKUP SERVICE AREA ID ---
    int? selectedAreaId;
    try {
      final cityObj = _apiData.firstWhere((c) => c.cityName == _selectedCity);
      final areaObj = cityObj.areas.firstWhere((a) => a.name == _selectedArea);
      selectedAreaId = areaObj.id;
    } catch (e) {
      debugPrint("Error finding area ID: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error validating area selection.')),
      );
      return;
    }

    final String finalCityArea = '$_selectedCity, $_selectedArea';
    String finalAddress = _fullResolvedAddress ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaScreen(
          // --- PASS NEW DATA ---
          serviceIds: widget.serviceIds, // Pass through from constructor
          serviceAreaId: selectedAreaId!, // Found from API list
          latitude: _customerLocation!.latitude,
          longitude: _customerLocation!.longitude,

          // ---------------------
          serviceName: widget.serviceName,
          unitType: widget.unitType,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          selectionMode: widget.selectionMode,
          totalTimeMinutes: widget.totalTimeMinutes,
          totalPrice: widget.totalPrice,
          resolvedAddress: finalAddress,
          resolvedCityArea: finalCityArea,
        ),
      ),
    );
  }

  void _onCitySelected(String city) {
    setState(() {
      _selectedCity = city;
      _selectedArea = null;
    });
  }

  void _onAreaTapped(String area) {
    setState(() {
      _selectedArea = area;
    });
  }

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
    }
  }

  Future<Map<String, String?>> getAreaFromCoordinates(
    LatLng location,
    String apiKey,
  ) async {
    // Basic placeholder implementation
    return {'city': null, 'area': null, 'governorate': null};
  }

  @override
  Widget build(BuildContext context) {
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
            isNextEnabled: _isNextEnabled,
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
          color: _primaryBlue,
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
              const SizedBox(height: 15.0),
              Padding(
                padding: const EdgeInsets.only(
                  left: _horizontalPadding,
                  top: 20.0,
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

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  10.0,
                  _horizontalPadding,
                  0,
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _mapAspectRatio,
                    child: _buildMapPlaceholder(isDarkMode),
                  ),
                ),
              ),

              const SizedBox(height: 22.0),

              // --- DYNAMIC LOCATION SELECTOR ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: _isLoadingAreas
                    ? Container(
                        height: 250,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      )
                    : _CustomerLocationSelector(
                        city: _selectedCity,
                        area: _selectedArea,
                        cities: _customerCities,
                        cityAreas: _customerCityAreas,
                        onCitySelected: _onCitySelected,
                        onAreaTapped: _onAreaTapped,
                        isDarkMode: isDarkMode,
                      ),
              ),
              const SizedBox(height: 30.0),
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
            if (_isEditingLocation)
              const Align(
                alignment: Alignment.center,
                child: IgnorePointer(
                  child: Icon(Icons.location_pin, size: 50, color: Colors.red),
                ),
              ),
            Positioned(
              top: 15,
              right: 15,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        },
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ),
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
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: _primaryBlue,
                    onPressed: () => _showMaximizedMap(context, isDarkMode),
                    child: const Icon(Icons.open_in_full, color: Colors.white),
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
          const Text(
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
          ),
          IconButton(
            iconSize: 28.0,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(isNextEnabled ? 1.0 : 0.5),
            ),
            onPressed: isNextEnabled ? onNextTap : null,
          ),
        ],
      ),
    );
  }
}

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0, left: 20, right: 20),
          child: const Text(
            'Select your area. This will be used to determine your Ajeer!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(
          height: 250.0,
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

  @override
  Widget build(BuildContext context) {
    final Color listBgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final Color borderColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return Container(
      decoration: BoxDecoration(
        color: listBgColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: kPrimaryBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13.0)),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final Color selectedBgColor = const Color(0xFF1976D2).withOpacity(0.1);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final bool isSelected = city == selectedCity;
        final Color itemTextColor = isSelected
            ? const Color(0xFF1976D2)
            : (isDarkMode ? Colors.white70 : Colors.black87);

        return ListTile(
          onTap: () => onCitySelected(city),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          visualDensity: const VisualDensity(vertical: -4),
          dense: true,
          title: Text(
            city,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: itemTextColor,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check, color: Color(0xFF1976D2), size: 20)
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

  @override
  Widget build(BuildContext context) {
    if (selectedCity == null) {
      return Center(
        child: Text(
          'Select a city first.',
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
          'No areas available.',
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

        final Color itemTextColor = isDarkMode
            ? (isSelected ? const Color(0xFF1976D2) : Colors.white70)
            : (isSelected ? const Color(0xFF1976D2) : Colors.black87);

        return ListTile(
          onTap: () => onAreaTapped(area),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          visualDensity: const VisualDensity(vertical: -4),
          dense: true,
          title: Text(
            area,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: itemTextColor,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : Icon(
                  Icons.radio_button_unchecked,
                  color: isDarkMode
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                  size: 20,
                ),
          tileColor: isSelected
              ? const Color(0xFF1976D2).withOpacity(0.1)
              : null,
        );
      },
    );
  }
}

class AreaResponse {
  final int id;
  final String name;

  AreaResponse({required this.id, required this.name});

  factory AreaResponse.fromJson(Map<String, dynamic> json) {
    return AreaResponse(id: json['id'], name: json['name']);
  }
}

class CityResponse {
  final String cityName;
  final List<AreaResponse> areas;

  CityResponse({required this.cityName, required this.areas});

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    var areasList = json['areas'] as List;
    List<AreaResponse> areasItems = areasList
        .map((i) => AreaResponse.fromJson(i))
        .toList();

    return CityResponse(cityName: json['cityName'], areas: areasItems);
  }
}
