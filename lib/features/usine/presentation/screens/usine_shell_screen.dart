import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
=======
import '../../../../core/theme/app_colors.dart';
>>>>>>> refs/remotes/origin/main

class UsineShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const UsineShellScreen({
    super.key,
    required this.navigationShell,
  });

<<<<<<< HEAD
  void _onTap(BuildContext context, int index) {
=======
  void _goBranch(int index) {
>>>>>>> refs/remotes/origin/main
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
<<<<<<< HEAD
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE53935), // Primary Red
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Matières',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.precision_manufacturing_outlined),
            activeIcon: Icon(Icons.precision_manufacturing),
            label: 'Transformation',
=======
        onTap: _goBranch,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.recycling_outlined),
            activeIcon: Icon(Icons.recycling),
            label: 'Matières',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.factory_outlined),
            activeIcon: Icon(Icons.factory),
            label: 'Production',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Commandes',
>>>>>>> refs/remotes/origin/main
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
