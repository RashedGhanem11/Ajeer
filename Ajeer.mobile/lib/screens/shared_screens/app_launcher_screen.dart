import 'package:flutter/material.dart';
import '../customer_screens/login_screen.dart';
import 'profile_screen.dart';
import '../../themes/theme_notifier.dart';

class AppLauncherScreen extends StatefulWidget {
  final bool isLoggedIn;
  final ThemeNotifier themeNotifier;

  const AppLauncherScreen({
    super.key,
    required this.isLoggedIn,
    required this.themeNotifier,
  });

  @override
  State<AppLauncherScreen> createState() => _AppLauncherScreenState();
}

class _AppLauncherScreenState extends State<AppLauncherScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  final String _text = "Ajeer";
  final List<Animation<double>> _letterOpacityAnimations = [];
  final List<Animation<Offset>> _letterSlideAnimations = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    const double textStartTime = 0.4;
    const double textDuration = 0.5;
    final double step = textDuration / _text.length;

    for (int i = 0; i < _text.length; i++) {
      final double start = textStartTime + (i * step);
      final double end = start + 0.15;

      _letterOpacityAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeIn),
          ),
        ),
      );

      _letterSlideAnimations.add(
        Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start,
              end > 1.0 ? 1.0 : end,
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    Widget destination = widget.isLoggedIn
        ? ProfileScreen(themeNotifier: widget.themeNotifier)
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.themeNotifier.isDarkMode;
    final Color backgroundColor = isDark ? Colors.black : Colors.white;
    final Color primaryBlue = const Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/image/app_launcher.png'),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            // Added Directionality widget here to force LTR layout
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_text.length, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _letterOpacityAnimations[index].value,
                        child: SlideTransition(
                          position: _letterSlideAnimations[index],
                          child: Text(
                            _text[index],
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              letterSpacing: 1.5,
                              fontFamily: 'font',
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
