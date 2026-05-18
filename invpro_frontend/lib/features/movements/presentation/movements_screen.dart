import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/movements_service.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../../core/network/api_client.dart';
import 'dart:convert';

final movementsServiceProvider = Provider(
  (ref) => MovementsService(ApiClient()),
);

final movimientosProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(movementsServiceProvider).getMovimientos();
});

class MovementsScreen extends ConsumerWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimientosAsync = ref.watch(movimientosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context, ref),
        child: const Icon(Icons.add),
      ),
      body: movimientosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (movimientos) => movimientos.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swap_horiz, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay movimientos registrados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(movimientosProvider),
                child: ListView.builder(
                  itemCount: movimientos.length,
                  itemBuilder: (context, index) {
                    final m = movimientos[index];
                    final esEntrada = m['tipo'] == 'ENTRADA';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: esEntrada ? Colors.green : Colors.red,
                        child: Icon(
                          esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(m['producto_nombre']),
                      subtitle: Text(
                        'Por: ${m['autor_username']} · ${m['creado_en'].toString().substring(0, 10)}',
                      ),
                      trailing: Text(
                        '${esEntrada ? '+' : '-'}${m['cantidad']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: esEntrada ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, WidgetRef ref) {
    final cantidadController = TextEditingController();
    final notasController = TextEditingController();
    int? productoSeleccionado;
    String tipoSeleccionado = 'ENTRADA';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final productosAsync = ref.watch(productosProvider);
            return productosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (productos) => StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Registrar Movimiento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: tipoSeleccionado,
                      items: const [
                        DropdownMenuItem(
                          value: 'ENTRADA',
                          child: Text('Entrada'),
                        ),
                        DropdownMenuItem(
                          value: 'SALIDA',
                          child: Text('Salida'),
                        ),
                      ],
                      onChanged: (v) => setState(() => tipoSeleccionado = v!),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Producto',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: productoSeleccionado,
                      items: productos
                          .map<DropdownMenuItem<int>>(
                            (p) => DropdownMenuItem(
                              value: p['id'],
                              child: Text(p['nombre']),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => productoSeleccionado = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notasController,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (productoSeleccionado == null) return;
                          final cantidad = int.tryParse(
                            cantidadController.text,
                          );
                          if (cantidad == null || cantidad <= 0) return;

                          try {
                            const storage = FlutterSecureStorage();
                            final token = await storage.read(
                              key: 'access_token',
                            );
                            final parts = token!.split('.');
                            final payload = parts[1];
                            final normalized = base64Url.normalize(payload);
                            final decoded = utf8.decode(
                              base64Url.decode(normalized),
                            );
                            final map = jsonDecode(decoded);
                            final autorId = map['user_id'].toString();

                            await ref
                                .read(movementsServiceProvider)
                                .registrarMovimiento(
                                  productoId: productoSeleccionado!,
                                  tipo: tipoSeleccionado,
                                  cantidad: cantidad,
                                  autorId: autorId,
                                  notas: notasController.text,
                                );
                            if (context.mounted) Navigator.pop(context);
                            ref.invalidate(movimientosProvider);
                          } catch (e) {
                            if (context.mounted) {
                              String mensaje = 'Error al registrar movimiento';
                              if (e is DioException &&
                                  e.response?.data != null) {
                                mensaje = e.response!.data.toString();
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(mensaje),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Registrar'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
