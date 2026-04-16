import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/order_card.dart';

class UsineCommandesScreen extends StatelessWidget {
  const UsineCommandesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockOrders = [
      {
        'product': 'Briques en plastique recyclé',
        'quantity': '500 unités',
        'status': 'En attente',
        'date': '13 Oct 2026',
        'clientName': 'BTP Conakry',
      },
      {
        'product': 'Granulés PET',
        'quantity': '2 tonnes',
        'status': 'Validée',
        'date': '10 Oct 2026',
        'clientName': 'Plastiques de Guinée',
      },
      {
        'product': 'Briques en plastique recyclé',
        'quantity': '100 unités',
        'status': 'Livrée',
        'date': '05 Oct 2026',
        'clientName': 'Aménagement S.A',
      },
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: mockOrders.length,
        itemBuilder: (context, index) {
          final order = mockOrders[index];
          return OrderCard(
            product: order['product'],
            quantity: order['quantity'],
            status: order['status'],
            date: order['date'],
            clientName: order['clientName'],
            onTap: () {
              context.push('/usine/commande_detail', extra: order);
            },
            onValidate: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Commande validée pour ${order['clientName']} !')),
              );
            },
            onDeliver: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Commande marquée comme livrée pour ${order['clientName']} !')),
              );
            },
          );
        },
      ),
    );
  }
}
