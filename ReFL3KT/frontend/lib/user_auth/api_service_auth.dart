import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthApiService {
  final String? baseURL = dotenv.env['auth_url'];
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> registerUser(
    String emailid,
    String password,
    String first_name,
    String last_name,
    String phone_number,
  ) async {
    final url = Uri.parse('$baseURL/api/auth/register/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": emailid,
          "first_name": first_name,
          "last_name": last_name,
          "phone_number": phone_number,
          "password": password,
          "password_confirm": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        await storage.write(key: 'jwt_token', value: token);
        return token;
      } else {
        print('Registration failed [${response.statusCode}]: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'jwt_token');
    return token != null;
  }

  Future<String?> signIn(String emailID, String password) async {
    final url = Uri.parse('$baseURL/api/auth/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"username": emailID, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        await storage.write(key: 'jwt_token', value: token);
        return token;
      } else {
        print('Sign In failed, ${response.statusCode}  and ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await storage.delete(key: 'jwt_token');
  }
}
