import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/usine_providers.dart';
import '../widgets/order_card.dart';

class UsineCommandesScreen extends ConsumerWidget {
  const UsineCommandesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(factoryOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Commandes',
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
        onRefresh: () async => ref.invalidate(factoryOrdersProvider),
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return const Center(
                child: Text('Aucune commande pour le moment.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final client = order['users']?['name'] ?? 'Client inconnu';
                final productName = order['factory_products']?['name'] ?? 'Produit inconnu';
                
                return OrderCard(
                  product: productName,
                  quantity: '${order['quantity']} ${order['unit'] ?? ''}',
                  status: order['status'] ?? 'En attente',
                  date: order['createdat'] != null 
                      ? DateTime.parse(order['createdat']).toString().split(' ')[0] 
                      : '',
                  clientName: client,
                  onTap: () {
                    context.push('/usine/commande_detail', extra: order);
                  },
                  onValidate: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Commande validée pour $client !')),
                    );
                  },
                  onDeliver: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Commande marquée comme livrée pour $client !')),
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
