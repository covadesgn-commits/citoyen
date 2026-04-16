import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/pme_models.dart';
import '../../domain/repositories/pme_repository.dart';
import '../../data/repositories/supabase_pme_repository.dart';

final pmeRepositoryProvider = Provider<PmeRepository>((ref) {
  return SupabasePmeRepository(Supabase.instance.client);
});

final pmeProfileProvider = FutureProvider<PmeProfile?>((ref) async {
  return ref.watch(pmeRepositoryProvider).getPmeProfile();
});

final wasteReportsProvider = FutureProvider<List<WasteReport>>((ref) async {
  return ref.watch(pmeRepositoryProvider).getWasteReports();
});

final pmeClientsProvider = FutureProvider<List<PmeClient>>((ref) async {
  return ref.watch(pmeRepositoryProvider).getPmeClients();
});

final pmeStatsProvider = FutureProvider<PmeStats>((ref) async {
  return ref.watch(pmeRepositoryProvider).getPmeStats();
});

final pmeNotificationsProvider = FutureProvider<List<PmeNotification>>((ref) async {
  return ref.watch(pmeRepositoryProvider).getNotifications();
});

final pmeReportsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) return Stream.value([]);

  return supabase
      .from('citizen_reports')
      .stream(primaryKey: ['id'])
      .eq('assignedpmeid', uid)
      .order('createdat');
});
