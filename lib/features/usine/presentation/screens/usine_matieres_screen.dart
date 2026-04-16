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
    // Dans un vrai projet, on utiliserait le provider
    // final materialsAsync = ref.watch(usineMaterialsProvider);

    // Mock des données pour correspondre au design Figma
    final List<Map<String, dynamic>> mockMaterials = [
      {
        'type': 'Plastique PET',
        'quantity': '150 kg',
        'provenance': 'ZTT Conakry Nord',
        'date': '12 Oct 2026',
      },
      {
        'type': 'Verre',
        'quantity': '300 kg',
        'provenance': 'ZTT Dixinn',
        'date': '13 Oct 2026',
      },
      {
        'type': 'Métal (Aluminium)',
        'quantity': '85 kg',
        'provenance': 'ZTT Kaloum',
        'date': '14 Oct 2026',
      },
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: mockMaterials.length,
        itemBuilder: (context, index) {
          final material = mockMaterials[index];
          return MaterialCard(
            type: material['type'],
            quantity: material['quantity'],
            provenance: material['provenance'],
            date: material['date'],
            onTap: () {
              context.push('/usine/matiere_detail', extra: material);
            },
            onReserve: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${material['type']} réservé avec succès !')),
              );
            },
            onRetrieve: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Récupération de ${material['type']} initiée !')),
              );
            },
          );
        },
      ),
    );
  }
}
