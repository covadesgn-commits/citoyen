import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String role;
  
  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Shared controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _localisationController = TextEditingController();
  final _contactController = TextEditingController();
  final _ifuController = TextEditingController();
  final _rccmController = TextEditingController();
  final _responsableController = TextEditingController();
  
  // Citoyen specific controllers
  final _nomCompletController = TextEditingController();
  
  // PME specific controllers
  final _raisonSocialeController = TextEditingController();
  
  // ZTT specific controllers
  final _nomZttController = TextEditingController();
  final _gestionnaireController = TextEditingController();
  
  // Usine specific controllers
  final _nomUsineController = TextEditingController();
  final _matieresController = TextEditingController();
  
  // Mairie specific controllers
  final _communeController = TextEditingController();
  final _codeMairieController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir correctement tous les champs requis.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: AppColors.error),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      
      final Map<String, dynamic> metadata = {'role': widget.role};
      
      // Map data based on role
      switch (widget.role) {
        case 'citoyen':
          metadata['full_name'] = _nomCompletController.text.trim();
          metadata['contact_phone'] = _contactController.text.trim();
          metadata['location_address'] = _localisationController.text.trim();
          break;
        case 'pme':
          metadata['business_name'] = _raisonSocialeController.text.trim();
          metadata['ifu'] = _ifuController.text.trim();
          metadata['rccm'] = _rccmController.text.trim();
          metadata['representative_name'] = _responsableController.text.trim();
          metadata['contact_phone'] = _contactController.text.trim();
          metadata['location_address'] = _localisationController.text.trim();
          break;
        case 'ztt':
          metadata['center_name'] = _nomZttController.text.trim();
          metadata['manager_name'] = _gestionnaireController.text.trim();
          metadata['ifu'] = _ifuController.text.trim();
          metadata['contact_phone'] = _contactController.text.trim();
          metadata['location_address'] = _localisationController.text.trim();
          break;
        case 'usine':
          metadata['factory_name'] = _nomUsineController.text.trim();
          metadata['materials_accepted'] = _matieresController.text.trim();
          metadata['manager_name'] = _responsableController.text.trim();
          metadata['ifu'] = _ifuController.text.trim();
          metadata['rccm'] = _rccmController.text.trim();
          metadata['contact_phone'] = _contactController.text.trim();
          metadata['location_address'] = _localisationController.text.trim();
          break;
        case 'mairie':
          metadata['commune'] = _communeController.text.trim();
          metadata['mairie_code'] = _codeMairieController.text.trim();
          metadata['manager_name'] = _responsableController.text.trim();
          metadata['contact_phone'] = _contactController.text.trim();
          break;
      }

      await authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        metadata: metadata,
      );
      if (mounted) {
        _clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // We can either redirect or let the user see the cleared fields.
        // The user asked to clear fields, so maybe they want to see they are cleared.
        // But usually redirection is better. I'll redirect after a short delay.
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/success');
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        String msg = "Échec de l'inscription : ${e.message}";
        if (e.message.toLowerCase().contains('already registered') || 
            e.message.toLowerCase().contains('already exists')) {
          msg = 'Un compte avec cet email existe déjà.';
        } else if (e.message.toLowerCase().contains('password')) {
          msg = 'Le mot de passe doit contenir au moins 6 caractères.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Une erreur inattendue est survenue : ${e.toString()}"),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _localisationController.clear();
    _contactController.clear();
    _ifuController.clear();
    _rccmController.clear();
    _responsableController.clear();
    _nomCompletController.clear();
    _raisonSocialeController.clear();
    _nomZttController.clear();
    _gestionnaireController.clear();
    _nomUsineController.clear();
    _matieresController.clear();
    _communeController.clear();
    _codeMairieController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _localisationController.dispose();
    _contactController.dispose();
    _ifuController.dispose();
    _rccmController.dispose();
    _responsableController.dispose();
    _nomCompletController.dispose();
    _raisonSocialeController.dispose();
    _nomZttController.dispose();
    _gestionnaireController.dispose();
    _nomUsineController.dispose();
    _matieresController.dispose();
    _communeController.dispose();
    _codeMairieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String roleTitle;
    switch(widget.role) {
      case 'pme': roleTitle = 'PME / Entreprise'; break;
      case 'citoyen': roleTitle = 'Citoyen'; break;
      case 'ztt': roleTitle = 'Zone de Transit'; break;
      case 'usine': roleTitle = 'Usine'; break;
      case 'mairie': roleTitle = 'Mairie'; break;
      default: roleTitle = 'Inscription';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile_selection'),
        ),
        title: Text('Inscription - $roleTitle'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Veuillez remplir vos informations en tant que $roleTitle.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSocialLoginSection(),
                    const SizedBox(height: 24),
                    
                    // Dynamic Fields
                    if (widget.role == 'citoyen') ...[
                      CustomTextField(
                        controller: _nomCompletController,
                        hintText: 'Nom complet',
                        prefixIcon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Adresse email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _contactController,
                        hintText: 'Contact / Téléphone',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _localisationController,
                        hintText: 'Adresse',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                    ] else if (widget.role == 'pme') ...[
                      CustomTextField(
                        controller: _raisonSocialeController,
                        hintText: "Nom de l'entreprise (Raison sociale)",
                        prefixIcon: Icons.business_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _ifuController,
                        hintText: 'IFU',
                        prefixIcon: Icons.numbers_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _rccmController,
                        hintText: 'RCCM',
                        prefixIcon: Icons.receipt_long_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _responsableController,
                        hintText: 'Nom du représentant',
                        prefixIcon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _contactController,
                        hintText: 'Contact',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Adresse email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _localisationController,
                        hintText: 'Localisation / Adresse',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                    ] else if (widget.role == 'ztt') ...[
                      CustomTextField(
                        controller: _nomZttController,
                        hintText: 'Nom de la ZTT',
                        prefixIcon: Icons.home_work_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _gestionnaireController,
                        hintText: 'Nom du gestionnaire',
                        prefixIcon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _ifuController,
                        hintText: 'Document IFU',
                        prefixIcon: Icons.file_present_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _contactController,
                        hintText: 'Numéro de contact',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Adresse email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _localisationController,
                        hintText: 'Adresse / Emplacement',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                    ] else if (widget.role == 'usine') ...[
                      CustomTextField(
                        controller: _nomUsineController,
                        hintText: "Nom de l'usine (Raison sociale)",
                        prefixIcon: Icons.factory_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _matieresController,
                        hintText: "Matières recyclables traitées",
                        prefixIcon: Icons.recycling_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _responsableController,
                        hintText: 'Nom du responsable',
                        prefixIcon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _ifuController,
                        hintText: 'IFU',
                        prefixIcon: Icons.numbers_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _rccmController,
                        hintText: 'RCCM',
                        prefixIcon: Icons.receipt_long_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Adresse email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _contactController,
                        hintText: 'Contact / Téléphone',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _localisationController,
                        hintText: 'Localisation',
                        prefixIcon: Icons.location_on_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                    ] else if (widget.role == 'mairie') ...[
                      CustomTextField(
                        controller: _communeController,
                        hintText: 'Commune / Mairie affiliée',
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _codeMairieController,
                        hintText: "Code Mairie (Code d'identification)",
                        prefixIcon: Icons.qr_code_outlined,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _responsableController,
                        hintText: 'Nom du responsable',
                        prefixIcon: Icons.person_outline,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _contactController,
                        hintText: 'Contact direct',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Adresse email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Mot de passe',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirmer le mot de passe',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: "S'inscrire",
                      isLoading: _isLoading,
                      onPressed: _register,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Déjà un compte ? '),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[400])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OU',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[400])),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'S\'inscrire avec',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _socialButton(
              logoPath: 'asset/google_logo.png',
              onTap: () => _handleSocialSignIn(OAuthProvider.google),
            ),
            _socialButton(
              logoPath: 'asset/facebook_logo.png',
              onTap: () => _handleSocialSignIn(OAuthProvider.facebook),
            ),
            _socialButton(
              logoPath: 'asset/github_logo.png',
              onTap: () => _handleSocialSignIn(OAuthProvider.github),
            ),
          ],
        ),
      ],
    );
  }

  Widget _socialButton({required String logoPath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          logoPath,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future<void> _handleSocialSignIn(OAuthProvider provider) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithOAuth(provider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Échec de la connexion sociale : ${e.toString()}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
