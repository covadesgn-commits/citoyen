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

// Mairie Screens
import '../../features/mairie/presentation/screens/mairie_dashboard_screen.dart';
import '../../features/mairie/presentation/screens/mairie_notifications_screen.dart';
import '../../features/mairie/presentation/screens/mairie_map_screen.dart';
import '../../features/mairie/presentation/screens/mairie_stats_screen.dart';
import '../../features/mairie/presentation/screens/mairie_profil_screen.dart';
import '../../features/mairie/presentation/screens/mairie_shell_screen.dart';

// Usine Screens
import '../../features/usine/presentation/screens/usine_shell_screen.dart';
import '../../features/usine/presentation/screens/usine_matieres_screen.dart';
import '../../features/usine/presentation/screens/usine_production_screen.dart';
import '../../features/usine/presentation/screens/usine_commandes_screen.dart';
import '../../features/usine/presentation/screens/usine_profil_screen.dart';
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

// ZTT Screens
import '../../features/ztt/presentation/screens/ztt_shell_screen.dart';
import '../../features/ztt/presentation/screens/ztt_home_screen.dart';
import '../../features/ztt/presentation/screens/ztt_history_screen.dart';
import '../../features/ztt/presentation/screens/ztt_factory_screen.dart';
import '../../features/ztt/presentation/screens/ztt_profil_screen.dart';
import '../../features/ztt/presentation/screens/ztt_sorting_form_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

String _getHomeRouteForRole(User? user) {
  final role = user?.userMetadata?['role']?.toString().toLowerCase() ?? 'citoyen';
  if (role == 'mairie') return '/mairie';
  if (role == 'usine') return '/usine';
  if (role == 'pme') return '/dashboard-pme';
  if (role == 'ztt') return '/dashboard-ztt';
  return '/dashboard-citoyen';
}

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) {
    final session = SupabaseService.client.auth.currentSession;
    final isLoggedIn = session != null;
    final user = session?.user;
    final homeRoute = _getHomeRouteForRole(user);
    
    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation.startsWith('/register');
    final isGoingToSplash = state.matchedLocation == '/splash';
    final isGoingToProfile = state.matchedLocation == '/profile_selection';
    final isGoingToSuccess = state.matchedLocation == '/success';

    if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash && !isGoingToProfile && !isGoingToSuccess) {
      return '/splash';
    }
    
    if (isLoggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash || isGoingToProfile || isGoingToSuccess || state.matchedLocation == '/')) {
      return homeRoute;
    }

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

    // Dashboard Shell Route for Mairie
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MairieShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mairie',
              builder: (context, state) => const MairieDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mairie/carte',
              builder: (context, state) => const MairieMapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mairie/stats',
              builder: (context, state) => const MairieStatsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mairie/profil',
              builder: (context, state) => const MairieProfilScreen(),
            ),
          ],
        ),
      ],
    ),

    // Dashboard Shell Route for PME
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PmeShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-pme',
              builder: (context, state) => const PmeHomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
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
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-pme/clients',
              builder: (context, state) => const PmeClientsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard-pme/entreprise',
              builder: (context, state) => const PmeEntrepriseScreen(),
            ),
          ],
        ),
      ],
    ),

    // Dashboard Shell Route for Citizens
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
    
    // Sub-screens
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
    GoRoute(
      path: '/pme_notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PmeNotificationsScreen(),
    ),
  ],
);
