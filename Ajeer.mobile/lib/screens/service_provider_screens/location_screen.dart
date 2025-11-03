import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/theme_notifier.dart';
import 'work_schedule_screen.dart';

const Color kLightBlue = Color(0xFF8CCBFF);
const Color kPrimaryBlue = Color(0xFF1976D2);
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

class LocationSelection {
  final String city;
  final Set<String> areas;

  LocationSelection({required this.city, required this.areas});
}

const List<String> kJordanCities = [
  'Amman',
  'Zarqa',
  'Irbid',
  'Aqaba',
  'Salt',
  'Madaba',
  'Karak',
  'Mafraq',
  'Jerash',
  'Ajloun',
  'Tafilah',
  'Ma\'an',
];

const Map<String, List<String>> kCityAreas = {
  'Amman': [
    'Al-Balad (Downtown Amman)',
    'Jabal Amman',
    'Jabal Al Lweibdeh',
    'Jabal Al Hussein',
    'Abdali',
    'Ras Al Ain',
    'Al Ashrafieh',
    'Abdoun',
    'Sweifieh',
    'Dabouq',
    'Khalda',
    'Deir Ghbar',
    'Al-Rabyeh',
    'Al-Kursi',
    'Al-Jandaweel',
    'Um Uthaina',
    'Al-Sweifieh',
    'Al-Sahl',
    'Al-Bayader',
    'Mecca Street',
    'Gardens (Wasfi Al-Tal Street)',
    'Al-Madina Al-Munawara Street',
    'Um Al-Summaq',
    'Tla’ Al-Ali',
    'Al-Rawnaq',
    'Al-Jubaiha',
    'Al-Tariq',
    'Abu Nsair',
    'Al-Nuzha',
    'Al-Huson Road area',
    'Al-Baqa’a',
    'Al-Zahra’a',
    'Al-Muqablain',
    'Al-Tabarbour',
    'Marka',
    'Al-Yadoudeh',
    'Al-Hashmi Al-Janoubi',
    'Al-Nasr',
    'Sahab',
    'Al-Qweismeh',
    'Al-Jweideh',
    'Al-Taj',
    'Marj Al-Hamam',
    'Al-Misdar',
    'Al-Hashmi Al-Shamali',
    'Al-Wehdat',
    'Al-Mahatta',
    'Al-Taybeh',
    'Al-Manshieh',
    'Airport Road area',
    'Naour',
    'Al-Hummar',
    'Al-Muwaqqar',
    'Madinat Al-Hassan',
    'Al-Mustanda',
    'Al-Salt Road area',
  ],
  'Zarqa': ['New Zarqa', 'Zarqa City Center', 'Hashemiyya'],
  'Irbid': ['Irbid City Center', 'North Irbid', 'University District'],
  'Aqaba': ['Aqaba Center', 'Tala Bay', 'South Beach'],
  'Salt': ['Salt Downtown', 'Yarka', 'Zai'],
  'Madaba': ['Madaba Center', 'Mount Nebo Area'],
  'Karak': ['Karak Castle Area', 'Muta'],
  'Mafraq': ['Mafraq City Center', 'Al-Ruwaished'],
  'Jerash': ['Jerash City Center', 'Souf'],
  'Ajloun': ['Ajloun Center', 'Anjara'],
  'Tafilah': ['Tafilah City Center', 'Al-Ais'],
  'Ma\'an': ['Ma\'an City Center', 'Petra Area'],
};

class LocationScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  final Map<String, Set<String>> selectedServices;

  const LocationScreen({
    super.key,
    required this.themeNotifier,
    required this.selectedServices,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? _selectedCity;
  Set<String> _currentAreaSelection = {};
  List<LocationSelection> _finalLocations = [];
  String _areaSearchQuery = '';

  List<String> get _availableCities => kJordanCities
      .where((city) => !_finalLocations.any((loc) => loc.city == city))
      .toList();

  @override
  void initState() {
    super.initState();
    _selectedCity = _availableCities.isNotEmpty ? _availableCities.first : null;
  }

  void _onBackTap() => Navigator.pop(context);

  bool get _isNextEnabled => _finalLocations.isNotEmpty;

  void _onNextTap() {
    if (_isNextEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkScheduleScreen(
            themeNotifier: widget.themeNotifier,
            selectedServices: widget.selectedServices,
            selectedLocations: _finalLocations,
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
      });

      _currentAreaSelection = {};
      _selectedCity = _availableCities.isNotEmpty
          ? _availableCities.first
          : null;
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
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kLightBlue, kPrimaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
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
                      'Pick location(s)',
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
                        'Select the cities and areas where you will be providing your services.',
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
              _LocationSelectionContent(
                availableCities: _availableCities,
                selectedCity: _selectedCity,
                currentAreaSelection: _currentAreaSelection,
                finalLocations: _finalLocations,
                areaSearchQuery: _areaSearchQuery,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderNavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final bool isNextEnabled;

  const _ProviderNavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    this.isNextEnabled = false,
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
              color: Colors.white.withOpacity(isNextEnabled ? 1.0 : 0.5),
            ),
            onPressed: isNextEnabled ? onNextTap : null,
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
  final ValueChanged<String> onCitySelected;
  final ValueChanged<String> onAreaTapped;
  final ValueChanged<String> onAreaSearchChanged;
  final VoidCallback onSave;
  final ValueChanged<LocationSelection> onEdit;
  final ValueChanged<String> onDelete;
  final bool isDarkMode;

  const _LocationSelectionContent({
    required this.availableCities,
    required this.selectedCity,
    required this.currentAreaSelection,
    required this.finalLocations,
    required this.areaSearchQuery,
    required this.onCitySelected,
    required this.onAreaTapped,
    required this.onAreaSearchChanged,
    required this.onSave,
    required this.onEdit,
    required this.onDelete,
    required this.isDarkMode,
  });

  List<Widget> _buildSelectedLocationsList() {
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;

    return [
      Padding(
        padding: const EdgeInsets.only(left: 10.0, bottom: 0.0),
        child: Text(
          'Selected Locations (${finalLocations.length})',
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
          final areas = loc.areas.toList().join(', ');
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
              boxShadow: isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.city,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => onEdit(loc),
                      customBorder: const CircleBorder(),
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
                      customBorder: const CircleBorder(),
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
            areaSearchQuery: areaSearchQuery,
            onCitySelected: onCitySelected,
            onAreaTapped: onAreaTapped,
            onAreaSearchChanged: onAreaSearchChanged,
            onSave: onSave,
            isDarkMode: isDarkMode,
          ),
          if (finalLocations.isNotEmpty) const SizedBox(height: 10.0),
          if (finalLocations.isNotEmpty) ..._buildSelectedLocationsList(),
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
  final String areaSearchQuery;
  final ValueChanged<String> onCitySelected;
  final ValueChanged<String> onAreaTapped;
  final ValueChanged<String> onAreaSearchChanged;
  final VoidCallback onSave;
  final bool isDarkMode;

  const _CityAreaSelector({
    required this.availableCities,
    required this.selectedCity,
    required this.currentAreaSelection,
    required this.areaSearchQuery,
    required this.onCitySelected,
    required this.onAreaTapped,
    required this.onAreaSearchChanged,
    required this.onSave,
    required this.isDarkMode,
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
                  title: 'City Picker',
                  child: _CityList(
                    cities: availableCities,
                    selectedCity: selectedCity,
                    onCitySelected: onCitySelected,
                    isDarkMode: isDarkMode,
                  ),
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _LocationBox(
                  title: 'Area Picker',
                  child: _AreaList(
                    selectedCity: selectedCity,
                    currentAreaSelection: currentAreaSelection,
                    areaSearchQuery: areaSearchQuery,
                    onAreaTapped: onAreaTapped,
                    onAreaSearchChanged: onAreaSearchChanged,
                    isDarkMode: isDarkMode,
                  ),
                  isDarkMode: isDarkMode,
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
                    isSaveEnabled ? 'Add Location' : 'Select Areas to Add',
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
    final Color headerBgColor = kPrimaryBlue;
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
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.vertical(
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

class _CityList extends StatelessWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String> onCitySelected;
  final bool isDarkMode;

  const _CityList({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
    required this.isDarkMode,
  });

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

class _AreaList extends StatelessWidget {
  final String? selectedCity;
  final Set<String> currentAreaSelection;
  final String areaSearchQuery;
  final ValueChanged<String> onAreaTapped;
  final ValueChanged<String> onAreaSearchChanged;
  final bool isDarkMode;

  const _AreaList({
    required this.selectedCity,
    required this.currentAreaSelection,
    required this.areaSearchQuery,
    required this.onAreaTapped,
    required this.onAreaSearchChanged,
    required this.isDarkMode,
  });

  String _normalizeString(String text) {
    return text.replaceAll(RegExp(r'[\s-]'), '').toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCity == null) {
      return Center(
        child: Text(
          'No city available for selection.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    final List<String> availableAreas = kCityAreas[selectedCity] ?? [];
    String normalizedQuery = _normalizeString(areaSearchQuery);

    final List<String> filteredAreas = availableAreas.where((area) {
      if (normalizedQuery.isEmpty) return true;
      return _normalizeString(area).contains(normalizedQuery);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: _AreaSearchBar(
            onSearchChanged: onAreaSearchChanged,
            isDarkMode: isDarkMode,
          ),
        ),
        Expanded(
          child: filteredAreas.isEmpty && normalizedQuery.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'No areas found for "$areaSearchQuery" in $selectedCity.',
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

                    final Color itemBgColor = isSelected
                        ? kPrimaryBlue.withOpacity(0.1)
                        : (isDarkMode
                              ? Colors.transparent
                              : Colors.transparent);
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
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: itemTextColor,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: kSelectedGreen,
                              size: 20,
                            )
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
                ),
        ),
      ],
    );
  }
}

class _AreaSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final bool isDarkMode;

  const _AreaSearchBar({
    required this.onSearchChanged,
    required this.isDarkMode,
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
          hintText: 'Search',
          hintStyle: TextStyle(color: searchHintColor, fontSize: 14.0),
          prefixIcon: Icon(Icons.search, color: iconColor, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 10,
          ),
          filled: true,
          fillColor: searchFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
