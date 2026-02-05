import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
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
      final UserModel? user = await _authRepository.signInWithGoogle();

      if (user != null) {
        if (user.isWithinRange) {
          _user = user;
          _isLoading = false;
          notifyListeners();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          _error = "Debes estar físicamente en el campus para votar.";
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _authRepository.signOut();
    _user = null;
    notifyListeners();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
