import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/voting_viewmodel.dart';

// Pantalla que muestra los resultados de la votación
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo color lavanda claro
      backgroundColor: const Color.fromRGBO(235, 226, 242, 1),
      // Barra superior color morado institucional
      appBar: AppBar(
        title: const Text('Resultados de Votación'),
        backgroundColor: const Color.fromRGBO(84, 9, 145, 1),
        foregroundColor: Colors.white,
      ),
      // Consumer para escuchar cambios en VotingViewModel
      body: Consumer<VotingViewModel>(
        builder: (context, vm, child) => FutureBuilder<Map<String, int>>(
          // Obtener resultados desde Firestore
          future: vm.getResults(),
          builder: (context, snapshot) {
            // Mostrar indicador de carga mientras se cargan datos
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(84, 9, 145, 1),
                ),
              );
            }

            // Obtener datos de resultados o diccionario vacío
            final results = snapshot.data ?? {};
            // Calcular total de votos
            final totalVotes = results.values.reduce(
              (sum, count) => sum + count,
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta con total de votos
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Título "Total de Votos"
                          const Text(
                            'Total de Votos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(84, 9, 145, 1),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Número total de votos
                          Text(
                            totalVotes.toString(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Título de sección
                  const Text(
                    'Votos por Candidato',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Lista de candidatos con sus votos
                  Expanded(
                    child: ListView.builder(
                      itemCount: vm.candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = vm.candidates[index];
                        // Obtener votos para este candidato
                        final votes = results[candidate.id] ?? 0;
                        // Calcular porcentaje de votos
                        final percentage = totalVotes > 0
                            ? ((votes / totalVotes) * 100).toStringAsFixed(1)
                            : '0.0';

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Foto del candidato
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(
                                    candidate.imageUrl,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Información del candidato
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        candidate.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        candidate.description,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Votos y porcentaje
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$votes votos',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color.fromRGBO(84, 9, 145, 1),
                                      ),
                                    ),
                                    Text(
                                      '$percentage%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
