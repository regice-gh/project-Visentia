import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8000';
  
  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final _storage = const FlutterSecureStorage();

  Future<void> register(String username, String password) async {
    try {
      await _dio.post('/register', data: {
        'username': username,
        'password': password,
      });
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['access_token'];
      
      await _storage.write(key: 'auth_token', value: token);
      return true; 
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}