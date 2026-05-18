import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

class MovementsService {
  final ApiClient _apiClient;
  static const _storage = FlutterSecureStorage();

  MovementsService(this._apiClient);

  Future<Options> _authOptions() async {
    final token = await _storage.read(key: 'access_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<dynamic>> getMovimientos() async {
    final response = await _apiClient.dio.get(
      '/movimientos/',
      options: await _authOptions(),
    );
    return response.data['results'] ?? response.data;
  }

  Future<void> registrarMovimiento({
    required int productoId,
    required String tipo,
    required int cantidad,
    required String autorId,
    String? notas,
  }) async {
    await _apiClient.dio.post(
      '/movimientos/',
      data: {
        'producto': productoId,
        'tipo': tipo,
        'cantidad': cantidad,
        'autor': autorId,
        'notas': notas ?? '',
      },
      options: await _authOptions(),
    );
  }
}
