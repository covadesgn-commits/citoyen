import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/app_notification.dart';

final mairieNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    AppNotification(
      id: '1',
      userId: 'mairie',
      title: 'Nouveau signalement prioritaire',
      message: 'Un dépôt sauvage a été signalé dans une zone sensible. Une validation rapide est requise.',
      type: 'signalement',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    AppNotification(
      id: '2',
      userId: 'mairie',
      title: 'Collecte confirmée',
      message: 'La tournée de collecte affectée à la PME partenaire a été clôturée avec succès.',
      type: 'prestation',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
});

class MairieNotificationsScreen extends ConsumerWidget {
  const MairieNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(mairieNotificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications mairie'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: notificationsAsync.when(
        data: (notifications) => ListView.separated(
          padding: const EdgeInsets.all(24),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: notification.isRead
                    ? Colors.grey[200]
                    : AppColors.primary.withValues(alpha: 0.12),
                child: Icon(
                  notification.type == 'signalement'
                      ? Icons.report_problem_outlined
                      : Icons.notifications_none_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  notification.message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemCount: notifications.length,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
