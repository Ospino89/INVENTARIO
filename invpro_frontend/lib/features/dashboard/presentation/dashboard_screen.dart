import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../movements/presentation/movements_screen.dart';
import '../../inventory/presentation/inventory_screen.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  
  final apiClient = ApiClient();
  final response = await apiClient.dio.get(
    '/dashboard/',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
  return response.data;
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

  return Scaffold(
  appBar: AppBar(
    title: const Text('InvPro - Dashboard'),
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
  ),
  drawer: Drawer(
    child: ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.indigo),
          child: Text('InvPro', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Movimientos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MovementsScreen()),
                );
              },
            ),
        ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Inventario'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryScreen()),
                );
              },
            ),   
      ],
    ),
  ),
body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error al cargar datos: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dashboardProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(dashboardProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del inventario',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MetricCard(
                      title: 'Total productos',
                      value: '${data['total_productos']}',
                      icon: Icons.inventory_2,
                      color: Colors.indigo,
                    ),
                    _MetricCard(
                      title: 'Bajo stock mínimo',
                      value: '${data['productos_bajo_minimo']}',
                      icon: Icons.warning_amber,
                      color: Colors.orange,
                    ),
                    _MetricCard(
                      title: 'Entradas hoy',
                      value: '${data['total_entradas_hoy']}',
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                    ),
                    _MetricCard(
                      title: 'Salidas hoy',
                      value: '${data['total_salidas_hoy']}',
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
