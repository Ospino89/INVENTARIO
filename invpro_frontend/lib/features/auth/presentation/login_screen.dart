import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../data/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService(ApiClient()));

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _regUsernameController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showRegister = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final success = await authService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      widget.onLoginSuccess();
    } else {
      setState(
        () => _errorMessage = 'Credenciales incorrectas. Intenta de nuevo.',
      );
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await Dio().post(
        'http://127.0.0.1:8000/api/v1/auth/register/',
        data: {
          'username': _regUsernameController.text.trim(),
          'password': _regPasswordController.text.trim(),
          'email': _emailController.text.trim(),
        },
      );
      setState(() {
        _successMessage = 'Usuario creado. Inicia sesión.';
        _showRegister = false;
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data['error'] ?? 'Error al registrar usuario.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'InvPro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'Unipamplona',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 28),
              if (!_showRegister) ...[
                _buildLoginForm(),
              ] else ...[
                _buildRegisterForm(),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: AppTheme.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_showRegister ? _handleRegister : _handleLogin),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_showRegister ? 'Crear cuenta' : 'Iniciar sesión'),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() {
                  _showRegister = !_showRegister;
                  _errorMessage = null;
                  _successMessage = null;
                }),
                child: Text(
                  _showRegister
                      ? '¿Ya tienes cuenta? Inicia sesión'
                      : '¿No tienes cuenta? Regístrate',
                  style: const TextStyle(fontSize: 12, color: AppTheme.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _DarkField(
          controller: _usernameController,
          label: 'Usuario',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _DarkField(
          controller: _passwordController,
          label: 'Contraseña',
          icon: Icons.lock_outline,
          obscure: true,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _DarkField(
          controller: _regUsernameController,
          label: 'Usuario',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _DarkField(
          controller: _emailController,
          label: 'Correo electrónico',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 12),
        _DarkField(
          controller: _regPasswordController,
          label: 'Contraseña',
          icon: Icons.lock_outline,
          obscure: true,
        ),
      ],
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  const _DarkField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, size: 16, color: AppTheme.textHint),
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
