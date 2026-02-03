import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/candidate_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotingViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Candidate> _candidates = [
    Candidate(
      id: "1",
      name: "Maria Garcia",
      description: "8vo Ciclo - Innovación Tecnológica",
      imageUrl: "https://i.pravatar.cc/150?u=1",
    ),
    Candidate(
      id: "2",
      name: "Juan Perez",
      description: "7mo Ciclo - Liderazgo Estudiantil",
      imageUrl: "https://i.pravatar.cc/150?u=2",
    ),
  ];

  List<Candidate> get candidates => _candidates;

  bool _hasVoted = false;
  bool get hasVoted => _hasVoted;

  VotingViewModel() {
    _checkIfUserHasVoted();
  }

  Future<void> _checkIfUserHasVoted() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final doc = await _firestore.collection('votes').doc(userId).get();
      _hasVoted = doc.exists;
      notifyListeners();
    }
  }

  Future<bool> castVote(String candidateId) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('Error: No hay usuario autenticado');
      return false;
    }

    try {
      // Verificar si ya votó
      if (_hasVoted) {
        print('Error: Usuario ya ha votado');
        return false;
      }

      // Guardar el voto en Firestore
      print(
        'Intentando guardar voto para usuario ${user.uid} y candidato $candidateId',
      );
      await _firestore.collection('votes').doc(user.uid).set({
        'candidateId': candidateId,
        'userEmail': user.email,
        'votedAt': FieldValue.serverTimestamp(),
      });
      print('Voto guardado exitosamente');

      _hasVoted = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error al registrar voto: $e');
      return false;
    }
  }

  // Obtener resultados de votación
  Future<Map<String, int>> getResults() async {
    final Map<String, int> results = {};

    try {
      // Inicializar resultados para cada candidato
      for (final candidate in _candidates) {
        results[candidate.id] = 0;
      }

      // Obtener todos los votos
      final snapshot = await _firestore.collection('votes').get();

      // Contar votos por candidato
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final candidateId = data['candidateId'] as String;

        if (results.containsKey(candidateId)) {
          results[candidateId] = results[candidateId]! + 1;
        }
      }

      return results;
    } catch (e) {
      print('Error al obtener resultados: $e');
      return results;
    }
  }

  // Limpiar todos los votos
  Future<bool> clearVotes() async {
    try {
      print('Intentando limpiar todos los votos');

      // Obtener todos los documentos de la colección 'votes'
      final snapshot = await _firestore.collection('votes').get();

      // Eliminar cada documento
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Reiniciar el estado de hasVoted para el usuario actual
      _hasVoted = false;
      notifyListeners();

      print('Votos limpiados exitosamente');
      return true;
    } catch (e) {
      print('Error al limpiar votos: $e');
      return false;
    }
  }
}
