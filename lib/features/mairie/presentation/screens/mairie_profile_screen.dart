import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/mairie_providers.dart';
import '../widgets/custom_button.dart';

class MairieProfileScreen extends ConsumerWidget {
  const MairieProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(mairieProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: profileAsync.when(
        data: (profile) => _buildProfileContent(context, profile, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Map<String, dynamic>? profile, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeader(profile),
          const SizedBox(height: 32),
          _buildSection('Informations', [
            _ProfileMenuItem(
              icon: Icons.location_city,
              title: 'Commune',
              subtitle: profile?['commune'] ?? 'Non renseigné',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: profile?['email'] ?? 'Non renseigné',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.phone_outlined,
              title: 'Téléphone',
              subtitle: profile?['phone'] ?? 'Non renseigné',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Paramètres', [
            _ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Sécurité et mot de passe',
              onTap: () {},
              showArrow: true,
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_none,
              title: 'Préférences de notification',
              onTap: () {},
              showArrow: true,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Aide et Support', [
            _ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Centre d\'aide',
              onTap: () {},
              showArrow: true,
            ),
            _ProfileMenuItem(
              icon: Icons.contact_support_outlined,
              title: 'Contacter le support Technique',
              onTap: () {},
              showArrow: true,
            ),
          ]),
          const SizedBox(height: 40),
          CustomButton(
            text: 'Se déconnecter',
            icon: Icons.logout,
            isPrimary: false,
            onPressed: () => _handleLogout(context),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? profile) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            image: const DecorationImage(
              image: AssetImage('asset/images/mairie.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: profile?['avatar_url'] == null
              ? const Icon(Icons.account_balance, size: 40, color: AppColors.primary)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          profile?['name'] ?? 'Responsable Mairie',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Compte Superviseur',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: 56, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }
      
      try {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Remove loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      }
    }
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
