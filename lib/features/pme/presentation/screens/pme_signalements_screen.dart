import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/pme_providers.dart';

class PmeSignalementsScreen extends ConsumerWidget {
  const PmeSignalementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(wasteReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(wasteReportsProvider);
                  try {
                    await ref.read(wasteReportsProvider.future);
                  } catch (_) {}
                },
                color: AppColors.primary,
                child: reportsAsync.when(
                  data: (reports) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      // Conversion for the UI card if needed, or update _buildReportCard
                      final reportMap = {
                        'citoyen': 'Citoyen #${report.id.substring(0, 4)}',
                        'location': 'Localisation: ${report.location.latitude.toStringAsFixed(4)}, ${report.location.longitude.toStringAsFixed(4)}',
                        'status': report.status,
                        'time': 'Aujourd\'hui',
                      };
                      return _buildReportCard(context, reportMap);
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (err, _) => Center(child: Text('Erreur: $err')),
                ),
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
            'Signalements',
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

  Widget _buildReportCard(BuildContext context, Map<String, String> report) {
    return GestureDetector(
      onTap: () {
        context.push('/dashboard-pme/signalements/details', extra: report);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.report_problem, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['citoyen']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report['location']!,
                    style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    report['time']!,
                    style: TextStyle(color: AppColors.getTextSecondaryColor(context).withValues(alpha: 0.8), fontSize: 11),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(context, report['status']!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'reçu':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF2196F3);
        break;
      case 'accepté':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        break;
      case 'en route':
        bgColor = const Color(0xFFF3E5F5);
        textColor = const Color(0xFF9C27B0);
        break;
      case 'collecté':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
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
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
