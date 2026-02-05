import 'package:flutter/material.dart';
import '../repositories/voting_repository.dart';
import '../models/candidate_model.dart';

class VotingViewModel extends ChangeNotifier {
  final VotingRepository _votingRepository = VotingRepository();

  List<Candidate> get candidates => _votingRepository.candidates;

  bool _hasVoted = false;
  bool get hasVoted => _hasVoted;

  VotingViewModel() {
    _checkIfUserHasVoted();
  }

  Future<void> _checkIfUserHasVoted() async {
    _hasVoted = await _votingRepository.hasUserVoted();
    notifyListeners();
  }

  Future<bool> castVote(String candidateId) async {
    try {
      final success = await _votingRepository.castVote(candidateId);
      if (success) {
        _hasVoted = true;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error al registrar voto: $e');
      return false;
    }
  }

  Future<Map<String, int>> getResults() async {
    try {
      return await _votingRepository.getResults();
    } catch (e) {
      print('Error al obtener resultados: $e');
      return {};
    }
  }

  Future<bool> clearVotes() async {
    try {
      final success = await _votingRepository.clearVotes();
      if (success) {
        _hasVoted = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error al limpiar votos: $e');
      return false;
    }
  }
}
