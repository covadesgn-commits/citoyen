import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/pme_providers.dart';

class PmeHeader extends ConsumerWidget {
  const PmeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pmeProfileAsync = ref.watch(pmeProfileProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: pmeProfileAsync.when(
              data: (profile) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile?.businessName ?? 'Mon Entreprise',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile?.locationAddress ?? 'Conakry, Guinée',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Text('Chargement...'),
              error: (_, __) => const Text('Erreur profil'),
            ),
          ),
          const SizedBox(width: 8),
          ref.watch(pmeNotificationsProvider).when(
            data: (notifications) {
              final unreadCount = notifications.where((n) => !n.isRead).length;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.push('/pme_notifications');
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                      child: const Icon(
                        FontAwesomeIcons.bell,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => Container(
              decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(FontAwesomeIcons.bell, color: AppColors.textPrimary, size: 18),
              ),
            ),
            error: (_, __) => Container(
              decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(FontAwesomeIcons.bell, color: AppColors.textPrimary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

