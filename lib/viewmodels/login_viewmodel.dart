import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/location_service.dart';
import '../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  UserModel? _user;
  UserModel? get user => _user;

  Future<void> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // VALIDACIÓN CLAVE: El dominio del correo
        if (googleUser.email.endsWith('@continental.edu.pe')) {
          // Autenticar con Firebase usando Google SignIn
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential userCredential = await _auth
              .signInWithCredential(credential);
          final User? firebaseUser = userCredential.user;

          if (firebaseUser != null) {
            // Create UserModel with email
            _user = UserModel(email: googleUser.email);

            // Verificar que el usuario esté físicamente en el campus
            bool isInUniversity = await LocationService().isUserInUniversity();

            if (!isInUniversity) {
              _error = "Debes estar físicamente en el campus para votar.";
              _isLoading = false;
              notifyListeners();
              return;
            }

            // Si es válido y está en la universidad, navegamos a la pantalla de votación
            _isLoading = false;
            notifyListeners();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        } else {
          // Si no es institucional, cerramos sesión y mostramos error
          await _googleSignIn.disconnect();
          _error = "Debes usar tu correo institucional @continental.edu.pe";
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = "Error al conectar con Google: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
