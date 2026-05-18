import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  static const _storage = FlutterSecureStorage();

  AuthService(this._apiClient);

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login/',
        data: {'username': username, 'password': password},
      );

      await _storage.write(key: 'access_token', value: response.data['access']);
      await _storage.write(
        key: 'refresh_token',
        value: response.data['refresh'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
