import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lógica para inicializar la app
  Future<void> initializeApp(BuildContext context) async {
    // Verificar si el usuario ya está logueado
    User? currentUser = _auth.currentUser;

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
