import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/time_tracking/home.dart';
import 'package:provider/provider.dart';
// import 'goal_tracking_outer_screen.dart';
import 'api_service_auth.dart'; // Import the API service

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthApiService _authService = AuthApiService();

  Future<String?> _loginUser(LoginData data) async {
    debugPrint("Attempting login for username: ${data.name}");

    try {
      final token = await _authService.signIn(data.name, data.password);

      if (token != null) {
        debugPrint("Login successful");
        return null; // success
      } else {
        return "Invalid username or password";
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return "Login failed. Please try again.";
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    debugPrint('Attempting signup for username: ${data.name}');

    try {
      // Extract additional fields
      final additionalData = data.additionalSignupData;
      final fullName = additionalData?['Name'] ?? '';
      final username = additionalData?['Username'] ?? data.name;

      // Split full name into first and last name
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final token = await _authService.registerUser(
        data.name!, // email/username
        data.password!,
        firstName,
        lastName,
        '', // phone_number - you might want to add this as an additional field
      );

      if (token != null) {
        debugPrint("Registration successful");
        return null; // success
      } else {
        return "Registration failed. Please try again.";
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      return "Registration failed. Please try again.";
    }
  }

  Future<String?> _recoverPassword(String name) async {
    debugPrint('Recovering password for: $name');

    // Since the API service doesn't have a password recovery method,
    // you'll need to implement this on your backend and add it to the API service
    return Future.delayed(const Duration(milliseconds: 2250)).then((_) {
      // For now, just simulate the recovery process
      return "Password recovery is not yet implemented";
    });
  }

  @override
  void initState() {
    super.initState();
    // print(Provider.of<UserProvider>(context).userId);
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Check if user is already logged in
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Theme(
        data: Theme.of(context).copyWith(
          // Override the overall theme to ensure white text
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF111111),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF4444), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF4444), width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.white54, fontSize: 16),
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
            errorStyle: const TextStyle(color: Color(0xFFFF4444), fontSize: 12),
            prefixStyle: const TextStyle(color: Colors.white),
            suffixStyle: const TextStyle(color: Colors.white),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionColor: Colors.white24,
            selectionHandleColor: Colors.white,
          ),
        ),
        child: FlutterLogin(
          title: 'ReFL3KT',
          onLogin: _loginUser,
          onSignup: _signupUser,
          onRecoverPassword: _recoverPassword,
          messages: LoginMessages(
            userHint: 'Email/Username',
            passwordHint: 'Password',
            confirmPasswordHint: 'Confirm Password',
            loginButton: 'SIGN IN',
            signupButton: 'REGISTER',
            forgotPasswordButton: 'Forgot Password?',
            recoverPasswordButton: 'RECOVER',
            goBackButton: 'GO BACK',
            confirmPasswordError: 'Passwords do not match!',
            recoverPasswordDescription: 'We will send you a recovery link',
            recoverPasswordSuccess: 'Recovery email sent successfully!',
          ),
          theme: LoginTheme(
            // Primary colors - Pure black theme
            primaryColor: const Color(0xFF000000),
            accentColor: const Color(0xFF1A1A1A),
            errorColor: const Color(0xFFFF4444),

            // Title styling
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 42,
              letterSpacing: 6.0,
            ),

            // Body style
            bodyStyle: const TextStyle(color: Colors.white70, fontSize: 16),

            // Text field styling - FORCE WHITE COLOR
            textFieldStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),

            // Button styling
            buttonStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 16,
              letterSpacing: 1.0,
            ),

            // Card theme - Black with subtle borders
            cardTheme: CardTheme(
              color: const Color(0xFF000000),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF333333), width: 1),
              ),
              margin: const EdgeInsets.only(top: 15),
            ),

            // Input decoration
            inputTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF111111),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF333333),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF333333),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF4444),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF4444),
                  width: 2,
                ),
              ),
              labelStyle: const TextStyle(color: Colors.white54, fontSize: 16),
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
              errorStyle: const TextStyle(
                color: Color(0xFFFF4444),
                fontSize: 12,
              ),
              prefixStyle: const TextStyle(color: Colors.white),
              suffixStyle: const TextStyle(color: Colors.white),
            ),

            // Button theme - Minimalist black design
            buttonTheme: LoginButtonTheme(
              splashColor: Colors.white.withOpacity(0.1),
              backgroundColor: Colors.white,
              highlightColor: const Color(0xFFE0E0E0),
              elevation: 0,
              highlightElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Page color scheme - Pure black
            pageColorLight: const Color(0xFF000000),
            pageColorDark: const Color(0xFF000000),

            // Before/After animation colors
            beforeHeroFontSize: 50,
            afterHeroFontSize: 20,
          ),
          userValidator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your email or username';
            }
            // Basic email validation
            if (value.contains('@') &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          passwordValidator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 5) {
              return 'Password must be at least 5 characters';
            }
            return null;
          },
          additionalSignupFields: [
            UserFormField(
              keyName: 'Username',
              displayName: 'Username',
              fieldValidator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a username';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),
            UserFormField(
              keyName: 'Name',
              displayName: 'Full Name',
              fieldValidator: (value) {
                final name = value ?? '';
                if (name.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            UserFormField(
              keyName: 'Phone',
              displayName: 'Phone Number (Optional)',
              fieldValidator: (value) {
                // Phone is optional, so return null if empty
                if (value == null || value.isEmpty) {
                  return null;
                }
                // Basic phone validation if provided
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
          ],
          scrollable: true,
          hideProvidersTitle: false,
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
            );
          },
        ),
      ),
    );
  }
}
