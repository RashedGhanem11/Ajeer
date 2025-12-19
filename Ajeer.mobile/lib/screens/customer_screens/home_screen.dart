import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../widgets/shared_widgets/custom_bottom_nav_bar.dart';
import 'unit_type_screen.dart';
import 'bookings_screen.dart';
import '../shared_screens/profile_screen.dart';
import '../shared_screens/chat_screen.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/language_notifier.dart';
import '../../config/app_config.dart';
import '../../models/service_models.dart';
import '../../services/service_category_service.dart';

class HomeScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 3;
  String _searchQuery = '';
  List<ServiceCategory> _categories = [];
  bool _isFetching = true;
  late AnimationController _overlayAnimationController;
  late AnimationController _gridAnimationController;
  ServiceCategory? _selectedCategoryForAnimation;

  @override
  void initState() {
    super.initState();
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _gridAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fetchCategories();
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    _gridAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final service = ServiceCategoryService();
      final fetchedCategories = await service.fetchCategories();

      if (!mounted) return;

      setState(() {
        _categories = fetchedCategories;
        _isFetching = false;
      });
      _gridAnimationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onCategorySelected(ServiceCategory category) async {
    setState(() {
      _selectedCategoryForAnimation = category;
    });

    await _overlayAnimationController.forward(from: 0.0);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnitTypeScreen(category: category),
      ),
    );

    if (!mounted) return;

    setState(() {
      _selectedCategoryForAnimation = null;
    });
    _overlayAnimationController.reset();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfileScreen(themeNotifier: widget.themeNotifier),
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
            builder: (context) =>
                HomeScreen(themeNotifier: widget.themeNotifier),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageNotifier>(context);
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
    const double logoHeight = 105.0;
    const double overlapAdjustment = 10.0;
    final double whiteContainerTop = screenHeight * 0.30;
    final double logoTopPosition =
        whiteContainerTop - logoHeight + overlapAdjustment;

    const double navBarHeight = 56.0 + 20.0;
    const double outerBottomMargin = 10.0;
    final double bottomNavClearance =
        navBarHeight +
        outerBottomMargin +
        MediaQuery.of(context).padding.bottom;

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

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              _buildBackgroundGradient(whiteContainerTop),
              _buildWhiteContainer(
                containerTop: whiteContainerTop,
                bottomNavClearance: bottomNavClearance,
                isDarkMode: isDarkMode,
                lang: lang,
              ),
              SearchHeader(onChanged: _onSearchChanged, lang: lang),
              _buildHomeImage(logoTopPosition, logoHeight, isDarkMode),
              if (_isFetching)
                Container(
                  color: isDarkMode ? Colors.black54 : Colors.white70,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            items: navItems,
            selectedIndex: _selectedIndex,
            onIndexChanged: _onNavItemTapped,
          ),
        ),
        if (_selectedCategoryForAnimation != null)
          _buildAnimationOverlay(isDarkMode),
      ],
    );
  }

  Widget _buildAnimationOverlay(bool isDarkMode) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _overlayAnimationController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF40403f) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/image/placeholder.png',
                image: AppConfig.getFullImageUrl(
                  _selectedCategoryForAnimation!.iconUrl,
                ),
                fit: BoxFit.contain,
                imageErrorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.red,
                  );
                },
              ),
            ),
          ),
        ),
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
            colors: [Color(0xFF8CCBFF), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeImage(
    double logoTopPosition,
    double logoHeight,
    bool isDarkMode,
  ) {
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
          height: logoHeight,
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
              padding: const EdgeInsetsDirectional.only(start: 20.0, top: 20.0),
              child: Text(
                lang.translate('selectService'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: ServiceGridView(
                services: _categories,
                searchQuery: _searchQuery,
                bottomPadding: bottomNavClearance,
                isDarkMode: isDarkMode,
                onCategorySelected: _onCategorySelected,
                animationController: _gridAnimationController,
                lang: lang,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchHeader extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final LanguageNotifier lang;

  const SearchHeader({super.key, required this.onChanged, required this.lang});

  @override
  Widget build(BuildContext context) {
    const gradientColors = [Color(0xFF8CCBFF), Color(0xFF1976D2)];

    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              lang.translate('appName'),
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
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.white, width: 1.5),
                  gradient: const LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: onChanged,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  decoration: InputDecoration(
                    hintText: lang.translate('searchHint'),
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceGridView extends StatelessWidget {
  final List<ServiceCategory> services;
  final String searchQuery;
  final double bottomPadding;
  final bool isDarkMode;
  final Function(ServiceCategory) onCategorySelected;
  final AnimationController animationController;
  final LanguageNotifier lang;

  const ServiceGridView({
    super.key,
    required this.services,
    required this.searchQuery,
    required this.bottomPadding,
    required this.isDarkMode,
    required this.onCategorySelected,
    required this.animationController,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final String normalizedQuery = searchQuery.trim().toLowerCase();

    final filteredServices = services.where((service) {
      final translatedName = lang.translate(service.name);
      return translatedName.toLowerCase().contains(normalizedQuery);
    }).toList();

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
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];
          final translatedName = lang.translate(service.name);

          final double start =
              (index /
                  (filteredServices.isEmpty ? 1 : filteredServices.length)) *
              0.5;
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
              child: ServiceGridItem(
                iconUrl: service.iconUrl,
                name: translatedName,
                isHighlighted:
                    normalizedQuery.isNotEmpty &&
                    translatedName.toLowerCase().contains(normalizedQuery),
                isDarkMode: isDarkMode,
                onTap: () => onCategorySelected(service),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ServiceGridItem extends StatelessWidget {
  final String iconUrl;
  final String name;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isDarkMode;

  const ServiceGridItem({
    super.key,
    required this.iconUrl,
    required this.name,
    this.isHighlighted = false,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = isHighlighted
        ? Colors.green.shade600
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400);

    final Color itemBackgroundColor = isHighlighted
        ? activeColor.withOpacity(0.1)
        : (isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100);

    final Color itemBorderColor = isHighlighted
        ? activeColor.withOpacity(0.5)
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: itemBackgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: itemBorderColor, width: 2),
            ),
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/image/placeholder.png',
                  image: AppConfig.getFullImageUrl(iconUrl),
                  fit: BoxFit.contain,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.red,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                color: isHighlighted
                    ? activeColor
                    : (isDarkMode ? Colors.white70 : Colors.black87),
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
