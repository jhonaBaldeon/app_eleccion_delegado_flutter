import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/voting_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VotingViewModel(),
      child: Consumer<VotingViewModel>(
        builder: (context, vm, child) => Scaffold(
          backgroundColor: const Color.fromRGBO(245, 243, 255, 1),
          appBar: AppBar(
            title: const Text("Candidatos Delegado"),
            backgroundColor: const Color.fromRGBO(84, 9, 145, 1),
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
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Consumer<LoginViewModel>(
                  builder: (context, loginVm, child) {
                    return DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(84, 9, 145, 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (FirebaseAuth.instance.currentUser?.photoURL !=
                                  null)
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage: NetworkImage(
                                    FirebaseAuth
                                        .instance
                                        .currentUser!
                                        .photoURL!,
                                  ),
                                )
                              else
                                const CircleAvatar(
                                  radius: 35,
                                  child: Icon(Icons.person, size: 40),
                                ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      FirebaseAuth
                                              .instance
                                              .currentUser
                                              ?.displayName ??
                                          'Usuario',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Facultad de Ingeniería de Sistemas e Informática',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.how_to_vote),
                  title: const Text("Votar"),
                  onTap: () {
                    Navigator.pop(context); // Cerrar el drawer
                    // Navegar a la pantalla de votación (ya estamos aquí)
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text("Resultados"),
                  onTap: () {
                    Navigator.pop(context); // Cerrar el drawer
                    Navigator.pushNamed(context, '/results');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text("Limpiar Votos"),
                  onTap: () {
                    Navigator.pop(context); // Cerrar el drawer
                    _showClearVotesConfirmation(context, vm);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text("Salir"),
                  onTap: () {
                    Navigator.pop(context); // Cerrar el drawer
                    _handleLogout(context);
                  },
                ),
              ],
            ),
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
                          child: Image.asset(
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
                                backgroundColor: const Color.fromRGBO(
                                  84,
                                  9,
                                  145,
                                  1,
                                ),
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
                  Navigator.pushReplacementNamed(context, '/success');
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

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cerrar Sesión"),
        content: const Text("¿Estás seguro de cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Cerrar el diálogo
              await Provider.of<LoginViewModel>(
                context,
                listen: false,
              ).signOut(context);
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  void _showClearVotesConfirmation(BuildContext context, VotingViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Limpiar Votos"),
        content: const Text(
          "¿Estás seguro de limpiar todos los votos? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              final success = await vm.clearVotes();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Votos limpiados con éxito")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error al limpiar votos")),
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
