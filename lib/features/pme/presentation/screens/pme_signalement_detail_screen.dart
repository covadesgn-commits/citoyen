import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class PmeSignalementDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const PmeSignalementDetailScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    // We use arguments if navigating from list, otherwise fallback for design
    final citoyenName = arguments?['citoyen'] ?? 'Mamadou Bah';
    final location = arguments?['location'] ?? 'Avenue des Martyrs, Ratoma';
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text('Signalements', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/pme_notifications'),
            icon: const Icon(FontAwesomeIcons.bell, color: AppColors.textPrimary, size: 20),
          )
        ],
        // GoRouter usually sets leading automatically if nested, but here we enforce nothing 
        // to do the custom "< Retour" block below if desired, or let AppBar handle back.
        // We will build a custom back button exactly like Figma inside the body.
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                label: const Text('Retour', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Image Card
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
                image: DecorationImage(
                  image: AssetImage(arguments?['image'] ?? 'asset/img1.jpeg'),
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[200],
              ),
              child: (arguments?['image'] == null && !['asset/img1.jpeg', 'asset/img2.jpeg', 'asset/img3.jpeg'].contains(arguments?['image'])) 
                ? const Icon(Icons.cleaning_services, size: 80, color: Colors.white54)
                : null,
            ),
            
            const SizedBox(height: 24),
            
            // Category Badge
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5), // Purple light
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.build_circle_outlined, size: 16, color: Color(0xFF9C27B0)), // Purple
                    SizedBox(width: 8),
                    Text(
                      'Prestation de service',
                      style: TextStyle(color: Color(0xFF9C27B0), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info List
            _buildDetailItem(
              icon: Icons.person_outline,
              label: 'Citoyen',
              value: citoyenName,
            ),
            const SizedBox(height: 20),
            
            _buildDetailItem(
              icon: Icons.location_on_outlined,
              label: 'Localisation',
              value: location,
            ),
            const SizedBox(height: 20),
            
            _buildDetailItem(
              icon: Icons.description_outlined,
              label: 'Description',
              value: 'Nettoyage complet de la cour et évacuation des déchets végétaux',
            ),
            const SizedBox(height: 20),
            
            _buildDetailItem(
              icon: Icons.access_time,
              label: 'Signalé',
              value: 'Aujourd\'hui, 14:30',
            ),
            
            const SizedBox(height: 40),
            
            // Action button (Not fully shown in image, but standard UX)
            ElevatedButton(
              onPressed: () {
                // TODO: Action on the report
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action non implémentée')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Prendre en charge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[400], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
