import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/theme/app_colors.dart';

class PmeShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PmeShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.getSurfaceColor(context),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.getTextSecondaryColor(context),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled, color: AppColors.primary),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded, color: AppColors.primary),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded, color: AppColors.primary),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business_rounded, color: AppColors.primary),
            label: 'Entreprise',
          ),
        ],
      ),
    );
  }
}
