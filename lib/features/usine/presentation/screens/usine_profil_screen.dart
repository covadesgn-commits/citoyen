import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/usine_providers.dart';
import '../../../../core/theme/app_colors.dart';

class UsineProfilScreen extends ConsumerWidget {
  const UsineProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(usineProfileProvider);
    final statsAsync = ref.watch(usineStatsProvider);

    return profileAsync.when(
      data: (profile) {
        final String name = profile['name'] ?? 'Responsable Usine';
        final String email = profile['email'] ?? 'Non renseigné';
        final String phone = profile['phone'] ?? 'Non renseigné';
        final factoryInfo = profile['factory_info'];
        final String factoryName = factoryInfo?['factoryname'] ?? 'Usine sans nom';
        final String address = factoryInfo?['address'] ?? 'Conakry, Guinée';
        final String industryType = factoryInfo?['industrytype'] ?? 'Transformation';
        final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          appBar: AppBar(
            title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            backgroundColor: AppColors.getBackgroundColor(context),
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => context.push('/usine/notifications'),
                icon: const Icon(Icons.notifications_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, Color(0xFFEF5350)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Compte Usine',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Divider(height: 1),
                      const SizedBox(height: 32),
                      _buildProfileDetailRow(context, Icons.factory_outlined, factoryName, label: "Établissement"),
                      const SizedBox(height: 18),
                      _buildProfileDetailRow(context, Icons.category_outlined, industryType, label: "Secteur"),
                      const SizedBox(height: 18),
                      _buildProfileDetailRow(context, Icons.email_outlined, email, label: "Email"),
                      const SizedBox(height: 18),
                      _buildProfileDetailRow(context, Icons.phone_android_rounded, phone, label: "Contact"),
                      const SizedBox(height: 18),
                      _buildProfileDetailRow(context, Icons.location_on_outlined, address, label: "Localisation"),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                // Stats Section
                const Text(
                  'Performances Usine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                statsAsync.when(
                  data: (stats) => Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Produits',
                          value: stats['total_products']?.toString() ?? '0',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Achats TRI',
                          value: stats['total_purchases']?.toString() ?? '0',
                          icon: Icons.shopping_cart_outlined,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Erreur stats: $err')),
                ),

                const SizedBox(height: 32),
                const Text(
                  'Engagement CoVaDeS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    children: [
                      _buildActionTile(
                        context,
                        icon: Icons.volunteer_activism_outlined,
                        title: 'Contribuer à CoVaDeS',
                        onTap: () {},
                      ),
                      _divider(context),
                      _buildActionTile(
                        context,
                        icon: Icons.star_outline_rounded,
                        title: 'Noter l’application',
                        onTap: () {},
                      ),
                      _divider(context),
                      _buildActionTile(
                        context,
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Avis et commentaires',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  'Préférences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    children: [
                      _buildActionTile(
                        context,
                        icon: Icons.language_outlined,
                        title: 'Langue',
                        subtitle: 'Français',
                        onTap: () {},
                      ),
                      _divider(context),
                      _buildActionTile(
                        context,
                        icon: Icons.palette_outlined,
                        title: 'Thème de l\'application',
                        subtitle: 'Mode Clair',
                        onTap: () {},
                      ),
                      _divider(context),
                      _buildActionTile(
                        context,
                        icon: Icons.security_outlined,
                        title: 'Confidentialité et Sécurité',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Erreur: $err'))),
    );
  }

  Widget _buildProfileDetailRow(BuildContext context, IconData icon, String text, {String? label}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorderColor(context)),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.getTextSecondaryColor(context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: AppColors.getTextSecondaryColor(context)),
      ) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.getTextSecondaryColor(context), size: 20),
      onTap: onTap,
    );
  }

  Widget _divider(BuildContext context) => Divider(height: 1, indent: 60, color: AppColors.getBorderColor(context));
}
