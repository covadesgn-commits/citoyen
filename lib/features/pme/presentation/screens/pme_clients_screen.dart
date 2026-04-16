import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/pme_providers.dart';

import '../../domain/models/pme_models.dart';

class PmeClientsScreen extends ConsumerWidget {
  const PmeClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(pmeClientsProvider);
    final statsAsync = ref.watch(pmeStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: clientsAsync.when(
                data: (clients) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: clients.length + 1, // +1 for the stats card
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return statsAsync.maybeWhen(
                          data: (stats) => _buildStatsCard(stats),
                          orElse: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                        );
                      }
                      final client = clients[index - 1];
                      return _buildClientCard(context, client);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('Erreur: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mes Clients',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(FontAwesomeIcons.bell, color: AppColors.getTextPrimaryColor(context), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(PmeStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Clients actifs', '${stats.activeClients}', Colors.white),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3), margin: const EdgeInsets.symmetric(horizontal: 20)),
          _buildStatItem('Revenus/mois', '${stats.monthlyRevenue} GNF', Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, PmeClient client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.getTextPrimaryColor(context).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                client.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.getTextPrimaryColor(context)),
              ),
              _buildStatusBadge(context, client.paymentStatus),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${client.monthlyRate} GNF / mois',
            style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.getTextPrimaryColor(context)),
              const SizedBox(width: 8),
              Text(
                'Dernier paiement : ${client.lastPaymentDate != null ? "${client.lastPaymentDate!.day}/${client.lastPaymentDate!.month}/${client.lastPaymentDate!.year}" : "Aucun"}',
                style: TextStyle(color: AppColors.getTextPrimaryColor(context), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'A jour':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        break;
      case 'En retard':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        break;
      case 'Non payé':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFF44336);
        break;
      default:
        bgColor = AppColors.getBackgroundColor(context);
        textColor = AppColors.getTextSecondaryColor(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
