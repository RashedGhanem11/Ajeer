import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import '../../main.dart'; // Accesses the global themeNotifier

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  final OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: BorderSide(color: Colors.grey[300]!, width: 2.5),
  );

  final OutlineInputBorder _errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.0),
    borderSide: const BorderSide(color: Colors.red, width: 2.5),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndLogin() {
    debugPrint("Validation bypassed for testing! Navigating to Home Screen...");

    // FIX: Navigate to the correct class (HomeScreen) and pass the required themeNotifier instance.
    // NOTE: Because themeNotifier is a variable, you CANNOT use `const` here.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(themeNotifier: themeNotifier),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const double logoHeight = 105.0;
    final double formTopPosition = screenHeight * 0.30;
    final double logoTopPosition = formTopPosition - logoHeight;

    return Scaffold(
      backgroundColor: Colors.grey[200],
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
          colors: [Color(0xFF1976D2), Color(0xFF8CCBFF)],
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
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Image.asset('assets/image/home.png', height: logoHeight),
    );
  }

  Widget _buildLoginForm(double formTopPosition) {
    return Positioned(
      top: formTopPosition,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25.0),
                _buildEmailField(),
                const SizedBox(height: 20.0),
                _buildPasswordField(),
                const SizedBox(height: 10.0),
                _buildForgotButton(),
                const SizedBox(height: 30.0),
                _buildLoginButton(),
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
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[100],
      errorText: error,
      enabledBorder: _inputBorder,
      focusedBorder: _inputBorder.copyWith(
        borderSide: BorderSide(color: Colors.grey[500]!, width: 2.5),
      ),
      errorBorder: _errorBorder,
      focusedErrorBorder: _errorBorder,
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
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
      decoration: _createInputDecoration(
        hint: "Password",
        icon: Icons.lock_outline,
        error: _passwordError,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[500],
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
          style: TextStyle(color: Colors.blue, fontSize: 14.0),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF8CCBFF)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(color: const Color(0xFF478eff), width: 2.0),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _validateAndLogin,
            borderRadius: BorderRadius.circular(30.0),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                child: Text(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey[600]),
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
          child: const Text(
            "Sign up",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignUpButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        side: BorderSide(color: Colors.grey[300]!, width: 2.5),
      ),
      icon: Image.asset('assets/image/google.png', height: 22.0),
      label: const Text(
        "Sign up using Google",
        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
      ),
    );
  }
}
