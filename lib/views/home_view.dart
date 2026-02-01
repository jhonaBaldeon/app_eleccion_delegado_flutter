import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/voting_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VotingViewModel(),
      child: Consumer<VotingViewModel>(
        builder: (context, vm, child) => Scaffold(
          appBar: AppBar(
            title: const Text("Candidatos Delegado"),
            backgroundColor: const Color(0xFFE20613),
            foregroundColor: Colors.white,
            actions: [
              if (vm.hasVoted)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text("✓ Ya votaste", style: TextStyle(fontSize: 14)),
                  ),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: vm.candidates.length,
              itemBuilder: (context, index) {
                final candidate = vm.candidates[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            candidate.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              candidate.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              candidate.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE20613),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: vm.hasVoted
                                  ? null
                                  : () => _showConfirmation(
                                      context,
                                      vm,
                                      candidate.name,
                                      candidate.id,
                                    ),
                              child: Text(vm.hasVoted ? "Ya votaste" : "Votar"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmation(
    BuildContext context,
    VotingViewModel vm,
    String name,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Confirmar Voto"),
        content: Text("¿Estás seguro de votar por $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              final success = await vm.castVote(id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Voto registrado con éxito")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error al registrar voto")),
                  );
                }
              }
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }
}
