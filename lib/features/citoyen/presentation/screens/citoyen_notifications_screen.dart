import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/app_notification.dart';

// Provider temporaire pour simuler le backend
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return [
    AppNotification(
      id: '1',
      userId: 'user1',
      title: 'Abonnement PME',
      message: 'Votre demande d\'abonnement a été acceptée par EcoClean. Ils s\'occuperont désormais de vos déchets.',
      type: 'abonnement',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    AppNotification(
      id: '2',
      userId: 'user1',
      title: 'Signalement',
      message: 'Le déchet plastique signalé a été collecté avec succès. Merci pour votre signalement !',
      type: 'signalement',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: '3',
      userId: 'user1',
      title: 'Bienvenue',
      message: 'Bienvenue sur CoVaDeS ! Complétez votre profil pour profiter de toutes nos fonctionnalités.',
      type: 'system',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
});

class CitoyenNotificationsScreen extends ConsumerWidget {
  const CitoyenNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'Aucune notification pour le moment.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 32, color: Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _NotificationTile(notification: notif);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    IconData getIcon() {
      switch (notification.type) {
        case 'abonnement':
          return Icons.people_outline;
        case 'signalement':
          return Icons.error_outline;
        case 'prestation':
          return Icons.local_shipping_outlined;
        default:
          return Icons.notifications_none_rounded;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.grey[100] : AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            getIcon(),
            color: notification.isRead ? Colors.grey[600] : AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                        color: notification.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: notification.isRead ? Colors.grey[500] : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(notification.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inHours < 1) {
      if (difference.inMinutes <= 1) return 'À l\'instant';
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
