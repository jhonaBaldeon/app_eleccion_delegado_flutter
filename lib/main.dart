import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

// Importaciones de tus archivos (Asegúrate de que los nombres coincidan)
import 'views/splash_screen.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/results_view.dart'; // Pantalla de resultados
import 'views/success_view.dart'; // Pantalla de éxito
import 'viewmodels/splash_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/voting_viewmodel.dart';

// Firebase configuration for web
const FirebaseOptions webFirebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyDKRlyjnvMEKVn0EHKfJv67FpPK6g0neG4",
  authDomain: "votocontinental.firebaseapp.com",
  projectId: "votocontinental",
  storageBucket: "votocontinental.firebasestorage.app",
  messagingSenderId: "507643463642",
  appId: "1:507643463642:web:1cde76a68abe4831a0e2e3",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: webFirebaseOptions);
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
          primaryColor: const Color.fromRGBO(84, 9, 145, 1),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/results': (context) =>
              const ResultsScreen(), // Ruta para resultados
          '/success': (context) => const SuccessScreen(), // Ruta para éxito
        },
      ),
    );
  }
}
