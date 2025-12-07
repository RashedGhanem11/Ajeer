import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import '../../services/auth_service.dart'; // Import your new Auth Service

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Logic Variables
  bool _isPasswordVisible = false;
  bool _isLoading = false; // New state for API loading

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // UI Error messages
  String? _emailError;
  String? _passwordError;

  // Primary Colors (from app_themes.dart)
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _lightBlue = Color(0xFF8CCBFF);
  // Dark mode specific colors (from app_themes.dart)
  static const Color _darkScaffoldBackground = Color(0xFF121212);
  static const Color _darkCardColor = Color(0xFF1E1E1E);

  // Helper method to determine if dark mode is active
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // REFACTORED: Now connects to Backend via AuthService
  void _validateAndLogin() async {
    // Reset errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final input = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool isValid = true;

    // 1. Identifier (Email or Phone) Validation
    if (input.isEmpty) {
      _emailError = "Email Or Phone is required.";
      isValid = false;
    } else if (input.length > 100) {
      _emailError = "Email Or Phone cannot exceed 100 characters.";
      isValid = false;
    }

    // 2. Password Validation
    if (password.isEmpty) {
      _passwordError = "Password is required.";
      isValid = false;
    } else if (password.length < 8) {
      _passwordError = "Password must be at least 8 characters.";
      isValid = false;
    }

    // Stop and update UI errors if not valid
    if (!isValid) {
      setState(() {});
      return;
    }

    // --- Continue with API Call only if validation passes ---
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
          builder: (context) => HomeScreen(themeNotifier: themeNotifier),
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
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            "Ajeer",
            style: TextStyle(
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
                  "Login",
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
                const SizedBox(height: 10.0),
                _buildForgotButton(),
                const SizedBox(height: 30.0),
                _buildLoginButton(), // Updated to handle loading
                const SizedBox(height: 30.0),
                _buildSignUpLink(),
                const SizedBox(height: 25.0),
                _buildGoogleSignUpButton(),
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
        hint: "Email or phone number",
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
        hint: "Password",
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

  Widget _buildForgotButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: const Text(
          "Forgot?",
          style: TextStyle(color: _primaryBlue, fontSize: 14.0),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final Color shadowColor = _primaryBlue.withOpacity(_isDarkMode ? 0.8 : 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80.0),
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
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // Disable click when loading
            onTap: _isLoading ? null : _validateAndLogin,
            borderRadius: BorderRadius.circular(30.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                // Show Spinner when loading, Text otherwise
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
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
        Text("Don't have an account? ", style: TextStyle(color: linkTextColor)),
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
          child: const Text(
            "Sign up",
            style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignUpButton() {
    final Color buttonBackgroundColor = _isDarkMode
        ? Colors.grey[800]!
        : Colors.white;
    final Color buttonBorderColor = _isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[300]!;
    final Color buttonLabelColor = _isDarkMode
        ? Colors.white70
        : Colors.black54;

    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Implement Google Sign-In logic here later
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: buttonBackgroundColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        side: BorderSide(color: buttonBorderColor, width: 2.5),
      ),
      icon: Image.asset('assets/image/google.png', height: 22.0),
      label: Text(
        "Sign up using Google",
        style: TextStyle(color: buttonLabelColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
