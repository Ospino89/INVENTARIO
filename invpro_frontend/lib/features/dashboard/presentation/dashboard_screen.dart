import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sidebar.dart';
import '../../../core/network/api_client.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');

  final response = await Dio().get(
    'http://192.168.20.8:8000/api/v1/dashboard/',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  final userInfo = await ApiClient.getUserFromToken();

  return {
    ...response.data,
    'username': userInfo['username'] ?? 'Usuario',
    'role': userInfo['role'] ?? 'Operario',
  };
});

class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onLogout;
  const DashboardScreen({super.key, this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        children: [
          AppSidebar(selectedIndex: 0, onLogout: onLogout),
          Expanded(
            child: dashboardAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.danger,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $e',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(dashboardProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (data) => Column(
                children: [
                  _TopBar(
                    username: data['username'] ?? 'Usuario',
                    role: data['role'] ?? 'OPERARIO',
                  ),
                  Expanded(
                    child: _DashboardBody(data: data, ref: ref),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String username;
  final String role;

  const _TopBar({required this.username, required this.role});

  @override
  Widget build(BuildContext context) {
    final initials = username.isNotEmpty
        ? username.substring(0, 2).toUpperCase()
        : 'US';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppTheme.bgPrimary,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor, width: 0.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 16, color: AppTheme.textHint),
                  SizedBox(width: 8),
                  Text('Buscar productos, movimientos...',
                      style: TextStyle(fontSize: 13, color: AppTheme.textHint)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.notifications_outlined,
              size: 20, color: AppTheme.textMuted),
          const SizedBox(width: 16),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(username,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary)),
              Text(role == 'ADMIN' ? 'Administrador' : 'Operario',
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textHint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final WidgetRef ref;

  const _DashboardBody({required this.data, required this.ref});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(dashboardProvider),
      color: AppTheme.accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Total productos',
                    value: '${data['total_productos']}',
                    sub: 'en inventario',
                    subColor: AppTheme.textHint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.arrow_downward,
                    label: 'Entradas hoy',
                    value: '${data['total_entradas_hoy']}',
                    sub: 'movimientos',
                    subColor: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.warning_amber_outlined,
                    label: 'Bajo stock mínimo',
                    value: '${data['productos_bajo_minimo']}',
                    sub: 'requieren atención',
                    subColor: AppTheme.warning,
                    valueColor: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Expanded(
                  flex: 5,
                  child: _ChartCard(
                    grafica: List<dynamic>.from(data['grafica'] ?? []),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(flex: 3, child: _StatsCard(data: data)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color subColor;
  final Color? valueColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: subColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(sub, style: TextStyle(fontSize: 11, color: subColor)),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<dynamic> grafica;

  const _ChartCard({required this.grafica});

  @override
  Widget build(BuildContext context) {
    if (grafica.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: const Center(
          child: Text(
            'Sin movimientos hoy',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ),
      );
    }

    final maxY =
        grafica
            .map((e) => (e['entradas'] as int) + (e['salidas'] as int))
            .reduce((a, b) => a > b ? a : b)
            .toDouble() +
        1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movimientos de stock',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                backgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                maxY: maxY,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      getTitlesWidget: (val, meta) {
                        final index = val.toInt();
                        if (index < grafica.length) {
                          final hora = grafica[index]['hora'] as int;
                          return Text(
                            '${hora}h',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppTheme.textHint,
                            ),
                          );
                        }
                        
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < grafica.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (grafica[i]['entradas'] as int).toDouble(),
                          color: AppTheme.accent,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: (grafica[i]['salidas'] as int).toDouble(),
                          color: AppTheme.accentPink,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: AppTheme.accent, label: 'Entradas'),
              const SizedBox(width: 16),
              _Legend(color: AppTheme.accentPink, label: 'Salidas'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _StatsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del día',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'Entradas',
            value: '${data['total_entradas_hoy']}',
            color: AppTheme.success,
            bg: AppTheme.successBg,
          ),
          const SizedBox(height: 10),
          _StatRow(
            label: 'Salidas',
            value: '${data['total_salidas_hoy']}',
            color: AppTheme.danger,
            bg: AppTheme.dangerBg,
          ),
          const SizedBox(height: 10),
          _StatRow(
            label: 'Bajo mínimo',
            value: '${data['productos_bajo_minimo']}',
            color: AppTheme.warning,
            bg: AppTheme.warningBg,
          ),
          const SizedBox(height: 10),
          _StatRow(
            label: 'Total productos',
            value: '${data['total_productos']}',
            color: AppTheme.accent,
            bg: AppTheme.bgCardDeep,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
