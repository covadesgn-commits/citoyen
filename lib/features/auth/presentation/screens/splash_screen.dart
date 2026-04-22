import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Auto-redirect if already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'asset/img1.jpeg',
            fit: BoxFit.cover,
          ),
          // Dark overlay for legibility
          Container(
            color: Colors.black.withValues(alpha: 0.6),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Reconstitution parfaite du logo avec les 3 assets (Poubelle, Flèches, Texte)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Stack pour centraliser l'animation et l'icône poubelle
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Base image (la poubelle) - Static
                            Image.asset(
                              'asset/poubelle.png',
                              width: 90, // Calibré pour entrer dans le cercle
                              fit: BoxFit.contain,
                            ),
                            // Arrows image - Rotating
                            RotationTransition(
                              turns: _controller,
                              child: Image.asset(
                                'asset/imgfleche.png',
                                width: 160, // Encercle parfaitement la poubelle
                                height: 160,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        // Réduction de l'espace pour coller le texte sous le logo
                        const SizedBox(height: 12),
                        // Rapprocher le texte sous le logo en compensant son espace transparent supérieur
                        Transform.translate(
                          offset: const Offset(0, -60), // Ajustement pour le rapprocher sans le croiser
                          child: Image.asset(
                            'asset/covades.png',
                            width: 200, 
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Collecte et Valorisation des Dechets par Signalement',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: 'Commencer',
                    onPressed: () => context.go('/profile_selection'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

