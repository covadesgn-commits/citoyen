import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/supabase_usine_repository.dart';

final usineRecentReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(usineRepositoryProvider);
  return repository.getRecentReports();
});

final usineProcessedReportsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(usineRepositoryProvider);
  return repository.getProcessedReportsCount();
});

final usinePendingReportsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(usineRepositoryProvider);
  return repository.getPendingReportsCount();
});

final usineMaterialsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(usineRepositoryProvider);
  return repository.getAcceptedMaterials();
});

final usineProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final repository = ref.watch(usineRepositoryProvider);
  return repository.getProfile();
});
