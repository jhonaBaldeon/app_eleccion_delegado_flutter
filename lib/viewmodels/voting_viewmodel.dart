import 'package:flutter/material.dart';
import '../repositories/voting_repository.dart';
import '../models/candidate_model.dart';

// ViewModel para gestión de votos y candidatos
class VotingViewModel extends ChangeNotifier {
  final VotingRepository _votingRepository = VotingRepository();

  // Lista de candidatos disponibles
  List<Candidate> get candidates => _votingRepository.candidates;

  // Estado: usuario ya votó
  bool _hasVoted = false;
  bool get hasVoted => _hasVoted;

  // Constructor: verificar si usuario ya votó al iniciar
  VotingViewModel() {
    _checkIfUserHasVoted();
  }

  // Verificar si el usuario ya votó en Firestore
  Future<void> _checkIfUserHasVoted() async {
    _hasVoted = await _votingRepository.hasUserVoted();
    notifyListeners();
  }

  // Emitir voto por un candidato
  Future<bool> castVote(String candidateId) async {
    try {
      final success = await _votingRepository.castVote(candidateId);
      if (success) {
        _hasVoted = true;
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error al registrar voto: $e');
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
