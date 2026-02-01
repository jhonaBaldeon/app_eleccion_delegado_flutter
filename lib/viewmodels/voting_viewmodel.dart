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
      name: "Juan Pérez",
      description: "8vo Ciclo - Innovación Tecnológica",
      imageUrl: "https://i.pravatar.cc/150?u=1",
    ),
    Candidate(
      id: "2",
      name: "María Garcia",
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
      return false;
    }

    try {
      // Verificar si ya votó
      if (_hasVoted) {
        return false;
      }

      // Guardar el voto en Firestore
      await _firestore.collection('votes').doc(user.uid).set({
        'candidateId': candidateId,
        'userEmail': user.email,
        'votedAt': FieldValue.serverTimestamp(),
      });

      _hasVoted = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
