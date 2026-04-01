import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) {
    final session = SupabaseService.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isGoingToLogin = state.matchedLocation == '/login';
    final isGoingToRegister = state.matchedLocation.startsWith('/register');
    final isGoingToSplash = state.matchedLocation == '/splash';
    final isGoingToProfile = state.matchedLocation == '/profile_selection';
    final isGoingToSuccess = state.matchedLocation == '/success';

    if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash && !isGoingToProfile && !isGoingToSuccess) {
      return '/splash';
    }
    
    if (isLoggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash || isGoingToProfile || isGoingToSuccess)) {
      return '/';
    }

    return null;
  },
  routes: [
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

    // Dashboard Shell Route
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CitoyenShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
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
  ],
);
