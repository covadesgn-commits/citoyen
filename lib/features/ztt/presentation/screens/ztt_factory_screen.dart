import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ztt_providers.dart';

class ZttFactoriesScreen extends ConsumerWidget {
  const ZttFactoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoriesAsync = ref.watch(zttFactoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usines Partenaires', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: factoriesAsync.when(
        data: (factories) => factories.isEmpty
          ? const Center(child: Text('Aucune usine disponible'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: factories.length,
              itemBuilder: (context, index) {
                final factory = factories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.factory)),
                    title: Text(factory.name),
                    subtitle: Text(factory.specializedWasteTypes.join(', ')),
                    onTap: () {
                      // Factory Details
                    },
                  ),
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: \$err')),
      ),
    );
  }
}
