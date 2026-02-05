import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/location_service.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService();

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        if (googleUser.email.endsWith('@continental.edu.pe')) {
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
            final UserModel user = UserModel(email: googleUser.email);

            final bool isInUniversity = await _locationService
                .isUserInUniversity();

            return user.copyWith(isWithinRange: isInUniversity);
          }
        } else {
          await _googleSignIn.disconnect();
          throw Exception(
            "Debes usar tu correo institucional @continental.edu.pe",
          );
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
