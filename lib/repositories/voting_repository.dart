import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/candidate_model.dart';

class VotingRepository {
  // URL base de la API FastAPI - Configuración según plataforma
  // URL del backend - PRODUCCIÓN (Render)
  static const String _baseIp =
      'https://backend-eleccion-delegado.onrender.com/';

  static String get baseUrl {
    // Todas las plataformas usan la URL de Render en producción
    return _baseIp;
  }

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

  Future<bool> hasUserVoted(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}voto/verificar/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasVoted'];
      } else {
        throw Exception('Error al verificar voto: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Método para despertar el servidor (útil para Render free tier)
  Future<bool> wakeUpServer() async {
    try {
      debugPrint('Despertando servidor...');
      final response = await http
          .get(Uri.parse('${baseUrl}health'))
          .timeout(const Duration(seconds: 30));
      debugPrint('Servidor despierto: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error al despertar servidor: $e');
      return false;
    }
  }

  Future<bool> castVote(
    String candidateId,
    String userEmail,
    String userId,
  ) async {
    final url = '${baseUrl}voto/registrar';

    final body = json.encode({
      'candidateId': candidateId,
      'userEmail': userEmail,
      'uid': userId,
    });

    // Intentar la petición con reintentos para manejar cold start de Render
    int maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('Intento $attempt de $maxRetries...');

        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 45)); // Aumentado a 45 segundos

        if (response.statusCode == 200) {
          return true;
        } else if (response.statusCode == 400) {
          final data = json.decode(response.body);
          throw Exception(data['detail'] ?? 'Error desconocido del servidor');
        } else if (response.statusCode == 422) {
          final data = json.decode(response.body);
          throw Exception('Error de validación: ${data['detail']}');
        } else {
          throw Exception(
            'Error al registrar voto: ${response.statusCode} - ${response.body}',
          );
        }
      } on TimeoutException catch (_) {
        if (attempt == maxRetries) {
          throw Exception(
            'El servidor está despertando (cold start). Por favor, intenta de nuevo en unos segundos.',
          );
        }
        // Esperar antes de reintentar
        debugPrint('Timeout, esperando 3 segundos antes de reintentar...');
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Connection refused')) {
          throw Exception(
            'No se puede conectar al servidor. Verifica tu conexión a internet.',
          );
        }
        // Para otros errores, reintentar si no es el último intento
        if (attempt == maxRetries) {
          rethrow;
        }
        debugPrint('Error en intento $attempt: $e');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    return false;
  }

  Future<Map<String, int>> getResults() async {
    final Map<String, int> results = {};

    try {
      // Inicializar resultados con 0 votos
      for (final candidate in _candidates) {
        results[candidate.id] = 0;
      }

      final response = await http.get(Uri.parse('${baseUrl}voto/resultados'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        for (final item in data) {
          if (results.containsKey(item['candidateId'])) {
            results[item['candidateId']] = item['votes'];
          }
        }

        return results;
      } else {
        throw Exception('Error al obtener resultados: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> clearVotes() async {
    try {
      final response = await http.delete(Uri.parse('${baseUrl}voto/limpiar'));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al limpiar votos: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
