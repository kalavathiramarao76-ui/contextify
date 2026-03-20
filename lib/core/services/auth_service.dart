import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

/// Handles all authentication API calls and token storage.
class AuthService {
  static const String _baseUrl = 'https://contextify-backend.vercel.app';
  static const String _tokenKey = 'ctx_auth_token';

  /// Retrieve the stored auth token.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Persist the auth token.
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Remove the auth token.
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Build headers including Authorization if a token is available.
  Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Create a new account.
  Future<AppUser> signup(String email, String password, String fullName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException(
        body['message'] as String? ?? 'Signup failed. Please try again.',
      );
    }

    if (body['ok'] != true) {
      throw AuthException(
        body['message'] as String? ?? 'Signup failed. Please try again.',
      );
    }

    final token = body['token'] as String;
    await _saveToken(token);

    return AppUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  /// Log in with existing credentials.
  Future<AppUser> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw AuthException(
        body['message'] as String? ?? 'Login failed. Please try again.',
      );
    }

    if (body['ok'] != true) {
      throw AuthException(
        body['message'] as String? ?? 'Login failed. Please try again.',
      );
    }

    final token = body['token'] as String;
    await _saveToken(token);

    return AppUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  /// Fetch the current authenticated user. Returns null if not authenticated.
  Future<AppUser?> getMe() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/me'),
        headers: await _headers(),
      );

      if (response.statusCode != 200) {
        await _removeToken();
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final userData = body['user'] as Map<String, dynamic>?;
      if (userData == null) {
        await _removeToken();
        return null;
      }

      return AppUser.fromJson(userData);
    } catch (_) {
      // Network error — don't remove token, user may be offline
      return null;
    }
  }

  /// Log out and clear the stored token.
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/auth/logout'),
        headers: await _headers(),
      );
    } catch (_) {
      // Ignore network errors on logout
    }
    await _removeToken();
  }
}

/// Custom exception for authentication errors.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
