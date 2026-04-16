import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class CitoyenPrestationScreen extends ConsumerStatefulWidget {
  const CitoyenPrestationScreen({super.key});

  @override
  ConsumerState<CitoyenPrestationScreen> createState() => _CitoyenPrestationScreenState();
}

class _CitoyenPrestationScreenState extends ConsumerState<CitoyenPrestationScreen> {
  final _peopleController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedEvent;
  String? _selectedConsumption;

  final List<String> _events = [
    'Mariage',
    'Baptême',
    'Conférence',
    'Fête',
    'Remise de diplôme',
    'Autres'
  ];

  final List<Map<String, dynamic>> _consumptions = [
    {'title': 'Jus / Boissons en sachets', 'icon': Icons.local_drink_outlined},
    {'title': 'Eau en sachets', 'icon': Icons.water_drop_outlined},
    {'title': 'Nourriture emballée (plastique)', 'icon': Icons.inventory_2_outlined},
    {'title': 'Boissons en verre', 'icon': Icons.wine_bar_outlined},
    {'title': 'Mixte', 'icon': Icons.restaurant_outlined},
  ];

  @override
  void dispose() {
    _peopleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: Connect to backend
    if (_selectedEvent == null || _selectedConsumption == null || _peopleController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recherche de PME en cours...')),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Prestation de service', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Organisez un événement et trouvez une PME pour gérer vos déchets",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle("Type d'événement *"),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _events.map((event) {
                final isSelected = _selectedEvent == event;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEvent = event),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48 - 12) / 2, // 2 columns
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(context),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.getBorderColor(context),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      event,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle("Type de consommation * (déchets majoritaires)"),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _consumptions.map((consumption) {
                final isSelected = _selectedConsumption == consumption['title'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedConsumption = consumption['title']),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(context),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.getBorderColor(context),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary.withValues(alpha: 0.1) 
                                : AppColors.getBackgroundColor(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            consumption['icon'], 
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          consumption['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle("Nombre approximatif de personnes *"),
            CustomTextField(
              controller: _peopleController,
              hintText: 'Ex: 150',
              prefixIcon: Icons.people_outline,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("Lieu de l'événement *"),
            CustomTextField(
              controller: _locationController,
              hintText: 'Adresse complète',
              prefixIcon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 48),
            PrimaryButton(
              text: 'Rechercher des PME',
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
