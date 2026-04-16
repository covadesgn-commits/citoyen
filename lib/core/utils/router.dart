import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

// Auth Screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/profile_selection_screen.dart';
import '../../features/auth/presentation/screens/success_screen.dart';

// Citoyen Screens
import '../../features/citoyen/presentation/screens/citoyen_shell_screen.dart';
import '../../features/citoyen/presentation/screens/citoyen_home_screen.dart';
import '../../features/citoyen/presentation/screens/citoyen_prestation_screen.dart';
import '../../features/citoyen/presentation/screens/citoyen_marketplace_screen.dart';
import '../../features/citoyen/presentation/screens/citoyen_profil_screen.dart';
import '../../features/citoyen/presentation/screens/citoyen_notifications_screen.dart';
import '../../features/citoyen/presentation/screens/pme_subscription_screen.dart';
import '../../features/citoyen/presentation/screens/report_waste_screen.dart';
import '../../features/mairie/presentation/screens/mairie_dashboard_screen.dart';
import '../../features/mairie/presentation/screens/mairie_notifications_screen.dart';
import '../../features/mairie/presentation/screens/mairie_map_screen.dart';
import '../../features/mairie/presentation/screens/mairie_stats_screen.dart';
import '../../features/mairie/presentation/screens/mairie_profile_screen.dart';
import '../../features/mairie/presentation/screens/mairie_shell_screen.dart';
import '../../features/usine/presentation/screens/usine_matieres_screen.dart';
import '../../features/usine/presentation/screens/usine_production_screen.dart';
import '../../features/usine/presentation/screens/usine_commandes_screen.dart';
import '../../features/usine/presentation/screens/usine_profil_screen.dart';
import '../../features/usine/presentation/screens/usine_shell_screen.dart';
import '../../features/usine/presentation/screens/usine_matiere_detail_screen.dart';
import '../../features/usine/presentation/screens/usine_commande_detail_screen.dart';
import '../../features/usine/presentation/screens/usine_notifications_screen.dart';

// PME Screens
import '../../features/pme/presentation/screens/pme_shell_screen.dart';
import '../../features/pme/presentation/screens/pme_home_screen.dart';
import '../../features/pme/presentation/screens/pme_map_screen.dart';

import '../../features/pme/presentation/screens/pme_signalement_detail_screen.dart';
import '../../features/pme/presentation/screens/pme_clients_screen.dart';
import '../../features/pme/presentation/screens/pme_entreprise_screen.dart';
import '../../features/pme/presentation/screens/pme_notifications_screen.dart';

import '../../features/ztt/presentation/screens/ztt_sorting_form_screen.dart';

// ZTT Screens
import '../../features/ztt/presentation/screens/ztt_shell_screen.dart';
import '../../features/ztt/presentation/screens/ztt_home_screen.dart';
import '../../features/ztt/presentation/screens/ztt_history_screen.dart';
import '../../features/ztt/presentation/screens/ztt_factory_screen.dart';
import '../../features/ztt/presentation/screens/ztt_profil_screen.dart';

// Usine Screens
import '../../features/usine/presentation/screens/usine_shell_screen.dart';
import '../../features/usine/presentation/screens/usine_home_screen.dart';
import '../../features/usine/presentation/screens/usine_materials_screen.dart';
import '../../features/usine/presentation/screens/usine_transformation_screen.dart';
import '../../features/usine/presentation/screens/usine_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

String _getHomeRouteForRole(User? user) {
  final role = user?.userMetadata?['role']?.toString().toLowerCase();
  if (role == 'mairie') return '/mairie';
  if (role == 'usine') return '/usine';
  return '/';
}

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) {
    final session = SupabaseService.client.auth.currentSession;
    final user = session?.user;
    final homeRoute = _getHomeRouteForRole(user);
    final isLoggedIn = session != null;
    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation.startsWith('/register');
    final isGoingToSplash = state.matchedLocation == '/splash';
    final isGoingToProfile = state.matchedLocation == '/profile_selection';
    final isGoingToSuccess = state.matchedLocation == '/success';
    final isGoingToMairieArea = state.matchedLocation.startsWith('/mairie');
    final isGoingToUsineArea = state.matchedLocation.startsWith('/usine');

    if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash && !isGoingToProfile && !isGoingToSuccess) {
      return '/splash';
    }
    
<<<<<<< HEAD
    if (isLoggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash || isGoingToProfile || isGoingToSuccess || state.matchedLocation == '/')) {
      final role = session.user.userMetadata?['role'] ?? 'citoyen';
      if (role == 'pme') {
        return '/dashboard-pme';
      } else if (role == 'ztt') {
        return '/dashboard-ztt';
      } else if (role == 'usine') {
        return '/dashboard-usine';
      }
      return '/dashboard-citoyen';
    }

=======
    if (isLoggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash || isGoingToProfile || isGoingToSuccess)) {
      return homeRoute;
    }

    if (isLoggedIn && homeRoute == '/mairie' && state.matchedLocation == '/') {
      return '/mairie';
    }

    if (isLoggedIn && homeRoute == '/usine' && state.matchedLocation == '/') {
      return '/usine';
    }

    if (isLoggedIn && homeRoute == '/' && isGoingToMairieArea) {
      return '/';
    }

    if (isLoggedIn && homeRoute != '/usine' && isGoingToUsineArea) {
      return homeRoute;
    }
>>>>>>> refs/remotes/origin/main

    return null;
  },
  routes: [
    GoRoute(
      path: '/pme_notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PmeNotificationsScreen(),
    ),
    // Dashboard Shell Route for Usine
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return UsineShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-usine',
              builder: (context, state) => const UsineHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-usine/materials',
              builder: (context, state) => const UsineMaterialsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-usine/transformation',
              builder: (context, state) => const UsineTransformationScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-usine/profile',
              builder: (context, state) => const UsineProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Dashboard Shell Route for ZTT
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ZttShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-ztt',
              builder: (context, state) => const ZttHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-ztt/trier',
              builder: (context, state) => const ZttHistoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-ztt/usines',
              builder: (context, state) => const ZttFactoriesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-ztt/profil',
              builder: (context, state) => const ZttProfilScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/dashboard-ztt/form',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ZttSortingFormScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/profile_selection',
      builder: (context, state) => const ProfileSelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register/:role',
      builder: (context, state) {
        final role = state.pathParameters['role'] ?? 'citoyen';
        return RegisterScreen(role: role);
      },
    ),
    
    // Sub-screens of Dashboard
    GoRoute(
      path: '/subscription',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PmeSubscriptionScreen(),
    ),
    GoRoute(
      path: '/report_waste',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReportWasteScreen(),
    ),

    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CitoyenNotificationsScreen(),
    ),
    GoRoute(
      path: '/mairie/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MairieNotificationsScreen(),
    ),
    GoRoute(
      path: '/usine/matiere_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return UsineMatiereDetailScreen(
          type: extras['type'] ?? '',
          quantity: extras['quantity'] ?? '',
          provenance: extras['provenance'] ?? '',
          date: extras['date'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/usine/commande_detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return UsineCommandeDetailScreen(
          product: extras['product'] ?? '',
          quantity: extras['quantity'] ?? '',
          status: extras['status'] ?? '',
          date: extras['date'] ?? '',
          clientName: extras['clientName'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/usine/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const UsineNotificationsScreen(),
    ),

    // Dashboard Shell Route
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CitoyenShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-citoyen',
              builder: (context, state) => const CitoyenHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/prestation',
              builder: (context, state) => const CitoyenPrestationScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/marketplace',
              builder: (context, state) => const CitoyenMarketplaceScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profil',
              builder: (context, state) => const CitoyenProfilScreen(),
            ),
          ],
        ),
      ],
    ),
<<<<<<< HEAD
    // Dashboard Shell Route for PME
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PmeShellScreen(navigationShell: navigationShell);
=======
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MairieShellScreen(navigationShell: navigationShell);
>>>>>>> refs/remotes/origin/main
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
<<<<<<< HEAD
              path: '/dashboard-pme',
              builder: (context, state) => const PmeHomeScreen(),
=======
              path: '/mairie',
              builder: (context, state) => const MairieDashboardScreen(),
>>>>>>> refs/remotes/origin/main
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
<<<<<<< HEAD
              path: '/dashboard-pme/carte',
              builder: (context, state) => const PmeMapScreen(),
              routes: [
                 GoRoute(
                  path: 'details',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return PmeSignalementDetailScreen(arguments: extra);
                  },
                ),
              ],
=======
              path: '/mairie/carte',
              builder: (context, state) => const MairieMapScreen(),
>>>>>>> refs/remotes/origin/main
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
<<<<<<< HEAD
              path: '/dashboard-pme/clients',
              builder: (context, state) => const PmeClientsScreen(),
=======
              path: '/mairie/stats',
              builder: (context, state) => const MairieStatsScreen(),
>>>>>>> refs/remotes/origin/main
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
<<<<<<< HEAD
              path: '/dashboard-pme/entreprise',
              builder: (context, state) => const PmeEntrepriseScreen(),
=======
              path: '/mairie/profil',
              builder: (context, state) => const MairieProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return UsineShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/usine',
              builder: (context, state) => const UsineMatieresScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/usine/production',
              builder: (context, state) => const UsineProductionScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/usine/commandes',
              builder: (context, state) => const UsineCommandesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/usine/profil',
              builder: (context, state) => const UsineProfilScreen(),
>>>>>>> refs/remotes/origin/main
            ),
          ],
        ),
      ],
    ),
  ],
);
