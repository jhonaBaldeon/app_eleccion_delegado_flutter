import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/candidate_model.dart';

class VotingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Candidate> _candidates = [
    Candidate(
      id: '1',
      name: 'Maria Garcia',
      description: '8vo Ciclo - Innovación Tecnológica',
      imageUrl: 'assets/candidatos/candidate1.png',
    ),
    Candidate(
      id: '2',
      name: 'Juan Perez',
      description: '7mo Ciclo - Liderazgo Estudiantil',
      imageUrl: 'assets/candidatos/candidate2.png',
    ),
    Candidate(
      id: '3',
      name: 'Ana Rodriguez',
      description: '9vo Ciclo - Desarrollo de Software',
      imageUrl: 'assets/candidatos/candidate3.png',
    ),
    Candidate(
      id: '4',
      name: 'Luis Martinez',
      description: '6mo Ciclo - Seguridad Informática',
      imageUrl: 'assets/candidatos/candidate4.png',
    ),
  ];

  List<Candidate> get candidates => _candidates;

  Future<bool> hasUserVoted() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final doc = await _firestore.collection('votes').doc(userId).get();
      return doc.exists;
    }
    return false;
  }

  Future<bool> castVote(String candidateId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      final hasVoted = await hasUserVoted();
      if (hasVoted) {
        throw Exception('Usuario ya ha votado');
      }

      await _firestore.collection('votes').doc(user.uid).set({
        'candidateId': candidateId,
        'userEmail': user.email,
        'votedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, int>> getResults() async {
    final Map<String, int> results = {};

    try {
      for (final candidate in _candidates) {
        results[candidate.id] = 0;
      }

      final snapshot = await _firestore.collection('votes').get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final candidateId = data['candidateId'] as String;

        if (results.containsKey(candidateId)) {
          results[candidateId] = results[candidateId]! + 1;
        }
      }

      return results;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> clearVotes() async {
    try {
      final snapshot = await _firestore.collection('votes').get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
