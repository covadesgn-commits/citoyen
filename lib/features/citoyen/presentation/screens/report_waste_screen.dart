import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/supabase_citoyen_repository.dart';
import '../../../../core/theme/app_colors.dart';

class ReportWasteScreen extends ConsumerStatefulWidget {
  const ReportWasteScreen({super.key});

  @override
  ConsumerState<ReportWasteScreen> createState() => _ReportWasteScreenState();
}

class _ReportWasteScreenState extends ConsumerState<ReportWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'plastique';
  String _size = 'moyen';
  String _priority = 'moyenne';
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  bool _useAI = false; // New: AI Toggle state (Désactivé)
  double _lat = 0.0;
  double _lng = 0.0;
  
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = ['plastique', 'verre', 'papier', 'organique', 'electronique'];
  final List<String> _sizes = ['petit', 'moyen', 'grand', 'très_grand'];
  final List<String> _priorities = ['faible', 'moyenne', 'haute', 'urgente'];

  String _formatCategory(String cat) {
    switch(cat) {
      case 'plastique': return 'Plastique';
      case 'verre': return 'Verre';
      case 'papier': return 'Papier / Carton';
      case 'organique': return 'Organique';
      case 'electronique': return 'Électronique';
      default: return cat;
    }
  }

  String _formatSize(String sz) {
    switch(sz) {
      case 'petit': return 'Petit (Sac)';
      case 'moyen': return 'Moyen (Poubelle)';
      case 'grand': return 'Grand (Conteneur)';
      case 'très_grand': return 'Très Grand';
      default: return sz;
    }
  }

  String _formatPriority(String pr) {
    switch(pr) {
      case 'faible': return 'Faible';
      case 'moyenne': return 'Moyenne';
      case 'haute': return 'Haute';
      case 'urgente': return 'Urgente';
      default: return pr;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image == null) return;
      if (!mounted) return;
      
      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur d'accès à la caméra: $e")));
      }
    }
  }

  Future<void> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les services de localisation sont désactivés.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ignore: use_build_context_synchronously
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les permissions de localisation sont refusées.')));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // ignore: use_build_context_synchronously
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Les permissions sont définitivement refusées.')));
      return;
    } 

    setState(() => _isLoadingLocation = true);
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _addressController.text = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez ajouter une photo du déchet.')));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(citoyenRepositoryProvider);
      
      await repo.reportWaste(
        category: _category,
        size: _size,
        priority: _priority,
        description: _descController.text,
        address: _addressController.text.isEmpty ? "Position détectée" : _addressController.text,
        lat: _lat,
        lng: _lng,
        imageFile: _selectedImage!,
      );

      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signalement envoyé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLostData();
  }

  Future<void> _checkLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) return;
    if (response.file != null && mounted) {
      setState(() {
        _selectedImage = File(response.file!.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Signaler un déchet', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AI Toggle Switch
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Remplissage intelligent',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Analyse automatique par IA (Bientôt disponible)',
                            style: TextStyle(fontSize: 12, color: AppColors.getTextSecondaryColor(context)),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useAI,
                      activeColor: AppColors.primary,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (BuildContext ctx) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                              title: const Text('Prendre une photo'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library, color: AppColors.primary),
                              title: const Text('Choisir dans la galerie'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  );
                },
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.getBorderColor(context), width: 2),
                    image: _selectedImage != null
                        ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (_selectedImage == null)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
                              ),
                              const SizedBox(height: 12),
                              const Text('Ajouter une photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      if (_selectedImage != null)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                              radius: 16,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                onPressed: () => setState(() => _selectedImage = null),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Catégorie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) => ChoiceChip(
                  label: Text(_formatCategory(cat)),
                  selected: _category == cat,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _category == cat ? Colors.white : AppColors.getTextSecondaryColor(context),
                    fontWeight: _category == cat ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.getSurfaceColor(context),
                  onSelected: (selected) {
                    if (selected) setState(() => _category = cat);
                  },
                )).toList(),
              ),
              const SizedBox(height: 24),

              const Text('Taille estimée', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sizes.map((sz) => ChoiceChip(
                  label: Text(_formatSize(sz)),
                  selected: _size == sz,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _size == sz ? Colors.white : AppColors.getTextSecondaryColor(context),
                    fontWeight: _size == sz ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.getSurfaceColor(context),
                  onSelected: (selected) {
                    if (selected) setState(() => _size = sz);
                  },
                )).toList(),
              ),
              const SizedBox(height: 24),

              const Text('Urgence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _priorities.map((pr) => ChoiceChip(
                  label: Text(_formatPriority(pr)),
                  selected: _priority == pr,
                  selectedColor: _priority == 'urgente' ? Colors.red : AppColors.primary,
                  labelStyle: TextStyle(
                    color: _priority == pr ? Colors.white : AppColors.getTextSecondaryColor(context),
                    fontWeight: _priority == pr ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppColors.getSurfaceColor(context),
                  onSelected: (selected) {
                    if (selected) setState(() => _priority = pr);
                  },
                )).toList(),
              ),
              const SizedBox(height: 24),

              const Text('Localisation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse de collecte',
                  filled: true,
                  fillColor: AppColors.getSurfaceColor(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                  suffixIcon: _isLoadingLocation 
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location, color: AppColors.primary),
                          onPressed: _getCurrentPosition,
                          tooltip: 'Utiliser ma position',
                        ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Veuillez entrer ou détecter une adresse' : null,
              ),
              const SizedBox(height: 24),

              const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Précisions supplémentaires (optionnel)',
                  filled: true,
                  fillColor: AppColors.getSurfaceColor(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 40),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Envoyer le signalement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
