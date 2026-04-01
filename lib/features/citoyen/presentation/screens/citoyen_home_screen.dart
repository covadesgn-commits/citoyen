import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/citoyen_providers.dart';
import '../../../../core/theme/app_colors.dart';

class CitoyenHomeScreen extends ConsumerWidget {
  const CitoyenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentActions = ref.watch(recentActionsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(recentReportsProvider);
            ref.invalidate(recentSubscriptionsProvider);
            ref.invalidate(userProfileProvider);
          },
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenue',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          userProfileAsync.when(
                            data: (profile) {
                              final name = profile?['name'] ?? 'Citoyen';
                              return Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ); 
                            },
                            loading: () => const Text('Chargement...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            error: (_, __) => const Text('Utilisateur', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderButton(
                          icon: Icons.notifications_none_rounded,
                          onTap: () => context.push('/notifications'),
                        ),
                        const SizedBox(width: 10),
                        _buildHeaderButton(
                          icon: Icons.logout_rounded,
                          onTap: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          isLogout: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Red Action Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.85), // Version plus douce demandée
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        title: "Abonnement",
                        icon: Icons.people_outline,
                        onTap: () => context.push('/subscription'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        title: "Signalement",
                        icon: Icons.error_outline,
                        onTap: () => context.push('/report_waste'),
                      ),
                    ),
                  ],
                ),
              ),

              // Recent Actions List
              Expanded(
                child: Container(
                  color: const Color(0xFFFBFBFB),
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      const Text(
                        'Actions récentes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      recentActions.when(
                        data: (actions) {
                          if (actions.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
                                  'Aucune action récente',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: actions.map((action) => _ActivityCard(
                              type: action['type'],
                              description: action['description'],
                              date: action['date'],
                            )).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              'Erreur de récupération des données \${err.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isLogout 
            ? AppColors.primary.withValues(alpha: 0.1) 
            : Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon, 
          color: isLogout ? AppColors.primary : AppColors.textPrimary,
          size: 20,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String type;
  final String description;
  final String? date;

  const _ActivityCard({
    required this.type,
    required this.description,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    String displayDate = '';
    if (date != null) {
      try {
        final dt = DateTime.parse(date!);
        final months = [
          'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
        ];
        displayDate = "${dt.day} ${months[dt.month - 1]} ${dt.year}";
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayDate,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
