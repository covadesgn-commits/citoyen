import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/citoyen_providers.dart';
import '../../data/repositories/supabase_citoyen_repository.dart';
import '../../../../core/theme/app_colors.dart';

class PmeSubscriptionScreen extends ConsumerStatefulWidget {
  const PmeSubscriptionScreen({super.key});

  @override
  ConsumerState<PmeSubscriptionScreen> createState() => _PmeSubscriptionScreenState();
}

class _PmeSubscriptionScreenState extends ConsumerState<PmeSubscriptionScreen> {
  bool _isCheckingPermission = true;
  bool _hasPermission = false;
  Position? _currentPosition;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() {
      _isCheckingPermission = true;
      _errorMessage = null;
    });

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Les services de localisation sont désactivés.';
          _isCheckingPermission = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'La permission de localisation a été refusée.';
            _isCheckingPermission = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Les permissions de localisation sont définitivement refusées. Veuillez les activer dans les paramètres.';
          _isCheckingPermission = false;
        });
        return;
      }

      // If we reach here, permissions are granted.
      // Getting the current position
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _hasPermission = true;
        _isCheckingPermission = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération de la position : $e';
        _isCheckingPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Vérification de la localisation...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.getBackgroundColor(context), foregroundColor: AppColors.textPrimary, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off_outlined, size: 64, color: AppColors.error.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checkLocationPermission,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final availablePMEs = ref.watch(availablePMEsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text("S'abonner à une PME", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_hasPermission && _currentPosition != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Tooltip(
                message: 'Position : ${_currentPosition!.latitude.toStringAsFixed(2)}, ${_currentPosition!.longitude.toStringAsFixed(2)}',
                child: const Icon(Icons.location_on, size: 20, color: Colors.green),
              ),
            ),
        ],
      ),
      body: availablePMEs.when(
        data: (pmes) {
          if (pmes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 80, color: AppColors.getBorderColor(context)),
                    const SizedBox(height: 24),
                    const Text(
                      'Aucune PME disponible pour le moment dans votre zone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18, 
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Revenez bientôt ! Nous étendons notre réseau de collecte.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.getTextSecondaryColor(context)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: pmes.length,
            itemBuilder: (context, index) {
              final pme = pmes[index];
              final info = (pme['pme_info'] != null && (pme['pme_info'] as List).isNotEmpty) 
                  ? pme['pme_info'][0] 
                  : {};

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.business, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pme['name'] ?? 'PME Inconnue',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        pme['location_address'] ?? 'Adresse non précisée',
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getBorderColor(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _InfoColumn(title: 'Spécialité', value: info['businessName'] ?? 'Général'),
                            _InfoColumn(title: 'IFU', value: info['ifu'] ?? '-'),
                            _InfoColumn(title: 'RCCM', value: info['rccm'] ?? '-'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () => _confirmSubscription(context, ref, pme),
                          child: const Text('Sélectionner cette PME', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Erreur: \$err')),
      ),
    );
  }

  void _confirmSubscription(BuildContext context, WidgetRef ref, Map<String, dynamic> pme) {
    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmation'),
        content: Text("Voulez-vous vraiment vous abonner aux services de \${pme['name']} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextDialog),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(contextDialog); // Close dialog
              await _subscribe(context, ref, pme['id']);
            },
            child: const Text('Confirmer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe(BuildContext context, WidgetRef ref, String pmeId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
      
      final repo = ref.read(citoyenRepositoryProvider);
      await repo.subscribeToPME(pmeId);
      ref.invalidate(recentSubscriptionsProvider);
      
      if (context.mounted) {
        Navigator.pop(context); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Abonnement réussi !'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // return to dashboard
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: \$e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _InfoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: AppColors.getTextSecondaryColor(context), fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}

