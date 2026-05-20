import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: InvProApp()));
}

class InvProApp extends StatelessWidget {
  const InvProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService(ApiClient());
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authenticated = await _authService.isAuthenticated();
    setState(() {
      _isAuthenticated = authenticated;
      _isLoading = false;
    });
  }

  void _onLogin() {
    setState(() => _isAuthenticated = true);
  }

  void _onLogout() {
    setState(() => _isAuthenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1729),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4F6EF7)),
        ),
      );
    }

    if (_isAuthenticated) {
      return DashboardScreen(onLogout: _onLogout);
    }

    return LoginScreen(onLoginSuccess: _onLogin);
  }
}
