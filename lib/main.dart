import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Importaciones de tus archivos (Asegúrate de que los nombres coincidan)
import 'views/splash_screen.dart';
import 'views/login_view.dart';
import 'views/home_view.dart'; // <--- Nueva importación
import 'viewmodels/splash_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/voting_viewmodel.dart'; // <--- Nuevo ViewModel

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(
          create: (_) => VotingViewModel(),
        ), // Centralizamos el ViewModel aquí
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voto Continental',
        theme: ThemeData(
          primaryColor: const Color(0xFFE20613), // Rojo Continental
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(), // <--- RUTA REGISTRADA
        },
      ),
    );
  }
}
