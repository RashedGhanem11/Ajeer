import 'package:flutter/material.dart';

enum ResetStep { selectMethod, enterDetails, resetPassword }

enum ResetMethod { none, email, phone }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

// --- Constants Class for Cleanliness ---
class _ForgotPasswordConstants {
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFF8CCBFF);
  // Dark mode specific colors
  static const Color darkScaffoldBackground = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ResetStep _currentStep = ResetStep.selectMethod;
  ResetMethod _selectedMethod = ResetMethod.none;

  final TextEditingController _emailPhoneController = TextEditingController();
  String? _emailPhoneError;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _newPasswordError;
  String? _confirmPasswordError;

  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // Helper method to determine if dark mode is active
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Input Decoration Builder ---
  InputDecoration _buildInputDecoration(
    String hint,
    IconData icon, [
    String? errorText,
    Widget? suffixIcon,
  ]) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12.0));
    const Color primaryColor = _ForgotPasswordConstants.primaryBlue;

    // Theme-aware colors
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
    final Color focusBorderColor = _isDarkMode
        ? _ForgotPasswordConstants.lightBlue
        : primaryColor;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintTextColor),
      prefixIcon: Icon(icon, color: iconColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputFillColor,
      errorText: errorText,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor, width: 2.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: focusBorderColor, width: 2.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.red, width: 2.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.red, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
    );
  }

  // --- Validation and Navigation Handlers (Unchanged) ---
  void _validateAndReset() {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;

      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (newPassword.isEmpty) {
        _newPasswordError = 'Please enter a new password.';
        return;
      }

      if (newPassword.length < 6) {
        _newPasswordError = 'Password must be at least 6 characters long.';
        return;
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Please confirm your password.';
        return;
      }

      if (newPassword == confirmPassword) {
        debugPrint('Passwords match! Resetting password...');
      } else {
        debugPrint('Passwords do not match.');
        _confirmPasswordError = 'Passwords do not match.';
      }
    });
  }

  void _validateEmailPhone() {
    setState(() {
      _emailPhoneError = null;
      final input = _emailPhoneController.text.trim();

      if (input.isEmpty) {
        _emailPhoneError =
            'Please enter your ${_selectedMethod == ResetMethod.email ? 'email' : 'phone number'}.';
        return;
      }

      if (_selectedMethod == ResetMethod.email && !input.contains('@')) {
        _emailPhoneError = 'Please enter a valid email address.';
        return;
      }

      debugPrint('Sending reset code to: $input');
      _currentStep = ResetStep.resetPassword;
    });
  }

  void _handleBackButton() {
    if (_currentStep == ResetStep.enterDetails) {
      setState(() {
        _currentStep = ResetStep.selectMethod;
        _selectedMethod = ResetMethod.none;
        _emailPhoneError = null;
      });
    } else if (_currentStep == ResetStep.resetPassword) {
      setState(() {
        _currentStep = ResetStep.enterDetails;
        _newPasswordError = null;
        _confirmPasswordError = null;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _handleCancel() {
    setState(() {
      _currentStep = ResetStep.selectMethod;
      _selectedMethod = ResetMethod.none;
      _emailPhoneController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _emailPhoneError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });
  }

  // --- Step Widgets ---

  Widget _buildSelectMethod() {
    const Color primaryColor = _ForgotPasswordConstants.primaryBlue;
    final Color headingColor = _isDarkMode ? Colors.white : Colors.black;
    final Color subtitleColor = _isDarkMode
        ? Colors.grey[400]!
        : Colors.grey[600]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'How would you like to reset your password?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: subtitleColor),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.email_outlined),
            label: const Text('Reset using Email'),
            onPressed: () {
              setState(() {
                _selectedMethod = ResetMethod.email;
                _currentStep = ResetStep.enterDetails;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: primaryColor,
              // FIX: Removed 'const' from BorderSide
              side: BorderSide(color: primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Reset using Phone'),
            onPressed: () {
              setState(() {
                _selectedMethod = ResetMethod.phone;
                _currentStep = ResetStep.enterDetails;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: primaryColor,
              // FIX: Removed 'const' from BorderSide
              side: BorderSide(color: primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEnterDetails() {
    bool isEmail = _selectedMethod == ResetMethod.email;
    final Color headingColor = _isDarkMode ? Colors.white : Colors.black;
    final Color fieldTextColor = _isDarkMode ? Colors.white : Colors.black87;
    final Color buttonTextColor = _isDarkMode
        ? Colors.grey[400]!
        : Colors.grey[700]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEmail ? 'Enter Email' : 'Enter Phone Number',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailPhoneController,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.phone,
          textInputAction: TextInputAction.done,
          style: TextStyle(color: fieldTextColor),
          decoration: _buildInputDecoration(
            isEmail ? 'your-email@example.com' : '+962 7XXXXXXXX',
            isEmail ? Icons.email_outlined : Icons.phone_outlined,
            _emailPhoneError,
          ),
          onSubmitted: (_) => _validateEmailPhone(),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _handleCancel,
              child: Text(
                'Cancel',
                style: TextStyle(color: buttonTextColor, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            _buildContinueButton(onPressed: _validateEmailPhone),
          ],
        ),
      ],
    );
  }

  Widget _buildResetPassword() {
    final Color headingColor = _isDarkMode ? Colors.white : Colors.black;
    final Color fieldTextColor = _isDarkMode ? Colors.white : Colors.black87;
    final Color iconColor = _isDarkMode ? Colors.grey[400]! : Colors.grey[500]!;
    final Color buttonTextColor = _isDarkMode
        ? Colors.grey[400]!
        : Colors.grey[700]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 30),
        // New Password Field
        TextField(
          controller: _newPasswordController,
          obscureText: _isNewPasswordObscured,
          style: TextStyle(color: fieldTextColor),
          decoration: _buildInputDecoration(
            'New Password',
            Icons.lock_outline,
            _newPasswordError,
            IconButton(
              icon: Icon(
                _isNewPasswordObscured
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: iconColor,
              ),
              onPressed: () {
                setState(() {
                  _isNewPasswordObscured = !_isNewPasswordObscured;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Confirm Password Field
        TextField(
          controller: _confirmPasswordController,
          obscureText: _isConfirmPasswordObscured,
          style: TextStyle(color: fieldTextColor),
          decoration: _buildInputDecoration(
            'Confirm New Password',
            Icons.lock_outline,
            _confirmPasswordError,
            IconButton(
              icon: Icon(
                _isConfirmPasswordObscured
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: iconColor,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                });
              },
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _validateAndReset(),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _handleCancel,
              child: Text(
                'Cancel',
                style: TextStyle(color: buttonTextColor, fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            _buildContinueButton(onPressed: _validateAndReset),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton({required VoidCallback onPressed}) {
    const Color primaryColor = _ForgotPasswordConstants.primaryBlue;
    final Color buttonShadowColor = primaryColor.withOpacity(
      _isDarkMode ? 0.8 : 0.5,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, _ForgotPasswordConstants.lightBlue],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: _ForgotPasswordConstants.lightBlue,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: buttonShadowColor,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case ResetStep.selectMethod:
        return _buildSelectMethod();
      case ResetStep.enterDetails:
        return _buildEnterDetails();
      case ResetStep.resetPassword:
        return _buildResetPassword();
    }
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    final Color cardColor = _isDarkMode
        ? _ForgotPasswordConstants.darkCardColor
        : Colors.white;

    const Color primaryColor = _ForgotPasswordConstants.primaryBlue;

    return Scaffold(
      backgroundColor: _isDarkMode
          ? _ForgotPasswordConstants.darkScaffoldBackground
          : Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _ForgotPasswordConstants.primaryBlue,
              _ForgotPasswordConstants.lightBlue,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    onPressed: _handleBackButton,
                  ),
                ),
              ),
              // Main Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Card (Theme-aware)
                          Card(
                            elevation: 8,
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 50,
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _buildCurrentStepWidget(),
                              ),
                            ),
                          ),
                          // Key Icon (Solid Blue)
                          Positioned(
                            top: -35,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black38,
                                    spreadRadius: 0.5,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(15),
                              child: const Icon(
                                Icons.vpn_key,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
