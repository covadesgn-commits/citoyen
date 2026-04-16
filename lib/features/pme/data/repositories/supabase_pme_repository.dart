import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/pme_models.dart';
import '../../domain/repositories/pme_repository.dart';

class SupabasePmeRepository implements PmeRepository {
  final SupabaseClient _supabase;

  SupabasePmeRepository(this._supabase);

  String? get _userId => _supabase.auth.currentUser?.id;

  // ─── Profile ───────────────────────────────────────────────────────────────
  @override
  Future<PmeProfile?> getPmeProfile() async {
    final uid = _userId;
    if (uid == null) return null;

    final userRes = await _supabase
        .from('users')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (userRes == null) return null;

    final infoRes = await _supabase
        .from('pme_info')
        .select()
        .eq('user_id', uid)
        .maybeSingle();

    return PmeProfile.fromJson(userRes, infoRes);
  }

  // ─── Waste Reports (filtered to this PME) ──────────────────────────────────
  @override
  Future<List<WasteReport>> getWasteReports() async {
    final uid = _userId;
    if (uid == null) return [];

    final response = await _supabase
        .from('citizen_reports')
        .select('*, users!citizen_reports_citizen_id_fkey(name, phone)')
        .eq('assignedpmeid', uid)
        .order('createdat', ascending: false);

    return (response as List).map((json) => WasteReport.fromJson(json)).toList();
  }

  // ─── Clients (citizen_subscriptions + users + payments) ────────────────────
  @override
  Future<List<PmeClient>> getPmeClients() async {
    final uid = _userId;
    if (uid == null) return [];

    // Fetch subscriptions with citizen user info
    final subsRes = await _supabase
        .from('citizen_subscriptions')
        .select('*, users!citizen_subscriptions_citizen_id_fkey(id, name, phone, email, location_address)')
        .eq('pme_id', uid)
        .order('createdat', ascending: false);

    final subs = subsRes as List;

    // For each subscriber, get their most recent payment to this PME
    final List<PmeClient> clients = [];
    for (final sub in subs) {
      final citizenId = sub['citizen_id'];
      List<dynamic> payments = [];
      if (citizenId != null) {
        payments = await _supabase
            .from('payments')
            .select('createdat, amount, status')
            .eq('user_id', citizenId)
            .eq('status', 'completed')
            .order('createdat', ascending: false)
            .limit(1);
      }
      clients.add(PmeClient.fromJson({...sub, 'payments': payments}));
    }

    return clients;
  }

  // ─── Stats for Home Dashboard ───────────────────────────────────────────────
  @override
  Future<PmeStats> getPmeStats() async {
    final uid = _userId;
    if (uid == null) {
      return const PmeStats(
        activeClients: 0,
        monthlyRevenue: 0,
        totalCollections: 0,
        totalBalance: 0,
      );
    }

    // Active clients count
    final subsRes = await _supabase
        .from('citizen_subscriptions')
        .select('id')
        .eq('pme_id', uid)
        .eq('status', 'active');
    final activeClients = (subsRes as List).length;

    // Total collections assigned to this PME
    final collectionsRes = await _supabase
        .from('citizen_reports')
        .select('id')
        .eq('assignedpmeid', uid);
    final totalCollections = (collectionsRes as List).length;

    // Revenue this month from payments
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final paymentsRes = await _supabase
        .from('payments')
        .select('amount')
        .eq('user_id', uid)
        .eq('status', 'completed')
        .gte('createdat', startOfMonth);
    final monthlyRevenue = (paymentsRes as List)
        .fold<double>(0, (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0));

    // Total balance = all completed payments ever received
    final totalPaymentsRes = await _supabase
        .from('payments')
        .select('amount')
        .eq('user_id', uid)
        .eq('status', 'completed');
    final totalBalance = (totalPaymentsRes as List)
        .fold<double>(0, (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0));

    return PmeStats(
      activeClients: activeClients,
      monthlyRevenue: monthlyRevenue,
      totalCollections: totalCollections,
      totalBalance: totalBalance,
    );
  }

  // ─── Notifications ──────────────────────────────────────────────────────────
  @override
  Future<List<PmeNotification>> getNotifications() async {
    final uid = _userId;
    if (uid == null) return [];

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', uid)
        .order('createdat', ascending: false);

    return (response as List).map((json) => PmeNotification.fromJson(json)).toList();
  }

  // ─── Auth ───────────────────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
