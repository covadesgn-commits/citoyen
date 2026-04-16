import 'package:flutter_test/flutter_test.dart';

// Simulating the user session and metadata
class MockUserSession {
  final Map<String, dynamic>? userMetadata;
  MockUserSession({this.userMetadata});
}

// Extracting the pure logic from router.dart for testing
String? calculateRedirect(String matchedLocation, MockUserSession? session) {
  final isLoggedIn = session != null;
  final isGoingToLogin = matchedLocation == '/login';
  final isGoingToRegister = matchedLocation.startsWith('/register');
  final isGoingToSplash = matchedLocation == '/splash';
  final isGoingToProfile = matchedLocation == '/profile_selection';
  final isGoingToSuccess = matchedLocation == '/success';

  if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash && !isGoingToProfile && !isGoingToSuccess) {
    return '/splash';
  }
  
  if (isLoggedIn && (isGoingToLogin || isGoingToRegister || isGoingToSplash || isGoingToProfile || isGoingToSuccess || matchedLocation == '/')) {
    final role = session.userMetadata?['role'] ?? 'citoyen';
    if (role == 'pme') {
      return '/pme';
    }
    if (matchedLocation == '/') return null; // Already at home
    return '/';
  }

  return null;
}

void main() {
  group('Router Redirection Rules', () {
    test('Unauthenticated user trying to access secure route goes to /splash', () {
      expect(calculateRedirect('/', null), '/splash');
      expect(calculateRedirect('/pme', null), '/splash');
    });

    test('PME user trying to access root / is redirected to /pme', () {
      final pmeSession = MockUserSession(userMetadata: {'role': 'pme'});
      expect(calculateRedirect('/', pmeSession), '/pme');
    });

    test('PME user trying to access login page is redirected to /pme', () {
      final pmeSession = MockUserSession(userMetadata: {'role': 'pme'});
      expect(calculateRedirect('/login', pmeSession), '/pme');
    });

    test('Citoyen user trying to access root / stays on /', () {
      final citoyenSession = MockUserSession(userMetadata: {'role': 'citoyen'});
      expect(calculateRedirect('/', citoyenSession), null);
    });
  });
}
