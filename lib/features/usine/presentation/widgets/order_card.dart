import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'custom_button.dart';

class OrderCard extends StatelessWidget {
  final String product;
  final String quantity;
  final String status;
  final String date;
  final String clientName;
  final VoidCallback onValidate;
  final VoidCallback onDeliver;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.status,
    required this.date,
    required this.clientName,
    required this.onValidate,
    required this.onDeliver,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (status.toLowerCase().contains('livrée')) {
      statusColor = AppColors.success;
    } else if (status.toLowerCase().contains('validée')) {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quantité',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quantity,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFE5E7EB)),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Client: $clientName',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (status.toLowerCase().contains('attente')) ...[
                  CustomButton(
                    onPressed: onValidate,
                    text: 'Valider la commande',
                  ),
                ] else if (status.toLowerCase().contains('validée')) ...[
                  CustomButton(
                    onPressed: onDeliver,
                    text: 'Marquer comme livrée',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
