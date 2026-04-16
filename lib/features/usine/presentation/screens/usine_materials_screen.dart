import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usine_providers.dart';
import '../../domain/models/available_material.dart';
import '../../../../core/theme/app_colors.dart';

class UsineMaterialsScreen extends ConsumerWidget {
  const UsineMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(availableMaterialsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Matières Disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.getTextPrimaryColor(context),
        elevation: 0,
      ),
      body: materialsAsync.when(
        data: (materials) => materials.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.getTextSecondaryColor(context).withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune matière disponible pour le moment',
                      style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final material = materials[index];
                  return _buildMaterialCard(context, ref, material);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, WidgetRef ref, AvailableMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  material.material.toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${material.quantity} ${material.unit}',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  material.zttInfo?['name'] ?? 'Provenance inconnue',
                  style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prix unitaire',
                      style: TextStyle(fontSize: 11, color: AppColors.getTextSecondaryColor(context)),
                    ),
                    Text(
                      '${material.pricePerUnit} GNF/kg',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _showBuyDialog(context, ref, material),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Acheter', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBuyDialog(BuildContext context, WidgetRef ref, AvailableMaterial material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer l\'achat'),
        content: Text(
          'Voulez-vous acheter ${material.quantity} ${material.unit} de ${material.material} pour un total de ${material.quantity * material.pricePerUnit} GNF ?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final usineRepo = ref.read(usineRepositoryProvider);
              final profile = ref.read(usineProfileProvider).value;
              final userId = profile?['id'];
              
              if (userId != null) {
                try {
                  await usineRepo.buyMaterial(
                    materialId: material.id,
                    factoryId: userId,
                    amount: material.quantity * material.pricePerUnit,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.invalidate(availableMaterialsProvider);
                    ref.invalidate(usineStatsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Achat réussi !'), backgroundColor: AppColors.success),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
