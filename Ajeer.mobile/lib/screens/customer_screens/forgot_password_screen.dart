import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
      } else {
        print('Passwords do not match.');
        _confirmPasswordError = 'Passwords do not match.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                              // Kept the more rounded corners
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 50,
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 30),
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
                                                _isNewPasswordObscured =
                                                    !_isNewPasswordObscured;
                                              });
                                            },
                                          ),
                                        ),
                                  ),
                                  SizedBox(height: 20),
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
                                                _isConfirmPasswordObscured =
                                                    !_isConfirmPasswordObscured;
                                              });
                                            },
                                          ),
                                        ),
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),

                                      // 1. RE-INTRODUCED Container FOR BORDER
                                      Container(
                                        decoration: BoxDecoration(
                                          // 2. REPLACED gradient with solid color
                                          color: const Color(0xFF1976D2),
                                          // 3. KEPT original border
                                          border: Border.all(
                                            color: const Color(0xFF478eff),
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            27,
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _validateAndReset,
                                          style: ElevatedButton.styleFrom(
                                            // Button is transparent to show container
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 25,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(27),
                                            ),
                                          ),
                                          child: Text(
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
                              ),
                            ),
                          ),

                          // The Icon
                          Positioned(
                            top: -35,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
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
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(15),
                              child: Icon(
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
