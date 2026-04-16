import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ztt_providers.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ZttHistoryScreen extends ConsumerWidget {
  const ZttHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(zttHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Historique des Tris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.getTextPrimaryColor(context),
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (reports) => reports.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.getBorderColor(context)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun tri enregistré',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.getTextSecondaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                
                final String formattedDate = DateFormat('EEEE d MMMM y à HH:mm', 'fr_FR').format(report.date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.recycling_rounded, color: AppColors.primary, size: 24),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${report.totalWeight} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report.factoryName,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(formattedDate, style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (report.selections.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: report.selections.take(3).map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.getBackgroundColor(context),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.getBorderColor(context).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                '${s.type}: ${s.weight}kg',
                                style: TextStyle(fontSize: 11, color: AppColors.getTextPrimaryColor(context)),
                              ),
                            )).toList(),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {
                      // Detail functionality
                    },
                  ),
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Erreur de chargement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

