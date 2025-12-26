import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../notifiers/language_notifier.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/auth_service.dart';
import '../shared_screens/profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  late LanguageNotifier _languageNotifier;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageNotifier = Provider.of<LanguageNotifier>(context);
  }

  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _darkScaffoldBackground = Color(0xFF121212);
  static const Color _darkCardColor = Color(0xFF1E1E1E);

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final input = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool isValid = true;

    if (input.isEmpty) {
      _emailError = _languageNotifier.translate('emailOrPhoneRequired');
      isValid = false;
    } else if (input.length > 100) {
      _emailError = _languageNotifier.translate('emailOrPhoneTooLong');
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = _languageNotifier.translate('passwordRequired');
      isValid = false;
    } else if (password.length < 8) {
      _passwordError = _languageNotifier.translate('passwordTooShort');
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      await authService.login(input, password);

      if (!mounted) return;

      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(themeNotifier: themeNotifier),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const double logoHeight = 105.0;
    final double formTopPosition = screenHeight * 0.30;
    final double logoTopPosition = formTopPosition - logoHeight;

    return Scaffold(
      backgroundColor: _isDarkMode ? _darkScaffoldBackground : Colors.grey[200],
      body: Stack(
        children: [
          _buildHeaderGradient(screenHeight),
          _buildTitle(),
          _buildLoginForm(formTopPosition),
          _buildLogo(logoTopPosition, logoHeight),
        ],
      ),
    );
  }

  Widget _buildHeaderGradient(double screenHeight) {
    return Container(
      height: screenHeight * 0.35,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBlue, _lightBlue],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            _languageNotifier.translate('appName'),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
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
      ),
    );
  }

  Widget _buildLogo(double logoTopPosition, double logoHeight) {
    final String imagePath = _isDarkMode
        ? 'assets/image/home_dark.png'
        : 'assets/image/home.png';

    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Image.asset(imagePath, height: logoHeight),
    );
  }

  Widget _buildLoginForm(double formTopPosition) {
    final Color containerColor = _isDarkMode ? _darkCardColor : Colors.white;
    final Color titleColor = _isDarkMode ? Colors.white : Colors.black;
    final Color shadowColor = _isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.1);

    return Positioned(
      top: formTopPosition,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _languageNotifier.translate('loginTitle'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 25.0),
                _buildEmailField(),
                const SizedBox(height: 20.0),
                _buildPasswordField(),
                const SizedBox(height: 50.0),
                _buildLoginButton(),
                const SizedBox(height: 40.0),
                _buildSignUpLink(),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _createInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    String? error,
  }) {
    final Color inputFillColor = _isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[100]!;
    final Color hintTextColor = _isDarkMode
        ? Colors.grey[500]!
        : Colors.grey[400]!;
    final Color iconColor = _isDarkMode ? Colors.grey[400]! : Colors.grey[500]!;
    final Color borderColor = _isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[300]!;
    final Color focusBorderColor = _isDarkMode ? _lightBlue : _primaryBlue;

    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.red, width: 2.5),
    );

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: borderColor, width: 2.5),
    );

    final OutlineInputBorder focusedBorder = inputBorder.copyWith(
      borderSide: BorderSide(color: focusBorderColor, width: 2.5),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintTextColor),
      prefixIcon: Icon(icon, color: iconColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputFillColor,
      errorText: error,
      enabledBorder: inputBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
      decoration: _createInputDecoration(
        hint: _languageNotifier.translate('emailOrPhoneHint'),
        icon: Icons.email_outlined,
        error: _emailError,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
      decoration: _createInputDecoration(
        hint: _languageNotifier.translate('passwordHint'),
        icon: Icons.lock_outline,
        error: _passwordError,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _isDarkMode ? Colors.grey[400]! : Colors.grey[500]!,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final Color shadowColor = _primaryBlue.withOpacity(_isDarkMode ? 0.8 : 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 95.0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primaryBlue, _lightBlue],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(color: const Color(0xFF478eff), width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _validateAndLogin,
              borderRadius: BorderRadius.circular(30.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _languageNotifier.translate('loginButton'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    final Color linkTextColor = _isDarkMode
        ? Colors.grey[400]!
        : Colors.grey[600]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _languageNotifier.translate('dontHaveAccount'),
          style: TextStyle(color: linkTextColor),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _languageNotifier.translate('signUp'),
            style: const TextStyle(
              color: _primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
