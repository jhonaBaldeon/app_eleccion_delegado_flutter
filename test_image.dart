import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Google Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final GoogleSignIn googleSignIn = GoogleSignIn();
                  final GoogleSignInAccount? googleUser = await googleSignIn
                      .signIn();

                  if (googleUser != null) {
                    debugPrint('Google user:');
                    debugPrint('  Display name: ${googleUser.displayName}');
                    debugPrint('  Email: ${googleUser.email}');
                    debugPrint('  Photo URL: ${googleUser.photoUrl}');

                    final GoogleSignInAuthentication googleAuth =
                        await googleUser.authentication;
                    final credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );

                    final UserCredential userCredential = await FirebaseAuth
                        .instance
                        .signInWithCredential(credential);
                    final User? firebaseUser = userCredential.user;

                    if (firebaseUser != null) {
                      debugPrint('Firebase user:');
                      debugPrint('  Display name: ${firebaseUser.displayName}');
                      debugPrint('  Email: ${firebaseUser.email}');
                      debugPrint('  Photo URL: ${firebaseUser.photoURL}');

                      // Try to load image
                      if (firebaseUser.photoURL != null) {
                        final photoUrl = firebaseUser.photoURL!;
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('User Image'),
                              content: Image.network(photoUrl),
                            ),
                          );
                        }
                      }
                    }
                  }
                } catch (e) {
                  debugPrint('Error: $e');
                }
              },
              child: const Text('Sign In with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
