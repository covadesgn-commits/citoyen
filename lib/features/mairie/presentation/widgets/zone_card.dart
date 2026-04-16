import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ZoneCard extends StatelessWidget {
  final String title;
  final String reportCount;
  final String severity; // 'haute', 'moyenne', 'faible'
  final VoidCallback onTap;

  const ZoneCard({
    super.key,
    required this.title,
    required this.reportCount,
    required this.severity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    String severityLabel;

    switch (severity.toLowerCase()) {
      case 'haute':
        severityColor = AppColors.error;
        severityLabel = 'Priorité Haute';
        break;
      case 'moyenne':
        severityColor = Colors.orange;
        severityLabel = 'Priorité Moyenne';
        break;
      case 'faible':
        severityColor = AppColors.success;
        severityLabel = 'Priorité Faible';
        break;
      default:
        severityColor = AppColors.textSecondary;
        severityLabel = 'Non défini';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: severityColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$reportCount signalements en attente',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                severityLabel,
                style: TextStyle(
                  color: severityColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
