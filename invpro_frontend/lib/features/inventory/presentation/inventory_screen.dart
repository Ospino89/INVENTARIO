import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sidebar.dart';
import 'package:image_picker/image_picker.dart';

final inventoryServiceProvider = Provider((ref) => InventoryService(ApiClient()));

final productosProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(inventoryServiceProvider).getProductos();
});

final categoriasProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(inventoryServiceProvider).getCategorias();
});

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        children: [
          const AppSidebar(selectedIndex: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: AppTheme.bgPrimary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Inventario',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary)),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(context, ref),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Nuevo producto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: productosAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.accent)),
                    error: (e, _) => Center(
                        child: Text('Error: $e',
                            style: const TextStyle(
                                color: AppTheme.textSecondary))),
                    data: (productos) => productos.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64, color: AppTheme.textHint),
                                SizedBox(height: 16),
                                Text('No hay productos registrados',
                                    style: TextStyle(
                                        color: AppTheme.textMuted)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async =>
                                ref.refresh(productosProvider),
                            color: AppTheme.accent,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgCard,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppTheme.borderColor,
                                          width: 0.5),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                flex: 3,
                                                child: Text('Producto',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: AppTheme.textHint)),
                                              ),
                                              const Expanded(
                                                flex: 2,
                                                child: Text('SKU',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: AppTheme.textHint)),
                                              ),
                                              const Expanded(
                                                flex: 2,
                                                child: Text('Categoría',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: AppTheme.textHint)),
                                              ),
                                              const Expanded(
                                                flex: 1,
                                                child: Text('Stock',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: AppTheme.textHint)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(
                                            color: AppTheme.borderColor,
                                            height: 0.5,
                                            thickness: 0.5),
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: productos.length,
                                          separatorBuilder: (context, index) =>
                                              const Divider(
                                                  color: AppTheme.bgCardDeep,
                                                  height: 0.5,
                                                  thickness: 0.5),
                                          itemBuilder: (context, index) {
                                            final p = productos[index];
                                            final bajoMinimo =
                                                p['stock_actual'] < 
                                                    p['stock_minimo'];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 32,
                                                          height: 32,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppTheme
                                                                .accent
                                                                .withValues(
                                                                    alpha:
                                                                        0.15),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              p['sku']
                                                                  .toString()
                                                                  .substring(
                                                                      0, 1)
                                                                  .toUpperCase(),
                                                              style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: AppTheme
                                                                      .accent),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Expanded(
                                                          child: Text(
                                                              p['nombre'],
                                                              style: const TextStyle(
                                                                  fontSize: 13,
                                                                  color: AppTheme
                                                                      .textPrimary)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                        p['sku'],
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme
                                                                .textHint)),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                        p['categoria_nombre'],
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme
                                                                .textSecondary)),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 10,
                                                            vertical: 3),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: bajoMinimo
                                                              ? AppTheme
                                                                  .warningBg
                                                              : AppTheme
                                                                  .successBg,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Text(
                                                          '${p['stock_actual']}',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: bajoMinimo
                                                                  ? AppTheme
                                                                      .warning
                                                                  : AppTheme
                                                                      .success),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
    final skuController = TextEditingController();
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final stockController = TextEditingController();
    final stockMinimoController = TextEditingController();
    int? categoriaSeleccionada;
    XFile? imagenSeleccionada;

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
            final categoriasAsync = ref.watch(categoriasProvider);
            return categoriasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (categorias) => StatefulBuilder(
                builder: (context, setState) => SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nuevo producto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Selector de imagen
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setState(() => imagenSeleccionada = image);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.bgCardDeep,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.borderColor,
                              width: 0.5,
                            ),
                          ),
                          child: imagenSeleccionada != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imagenSeleccionada!.path,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 32,
                                      color: AppTheme.textHint,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Toca para agregar imagen',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DarkField(controller: skuController, label: 'SKU'),
                      const SizedBox(height: 10),
                      _DarkField(controller: nombreController, label: 'Nombre'),
                      const SizedBox(height: 10),
                      _DarkField(
                        controller: descripcionController,
                        label: 'Descripción',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DarkField(
                              controller: stockController,
                              label: 'Stock inicial',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DarkField(
                              controller: stockMinimoController,
                              label: 'Stock mínimo',
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        dropdownColor: AppTheme.bgCard,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          labelStyle: const TextStyle(
                            color: AppTheme.textMuted,
                          ),
                          filled: true,
                          fillColor: AppTheme.bgCardDeep,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                        initialValue: categoriaSeleccionada,
                        items: categorias
                            .map<DropdownMenuItem<int>>(
                              (c) => DropdownMenuItem(
                                value: c['id'],
                                child: Text(c['nombre']),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => categoriaSeleccionada = v),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (categoriaSeleccionada == null) return;
                            await ref
                                .read(inventoryServiceProvider)
                                .crearProductoConImagen({
                                  'sku': skuController.text,
                                  'nombre': nombreController.text,
                                  'descripcion': descripcionController.text,
                                  'stock_actual':
                                      int.tryParse(stockController.text) ?? 0,
                                  'stock_minimo':
                                      int.tryParse(
                                        stockMinimoController.text,
                                      ) ??
                                      0,
                                  'categoria': categoriaSeleccionada,
                                  'activo': true,
                                }, imagenSeleccionada?.path);
                            if (context.mounted) Navigator.pop(context);
                            ref.invalidate(productosProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Guardar producto'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumber;

  const _DarkField({
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
          borderSide:
              const BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppTheme.borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1),
        ),
      ),
    );
  }
}