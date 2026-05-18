import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_service.dart';
import '../../../core/network/api_client.dart';

final inventoryServiceProvider = Provider(
  (ref) => InventoryService(ApiClient()),
);

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
      appBar: AppBar(
        title: const Text('Inventario'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context, ref),
        child: const Icon(Icons.add),
      ),
      body: productosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (productos) => productos.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay productos registrados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(productosProvider),
                child: ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final p = productos[index];
                    final bajominimo = p['stock_actual'] < p['stock_minimo'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: bajominimo
                            ? Colors.orange
                            : Colors.indigo,
                        child: Text(
                          p['sku'].toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(p['nombre']),
                      subtitle: Text(
                        'SKU: ${p['sku']} · Categoría: ${p['categoria_nombre']}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${p['stock_actual']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: bajominimo ? Colors.orange : Colors.indigo,
                            ),
                          ),
                          Text(
                            'stock',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
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
            final categoriasAsync = ref.watch(categoriasProvider);
            return categoriasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error cargando categorías: $e'),
              data: (categorias) => StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nuevo Producto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock inicial',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: stockMinimoController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock mínimo',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
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
                              .crearProducto({
                                'sku': skuController.text,
                                'nombre': nombreController.text,
                                'descripcion': descripcionController.text,
                                'stock_actual':
                                    int.tryParse(stockController.text) ?? 0,
                                'stock_minimo':
                                    int.tryParse(stockMinimoController.text) ??
                                    0,
                                'categoria': categoriaSeleccionada,
                                'activo': true,
                              });
                          if (context.mounted) Navigator.pop(context);
                          ref.invalidate(productosProvider);
                        },
                        child: const Text('Guardar producto'),
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
