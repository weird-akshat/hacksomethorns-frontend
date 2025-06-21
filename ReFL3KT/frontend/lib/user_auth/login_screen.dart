import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/time_tracking/home.dart';
import 'package:provider/provider.dart';
import 'api_service_auth.dart';

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
      final result = await _authService.signIn(data.name, data.password);

      if (result != null) {
        // Store in provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(
          userId: result['userId'] ?? '',
          username: result['username'] ?? data.name,
          token: result['token'],
        );
        debugPrint("Login successful. User ID: ${userProvider.userId}");
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
      final phoneNumber = additionalData?['Phone'] ?? '';

      // Split full name into first and last name
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await _authService.registerUser(
        data.name!, // email/username
        data.password!,
        firstName,
        lastName,
        phoneNumber,
      );

      if (result != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(
          userId: result['userId'] ?? '',
          username: result['username'] ?? data.name,
          token: result['token'],
        );
        debugPrint("Registration successful. User ID: ${userProvider.userId}");
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
    return Future.delayed(const Duration(milliseconds: 2250)).then((_) {
      return "Password recovery is not yet implemented";
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn && mounted) {
      // Restore user info from storage and update provider
      final userData = await _authService.getUserFromStorage();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(
        userId: userData['userId'] ?? '',
        username: userData['username'] ?? '',
        token: userData['token'] ?? '',
      );
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
            primaryColor: const Color(0xFF000000),
            accentColor: const Color(0xFF1A1A1A),
            errorColor: const Color(0xFFFF4444),
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 42,
              letterSpacing: 6.0,
            ),
            bodyStyle: const TextStyle(color: Colors.white70, fontSize: 16),
            textFieldStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            buttonStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
            cardTheme: CardTheme(
              color: const Color(0xFF000000),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF333333), width: 1),
              ),
              margin: const EdgeInsets.only(top: 15),
            ),
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
            pageColorLight: const Color(0xFF000000),
            pageColorDark: const Color(0xFF000000),
            beforeHeroFontSize: 50,
            afterHeroFontSize: 20,
          ),
          userValidator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your email or username';
            }
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
                if (value == null || value.isEmpty) {
                  return null;
                }
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
