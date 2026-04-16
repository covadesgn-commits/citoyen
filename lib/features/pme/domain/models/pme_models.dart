import 'package:latlong2/latlong.dart';

// ─── PME Profile ────────────────────────────────────────────────────────────
class PmeProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String? businessName;
  final String? licenseNumber;
  final String? ifu;
  final String? rccm;
  final String? representativeName;
  final String? locationAddress;
  final String? locationCommune;
  final String? locationQuartier;
  final double? latitude;
  final double? longitude;
  final String? zoneId;

  PmeProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.businessName,
    this.licenseNumber,
    this.ifu,
    this.rccm,
    this.representativeName,
    this.locationAddress,
    this.locationCommune,
    this.locationQuartier,
    this.latitude,
    this.longitude,
    this.zoneId,
  });

  factory PmeProfile.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? infoJson,
  ) {
    return PmeProfile(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      businessName: infoJson?['businessname'],
      licenseNumber: infoJson?['licensenumber'],
      ifu: infoJson?['ifu'],
      rccm: infoJson?['rccm'],
      representativeName: infoJson?['representative_name'],
      locationAddress: json['location_address'],
      locationCommune: json['location_commune'],
      locationQuartier: json['location_quartier'],
      latitude: (json['location_coordinates_lat'] as num?)?.toDouble(),
      longitude: (json['location_coordinates_lng'] as num?)?.toDouble(),
      zoneId: infoJson?['zone_id'],
    );
  }
}

// ─── PME Client (citizen subscriber) ────────────────────────────────────────
class PmeClient {
  final String id;          // citizen user id
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String subscriptionStatus; // 'active', 'inactive'
  final String paymentStatus;      // 'A jour', 'En retard', 'Non payé'
  final double monthlyRate;
  final DateTime? lastPaymentDate;
  final DateTime subscribedAt;

  PmeClient({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.subscriptionStatus,
    required this.paymentStatus,
    required this.monthlyRate,
    this.lastPaymentDate,
    required this.subscribedAt,
  });

  factory PmeClient.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>? ?? {};
    final payments = json['payments'] as List<dynamic>? ?? [];

    // Determine payment status from latest payment
    String paymentStatus = 'Non payé';
    DateTime? lastPaymentDate;
    if (payments.isNotEmpty) {
      // Sorted by createdat descending from the query
      final latest = payments.first as Map<String, dynamic>;
      lastPaymentDate = latest['createdat'] != null
          ? DateTime.tryParse(latest['createdat'])
          : null;

      if (lastPaymentDate != null) {
        final daysSince = DateTime.now().difference(lastPaymentDate).inDays;
        if (daysSince <= 35) {
          paymentStatus = 'A jour';
        } else if (daysSince <= 60) {
          paymentStatus = 'En retard';
        } else {
          paymentStatus = 'Non payé';
        }
      }
    }

    return PmeClient(
      id: json['citizen_id'] ?? '',
      name: user['name'] ?? 'Inconnu',
      phone: user['phone'],
      email: user['email'],
      address: user['location_address'],
      subscriptionStatus: json['status'] ?? 'active',
      paymentStatus: paymentStatus,
      monthlyRate: 30000,
      lastPaymentDate: lastPaymentDate,
      subscribedAt: json['createdat'] != null
          ? DateTime.parse(json['createdat'])
          : DateTime.now(),
    );
  }
}

// ─── PME Revenue Stats ───────────────────────────────────────────────────────
class PmeStats {
  final int activeClients;
  final double monthlyRevenue;
  final int totalCollections;
  final double totalBalance;

  const PmeStats({
    required this.activeClients,
    required this.monthlyRevenue,
    required this.totalCollections,
    required this.totalBalance,
  });
}

// ─── Waste Report ────────────────────────────────────────────────────────────
class WasteReport {
  final String id;
  final String citizenId;
  final String? citizenName;
  final String category;
  final String size;
  final String? description;
  final List<String> photos;
  final LatLng location;
  final String? address;
  final String? commune;
  final String? quartier;
  final String status;
  final String priority;
  final DateTime createdAt;

  WasteReport({
    required this.id,
    required this.citizenId,
    this.citizenName,
    required this.category,
    required this.size,
    this.description,
    required this.photos,
    required this.location,
    this.address,
    this.commune,
    this.quartier,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  factory WasteReport.fromJson(Map<String, dynamic> json) {
    final user = json['users'] as Map<String, dynamic>?;
    return WasteReport(
      id: json['id'],
      citizenId: json['citizen_id'] ?? '',
      citizenName: user?['name'],
      category: json['category'] ?? '',
      size: json['size'] ?? 'moyen',
      description: json['description'],
      photos: List<String>.from(json['photos'] ?? []),
      location: LatLng(
        (json['location_coordinates_lat'] as num?)?.toDouble() ?? 0.0,
        (json['location_coordinates_lng'] as num?)?.toDouble() ?? 0.0,
      ),
      address: json['location_address'],
      commune: json['location_commune'],
      quartier: json['location_quartier'],
      status: json['status'] ?? 'reçu',
      priority: json['priority'] ?? 'moyenne',
      createdAt: DateTime.parse(json['createdat']),
    );
  }
}

// ─── PME Notification ────────────────────────────────────────────────────────
class PmeNotification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String type;
  final DateTime createdAt;

  PmeNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.type,
    required this.createdAt,
  });

  factory PmeNotification.fromJson(Map<String, dynamic> json) {
    return PmeNotification(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isread'] ?? false,
      type: json['type'] ?? 'info',
      createdAt: DateTime.parse(json['createdat']),
    );
  }
}
