// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // A key to identify our form & trigger validation
  final _formKey = GlobalKey<FormState>();

  // Controllers to get the text from fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- This layout is identical to your LoginScreen ---
    final screenHeight = MediaQuery.of(context).size.height;
    const double logoHeight = 105.0;

    // --- MODIFIED ---
    // Moved the form up from 30% to 25% of the screen height
    final double formTopPosition = screenHeight * 0.25;
    // --- END MODIFIED ---

    final double logoTopPosition = formTopPosition - logoHeight;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          _buildHeaderGradient(screenHeight),
          _buildTitle(), // <-- This widget now contains the back button
          // We pass the key values to the form widget
          _buildSignUpForm(screenHeight, formTopPosition),
          _buildLogo(logoTopPosition, logoHeight),
        ],
      ),
    );
  }

  // --- These widgets are copied directly from LoginScreen for identical style ---

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

  // --- MODIFIED: This widget now includes the back button ---
  Widget _buildTitle() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Stack(
          // Use a Stack to layer the title and the button
          children: [
            // This is your original centered title
            const Align(
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

            // --- ADDED THIS WIDGET ---
            // This is the new back button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                // Add some padding to push it in from the edge
                padding: const EdgeInsets.only(left: 12.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new, // The iOS-style icon
                    color: Colors.white,
                    size: 24.0,
                  ),
                  onPressed: () {
                    // This is the same action as your "Log in" text button
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            // --- END ADDED WIDGET ---
          ],
        ),
      ),
    );
  }
  // --- END MODIFIED ---

  Widget _buildLogo(double logoTopPosition, double logoHeight) {
    // Note: You might want a different logo for sign up,
    // but we use the same one for consistency for now.
    return Positioned(
      top: logoTopPosition,
      left: 0,
      right: 0,
      child: Column(
        children: [Image.asset('assets/image/home.png', height: logoHeight)],
      ),
    );
  }

  // --- This is the main Sign Up Form widget ---

  Widget _buildSignUpForm(double screenHeight, double formTopPosition) {
    return Positioned(
      top: formTopPosition,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        // Style is copied from LoginScreen's form
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
            // --- MODIFIED ---
            // Reduced top padding from 40.0 to 30.0
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 20.0),
            // --- END MODIFIED ---

            // We use a Form widget to get validation features
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Account", // <-- Changed text
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // --- MODIFIED ---
                  // Reduced spacing from 25.0 to 20.0
                  const SizedBox(height: 20.0),
                  _buildNameFields(), // <-- New widget for first/last name
                  // Reduced spacing from 20.0 to 15.0
                  const SizedBox(height: 15.0),
                  _buildPhoneField(), // <-- New widget for phone
                  // Reduced spacing from 20.0 to 15.0
                  const SizedBox(height: 15.0),
                  _buildEmailField(), // <-- Adapted from LoginScreen
                  // Reduced spacing from 20.0 to 15.0
                  const SizedBox(height: 15.0),
                  _buildPasswordField(), // <-- Adapted from LoginScreen
                  // Reduced spacing from 20.0 to 15.0
                  const SizedBox(height: 15.0),
                  _buildConfirmPasswordField(), // <-- New widget for confirm
                  // Reduced spacing from 30.0 to 25.0
                  const SizedBox(height: 25.0),
                  _buildSignUpButton(), // <-- Adapted from LoginScreen
                  // Reduced spacing from 30.0 to 25.0
                  const SizedBox(height: 25.0),
                  _buildLoginLink(), // <-- Adapted from LoginScreen
                  const SizedBox(height: 20.0), // Keep some bottom space
                  // --- END MODIFIED ---
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // I created this helper to avoid repeating the decoration code 5 times
  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    Color? fillColor, // <-- MODIFIED: Added parameter
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      suffixIcon: suffixIcon,
      filled: true,
      // MODIFIED: Use parameter or default to grey
      fillColor: fillColor ?? Colors.grey[100],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 2.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 2.5),
      ),
      // Add error borders for validation
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.5),
      ),
    );
  }

  // New widget for side-by-side name fields
  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstNameController,
            decoration: _buildInputDecoration(
              hint: "First Name",
              icon: Icons.person_outline,
              fillColor: Colors.white, // <-- MODIFIED
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Cannot be empty';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 15.0),
        Expanded(
          child: TextFormField(
            controller: _lastNameController,
            decoration: _buildInputDecoration(
              hint: "Last Name",
              icon: Icons.person_outline,
              fillColor: Colors.white, // <-- MODIFIED
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Cannot be empty';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: _buildInputDecoration(
        hint: "Phone Number",
        icon: Icons.phone_outlined,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter phone number';
        }
        // You can add more complex phone validation here if needed
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _buildInputDecoration(
        hint: "Email",
        icon: Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: _buildInputDecoration(
        hint: "Password",
        icon: Icons.lock_outline,
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
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: _buildInputDecoration(
        hint: "Confirm Password",
        icon: Icons.lock_outline,
        fillColor: Colors.white, // <-- MODIFIED
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey[500],
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        // Here is the matching logic
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    // Copied directly from _buildLoginButton, just changed text and logic
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
            onTap: () {
              // This is where the validation happens
              if (_formKey.currentState!.validate()) {
                // If the form is valid, show a snackbar (or proceed with auth)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign Up Successful!')),
                );
                // TODO: Add your sign-up logic (e.g., Firebase, API call)
                print("First Name: ${_firstNameController.text}");
                print("Email: ${_emailController.text}");
              }
            },
            borderRadius: BorderRadius.circular(30.0),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                child: Text(
                  "SIGN UP", // <-- Changed text
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

  Widget _buildLoginLink() {
    // Copied from _buildSignUpLink, just changed text and logic
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ", // <-- Changed text
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            // This pops the current screen off the stack,
            // returning to the LoginScreen
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            "Log in", // <-- Changed text
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
