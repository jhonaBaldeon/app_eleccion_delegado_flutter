import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Importaciones de tus archivos (Asegúrate de que los nombres coincidan)
import 'views/splash_screen.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/results_view.dart'; // Pantalla de resultados
import 'viewmodels/splash_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/voting_viewmodel.dart';

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
        ChangeNotifierProvider(create: (_) => VotingViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Voto Continental',
        theme: ThemeData(
          primaryColor: const Color(0xFFE20613),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/results': (context) =>
              const ResultsScreen(), // Ruta para resultados
        },
      ),
    );
  }
}
