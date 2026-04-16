import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/pme_providers.dart';

class PmeHomeScreen extends ConsumerStatefulWidget {
  const PmeHomeScreen({super.key});

  @override
  ConsumerState<PmeHomeScreen> createState() => _PmeHomeScreenState();
}

class _PmeHomeScreenState extends ConsumerState<PmeHomeScreen> {
  bool _isBalanceVisible = false;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(wasteReportsProvider);
    final profileAsync = ref.watch(pmeProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildBalanceCard(profileAsync),
                    const SizedBox(height: 32),
                    const Text(
                      'Vue d\'ensemble',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(reportsAsync),
                    const SizedBox(height: 32),
                    const Text(
                      'Activités récentes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivities(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = AppColors.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tableau de bord',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme toggle icon
              IconButton(
                onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                    color: AppColors.getTextPrimaryColor(context),
                    size: 22,
                  ),
                ),
                tooltip: isDark ? 'Mode clair' : 'Mode sombre',
              ),
              // Notification bell
              IconButton(
                onPressed: () {},
                icon: Icon(FontAwesomeIcons.bell, color: AppColors.getTextPrimaryColor(context), size: 20),
                tooltip: 'Notifications',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(AsyncValue<dynamic> profileAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solde attendu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isBalanceVisible ? '2.450.000 GNF' : '•••••• GNF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                icon: Icon(
                  _isBalanceVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceSubItem('Ce mois', _isBalanceVisible ? '120.000' : '••••', Colors.white),
              _buildBalanceSubItem('Abonnés', '8', Colors.white),
              _buildBalanceSubItem('Collectes', '82', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSubItem(String label, String value, [Color color = AppColors.textPrimary]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color == Colors.white ? Colors.white70 : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AsyncValue<List<dynamic>> reportsAsync) {
    return reportsAsync.when(
      data: (reports) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildSmallStatCard(
              'Clients',
              '8',
              Icons.people_alt_rounded,
              Colors.blue,
            ),
            _buildSmallStatCard(
              'Collectes',
              '82',
              Icons.local_shipping_rounded,
              Colors.green,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Erreur stats: $err'),
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.getTextPrimaryColor(context), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActivityItem(context, 'Nouveau signalement à Kaloum', 'Il y a 5 min', true),
          _divider(context),
          _buildActivityItem(context, 'Collecte terminée - Rue 123', 'Il y a 15 min', false),
          _divider(context),
          _buildActivityItem(context, 'Client abonné - Camayenne', 'Il y a 1 heure', false),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String time, bool isUrgent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.primary : AppColors.getBorderColor(context),
              shape: BoxShape.circle,
              boxShadow: isUrgent ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ] : null,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.getTextPrimaryColor(context).withValues(alpha: 0.3), size: 20),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(height: 24, indent: 26, color: AppColors.getBorderColor(context));
}
