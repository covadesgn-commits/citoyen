import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/ztt_providers.dart';
import '../../../../core/theme/app_colors.dart';

class ZttProfilScreen extends ConsumerWidget {
  const ZttProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(zttProfileProvider);
    final userStatsAsync = ref.watch(zttStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.getTextPrimaryColor(context),
        elevation: 0,
      ),
      body: userProfileAsync.when(
        data: (profile) {
          final String name = profile['name'] ?? 'Zone de Transit';
          final String email = profile['email'] ?? 'Non renseigné';
          final String phone = profile['phone'] ?? 'Non renseigné';
          final String address = profile['location_address'] ?? 'Conakry, Guinée';
          final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'Z';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                              color: AppColors.primary,
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
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getTextPrimaryColor(context),
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
                                    'Compte ZTT',
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
                      _buildProfileDetailRow(context, Icons.email_outlined, email, label: "Email"),
                      const SizedBox(height: 18),
                      _buildProfileDetailRow(context, Icons.phone_android_rounded, phone, label: "Contact"),
                      const SizedBox(height: 18),
                      _buildProfileDetailRow(context, Icons.location_on_outlined, address, label: "Ville"),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                // Stats Section
                Text(
                  'Mes Statistiques',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Trié',
                        value: userStatsAsync.when(
                          data: (stats) => "${stats['totalWeight']} kg",
                          loading: () => '...',
                          error: (_, __) => '?',
                        ),
                        icon: Icons.scale_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Opérations',
                        value: userStatsAsync.when(
                          data: (stats) => "${stats['totalSorts']}",
                          loading: () => '...',
                          error: (_, __) => '?',
                        ),
                        icon: Icons.recycling_rounded,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Engagement Section
                Text(
                  'Engagement CoVaDeS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(16),
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
                      _buildActionTile(
                        context,
                        icon: Icons.volunteer_activism_outlined,
                        title: 'Contribuer à CoVaDeS',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildActionTile(
                        context,
                        icon: Icons.star_border_rounded,
                        title: 'Noter l\'application',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildActionTile(
                        context,
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Donnez-nous votre avis',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Preferences Section
                Text(
                  'Préférences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(16),
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
                      _buildActionTile(
                        context,
                        icon: Icons.language_rounded,
                        title: 'Langue',
                        trailing: Text(
                          'Français',
                          style: TextStyle(
                            color: AppColors.getTextSecondaryColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildActionTile(
                        context,
                        icon: Icons.dark_mode_outlined,
                        title: 'Thème sombre',
                        trailing: Switch(
                          value: false, // Wire up to ThemeProvider if exists
                          onChanged: (val) {},
                          activeColor: AppColors.primary,
                        ),
                        onTap: () {}, // Handled by Switch
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
                    label: const Text(
                      'Déconnexion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Impossible de charger le profil', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(err.toString(), style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(BuildContext context, IconData icon, String value, {required String label}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.getBackgroundColor(context),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.getTextSecondaryColor(context), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.getTextPrimaryColor(context), size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.getTextPrimaryColor(context),
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: AppColors.getTextSecondaryColor(context)),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de déconnexion : $e')),
        );
      }
    }
  }
}
