import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/usine_providers.dart';
import '../widgets/material_card.dart';

class UsineMatieresScreen extends ConsumerWidget {
  const UsineMatieresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(availableMaterialsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Matières disponibles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/usine/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(availableMaterialsProvider),
        child: materialsAsync.when(
          data: (materials) {
            if (materials.isEmpty) {
              return const Center(
                child: Text('Aucune matière disponible pour le moment.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return MaterialCard(
                  type: material.material,
                  quantity: '${material.quantity} ${material.unit}',
                  provenance: material.zttInfo?['name'] ?? 'ZTT Inconnue',
                  date: '', // Model doesn't have date, could use a default or omit
                  onTap: () {
                    context.push('/usine/matiere_detail', extra: material);
                  },
                  onReserve: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${material.material} réservé avec succès !')),
                    );
                  },
                  onRetrieve: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Récupération de ${material.material} initiée !')),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erreur: $err')),
        ),
      ),
    );
  }
}
