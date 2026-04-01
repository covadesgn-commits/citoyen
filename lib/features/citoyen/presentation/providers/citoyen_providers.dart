import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/supabase_citoyen_repository.dart';

final availablePMEsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(citoyenRepositoryProvider);
  return repository.getAvailablePMEs();
});

final recentReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(citoyenRepositoryProvider);
  return repository.getRecentReports();
});

final recentSubscriptionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(citoyenRepositoryProvider);
  return repository.getRecentSubscriptions();
});

final recentActionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Use .future to wait for initial data without manual watch(provider.future)
  // or use ref.watch and handle AsyncValue.
  // We'll use watch and check for data.
  final reportsAsync = ref.watch(recentReportsProvider);
  final subsAsync = ref.watch(recentSubscriptionsProvider);

  if (reportsAsync is AsyncLoading || subsAsync is AsyncLoading) {
    return []; // Return empty during load or handle in UI
  }

  final reports = reportsAsync.value ?? [];
  final subs = subsAsync.value ?? [];

  final List<Map<String, dynamic>> combined = [];

  // Format Reports
  for (var r in reports) {
    combined.add({
      'type': 'Signalement',
      'description': 'Déchets \${r["category"]} signalé',
      'date': r['createdat'],
      'status': r['status'],
      'icon': 'delete_forever_outlined',
    });
  }

  // Format Subscriptions
  for (var s in subs) {
    combined.add({
      'type': 'Abonnement',
      'description': "Abonné à \${s['users']?['name'] ?? 'PME'}",
      'date': s['createdat'],
      'status': s['status'],
      'icon': 'business_center_outlined',
    });
  }

  // Sort by date (descending)
  combined.sort((a, b) {
    final dateA = a['date'] != null ? DateTime.parse(a['date']) : DateTime(0);
    final dateB = b['date'] != null ? DateTime.parse(b['date']) : DateTime(0);
    return dateB.compareTo(dateA);
  });


  return combined.take(10).toList();
});

final productsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(citoyenRepositoryProvider);
  return repository.getProducts();
});

final reportCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(citoyenRepositoryProvider);
  return repository.getReportCount();
});

final activePMESubscriptionProvider = FutureProvider<String?>((ref) async {
  final repository = ref.watch(citoyenRepositoryProvider);
  return repository.getActivePMESubscription();
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final repository = ref.watch(citoyenRepositoryProvider);
  return repository.getProfile();
});
