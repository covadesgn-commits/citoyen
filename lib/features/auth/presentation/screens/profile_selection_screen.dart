import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/role_card.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/splash'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Qui êtes-vous ?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sélectionnez votre profil pour continuer',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    RoleCard(
                      title: 'Citoyen',
                      icon: Icons.person_outline,
                      isSelected: false,
                      onTap: () => context.go('/register/citoyen'),
                    ),
                    RoleCard(
                      title: 'PME',
                      icon: Icons.business_center_outlined,
                      isSelected: false,
                      onTap: () => context.go('/register/pme'),
                    ),
                    RoleCard(
                      title: 'ZTT',
                      icon: Icons.local_shipping_outlined,
                      isSelected: false,
                      onTap: () => context.go('/register/ztt'),
                    ),
                    RoleCard(
                      title: 'Usine',
                      icon: Icons.factory_outlined,
                      isSelected: false,
                      onTap: () => context.go('/register/usine'),
                    ),
                    RoleCard(
                      title: 'Mairie',
                      icon: Icons.account_balance_outlined,
                      isSelected: false,
                      onTap: () => context.go('/register/mairie'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
