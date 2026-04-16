import '../models/pme_models.dart';

abstract class PmeRepository {
  Future<PmeProfile?> getPmeProfile();
  Future<List<WasteReport>> getWasteReports();
  Future<List<PmeClient>> getPmeClients();
  Future<PmeStats> getPmeStats();
  Future<List<PmeNotification>> getNotifications();
  Future<void> logout();
}
