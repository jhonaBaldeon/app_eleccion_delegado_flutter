import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Importación de pantallas
import 'views/splash_screen.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/results_view.dart';
import 'views/success_view.dart';

// Importación de ViewModels para gestión de estado
import 'viewmodels/splash_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/voting_viewmodel.dart';

// Configuración de Firebase para la aplicación web
const FirebaseOptions webFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDKRlyjnvMEKVn0EHKfJv67FpPK6g0neG4',
  authDomain: 'votocontinental.firebaseapp.com',
  projectId: 'votocontinental',
  storageBucket: 'votocontinental.firebasestorage.app',
  messagingSenderId: '507643463642',
  appId: '1:507643463642:web:1cde76a68abe4831a0e2e3',
);

// Punto de entrada de la aplicación
void main() async {
  // Inicialización de bindings y Firebase antes de ejecutar la app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: webFirebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuración de proveedores de estado (MVVM)
    return MultiProvider(
      providers: [
        // ViewModel para pantalla de splash
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        // ViewModel para autenticación y login
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        // ViewModel para gestión de votos y candidatos
        ChangeNotifierProvider(create: (_) => VotingViewModel()),
      ],
      child: MaterialApp(
        title: 'Votación Delegado',
        theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
        // Rutas de navegación de la aplicación
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/results': (_) => const ResultsScreen(),
          '/success': (_) => const SuccessScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
