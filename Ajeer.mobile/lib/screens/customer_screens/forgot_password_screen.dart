import 'package:flutter/material.dart';

enum ResetStep { selectMethod, enterDetails, resetPassword }

enum ResetMethod { none, email, phone }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
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

  InputDecoration _buildInputDecoration(
    String hint,
    IconData icon, [
    String? errorText,
  ]) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12.0));
    const Color primaryColor = Color(0xFF1976D2);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[100],
      errorText: errorText,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.grey[300]!, width: 2.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: primaryColor, width: 2.5),
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
      final input = _emailPhoneController.text;

      if (input.isEmpty) {
        _emailPhoneError =
            'Please enter your ${_selectedMethod == ResetMethod.email ? 'email' : 'phone number'}.';
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
      _emailPhoneError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });
  }

  Widget _buildSelectMethod() {
    const Color primaryColor = Color(0xFF1976D2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'How would you like to reset your password?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
              side: const BorderSide(color: primaryColor, width: 2),
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
              side: const BorderSide(color: primaryColor, width: 2),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEmail ? 'Enter Email' : 'Enter Phone Number',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailPhoneController,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.phone,
          decoration: _buildInputDecoration(
            isEmail ? 'your-email@example.com' : '+962 7XXXXXXXX',
            isEmail ? Icons.email_outlined : Icons.phone_outlined,
            _emailPhoneError,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _handleCancel,
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _newPasswordController,
          obscureText: _isNewPasswordObscured,
          decoration:
              _buildInputDecoration(
                'New Password',
                Icons.lock_outline,
                _newPasswordError,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[500],
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
        TextField(
          controller: _confirmPasswordController,
          obscureText: _isConfirmPasswordObscured,
          decoration:
              _buildInputDecoration(
                'Confirm New Password',
                Icons.lock_outline,
                _confirmPasswordError,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey[500],
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                    });
                  },
                ),
              ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _handleCancel,
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
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
    const Color primaryColor = Color(0xFF1976D2);
    const Color accentColor = Color(0xFF478eff);

    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        border: Border.all(color: accentColor, width: 2.0),
        borderRadius: BorderRadius.circular(27),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF8CCBFF)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
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
                          Card(
                            elevation: 8,
                            color: Colors.white,
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
                          Positioned(
                            top: -35,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1976D2),
                                    Color(0xFF8CCBFF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
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
