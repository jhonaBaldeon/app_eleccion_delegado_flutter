import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importación de ViewModels para gestión de estado
import '../viewmodels/voting_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';

// Pantalla principal que muestra los candidatos
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializar el VotingViewModel con los datos del usuario actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final vm = Provider.of<VotingViewModel>(context, listen: false);
        vm.setUserInfo(userId: user.uid, userEmail: user.email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer escucha cambios en VotingViewModel
    return Consumer<VotingViewModel>(
      builder: (context, vm, child) => Scaffold(
        // Fondo color lavanda claro
        backgroundColor: const Color.fromRGBO(235, 226, 242, 1),
        // Barra superior color morado institucional
        appBar: AppBar(
          title: const Text('Candidatos Delegado'),
          backgroundColor: const Color.fromRGBO(84, 9, 145, 1),
          foregroundColor: Colors.white,
          actions: [
            // Indicador de que ya votó
            if (vm.hasVoted)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text('✓ Ya votaste', style: TextStyle(fontSize: 14)),
                ),
              ),
          ],
        ),
        // Menú lateral de navegación
        drawer: Drawer(
          child: Container(
            color: const Color.fromRGBO(235, 226, 242, 1),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header con información del usuario logueado
                Consumer<LoginViewModel>(
                  builder: (context, loginVm, child) {
                    // Obtener foto de Google como fuente primaria
                    final googlePhotoUrl = loginVm.user?.photoUrl;
                    // Obtener foto de Firebase como fuente secundaria
                    final firebasePhotoUrl =
                        FirebaseAuth.instance.currentUser?.photoURL;

                    // Usar Firebase como principal, Google como respaldo
                    final photoUrl = firebasePhotoUrl ?? googlePhotoUrl;

                    // Obtener nombre para iniciales
                    final userName =
                        loginVm.user?.name ??
                        FirebaseAuth.instance.currentUser?.displayName ??
                        'Usuario';

                    return DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(84, 9, 145, 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Widget de foto de perfil con manejo especial para web
                              _buildProfileImage(photoUrl, userName),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loginVm.user?.name ??
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
                  title: const Text('Votar'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Resultados'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/results');
                  },
                ),
                // Toggle de modo administrador (solo visible para el admin)
                if (vm.isAdmin)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Modo Admin'),
                    trailing: Switch(
                      value: vm.showAdminOptions,
                      onChanged: (value) {
                        vm.toggleAdminOptions();
                        // No cerramos el drawer para que el usuario vea el cambio
                      },
                      activeThumbColor: const Color.fromRGBO(84, 9, 145, 1),
                    ),
                  ),
                // Limpiar Votos solo visible si es admin Y el toggle está activado
                if (vm.isAdmin && vm.showAdminOptions)
                  ListTile(
                    leading: const Icon(Icons.delete_sweep, color: Colors.red),
                    title: const Text(
                      'Limpiar Votos',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showClearVotesConfirmation(context, vm);
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Salir'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout(context);
                  },
                ),
              ],
            ),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                            child: Text(vm.hasVoted ? 'Ya votaste' : 'Votar'),
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
    );
  }

  void _showConfirmation(
    BuildContext context,
    VotingViewModel vm,
    String name,
    String id,
  ) {
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Confirmar Voto'),
          content: isLoading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Conectando con el servidor...'),
                    SizedBox(height: 8),
                    Text(
                      'Esto puede tomar unos segundos',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )
              : Text('¿Estás seguro de votar por $name?'),
          actions: isLoading
              ? []
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() => isLoading = true);

                      final success = await vm.castVote(id);

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                        if (success) {
                          Navigator.pushReplacementNamed(context, '/success');
                        } else {
                          final errorMsg =
                              vm.errorMessage ?? 'Error al registrar voto';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMsg)),
                          );
                        }
                      }
                    },
                    child: const Text('Confirmar'),
                  ),
                ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Provider.of<LoginViewModel>(
                context,
                listen: false,
              ).signOut(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showClearVotesConfirmation(BuildContext context, VotingViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpiar Votos'),
        content: const Text(
          '¿Estás seguro de limpiar todos los votos? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await vm.clearVotes();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Votos limpiados con éxito')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al limpiar votos')),
                  );
                }
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // Método para construir la imagen de perfil según la plataforma
  Widget _buildProfileImage(String? photoUrl, String userName) {
    // Obtener iniciales del nombre
    String initials = '';
    final nameParts = userName.split(' ');
    if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      initials = nameParts[0][0].toUpperCase();
      if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    if (initials.isEmpty) initials = 'U';

    // En web, las imágenes de Google tienen restricciones CORS
    // Usamos un avatar con iniciales como solución alternativa
    if (kIsWeb) {
      // Intentar cargar la imagen, pero si falla mostrar avatar con iniciales
      if (photoUrl != null && photoUrl.isNotEmpty) {
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Image.network(
              photoUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              // Configuración especial para web
              headers: const {'Access-Control-Allow-Origin': '*'},
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stack) {
                // Si falla la carga, mostrar avatar con iniciales
                return CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(84, 9, 145, 1),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }

      // Si no hay URL, mostrar avatar con iniciales directamente
      return CircleAvatar(
        radius: 35,
        backgroundColor: Colors.white,
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(84, 9, 145, 1),
          ),
        ),
      );
    }

    // En móvil (Android/iOS), usar Image.network como antes
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Image.network(
            photoUrl,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (context, error, stack) {
              return const Icon(Icons.person, size: 40, color: Colors.white);
            },
          ),
        ),
      );
    }

    // Si no hay URL en móvil, mostrar icono genérico
    return const CircleAvatar(
      radius: 35,
      backgroundColor: Colors.white24,
      child: Icon(Icons.person, size: 40),
    );
  }
}
