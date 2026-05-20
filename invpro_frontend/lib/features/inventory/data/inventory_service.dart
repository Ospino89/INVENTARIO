import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

class InventoryService {
  final ApiClient _apiClient;
  static const _storage = FlutterSecureStorage();

  InventoryService(this._apiClient);

  Future<Options> _authOptions() async {
    final token = await _storage.read(key: 'access_token');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<dynamic>> getCategorias() async {
    final response = await _apiClient.dio.get(
      '/categorias/',
      options: await _authOptions(),
    );
    return response.data['results'] ?? response.data;
  }

  Future<List<dynamic>> getProductos() async {
    final response = await _apiClient.dio.get(
      '/productos/',
      options: await _authOptions(),
    );
    return response.data['results'] ?? response.data;
  }

  Future<void> crearProducto(Map<String, dynamic> data) async {
    await _apiClient.dio.post(
      '/productos/',
      data: data,
      options: await _authOptions(),
    );
  }

  Future<void> crearCategoria(String nombre) async {
    await _apiClient.dio.post(
      '/categorias/',
      data: {'nombre': nombre, 'activo': true},
      options: await _authOptions(),
    );
  }


  Future<void> crearProductoConImagen(
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    final token = await _storage.read(key: 'access_token');

    final formData = FormData.fromMap({
      'sku': data['sku'],
      'nombre': data['nombre'],
      'descripcion': data['descripcion'],
      'stock_actual': data['stock_actual'],
      'stock_minimo': data['stock_minimo'],
      'categoria': data['categoria'],
      'activo': data['activo'],
      if (imagePath != null) 'imagen': await MultipartFile.fromFile(imagePath),
    });

    await _apiClient.dio.post(
      '/productos/',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
