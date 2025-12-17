import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/auth_models.dart';
import '../../notifiers/language_notifier.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State Variables
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // New loading state

  // Primary Colors
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _lightBlue = Color(0xFF8CCBFF);
  static const Color _darkScaffoldBackground = Color(0xFF121212);
  static const Color _darkCardColor = Color(0xFF1E1E1E);

  late LanguageNotifier _languageNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageNotifier = Provider.of<LanguageNotifier>(context);
  }

  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // REFACTORED: Connects to Backend via AuthService and includes combined Name validation
  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      final String firstName = _firstNameController.text.trim();
      final String lastName = _lastNameController.text.trim();
      final String fullName = "$firstName $lastName";

      // --- 1. Check Name Maximum Length (Client-Side Check) ---
      if (fullName.length > 100) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_languageNotifier.translate('fullNameTooLong')),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // 2. Start Loading
      setState(() {
        _isLoading = true;
      });

      // 3. Prepare Data
      final request = UserRegisterRequest(
        name: fullName,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        // 4. Call API
        final authService = AuthService();
        await authService.register(request);

        if (!mounted) return;

        // 5. Success Feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_languageNotifier.translate('accountCreated')),
            backgroundColor: Colors.green,
          ),
        );

        // 6. Navigate back to Login
        Navigator.pop(context);
      } catch (e) {
        // 7. Error Handling
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        // 8. Stop Loading
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const double logoHeight = 105.0;

    final double formTopPosition = screenHeight * 0.25;
    final double logoTopPosition = formTopPosition - logoHeight;

    return Scaffold(
      backgroundColor: _isDarkMode ? _darkScaffoldBackground : Colors.grey[200],
      body: Stack(
        children: [
          _buildHeaderGradient(screenHeight),
          _buildTitleWithBackButton(context),
          _buildSignUpForm(formTopPosition),
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

  Widget _buildTitleWithBackButton(BuildContext context) {
    final isArabic = _languageNotifier.isArabic;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Stack(
          children: [
            Align(
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
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: IconButton(
                  icon: RotatedBox(
                    quarterTurns: isArabic ? 2 : 0,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
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

  Widget _buildSignUpForm(double formTopPosition) {
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
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _languageNotifier.translate('createAccount'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  _buildNameFields(),
                  const SizedBox(height: 15.0),
                  _buildPhoneField(),
                  const SizedBox(height: 15.0),
                  _buildEmailField(),
                  const SizedBox(height: 15.0),
                  _buildPasswordField(),
                  const SizedBox(height: 15.0),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 25.0),
                  _buildSignUpButton(),
                  const SizedBox(height: 25.0),
                  _buildLoginLink(),
                  const SizedBox(height: 20.0),
                ],
              ),
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
    Color? fillColor = Colors.grey,
  }) {
    final bool isWhiteFill = fillColor == Colors.white;

    final Color inputFillColor = _isDarkMode
        ? (isWhiteFill ? _darkCardColor : Colors.grey[800]!)
        : (isWhiteFill ? Colors.white : Colors.grey[100]!);
    final Color hintTextColor = _isDarkMode
        ? Colors.grey[500]!
        : Colors.grey[400]!;
    final Color iconColor = _isDarkMode ? Colors.grey[400]! : Colors.grey[500]!;
    final Color borderColor = _isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[300]!;
    final Color focusBorderColor = _isDarkMode ? _lightBlue : _primaryBlue;

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: borderColor, width: 2.5),
    );

    final OutlineInputBorder focusedBorder = inputBorder.copyWith(
      borderSide: BorderSide(color: focusBorderColor, width: 2.5),
    );

    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.red, width: 2.5),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintTextColor),
      prefixIcon: Icon(icon, color: iconColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputFillColor,
      enabledBorder: inputBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    );
  }

  Widget _buildNameFields() {
    final Color fieldTextColor = _isDarkMode ? Colors.white : Colors.black87;
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _firstNameController,
            style: TextStyle(color: fieldTextColor),
            decoration: _createInputDecoration(
              hint: _languageNotifier.translate('firstName'),
              icon: Icons.person_outline,
              fillColor: Colors.white,
            ),
            // VALIDATION: Name is required.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _languageNotifier.translate('nameRequired');
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 15.0),
        Expanded(
          child: TextFormField(
            controller: _lastNameController,
            style: TextStyle(color: fieldTextColor),
            decoration: _createInputDecoration(
              hint: _languageNotifier.translate('lastName'),
              icon: Icons.person_outline,
              fillColor: Colors.white,
            ),
            // VALIDATION: Name is required.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _languageNotifier.translate('nameRequired');
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    final Color fieldTextColor = _isDarkMode ? Colors.white : Colors.black87;
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: fieldTextColor),
      decoration: _createInputDecoration(
        hint: _languageNotifier.translate('phoneNumber'),
        icon: Icons.phone_outlined,
      ),
      // VALIDATION: Phone NotEmpty and MaxLength(20)
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _languageNotifier.translate('phoneRequired');
        }
        if (value.length > 20) {
          return _languageNotifier.translate('phoneTooLong');
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    final Color fieldTextColor = _isDarkMode ? Colors.white : Colors.black87;
    // Basic email regex for front-end validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: fieldTextColor),
      decoration: _createInputDecoration(
        hint: _languageNotifier.translate('email'),
        icon: Icons.email_outlined,
      ),
      // VALIDATION: Email NotEmpty, EmailAddress, and MaxLength(100)
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _languageNotifier.translate('emailRequired');
        }
        if (value.length > 100) {
          return _languageNotifier.translate('emailTooLong');
        }
        if (!emailRegex.hasMatch(value)) {
          return _languageNotifier.translate('emailInvalid');
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    final Color fieldTextColor = _isDarkMode ? Colors.white : Colors.black87;
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: fieldTextColor),
      decoration: _createInputDecoration(
        hint: _languageNotifier.translate('passwordHint'),
        icon: Icons.lock_outline,
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
      // VALIDATION: Password NotEmpty and MinLength(8)
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _languageNotifier.translate('passwordRequired');
        }
        if (value.length < 8) {
          return _languageNotifier.translate('passwordTooShort');
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    final Color fieldTextColor = _isDarkMode ? Colors.white : Colors.black87;
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      style: TextStyle(color: fieldTextColor),
      decoration: _createInputDecoration(
        hint: _languageNotifier.translate('confirmPassword'),
        icon: Icons.lock_outline,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: _isDarkMode ? Colors.grey[400]! : Colors.grey[500]!,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      // VALIDATION: Match Password
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _languageNotifier.translate('passwordRequired');
        }
        if (value != _passwordController.text) {
          return _languageNotifier.translate('passwordsDoNotMatch');
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
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
            onTap: _isLoading
                ? null
                : _handleSignUp, // Disable tap when loading
            borderRadius: BorderRadius.circular(30.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
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
                        _languageNotifier.translate('signUpButton'),
                        style: const TextStyle(
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
    final Color linkTextColor = _isDarkMode
        ? Colors.grey[400]!
        : Colors.grey[600]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _languageNotifier.translate('alreadyHaveAccount'),
          style: TextStyle(color: linkTextColor),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _languageNotifier.translate('logIn'),
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
