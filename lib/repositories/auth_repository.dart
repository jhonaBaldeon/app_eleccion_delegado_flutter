import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/location_service.dart';

// Repositorio para autenticación con Google y Firebase
class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService();

  // Método para iniciar sesión con Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Mostrar ventana de selección de cuenta Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // Verificar que use correo institucional
        if (googleUser.email.endsWith('@continental.edu.pe')) {
          // Obtener credenciales de autenticación
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          // Iniciar sesión en Firebase con credenciales Google
          final UserCredential userCredential = await _auth
              .signInWithCredential(credential);
          final User? firebaseUser = userCredential.user;

          if (firebaseUser != null) {
            // Crear modelo de usuario con datos de Google
            final UserModel user = UserModel(
              email: googleUser.email,
              name: googleUser.displayName,
              photoUrl: googleUser.photoUrl ?? firebaseUser.photoURL,
            );

            // Verificar ubicación del usuario
            final bool isInUniversity = await _locationService
                .isUserInUniversity();

            return user.copyWith(isWithinRange: isInUniversity);
          }
        } else {
          // Cerrar sesión Google si no es correo institucional
          await _googleSignIn.disconnect();
          throw Exception(
            'Debes usar tu correo institucional @continental.edu.pe',
          );
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Método para cerrar sesión en Google y Firebase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Obtener usuario actual de Firebase
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
