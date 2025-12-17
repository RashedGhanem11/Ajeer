import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/service_models.dart';
import '../../services/service_category_service.dart';
import '../shared_screens/profile_screen.dart';
import '../../themes/theme_notifier.dart';
import '../../config/app_config.dart';
import 'location_screen.dart';
import '../../../models/provider_data.dart';
import '../../notifiers/language_notifier.dart';

class ServicesScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  final bool isEdit;
  final ProviderData? initialData;

  const ServicesScreen({
    super.key,
    required this.themeNotifier,
    this.isEdit = false,
    this.initialData,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const Color _primaryBlue = Color(0xFF2f6cfa);
  static const Color _lightBlue = Color(0xFFa2bdfc);
  static const double _borderRadius = 50.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 8.0;
  static const double _whiteContainerTopRatio = 0.15;

  final ServiceCategoryService _apiService = ServiceCategoryService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ServiceCategory> _categories = [];
  final Map<int, List<ServiceItem>> _categoryItems = {};

  String _searchQuery = '';
  final Map<String, Set<String>> _selectedUnitTypes = {};

  late LanguageNotifier _languageNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageNotifier = Provider.of<LanguageNotifier>(context);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await _apiService.fetchCategories();

      await Future.wait(
        categories.map((category) async {
          try {
            final items = await _apiService.fetchServicesForCategory(
              category.id,
            );
            _categoryItems[category.id] = items;
          } catch (e) {
            _categoryItems[category.id] = [];
            debugPrint('Error fetching items for ${category.name}: $e');
          }
        }),
      );

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
        _prefillIfEditing();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load services. Please check your connection.';
        });
      }
    }
  }

  void _prefillIfEditing() {
    if (widget.isEdit && widget.initialData != null) {
      _selectedUnitTypes.clear();
      if (widget.initialData!.services.isNotEmpty) {
        final service = widget.initialData!.services.first;
        _selectedUnitTypes[service.name] = service.selectedUnitTypes.toSet();
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
    if (widget.isEdit) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProfileScreen(themeNotifier: widget.themeNotifier),
        ),
      );
    }
  }

  List<int> _getSelectedServiceIds() {
    List<int> ids = [];

    for (var category in _categories) {
      final selectedNames = _selectedUnitTypes[category.name];

      if (selectedNames != null && selectedNames.isNotEmpty) {
        final items = _categoryItems[category.id];
        if (items != null) {
          for (var item in items) {
            if (selectedNames.contains(item.name)) {
              ids.add(item.id);
            }
          }
        }
      }
    }
    return ids;
  }

  void _onNextTap() {
    if (_isNextEnabled) {
      final ids = _getSelectedServiceIds();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationScreen(
            themeNotifier: widget.themeNotifier,
            selectedServices: _selectedUnitTypes,
            serviceIds: ids,
            isEdit: widget.isEdit,
            initialData: widget.initialData,
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
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: searchFillColor,
          border: Border.all(color: searchBorderColor, width: 2),
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
          decoration: InputDecoration(
            hintText: _languageNotifier.translate('searchService'),
            prefixIcon: Icon(
              Icons.search,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            border: InputBorder.none,
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _languageNotifier.translate('selectServiceTitle'),
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
                      _languageNotifier.translate('selectServiceDesc'),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _languageNotifier.translate('loadServicesFailed'),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: _loadData,
                            child: Text(_languageNotifier.translate('retry')),
                          ),
                        ],
                      ),
                    )
                  : _ProviderServiceGridView(
                      categories: _categories,
                      categoryItems: _categoryItems,
                      searchQuery: _searchQuery,
                      selectedUnitTypes: _selectedUnitTypes,
                      onUnitTypeSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedUnitTypes.clear();
                          _selectedUnitTypes.addAll(newSelection);
                        });
                      },
                      bottomPadding: 20.0,
                      isDarkMode: isDarkMode,
                      languageNotifier: _languageNotifier,
                    ),
            ),
          ],
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

class _ProviderServiceGridView extends StatelessWidget {
  final List<ServiceCategory> categories;
  final Map<int, List<ServiceItem>> categoryItems;
  final String searchQuery;
  final Map<String, Set<String>> selectedUnitTypes;
  final ValueChanged<Map<String, Set<String>>> onUnitTypeSelectionChanged;
  final double bottomPadding;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _ProviderServiceGridView({
    required this.categories,
    required this.categoryItems,
    required this.searchQuery,
    required this.selectedUnitTypes,
    required this.onUnitTypeSelectionChanged,
    required this.bottomPadding,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    String normalizedQuery = searchQuery.trim().toLowerCase();
    List<ServiceCategory> categoriesToShow = categories;

    if (normalizedQuery.isNotEmpty) {
      categoriesToShow = categoriesToShow
          .where(
            (c) => languageNotifier
                .translate(c.name)
                .toLowerCase()
                .contains(normalizedQuery),
          )
          .toList();
    }
    categoriesToShow = categoriesToShow
        .where((c) => (categoryItems[c.id]?.isNotEmpty ?? false))
        .toList();

    bool isCategorySelected(String catName) =>
        selectedUnitTypes[catName]?.isNotEmpty ?? false;

    void toggleServiceSelection(ServiceCategory category) {
      String name = category.name;
      List<ServiceItem> items = categoryItems[category.id] ?? [];

      final Map<String, Set<String>> newSelection = {};

      if (!isCategorySelected(name)) {
        newSelection[name] = items.map((i) => i.name).toSet();
      }

      onUnitTypeSelectionChanged(newSelection);
    }

    void showUnitTypeSelectionDialog(ServiceCategory category) {
      showDialog(
        context: context,
        builder: (context) {
          return _UnitTypeSelectionDialog(
            categoryName: category.name,
            items: categoryItems[category.id] ?? [],
            initialSelectedUnitTypes: selectedUnitTypes[category.name] ?? {},
            onSave: (newSelection) {
              final Map<String, Set<String>> updatedSelection = {};
              if (newSelection.isNotEmpty) {
                updatedSelection[category.name] = newSelection;
              }
              onUnitTypeSelectionChanged(updatedSelection);
            },
            isDarkMode: isDarkMode,
            languageNotifier: languageNotifier,
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
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categoriesToShow.length,
        itemBuilder: (context, index) {
          final category = categoriesToShow[index];
          final unitCount = selectedUnitTypes[category.name]?.length ?? 0;
          final bool isHighlightedBySearch =
              normalizedQuery.isNotEmpty &&
              languageNotifier
                  .translate(category.name)
                  .toLowerCase()
                  .contains(normalizedQuery);

          return _ProviderServiceGridItem(
            iconUrl: category.iconUrl,
            name: languageNotifier.translate(category.name),
            unitCount: unitCount,
            isSelected: isCategorySelected(category.name),
            isHighlightedBySearch: isHighlightedBySearch,
            isDarkMode: isDarkMode,
            languageNotifier: languageNotifier,
            onTap: () => toggleServiceSelection(category),
            onUnitTypeTap: () => showUnitTypeSelectionDialog(category),
          );
        },
      ),
    );
  }
}

class _ProviderServiceGridItem extends StatelessWidget {
  final String iconUrl;
  final String name;
  final int unitCount;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onUnitTypeTap;
  final bool isDarkMode;
  final bool isHighlightedBySearch;
  final LanguageNotifier languageNotifier;

  const _ProviderServiceGridItem({
    required this.iconUrl,
    required this.name,
    required this.unitCount,
    required this.isSelected,
    required this.onTap,
    required this.onUnitTypeTap,
    required this.isDarkMode,
    required this.isHighlightedBySearch,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final Color _selectionBlue = const Color(0xFF1976D2);
    final Color _highlightGreen = Colors.green.shade600;

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

    const double iconContainerSize = 80.0;
    const double iconSize = 40.0;

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
                ),
                child: Center(
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/image/placeholder.png',
                      image: AppConfig.getFullImageUrl(iconUrl),
                      fit: BoxFit.contain,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.broken_image,
                          size: iconSize,
                          color: itemPrimaryColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: onUnitTypeTap,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        languageNotifier.convertNumbers('$unitCount'),
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
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: applyBoxStyle ? FontWeight.bold : FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.black54,
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
  final String categoryName;
  final List<ServiceItem> items;
  final Set<String> initialSelectedUnitTypes;
  final ValueChanged<Set<String>> onSave;
  final bool isDarkMode;
  final LanguageNotifier languageNotifier;

  const _UnitTypeSelectionDialog({
    required this.categoryName,
    required this.items,
    required this.initialSelectedUnitTypes,
    required this.onSave,
    required this.isDarkMode,
    required this.languageNotifier,
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
    final hrStr = widget.languageNotifier.translate('hr');
    final hrsStr = widget.languageNotifier.translate('hrs');
    final minStr = widget.languageNotifier.translate('min');
    final minsStr = widget.languageNotifier.translate('mins');

    String result;
    if (estimatedTime < 60) {
      result = '$estimatedTime $minsStr';
    } else {
      final hours = estimatedTime ~/ 60;
      final minutes = estimatedTime % 60;
      if (minutes == 0) {
        result = '$hours ${hours > 1 ? hrsStr : hrStr}';
      } else {
        result = '$hours ${hours > 1 ? hrsStr : hrStr} $minutes $minsStr';
      }
    }
    return widget.languageNotifier.convertNumbers(result);
  }

  @override
  Widget build(BuildContext context) {
    final Color dialogBgColor = widget.isDarkMode ? _subtleDark : Colors.white;
    final Color titleColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return AlertDialog(
      backgroundColor: dialogBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(
        '${widget.languageNotifier.translate('selectUnitTypesFor')} ${widget.languageNotifier.translate(widget.categoryName)}',
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
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final bool isSelected = _selectedUnitTypes.contains(
                    item.name,
                  );

                  return _UnitTypeListItem(
                    name: widget.languageNotifier.translate(item.name),
                    timeString: _formattedTime(item.timeInMinutes),
                    priceString: widget.languageNotifier.isArabic
                        ? '${widget.languageNotifier.convertNumbers(item.priceValue.toStringAsFixed(1))} ${widget.languageNotifier.translate('jod')}'
                        : 'JOD ${item.priceValue.toStringAsFixed(1)}',
                    isSelected: isSelected,
                    onTap: () => _onUnitTypeTapped(item.name),
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
            widget.languageNotifier.translate('cancel'),
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
          child: Text(
            widget.languageNotifier.translate('save'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _UnitTypeListItem extends StatefulWidget {
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

  @override
  State<_UnitTypeListItem> createState() => _UnitTypeListItemState();
}

class _UnitTypeListItemState extends State<_UnitTypeListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _subtleLighterDarkGrey = Color(0xFF242424);

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
    final Color fillColor = widget.isDarkMode
        ? _subtleLighterDarkGrey
        : Colors.grey[100]!;
    final Color unselectedBorderColor = widget.isDarkMode
        ? Colors.grey[600]!
        : Colors.grey[400]!;
    final Color unselectedTitleColor = widget.isDarkMode
        ? Colors.white70
        : Colors.grey[700]!;
    final Color timeTextColor = widget.isDarkMode
        ? Colors.grey[400]!
        : Colors.grey[600]!;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: widget.isSelected ? _primaryBlue : unselectedBorderColor,
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
                      widget.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: widget.isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: widget.isSelected
                            ? _primaryBlue
                            : unselectedTitleColor,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Est. Time: ${widget.timeString}',
                      style: TextStyle(fontSize: 13, color: timeTextColor),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.priceString,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                    ),
                  ),
                  Icon(
                    widget.isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: widget.isSelected ? Colors.green : Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
