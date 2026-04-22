import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/app_notification.dart';

final usineNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  // Simulating a delay for data fetching
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    AppNotification(
      id: '1',
      userId: 'usine',
      title: 'Besoin de production urgent',
      message: 'Une commande de 500 briques recyclées a été reçue. Veuillez valider la disponibilité.',
      type: 'signalement',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    AppNotification(
      id: '2',
      userId: 'usine',
      title: 'Matières disponibles',
      message: 'Une nouvelle cargaison de Plastique PET (150kg) est disponible à la ZTT de Kaloum.',
      type: 'prestation',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];
});

class UsineNotificationsScreen extends ConsumerWidget {
  const UsineNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(usineNotificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications Usine',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                      ? Icons.priority_high_rounded
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
              trailing: Text(
                '${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
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
