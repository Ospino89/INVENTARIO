import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/movements/presentation/movements_screen.dart';
import '../theme/app_theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback? onLogout;
  const AppSidebar({super.key, required this.selectedIndex, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: AppTheme.bgSidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'InvPro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _NavLabel('GENERAL'),
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () => _navigate(context, 0),
          ),
          _NavItem(
            icon: Icons.swap_horiz,
            label: 'Movimientos',
            selected: selectedIndex == 1,
            badge: '3',
            onTap: () => _navigate(context, 1),
          ),
          const SizedBox(height: 8),
          _NavLabel('HERRAMIENTAS'),
          _NavItem(
            icon: Icons.inventory_outlined,
            label: 'Inventario',
            selected: selectedIndex == 2,
            onTap: () => _navigate(context, 2),
          ),
          const Spacer(),
          const Divider(color: AppTheme.bgCard, thickness: 0.5),
          _NavItem(
            icon: Icons.logout,
            label: 'Cerrar sesión',
            selected: false,
            onTap: () async {
              const storage = FlutterSecureStorage();
              await storage.deleteAll();
              if (context.mounted) {
                onLogout?.call();
              }
            },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;
    Widget screen;
    switch (index) {
      case 0:
        screen = const DashboardScreen();
        break;
      case 1:
        screen = const MovementsScreen();
        break;
      case 2:
        screen = const InventoryScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => screen,
        transitionDuration: Duration.zero,
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  final String text;
  const _NavLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.textHint,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.bgCard : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppTheme.textPrimary : AppTheme.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? AppTheme.textPrimary : AppTheme.textMuted,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

