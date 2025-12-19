import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/language_notifier.dart';
import 'work_schedule_screen.dart';
import '../../models/provider_data.dart';
import '../../config/app_config.dart';

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

const Color kPrimaryBlue = Color(0xFF2f6cfa);
const Color kLightBlue = Color(0xFFa2bdfc);
const Color kDeleteRed = Color(0xFFF44336);
const Color kSelectedGreen = Colors.green;
const double kBorderRadius = 50.0;
const double kWhiteContainerTopRatio = 0.15;
const double kSaveButtonHeight = 45.0;
const double kSearchBoxHeight = 40.0;
const double kContentHorizontalPadding = 5.0;
const double kBoxRadius = 15.0;
const double kHeaderRadius = 13.0;
const double kListContainerHeight = 310.0;

class LocationScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  final Map<String, Set<String>> selectedServices;
  final List<int> serviceIds;
  final bool isEdit;
  final ProviderData? initialData;

  const LocationScreen({
    super.key,
    required this.themeNotifier,
    required this.selectedServices,
    required this.serviceIds,
    this.isEdit = false,
    this.initialData,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<CityResponse> _apiData = [];
  bool _isLoading = true;

  String? _selectedCity;
  Set<String> _currentAreaSelection = {};
  List<LocationSelection> _finalLocations = [];
  String _areaSearchQuery = '';

  late LanguageNotifier _languageNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageNotifier = Provider.of<LanguageNotifier>(context);
  }

  @override
  void initState() {
    super.initState();
    _fetchServiceAreas();
  }

  Future<void> _fetchServiceAreas() async {
    final url = Uri.parse('${AppConfig.apiUrl}/service-areas');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('authToken');

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
        if (mounted) {
          setState(() {
            _apiData = data.map((json) => CityResponse.fromJson(json)).toList();
            _isLoading = false;
            _initializeEditState();
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initializeEditState() {
    if (widget.isEdit && widget.initialData != null) {
      _finalLocations = List<LocationSelection>.from(
        widget.initialData!.selectedLocations,
      );
    }
    _selectedCity = _availableCities.isNotEmpty ? _availableCities.first : null;
  }

  List<String> get _allApiCityNames => _apiData.map((c) => c.cityName).toList();

  List<String> get _availableCities => _allApiCityNames
      .where((city) => !_finalLocations.any((loc) => loc.city == city))
      .toList();

  void _onBackTap() => Navigator.pop(context);

  bool get _isNextEnabled => _finalLocations.isNotEmpty;

  List<int> _getSelectedAreaIds() {
    List<int> ids = [];

    for (var loc in _finalLocations) {
      final cityData = _apiData.firstWhere(
        (c) => c.cityName == loc.city,
        orElse: () => CityResponse(cityName: '', areas: []),
      );

      for (var areaName in loc.areas) {
        final areaData = cityData.areas.firstWhere(
          (a) => a.name == areaName,
          orElse: () => AreaResponse(id: 0, name: ''),
        );
        if (areaData.id != 0) {
          ids.add(areaData.id);
        }
      }
    }
    return ids;
  }

  void _onNextTap() {
    if (_isNextEnabled) {
      final areaIds = _getSelectedAreaIds();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkScheduleScreen(
            themeNotifier: widget.themeNotifier,
            selectedServices: widget.selectedServices,
            selectedLocations: _finalLocations,
            serviceIds: widget.serviceIds,
            areaIds: areaIds,
            isEdit: widget.isEdit,
            initialData: widget.initialData,
          ),
        ),
      );
    }
  }

  void _onCitySelected(String city) {
    setState(() {
      _selectedCity = city;
      _currentAreaSelection = {};
      _areaSearchQuery = '';
    });
  }

  void _onAreaTapped(String area) {
    setState(() {
      if (_currentAreaSelection.contains(area)) {
        _currentAreaSelection.remove(area);
      } else {
        _currentAreaSelection.add(area);
      }
    });
  }

  void _onSaveLocations() {
    if (_selectedCity != null && _currentAreaSelection.isNotEmpty) {
      setState(() {
        _finalLocations.add(
          LocationSelection(
            city: _selectedCity!,
            areas: Set.from(_currentAreaSelection),
          ),
        );
        _currentAreaSelection = {};
        _selectedCity = _availableCities.isNotEmpty
            ? _availableCities.first
            : null;
      });
    }
  }

  void _onDeleteLocation(String city) {
    setState(() {
      _finalLocations.removeWhere((loc) => loc.city == city);
      if (_selectedCity == null && _availableCities.isNotEmpty) {
        _selectedCity = _availableCities.first;
      }
    });
  }

  void _onEditLocation(LocationSelection location) {
    setState(() {
      _selectedCity = location.city;
      _currentAreaSelection = Set.from(location.areas);
      _finalLocations.removeWhere((loc) => loc.city == location.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;

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
    final double whiteContainerTop = screenHeight * kWhiteContainerTopRatio;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            isDarkMode: isDarkMode,
          ),
          _ProviderNavigationHeader(
            onBackTap: _onBackTap,
            onNextTap: _onNextTap,
            isNextEnabled: _isNextEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kLightBlue, kPrimaryBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildWhiteContainer({
    required double containerTop,
    required bool isDarkMode,
  }) {
    return Positioned(
      top: containerTop,
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(kBorderRadius)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 5.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _languageNotifier.translate('pickLocationPlural'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        _languageNotifier.translate('locationSelectionDesc'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7.0),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _LocationSelectionContent(
                  availableCities: _availableCities,
                  selectedCity: _selectedCity,
                  currentAreaSelection: _currentAreaSelection,
                  finalLocations: _finalLocations,
                  areaSearchQuery: _areaSearchQuery,
                  apiData: _apiData,
                  onCitySelected: _onCitySelected,
                  onAreaTapped: _onAreaTapped,
                  onAreaSearchChanged: (query) {
                    setState(() {
                      _areaSearchQuery = query;
                    });
                  },
                  onSave: _onSaveLocations,
                  onEdit: _onEditLocation,
                  onDelete: _onDeleteLocation,
                  isDarkMode: isDarkMode,
                  languageNotifier: _languageNotifier,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderNavigationHeader extends StatefulWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final bool isNextEnabled;

  const _ProviderNavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    this.isNextEnabled = false,
  });

  @override
  State<_ProviderNavigationHeader> createState() =>
      _ProviderNavigationHeaderState();
}

class _ProviderNavigationHeaderState extends State<_ProviderNavigationHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isNextEnabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_ProviderNavigationHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNextEnabled != oldWidget.isNextEnabled) {
      if (widget.isNextEnabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageNotifier = Provider.of<LanguageNotifier>(context);

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
            onPressed: widget.onBackTap,
          ),
          Text(
            languageNotifier.translate('appName'),
            style: const TextStyle(
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
          Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isNextEnabled)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              IconButton(
                iconSize: 28.0,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: widget.isNextEnabled
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                onPressed: widget.isNextEnabled ? widget.onNextTap : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationSelectionContent extends StatelessWidget {
  final List<String> availableCities;
  final String? selectedCity;
  final Set<String> currentAreaSelection;
  final List<LocationSelection> finalLocations;
  final String areaSearchQuery;
  final List<CityResponse> apiData;
  final ValueChanged<String> onCitySelected;
  final ValueChanged<String> onAreaTapped;
  final ValueChanged<String> onAreaSearchChanged;
  final VoidCallback onSave;
  final ValueChanged<LocationSelection> onEdit;
  final ValueChanged<String> onDelete;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _LocationSelectionContent({
    required this.availableCities,
    required this.selectedCity,
    required this.currentAreaSelection,
    required this.finalLocations,
    required this.areaSearchQuery,
    required this.apiData,
    required this.onCitySelected,
    required this.onAreaTapped,
    required this.onAreaSearchChanged,
    required this.onSave,
    required this.onEdit,
    required this.onDelete,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  List<Widget> _buildSelectedLocationsList() {
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;

    return [
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          '${languageNotifier.translate('selectedLocations')} (${languageNotifier.convertNumbers(finalLocations.length.toString())})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: titleColor,
          ),
        ),
      ),
      const SizedBox(height: 5.0),
      ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: finalLocations.length,
        itemBuilder: (context, index) {
          final loc = finalLocations[index];
          final areas = languageNotifier.translateStringList(
            loc.areas.toList(),
          );
          final Color itemBgColor = isDarkMode
              ? Colors.black
              : Colors.grey.shade100;
          final Color itemBorderColor = isDarkMode
              ? Colors.grey.shade600
              : Colors.grey.shade400;
          final Color areaTextColor = isDarkMode
              ? Colors.grey.shade400
              : Colors.grey.shade600;
          final Color cityTextColor = isDarkMode
              ? Colors.white
              : Colors.black87;

          return Container(
            margin: const EdgeInsets.only(
              bottom: 8.0,
              left: kContentHorizontalPadding,
              right: kContentHorizontalPadding,
            ),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: itemBgColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: itemBorderColor, width: 2.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageNotifier.translate(loc.city),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: cityTextColor,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        areas,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: areaTextColor),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => onEdit(loc),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimaryBlue,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onDelete(loc.city),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kDeleteRed,
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kContentHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CityAreaSelector(
            availableCities: availableCities,
            selectedCity: selectedCity,
            currentAreaSelection: currentAreaSelection,
            finalLocations: finalLocations,
            areaSearchQuery: areaSearchQuery,
            apiData: apiData,
            onCitySelected: onCitySelected,
            onAreaTapped: onAreaTapped,
            onAreaSearchChanged: onAreaSearchChanged,
            onSave: onSave,
            isDarkMode: isDarkMode,
            languageNotifier: languageNotifier,
          ),
          if (finalLocations.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            ..._buildSelectedLocationsList(),
          ],
          const SizedBox(height: 15.0),
        ],
      ),
    );
  }
}

class _CityAreaSelector extends StatelessWidget {
  final List<String> availableCities;
  final String? selectedCity;
  final Set<String> currentAreaSelection;
  final List<LocationSelection> finalLocations;
  final String areaSearchQuery;
  final List<CityResponse> apiData;
  final ValueChanged<String> onCitySelected;
  final ValueChanged<String> onAreaTapped;
  final ValueChanged<String> onAreaSearchChanged;
  final VoidCallback onSave;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _CityAreaSelector({
    required this.availableCities,
    required this.selectedCity,
    required this.currentAreaSelection,
    required this.finalLocations,
    required this.areaSearchQuery,
    required this.apiData,
    required this.onCitySelected,
    required this.onAreaTapped,
    required this.onAreaSearchChanged,
    required this.onSave,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSaveEnabled =
        selectedCity != null && currentAreaSelection.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          height: kListContainerHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LocationBox(
                  title: languageNotifier.translate('cityPicker'),
                  isDarkMode: isDarkMode,
                  child: _CityList(
                    cities: availableCities,
                    selectedCity: selectedCity,
                    onCitySelected: onCitySelected,
                    isDarkMode: isDarkMode,
                    languageNotifier: languageNotifier,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _LocationBox(
                  title: languageNotifier.translate('areaPicker'),
                  isDarkMode: isDarkMode,
                  child: _AreaList(
                    selectedCity: selectedCity,
                    currentAreaSelection: currentAreaSelection,
                    areaSearchQuery: areaSearchQuery,
                    apiData: apiData,
                    onAreaTapped: onAreaTapped,
                    onAreaSearchChanged: onAreaSearchChanged,
                    isDarkMode: isDarkMode,
                    finalLocations: finalLocations,
                    languageNotifier: languageNotifier,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15.0),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
          child: Center(
            child: SizedBox(
              height: kSaveButtonHeight,
              child: ElevatedButton(
                onPressed: isSaveEnabled ? onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBoxRadius),
                  ),
                  elevation: 5,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    isSaveEnabled
                        ? languageNotifier.translate('addLocation')
                        : languageNotifier.translate('selectAreasToAdd'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
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
              color: kPrimaryBlue,
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

class _CityList extends StatelessWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String> onCitySelected;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _CityList({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedBgColor = kPrimaryBlue.withOpacity(0.1);

    if (cities.isEmpty) {
      return Center(
        child: Text(
          languageNotifier.translate('noCitiesAvailable'),
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
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final bool isSelected = city == selectedCity;

        final Color itemTextColor = isSelected
            ? kPrimaryBlue
            : (isDarkMode ? Colors.white70 : Colors.black87);

        return ListTile(
          onTap: () => onCitySelected(city),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          visualDensity: const VisualDensity(vertical: -4),
          dense: true,
          title: Text(
            languageNotifier.translate(city),
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

class _AreaList extends StatelessWidget {
  final String? selectedCity;
  final Set<String> currentAreaSelection;
  final String areaSearchQuery;
  final List<CityResponse> apiData;
  final ValueChanged<String> onAreaTapped;
  final ValueChanged<String> onAreaSearchChanged;
  final bool isDarkMode;
  final List<LocationSelection> finalLocations;
  final LanguageNotifier languageNotifier;

  const _AreaList({
    required this.selectedCity,
    required this.currentAreaSelection,
    required this.areaSearchQuery,
    required this.apiData,
    required this.onAreaTapped,
    required this.onAreaSearchChanged,
    required this.isDarkMode,
    required this.finalLocations,
    required this.languageNotifier,
  });

  String _normalizeString(String text) {
    return text.replaceAll(RegExp(r'[\s-]'), '').toLowerCase();
  }

  List<String> _getAreasForCity(String cityName) {
    try {
      final cityObj = apiData.firstWhere(
        (c) => c.cityName == cityName,
        orElse: () => CityResponse(cityName: '', areas: []),
      );
      return cityObj.areas.map((a) => a.name).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCity == null) {
      return Center(
        child: Text(
          languageNotifier.translate('noCitySelection'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    final List<String> availableAreas = _getAreasForCity(selectedCity!);
    final String normalizedQuery = _normalizeString(areaSearchQuery);

    final List<String> filteredAreas = availableAreas.where((area) {
      final translatedArea = languageNotifier.translate(area);
      if (normalizedQuery.isEmpty) return true;
      return _normalizeString(translatedArea).contains(normalizedQuery);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: _AreaSearchBar(
            onSearchChanged: onAreaSearchChanged,
            isDarkMode: isDarkMode,
            languageNotifier: languageNotifier,
          ),
        ),
        Expanded(
          child: filteredAreas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      normalizedQuery.isNotEmpty
                          ? '${languageNotifier.translate('noAreasFound')} "$areaSearchQuery".'
                          : languageNotifier.translate('noAreas'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredAreas.length,
                  itemBuilder: (context, index) {
                    final area = filteredAreas[index];
                    final bool isSelected = currentAreaSelection.contains(area);

                    return _AreaListItem(
                      areaName: languageNotifier.translate(area),
                      isSelected: isSelected,
                      isDarkMode: isDarkMode,
                      onTap: () => onAreaTapped(area),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AreaListItem extends StatefulWidget {
  final String areaName;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _AreaListItem({
    required this.areaName,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  State<_AreaListItem> createState() => _AreaListItemState();
}

class _AreaListItemState extends State<_AreaListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final Color itemBgColor = widget.isSelected
        ? kPrimaryBlue.withOpacity(0.1)
        : Colors.transparent;
    final Color itemTextColor = widget.isDarkMode
        ? (widget.isSelected ? kPrimaryBlue : Colors.white70)
        : (widget.isSelected ? kPrimaryBlue : Colors.black87);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: ListTile(
        onTap: _handleTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        visualDensity: const VisualDensity(vertical: -4),
        dense: true,
        title: Text(
          widget.areaName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            color: itemTextColor,
          ),
        ),
        trailing: widget.isSelected
            ? const Icon(Icons.check_circle, color: kSelectedGreen, size: 20)
            : Icon(
                Icons.radio_button_unchecked,
                color: widget.isDarkMode
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                size: 20,
              ),
        tileColor: itemBgColor,
      ),
    );
  }
}

class _AreaSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _AreaSearchBar({
    required this.onSearchChanged,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final Color searchFillColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade100;
    final Color searchTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color searchHintColor = isDarkMode
        ? Colors.grey.shade500
        : Colors.grey.shade600;
    final Color iconColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final Color borderColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade400;

    return SizedBox(
      height: kSearchBoxHeight,
      child: TextField(
        onChanged: onSearchChanged,
        style: TextStyle(color: searchTextColor, fontSize: 14.0),
        decoration: InputDecoration(
          hintText: languageNotifier.translate('search'),
          hintStyle: TextStyle(color: searchHintColor, fontSize: 14.0),
          prefixIcon: Icon(Icons.search, color: iconColor, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          filled: true,
          fillColor: searchFillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }
}
