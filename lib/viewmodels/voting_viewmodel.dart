import 'package:flutter/material.dart';
import '../repositories/voting_repository.dart';
import '../models/candidate_model.dart';

// ViewModel para gestión de votos y candidatos
class VotingViewModel extends ChangeNotifier {
  final VotingRepository _votingRepository = VotingRepository();
  String? _userId;
  String? _userEmail;

  // Email del administrador
  static const String _adminEmail = '46747313@continental.edu.pe';

  // Lista de candidatos disponibles
  List<Candidate> get candidates => _votingRepository.candidates;

  // Estado: usuario ya votó
  bool _hasVoted = false;
  bool get hasVoted => _hasVoted;

  // Estado: mostrar opciones de administrador
  bool _showAdminOptions = false;
  bool get showAdminOptions => _showAdminOptions;

  // Verificar si el usuario actual es administrador
  bool get isAdmin => _userEmail == _adminEmail;

  // Mensaje de error para mostrar al usuario
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Constructor vacío - la información del usuario se establece después
  VotingViewModel();

  // Toggle para mostrar/ocultar opciones de administrador
  void toggleAdminOptions() {
    _showAdminOptions = !_showAdminOptions;
    notifyListeners();
  }

  // Método para establecer información del usuario después del login
  void setUserInfo({required String userId, String? userEmail}) {
    _userId = userId;
    _userEmail = userEmail;
    _checkIfUserHasVoted();
  }

  // Verificar si el usuario ya votó en FastAPI
  Future<void> _checkIfUserHasVoted() async {
    if (_userId == null) return;
    _hasVoted = await _votingRepository.hasUserVoted(_userId!);
    notifyListeners();
  }

  // Emitir voto por un candidato
  Future<bool> castVote(String candidateId) async {
    _errorMessage = null;
    
    if (_userId == null || _userEmail == null) {
      _errorMessage = 'Error: No se ha proporcionado información del usuario';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }

    try {
      final success = await _votingRepository.castVote(
        candidateId,
        _userEmail!,
        _userId!,
      );
      if (success) {
        _hasVoted = true;
        _errorMessage = null;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Error al registrar voto: $_errorMessage');
      notifyListeners();
      return false;
    }
  }

  // Obtener resultados de votación
  Future<Map<String, int>> getResults() async {
    try {
      return await _votingRepository.getResults();
    } catch (e) {
      debugPrint('Error al obtener resultados: $e');
      return {};
    }
  }

  // Limpiar todos los votos (para administradores)
  Future<bool> clearVotes() async {
    try {
      final success = await _votingRepository.clearVotes();
      if (success) {
        _hasVoted = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error al limpiar votos: $e');
      return false;
    }
  }
}
