import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/movements_service.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sidebar.dart';

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
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        children: [
          const AppSidebar(selectedIndex: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  color: AppTheme.bgPrimary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Movimientos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(context, ref),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Registrar movimiento'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: movimientosAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Error: $e',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                    data: (movimientos) => movimientos.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.swap_horiz,
                                  size: 64,
                                  color: AppTheme.textHint,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No hay movimientos registrados',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async =>
                                ref.refresh(movimientosProvider),
                            color: AppTheme.accent,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.borderColor,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Tipo',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textHint,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Producto',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textHint,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Autor',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textHint,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Fecha',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textHint,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Cantidad',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textHint,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      color: AppTheme.borderColor,
                                      height: 0.5,
                                      thickness: 0.5,
                                    ),
                                    Expanded(
                                      child: ListView.separated(
                                        itemCount: movimientos.length,
                                        separatorBuilder: (context, index) =>
                                            const Divider(
                                              color: AppTheme.bgCardDeep,
                                              height: 0.5,
                                              thickness: 0.5,
                                            ),
                                        itemBuilder: (context, index) {
                                          final m = movimientos[index];
                                          final esEntrada =
                                              m['tipo'] == 'ENTRADA';
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: esEntrada
                                                          ? AppTheme.successBg
                                                          : AppTheme.dangerBg,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      esEntrada
                                                          ? 'Entrada'
                                                          : 'Salida',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: esEntrada
                                                            ? AppTheme.success
                                                            : AppTheme.danger,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    m['producto_nombre'],
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          AppTheme.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    m['autor_username'],
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textMuted,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    m['creado_en']
                                                        .toString()
                                                        .substring(0, 10),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textHint,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${esEntrada ? '+' : '-'}${m['cantidad']}',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: esEntrada
                                                          ? AppTheme.success
                                                          : AppTheme.danger,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registrar movimiento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DarkDropdown<String>(
                      label: 'Tipo',
                      value: tipoSeleccionado,
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
                    const SizedBox(height: 10),
                    _DarkDropdown<int>(
                      label: 'Producto',
                      value: productoSeleccionado,
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
                    const SizedBox(height: 10),
                    _DarkTextField(
                      controller: cantidadController,
                      label: 'Cantidad',
                      isNumber: true,
                    ),
                    const SizedBox(height: 10),
                    _DarkTextField(
                      controller: notasController,
                      label: 'Notas (opcional)',
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
                                  backgroundColor: AppTheme.danger,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Registrar'),
                      ),
                    ),
                    const SizedBox(height: 20),
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

class _DarkTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumber;

  const _DarkTextField({
    required this.controller,
    required this.label,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppTheme.bgCardDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1),
        ),
      ),
    );
  }
}

class _DarkDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const _DarkDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      dropdownColor: AppTheme.bgCard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppTheme.bgCardDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
      ),
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      initialValue: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
