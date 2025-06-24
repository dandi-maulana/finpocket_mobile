import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Sesuaikan dengan URL backend Laravel Anda
  static const String baseUrl = 'https://finpocket.my.id/api';

  // Helper method untuk menambahkan token ke header
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// ============ AUTHENTICATION ============ ///

  /// Register new user
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // Save token after successful registration
        if (data['access_token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['access_token']);
          await prefs.setInt('user_id', data['data']['id']);
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Registration failed',
          'errors': data['errors'] ?? {},
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data after successful login
        if (data['access_token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['access_token']);
          await prefs.setInt('user_id', data['user']['id']);
          await prefs.setString('user_name', data['user']['name']);
          await prefs.setString(
            'user_email',
            data['user']['email'],
          ); // Save email
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Logout user
  static Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        // Clear stored token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user_id');
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {'success': false, 'error': 'Logout failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get current user profile
  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$baseUrl/me');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': 'Failed to get profile'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? password,
  }) async {
    final url = Uri.parse('$baseUrl/profile');
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (password != null) {
        body['password'] = password;
        body['password_confirmation'] = password;
      }

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Update failed',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// ============ CATEGORIES ============ ///

  /// Get all categories
  static Future<Map<String, dynamic>> getCategories() async {
    final url = Uri.parse('$baseUrl/category');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': 'Failed to get categories'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Create new category
  static Future<Map<String, dynamic>> createCategory(
    String name,
    int balance,
  ) async {
    final url = Uri.parse('$baseUrl/category');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({'name_category': name, 'category_balance': balance}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to create category',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// ============ TRANSACTIONS ============ ///

  /// Get all transactions
  static Future<Map<String, dynamic>> getTransactions() async {
    final url = Uri.parse('$baseUrl/transaction');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': 'Failed to get transactions'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Create transaction (deposit or withdraw)
  static Future<Map<String, dynamic>> createTransaction({
    int? withdraw,
    int? deposit,
  }) async {
    final url = Uri.parse('$baseUrl/transaction');
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{};

      if (withdraw != null) body['withdraw'] = withdraw;
      if (deposit != null) body['deposit'] = deposit;

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Transaction failed',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  /// ============ USERS ============ ///

  /// Get all users (admin only)
  static Future<Map<String, dynamic>> getUsers() async {
    final url = Uri.parse('$baseUrl/user');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': 'Failed to get users'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
