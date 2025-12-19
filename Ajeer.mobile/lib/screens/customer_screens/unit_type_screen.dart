import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'date_time_screen.dart';
import 'bookings_screen.dart';
import '../shared_screens/profile_screen.dart';
import '../shared_screens/chat_screen.dart';
import 'home_screen.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/language_notifier.dart';
import '../../config/app_config.dart';
import '../../models/service_models.dart';
import '../../services/unit_type_service.dart';

class UnitTypeScreen extends StatefulWidget {
  final ServiceCategory category;

  const UnitTypeScreen({super.key, required this.category});

  @override
  State<UnitTypeScreen> createState() => _UnitTypeScreenState();
}

class _UnitTypeScreenState extends State<UnitTypeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 3;
  final Set<int> _selectedIds = {};
  List<ServiceItem> _availableServices = [];
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _listAnimationController;

  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const double _logoHeight = 105.0;
  static const double _overlapAdjustment = 10.0;
  static const double _navBarTotalHeight = 56.0 + 20.0 + 10.0;

  final String BASE_API_URL = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fetchData();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final apiService = UnitTypeService();
      final items = await apiService.fetchServicesByCategory(
        widget.category.id,
      );

      if (!mounted) return;
      setState(() {
        _availableServices = items;
        _isLoading = false;
      });
      _listAnimationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
            builder: (_) => ProfileScreen(themeNotifier: themeNotifier),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookingsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(themeNotifier: themeNotifier),
          ),
        );
        break;
    }
  }

  void _onServiceTapped(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _onNextTap(LanguageNotifier lang) {
    if (_selectedIds.isNotEmpty) {
      double totalCost = 0.0;
      int totalMinutes = 0;
      List<String> selectedNames = [];

      for (var service in _availableServices) {
        if (_selectedIds.contains(service.id)) {
          totalCost += service.priceValue;
          totalMinutes += service.timeInMinutes;
          selectedNames.add(lang.translate(service.name));
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DateTimeScreen(
            serviceIds: _selectedIds.toList(),
            serviceName: lang.translate(widget.category.name),
            unitType: selectedNames.join(', '),
            totalTimeMinutes: totalMinutes,
            totalPrice: totalCost,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('selectAtLeastOne')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final lang = Provider.of<LanguageNotifier>(context);
    final bool isDarkMode = themeNotifier.isDarkMode;

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
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop - _logoHeight + _overlapAdjustment;
    final double bottomNavClearance =
        _navBarTotalHeight + MediaQuery.of(context).padding.bottom;

    final List<Map<String, dynamic>> navItems = [
      {
        'label': lang.translate('profile'),
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
      },
      {
        'label': lang.translate('chat'),
        'icon': Icons.chat_bubble_outline,
        'activeIcon': Icons.chat_bubble,
      },
      {
        'label': lang.translate('bookings'),
        'icon': Icons.book_outlined,
        'activeIcon': Icons.book,
        'notificationCount': 3,
      },
      {
        'label': lang.translate('home'),
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
      },
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(whiteContainerTop),
          _buildServiceIcon(
            whiteContainerTop,
            MediaQuery.of(context).padding.top,
          ),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            bottomNavClearance: bottomNavClearance,
            isDarkMode: isDarkMode,
            lang: lang,
          ),
          _buildHomeImage(logoTopPosition, isDarkMode),
          _UnitTypeNavigationHeader(
            onBackTap: () => Navigator.pop(context),
            onNextTap: () => _onNextTap(lang),
            isNextEnabled: _selectedIds.isNotEmpty,
            lang: lang,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: navItems,
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

  Widget _buildServiceIcon(double containerTop, double statusBarHeight) {
    final double headerHeight = statusBarHeight + 60;
    final double availableHeight = containerTop - headerHeight;
    final double iconTopPosition = headerHeight + (availableHeight / 2) - 70;

    return PositionedDirectional(
      top: iconTopPosition,
      end: 25.0,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFc2e3ff), Color(0xFF57b2ff)],
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
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/image/placeholder.png',
              image:
                  '$BASE_API_URL/${widget.category.iconUrl.replaceAll("wwwroot/", "")}',
              fit: BoxFit.contain,
              imageErrorBuilder: (c, o, s) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 40),
            ),
          ),
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
    required LanguageNotifier lang,
  }) {
    return Positioned(
      top: containerTop,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 20.0,
                top: 20.0,
                bottom: 10.0,
              ),
              child: Text(
                lang.translate('selectUnitType'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text("Error: $_errorMessage"))
                  : _availableServices.isEmpty
                  ? Center(child: Text(lang.translate('noUnitsAvailable')))
                  : _UnitTypeListView(
                      services: _availableServices,
                      selectedIds: _selectedIds,
                      onServiceTap: _onServiceTapped,
                      bottomPadding: bottomNavClearance,
                      isDarkMode: isDarkMode,
                      animationController: _listAnimationController,
                      lang: lang,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitTypeNavigationHeader extends StatefulWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final bool isNextEnabled;
  final LanguageNotifier lang;

  const _UnitTypeNavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    this.isNextEnabled = false,
    required this.lang,
  });

  @override
  State<_UnitTypeNavigationHeader> createState() =>
      _UnitTypeNavigationHeaderState();
}

class _UnitTypeNavigationHeaderState extends State<_UnitTypeNavigationHeader>
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
  void didUpdateWidget(_UnitTypeNavigationHeader oldWidget) {
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
            widget.lang.translate('appName'),
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

class _UnitTypeListView extends StatelessWidget {
  final List<ServiceItem> services;
  final Set<int> selectedIds;
  final ValueChanged<int> onServiceTap;
  final double bottomPadding;
  final bool isDarkMode;
  final AnimationController animationController;
  final LanguageNotifier lang;

  const _UnitTypeListView({
    required this.services,
    required this.selectedIds,
    required this.onServiceTap,
    required this.bottomPadding,
    required this.isDarkMode,
    required this.animationController,
    required this.lang,
  });

  String _formatPrice(double price) {
    final String formattedNumber = lang.convertNumbers(
      price.toStringAsFixed(2),
    );
    return lang.isArabic
        ? '$formattedNumber ${lang.translate('jod')}'
        : '${lang.translate('jod')} $formattedNumber';
  }

  String _formatTime(int minutes) {
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    String result = '';

    if (h > 0) {
      String hrsLabel = h > 1 ? lang.translate('hrs') : lang.translate('hr');
      result += '${lang.convertNumbers(h.toString())} $hrsLabel';
    }

    if (m > 0) {
      if (result.isNotEmpty) result += ' ';
      String minsLabel = m > 1 ? lang.translate('mins') : lang.translate('min');
      result += '${lang.convertNumbers(m.toString())} $minsLabel';
    }

    return '${lang.translate('estTime')}: $result';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 10.0,
        bottom: bottomPadding,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final bool isSelected = selectedIds.contains(service.id);

        final double start =
            (index / (services.isNotEmpty ? services.length : 1)) * 0.5;
        final double end = (start + 0.5).clamp(0.0, 1.0);

        final Animation<double> animation = CurvedAnimation(
          parent: animationController,
          curve: Interval(start, end, curve: Curves.easeOutQuart),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: _SelectableUnitItem(
              name: lang.translate(service.name),
              estimatedTime: _formatTime(service.timeInMinutes),
              priceDisplay: _formatPrice(service.priceValue),
              isSelected: isSelected,
              onTap: () => onServiceTap(service.id),
              isDarkMode: isDarkMode,
            ),
          ),
        );
      },
    );
  }
}

class _SelectableUnitItem extends StatefulWidget {
  final String name;
  final String estimatedTime;
  final String priceDisplay;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _SelectableUnitItem({
    required this.name,
    required this.estimatedTime,
    required this.priceDisplay,
    required this.isSelected,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<_SelectableUnitItem> createState() => _SelectableUnitItemState();
}

class _SelectableUnitItemState extends State<_SelectableUnitItem>
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

  static const Color _primaryBlue = Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    final Color fillColor = widget.isDarkMode
        ? const Color(0xFF242424)
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
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: widget.isSelected ? _primaryBlue : unselectedBorderColor,
              width: 2.0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _primaryBlue.withOpacity(
                        widget.isDarkMode ? 0.4 : 0.2,
                      ),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        widget.isDarkMode ? 0.1 : 0.02,
                      ),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                        fontSize: 18,
                        fontWeight: widget.isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: widget.isSelected
                            ? _primaryBlue
                            : unselectedTitleColor,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      widget.estimatedTime,
                      style: TextStyle(fontSize: 14, color: timeTextColor),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.priceDisplay,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryBlue,
                    ),
                  ),
                  Icon(
                    widget.isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: widget.isSelected ? Colors.green : Colors.grey[400],
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
