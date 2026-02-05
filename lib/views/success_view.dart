import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Pantalla de confirmación de voto exitoso
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo color verde claro
      backgroundColor: const Color.fromRGBO(211, 244, 224, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animación Lottie de éxito
            Lottie.asset(
              'assets/animations/success.json',
              width: 250,
              height: 250,
              repeat: false, // La animación se ejecuta solo una vez
            ),
            const SizedBox(height: 20),
            // Título de confirmación
            const Text(
              '¡Voto Registrado!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(84, 9, 145, 1), // Morado institucional
              ),
            ),
            const SizedBox(height: 10),
            // Mensaje de agradecimiento
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tu participación es importante para la facultad de Ingeniería de Sistemas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            // Botón para volver al inicio
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(84, 9, 145, 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                // Navegar a pantalla principal y limpiar historial de navegación
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              child: const Text(
                'Finalizar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
