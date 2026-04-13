import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/mairie_providers.dart';

class MairieHomeScreen extends ConsumerWidget {
  const MairieHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(mairieProfileProvider);
    final totalAsync = ref.watch(mairieTotalReportsCountProvider);
    final pendingAsync = ref.watch(mairiePendingReportsCountProvider);
    final resolvedAsync = ref.watch(mairieResolvedReportsCountProvider);
    final activitiesAsync = ref.watch(mairieRecentActivitiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(mairieProfileProvider);
            ref.invalidate(mairieTotalReportsCountProvider);
            ref.invalidate(mairiePendingReportsCountProvider);
            ref.invalidate(mairieResolvedReportsCountProvider);
            ref.invalidate(mairieRecentReportsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: profileAsync.when(
                      data: (profile) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?['commune'] ?? 'Tableau de bord mairie',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?['name'] ?? 'Responsable mairie',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(
                        height: 48,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, __) => const Text('Mairie'),
                    ),
                  ),
                  _HeaderButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => context.push('/mairie/notifications'),
                  ),
                  const SizedBox(width: 10),
                  _HeaderButton(
                    icon: Icons.logout_rounded,
                    highlighted: true,
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilotage communal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Suivez les signalements, priorisez les actions terrain et coordonnez les interventions.',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _MetricCard(title: 'Signalements', value: totalAsync)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(title: 'En attente', value: pendingAsync)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(title: 'Traités', value: resolvedAsync)),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Activités récentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              activitiesAsync.when(
                data: (activities) {
                  if (activities.isEmpty) {
                    return const _EmptyCard(message: 'Aucun signalement récent.');
                  }

                  return Column(
                    children: activities.map((activity) {
                      return _ActivityCard(
                        title: activity['title'] as String,
                        description: activity['description'] as String,
                        date: activity['date']?.toString(),
                        priority: activity['priority']?.toString(),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )),
                error: (err, _) => _EmptyCard(message: 'Erreur: $err'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: highlighted ? AppColors.primary : AppColors.textPrimary),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final AsyncValue<int> value;

  const _MetricCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          value.when(
            data: (count) => Text(
              '$count',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            loading: () => const SizedBox(
              height: 28,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const Text('-'),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String? date;
  final String? priority;

  const _ActivityCard({
    required this.title,
    required this.description,
    this.date,
    this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (priority != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    priority!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (date != null) ...[
            const SizedBox(height: 8),
            Text(
              date!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
