import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/services.dart';
import '../customer_screens/profile_screen.dart';
import '../../themes/theme_notifier.dart';
import 'location_screen.dart';

class ServicesScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const ServicesScreen({super.key, required this.themeNotifier});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const double _borderRadius = 50.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;
  static const double _whiteContainerTopRatio = 0.15;

  String _searchQuery = '';
  final List<Service> _availableServices = kAvailableServices;
  final Map<String, Set<String>> _selectedUnitTypes = {};

  @override
  void initState() {
    super.initState();
    _initializeSelectedUnitTypes();
  }

  void _initializeSelectedUnitTypes() {
    for (var service in _availableServices) {
      if (service.unitTypes.isNotEmpty) {
        _selectedUnitTypes[service.name] = {};
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  bool get _isNextEnabled =>
      _selectedUnitTypes.values.any((set) => set.isNotEmpty);

  void _onBackTap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfileScreen(themeNotifier: widget.themeNotifier),
      ),
    );
  }

  void _onNextTap() {
    if (_isNextEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationScreen(
            themeNotifier: widget.themeNotifier,
            selectedServices: _selectedUnitTypes,
          ),
        ),
      );
    }
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
    final double whiteContainerTop = screenHeight * _whiteContainerTopRatio;
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(context),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            isDarkMode: isDarkMode,
            bottomPadding: bottomNavClearance,
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

  Widget _buildBackgroundGradient(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightBlue, _primaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _searchBarWidget(bool isDarkMode) {
    final Color searchFillColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.white;
    final Color searchBorderColor = isDarkMode
        ? Colors.grey.shade600
        : Colors.grey.shade400;
    final Color searchTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color searchHintColor = isDarkMode
        ? Colors.grey.shade500
        : Colors.grey.shade600;
    final Color iconColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: searchFillColor,
          border: Border.all(color: searchBorderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(color: searchTextColor, fontSize: 16.0),
          decoration: InputDecoration(
            hintText: 'Search for a service',
            hintStyle: TextStyle(color: searchHintColor, fontSize: 16.0),
            prefixIcon: IconButton(
              icon: Icon(Icons.search, color: iconColor),
              onPressed: () {},
            ),
            border: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteContainer({
    required double containerTop,
    required double bottomPadding,
    required bool isDarkMode,
  }) {
    return Positioned(
      top: containerTop,
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(_borderRadius)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black45 : Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select service(s)',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Select the services and unit types you want to provide.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15.0),
            _searchBarWidget(isDarkMode),
            Expanded(
              child: _ProviderServiceGridView(
                services: _availableServices,
                searchQuery: _searchQuery,
                selectedUnitTypes: _selectedUnitTypes,
                onUnitTypeSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedUnitTypes.clear();
                    _selectedUnitTypes.addAll(newSelection);
                  });
                },
                bottomPadding: bottomPadding,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
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
          Expanded(child: Center(child: _buildAjeerTitle())),
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

class _ProviderServiceGridView extends StatelessWidget {
  final List<Service> services;
  final String searchQuery;
  final Map<String, Set<String>> selectedUnitTypes;
  final ValueChanged<Map<String, Set<String>>> onUnitTypeSelectionChanged;
  final double bottomPadding;
  final bool isDarkMode;

  const _ProviderServiceGridView({
    required this.services,
    required this.searchQuery,
    required this.selectedUnitTypes,
    required this.onUnitTypeSelectionChanged,
    required this.bottomPadding,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    String normalizedQuery = searchQuery.trim().toLowerCase();

    List<Service> servicesToShow = services
        .where((s) => s.unitTypes.isNotEmpty)
        .toList();

    if (normalizedQuery.isNotEmpty) {
      servicesToShow = servicesToShow.where((service) {
        return service.name.toLowerCase().contains(normalizedQuery);
      }).toList();
    }

    bool isServiceSelected(String serviceName) =>
        selectedUnitTypes[serviceName]?.isNotEmpty ?? false;

    void toggleServiceSelection(Service service) {
      String name = service.name;
      Set<String> allUnitTypeKeys = service.unitTypes.keys.toSet();

      final Map<String, Set<String>> newSelection = {};

      if (!isServiceSelected(name)) {
        newSelection[name] = allUnitTypeKeys;
      }

      onUnitTypeSelectionChanged(newSelection);
    }

    void showUnitTypeSelectionDialog(Service service) {
      showDialog(
        context: context,
        builder: (context) {
          return _UnitTypeSelectionDialog(
            service: service,
            initialSelectedUnitTypes: selectedUnitTypes[service.name] ?? {},
            onSave: (newSelection) {
              final Map<String, Set<String>> updatedSelection = {};

              if (newSelection.isNotEmpty) {
                updatedSelection[service.name] = newSelection;
              }

              onUnitTypeSelectionChanged(updatedSelection);
            },
            isDarkMode: isDarkMode,
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: bottomPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: servicesToShow.length,
        itemBuilder: (context, index) {
          final service = servicesToShow[index];
          final serviceName = service.name;
          final serviceIcon = service.icon;
          final unitCount = selectedUnitTypes[serviceName]?.length ?? 0;

          final bool isHighlightedBySearch =
              normalizedQuery.isNotEmpty &&
              service.name.toLowerCase().contains(normalizedQuery);

          return _ProviderServiceGridItem(
            icon: serviceIcon,
            name: serviceName,
            unitCount: unitCount,
            isSelected: isServiceSelected(serviceName),
            isHighlightedBySearch: isHighlightedBySearch,
            isDarkMode: isDarkMode,
            onTap: () => toggleServiceSelection(service),
            onUnitTypeTap: () => showUnitTypeSelectionDialog(service),
          );
        },
      ),
    );
  }
}

class _ProviderServiceGridItem extends StatelessWidget {
  final IconData? icon;
  final String name;
  final int unitCount;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onUnitTypeTap;
  final bool isDarkMode;
  final bool isHighlightedBySearch;

  const _ProviderServiceGridItem({
    required this.icon,
    required this.name,
    required this.unitCount,
    required this.isSelected,
    required this.onTap,
    required this.onUnitTypeTap,
    required this.isDarkMode,
    required this.isHighlightedBySearch,
  });

  @override
  Widget build(BuildContext context) {
    final Color _selectionBlue = const Color(0xFF1976D2);
    final Color _highlightGreen = Colors.green.shade600;
    const Color _editButtonColor = Color(0xFF1976D2);
    const Color _badgeColor = Colors.green;

    Color activeColor;
    bool applyBoxStyle = false;

    if (isSelected) {
      activeColor = _selectionBlue;
      applyBoxStyle = true;
    } else if (isHighlightedBySearch) {
      activeColor = _highlightGreen;
      applyBoxStyle = true;
    } else {
      activeColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;
    }

    final Color itemPrimaryColor = activeColor;
    final Color itemBackgroundColor = applyBoxStyle
        ? itemPrimaryColor.withOpacity(0.1)
        : (isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100);
    final Color itemBorderColor = applyBoxStyle
        ? itemPrimaryColor.withOpacity(0.5)
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);
    final List<BoxShadow>? itemBoxShadow = applyBoxStyle
        ? [
            BoxShadow(
              color: itemPrimaryColor.withOpacity(isDarkMode ? 0.3 : 0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ]
        : null;
    final Color itemTextColor = applyBoxStyle
        ? (isDarkMode ? Colors.white : Colors.black87)
        : (isDarkMode ? Colors.white70 : Colors.black54);

    const double iconContainerSize = 80.0;
    const double iconSize = 40.0;
    const double badgeSize = 26.0;

    const double editIconContainerSize = 30.0;
    const double editIconOffset = -2.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: itemBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: itemBorderColor, width: 2),
                  boxShadow: itemBoxShadow,
                ),
                child: Icon(icon, size: iconSize, color: itemPrimaryColor),
              ),
              if (isSelected)
                Positioned(
                  bottom: editIconOffset,
                  right: editIconOffset,
                  child: GestureDetector(
                    onTap: onUnitTypeTap,
                    child: Container(
                      width: editIconContainerSize,
                      height: editIconContainerSize,
                      decoration: BoxDecoration(
                        color: _editButtonColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDarkMode
                              ? Theme.of(context).cardColor
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              if (isSelected && unitCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: badgeSize,
                    height: badgeSize,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: _badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode
                            ? Theme.of(context).cardColor
                            : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$unitCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: applyBoxStyle ? FontWeight.bold : FontWeight.w500,
                color: itemTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitTypeSelectionDialog extends StatefulWidget {
  final Service service;
  final Set<String> initialSelectedUnitTypes;
  final ValueChanged<Set<String>> onSave;
  final bool isDarkMode;

  const _UnitTypeSelectionDialog({
    required this.service,
    required this.initialSelectedUnitTypes,
    required this.onSave,
    required this.isDarkMode,
  });

  @override
  State<_UnitTypeSelectionDialog> createState() =>
      _UnitTypeSelectionDialogState();
}

class _UnitTypeSelectionDialogState extends State<_UnitTypeSelectionDialog> {
  late Set<String> _selectedUnitTypes;
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _subtleDark = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _selectedUnitTypes = Set.from(widget.initialSelectedUnitTypes);
  }

  void _onUnitTypeTapped(String unitType) {
    setState(() {
      if (_selectedUnitTypes.contains(unitType)) {
        _selectedUnitTypes.remove(unitType);
      } else {
        _selectedUnitTypes.add(unitType);
      }
    });
  }

  void _saveSelection() {
    widget.onSave(_selectedUnitTypes);
    Navigator.of(context).pop();
  }

  String _formattedTime(int estimatedTime) {
    if (estimatedTime < 60) return '$estimatedTime mins';
    final hours = estimatedTime ~/ 60;
    final minutes = estimatedTime % 60;
    if (minutes == 0) return '$hours hrs';
    return '$hours hrs $minutes mins';
  }

  @override
  Widget build(BuildContext context) {
    final unitTypesMap = widget.service.unitTypes;
    final unitTypeKeys = unitTypesMap.keys.toList();
    final Color dialogBgColor = widget.isDarkMode ? _subtleDark : Colors.white;
    final Color titleColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return AlertDialog(
      backgroundColor: dialogBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        'Select unit type(s) for ${widget.service.name}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: titleColor,
          fontSize: 21,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: unitTypeKeys.length,
                itemBuilder: (context, index) {
                  final unitName = unitTypeKeys[index];
                  final dynamic data = unitTypesMap[unitName];
                  if (data == null) return const SizedBox.shrink();

                  final int estimatedTime = data.estimatedTimeMinutes;
                  final double price = data.priceJOD;
                  final bool isSelected = _selectedUnitTypes.contains(unitName);

                  return _UnitTypeListItem(
                    name: unitName,
                    timeString: _formattedTime(estimatedTime),
                    priceString: 'JOD ${price.toStringAsFixed(1)}',
                    isSelected: isSelected,
                    onTap: () => _onUnitTypeTapped(unitName),
                    isDarkMode: widget.isDarkMode,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.grey : Colors.grey.shade700,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedUnitTypes.isNotEmpty ? _saveSelection : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _UnitTypeListItem extends StatelessWidget {
  final String name;
  final String timeString;
  final String priceString;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _UnitTypeListItem({
    required this.name,
    required this.timeString,
    required this.priceString,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  });

  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _subtleLighterDarkGrey = Color(0xFF242424);

  @override
  Widget build(BuildContext context) {
    final Color fillColor = isDarkMode
        ? _subtleLighterDarkGrey
        : Colors.grey[100]!;
    final Color unselectedBorderColor = isDarkMode
        ? Colors.grey[600]!
        : Colors.grey[400]!;
    final Color unselectedTitleColor = isDarkMode
        ? Colors.white70
        : Colors.grey[700]!;
    final Color timeTextColor = isDarkMode
        ? Colors.grey[400]!
        : Colors.grey[600]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? _primaryBlue : unselectedBorderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? _primaryBlue : unselectedTitleColor,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Est. Time: $timeString',
                    style: TextStyle(fontSize: 13, color: timeTextColor),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceString,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.green : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
