import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/supabase_mairie_repository.dart';

final mairieRecentReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(mairieRepositoryProvider);
  return repository.getRecentReports();
});

final mairieTotalReportsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(mairieRepositoryProvider);
  return repository.getTotalReportsCount();
});

final mairiePendingReportsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(mairieRepositoryProvider);
  return repository.getPendingReportsCount();
});

final mairieResolvedReportsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(mairieRepositoryProvider);
  return repository.getResolvedReportsCount();
});

final mairieServicesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(mairieRepositoryProvider);
  return repository.getMunicipalServices();
});

final mairieProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final repository = ref.watch(mairieRepositoryProvider);
  return repository.getProfile();
});

final mairieRecentActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final reports = await ref.watch(mairieRecentReportsProvider.future);

  return reports.map((report) {
    final status = (report['status'] ?? 'nouveau').toString();
    final category = (report['category'] ?? 'déchets').toString();
    final address = (report['location_address'] ?? 'Localisation non renseignée').toString();

    return {
      'type': 'Signalement',
      'title': category,
      'description': '$status - $address',
      'date': report['createdat'],
      'priority': report['priority'] ?? 'moyenne',
    };
  }).toList();
});
