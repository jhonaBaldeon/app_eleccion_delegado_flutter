import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // Lógica para inicializar la app
  Future<void> initializeApp(BuildContext context) async {
    // Verificar si el usuario ya está logueado
    final currentUser = _authRepository.getCurrentUser();

    // Simulamos una carga de datos o validación de 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      if (currentUser != null &&
          currentUser.email?.endsWith('@continental.edu.pe') == true) {
        // Usuario ya logueado con correo institucional, ir directamente a home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // No hay usuario logueado, ir a login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
