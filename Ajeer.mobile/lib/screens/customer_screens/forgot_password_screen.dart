import 'package:flutter/material.dart';

// NEW: Enums to manage the current view state
enum ResetStep { selectMethod, enterDetails, resetPassword }

enum ResetMethod { none, email, phone }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // NEW: State variables to manage the flow
  // MODIFIED: Set back to selectMethod for the correct, final flow
  ResetStep _currentStep = ResetStep.selectMethod;
  ResetMethod _selectedMethod = ResetMethod.none;

  // NEW: Controller and error for the new Email/Phone field
  final TextEditingController _emailPhoneController = TextEditingController();
  String? _emailPhoneError;

  // Original controllers
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Original error strings
  String? _newPasswordError;
  String? _confirmPasswordError;

  // Original password visibility state
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // This is your original, unchanged function to style TextFields.
  // It will be reused for the new Email/Phone field.
  InputDecoration _buildInputDecoration(
    String hint,
    IconData icon, [
    String? errorText,
  ]) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[100],
      errorText: errorText,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 2.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
    );
  }

  // Your original validation function for the final step
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
        print('Passwords match! Resetting password...');
        // Implement your password reset logic here
        // On success, you might want to pop the screen
        // Navigator.pop(context);
      } else {
        print('Passwords do not match.');
        _confirmPasswordError = 'Passwords do not match.';
      }
    });
  }

  // NEW: Validation function for the new Email/Phone step
  void _validateEmailPhone() {
    setState(() {
      _emailPhoneError = null;
      final input = _emailPhoneController.text;

      if (input.isEmpty) {
        _emailPhoneError =
            'Please enter your ${_selectedMethod == ResetMethod.email ? 'email' : 'phone number'}.';
        return;
      }

      // Add more specific validation if needed (e.g., email format)

      print('Sending reset code to: $input');
      // Implement your logic to send a reset code here

      // If successful, move to the next step
      _currentStep = ResetStep.resetPassword;
    });
  }

  // NEW: Makes the top-left back arrow context-aware
  void _handleBackButton() {
    if (_currentStep == ResetStep.enterDetails) {
      setState(() {
        _currentStep = ResetStep.selectMethod;
        _selectedMethod = ResetMethod.none;
        _emailPhoneError = null; // Clear error on navigating back
      });
    } else if (_currentStep == ResetStep.resetPassword) {
      setState(() {
        _currentStep = ResetStep.enterDetails;
        _newPasswordError = null; // Clear errors on navigating back
        _confirmPasswordError = null;
      });
    } else {
      // If we are on the first step, pop the screen
      Navigator.pop(context);
    }
  }

  // NEW: Makes the "Cancel" button always go back to the first step
  void _handleCancel() {
    setState(() {
      _currentStep = ResetStep.selectMethod;
      _selectedMethod = ResetMethod.none;
      // Clear all errors
      _emailPhoneError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });
  }

  // NEW: Widget for the first step (Method Selection)
  Widget _buildSelectMethod() {
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
              foregroundColor: const Color(0xFF1976D2),
              side: const BorderSide(color: Color(0xFF1976D2), width: 2),
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
              foregroundColor: const Color(0xFF1976D2),
              side: const BorderSide(color: Color(0xFF1976D2), width: 2),
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

  // NEW: Widget for the second step (Enter Details)
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
            // Phone hint text updated as requested
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
              onPressed: _handleCancel, // NEW: Use centralized cancel handler
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            // Re-using your exact button styling
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                border: Border.all(color: const Color(0xFF478eff), width: 2.0),
                borderRadius: BorderRadius.circular(27),
              ),
              child: ElevatedButton(
                onPressed: _validateEmailPhone, // NEW: Validate this step
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
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
            ),
          ],
        ),
      ],
    );
  }

  // NEW: Widget for the final step (Reset Password)
  // This is your original layout
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
              onPressed: _handleCancel, // NEW: Use centralized cancel handler
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),
            const SizedBox(width: 10),
            // Your original button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                border: Border.all(color: const Color(0xFF478eff), width: 2.0),
                borderRadius: BorderRadius.circular(27),
              ),
              child: ElevatedButton(
                onPressed: _validateAndReset, // Original function
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
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
            ),
          ],
        ),
      ],
    );
  }

  // NEW: This helper function selects which widget to show
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
            colors: [
              Color(0xFF1976D2), // Darker blue
              Color(0xFF8CCBFF), // Lighter blue
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
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
                    onPressed:
                        _handleBackButton, // NEW: Use context-aware handler
                  ),
                ),
              ),

              // Your main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Used a Stack for overlapping
                      Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none, // Allow overlap
                        children: [
                          // The Card
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
                              // NEW: The child is now dynamic
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _buildCurrentStepWidget(),
                              ),
                            ),
                          ),

                          // The Icon
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
