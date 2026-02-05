import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoginViewModel>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(84, 9, 145, 1),
              Color.fromRGBO(60, 5, 105, 1),
            ], // Degradado morado
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              SvgPicture.asset(
                'assets/logo/logoConti.svg',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "Bienvenido Estudiante",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Ingeniería de Sistemas e Informática",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 50),

              if (vm.isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CustomGoogleLogo(),
                  ),
                  label: const Text("Ingresar con Gmail"),
                  onPressed: () => vm.signInWithGoogle(context),
                ),

              if (vm.error != null) ...[
                const SizedBox(height: 20),
                Text(
                  vm.error!,
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Google logo widget using Google brand colors
class CustomGoogleLogo extends StatelessWidget {
  const CustomGoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // G
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'G',
              style: TextStyle(
                color: const Color(0xFF4285F4),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
