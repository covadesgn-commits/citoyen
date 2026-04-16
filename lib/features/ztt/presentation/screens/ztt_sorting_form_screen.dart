import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/ztt/presentation/providers/ztt_providers.dart';
import 'package:mobile/features/ztt/domain/models/ztt_report.dart';
import '../../../../core/utils/error_handler.dart';

class ZttSortingFormScreen extends ConsumerStatefulWidget {
  const ZttSortingFormScreen({super.key});

  @override
  ConsumerState<ZttSortingFormScreen> createState() => _ZttSortingFormScreenState();
}

class _ZttSortingFormScreenState extends ConsumerState<ZttSortingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _totalWeightController = TextEditingController();
  
  final Map<String, TextEditingController> _typeControllers = {
    'Plastique': TextEditingController(),
    'Organique': TextEditingController(),
    'Verre': TextEditingController(),
    'Carton': TextEditingController(),
    'Fer / Métal': TextEditingController(),
    'Débris': TextEditingController(),
    'Sans intérêt': TextEditingController(),
  };

  final Map<String, Color> _typeColors = {
    'Plastique': const Color(0xFF00E676),
    'Organique': const Color(0xFFFF9800),
    'Verre': const Color(0xFF2196F3),
    'Carton': const Color(0xFFD97706),
    'Fer / Métal': const Color(0xFF64748B),
    'Débris': const Color(0xFFEF4444),
    'Sans intérêt': const Color(0xFFCBD5E1),
  };

  final List<String> _lieux = [
    'Sélectionner un lieu',
    'Ratoma',
    'Matoto',
    'Kaloum',
    'Dixinn',
    'Matam'
  ];

  String _selectedLieu = 'Sélectionner un lieu';
  String? _selectedFactoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to type controllers to update total weight
    for (var controller in _typeControllers.values) {
      controller.addListener(_updateTotalWeight);
    }
  }

  void _updateTotalWeight() {
    double total = 0;
    for (var controller in _typeControllers.values) {
      final val = double.tryParse(controller.text) ?? 0;
      total += val;
    }
    setState(() {
      _totalWeightController.text = total > 0 ? total.toStringAsFixed(1) : '';
    });
  }

  @override
  void dispose() {
    _totalWeightController.dispose();
    for (var controller in _typeControllers.values) {
      controller.removeListener(_updateTotalWeight);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedLieu == 'Sélectionner un lieu') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un lieu de tri')),
      );
      return;
    }
    
    if (_selectedFactoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une usine destinataire')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final selections = _typeControllers.entries
          .where((e) => e.value.text.isNotEmpty)
          .map((e) => WasteTypeSelection(
                type: e.key,
                weight: double.parse(e.value.text),
              ))
          .toList();

      if (selections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez saisir au moins une quantité par type')),
        );
        setState(() => _isLoading = false);
        return;
      }

      await ref.read(zttRepositoryProvider).submitSortingReport(
            selections: selections,
            factoryId: _selectedFactoryId!,
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opération de tri enregistrée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(zttHistoryProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final factoriesAsync = ref.watch(zttFactoriesProvider);
    final String currentDate = DateFormat('EEEE d MMMM y à HH:mm', 'fr_FR').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouveau tri', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Heure
                    const Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Date et heure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4B5563))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentDate,
                        style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Poids Total
                    const Text('Poids total (kg) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4B5563))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _totalWeightController,
                      keyboardType: TextInputType.number,
                      readOnly: true, // Auto-calculated
                      decoration: InputDecoration(
                        hintText: 'Le total se calculera automatiquement',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Lieu du tri
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Lieu du tri *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4B5563))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLieu,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _lieux.map((l) {
                        return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 15)));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedLieu = val!),
                    ),
                    const SizedBox(height: 32),

                    // Répartition par type
                    const Text('Répartition par type (kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937))),
                    const SizedBox(height: 16),
                    ..._typeControllers.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _typeColors[entry.key],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: entry.value,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: entry.key,
                                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (double.tryParse(value) == null) {
                                      return 'Inv';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Usine destinataire
                    const Text('Usine destinataire *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4B5563))),
                    const SizedBox(height: 8),
                    factoriesAsync.when(
                      data: (factories) => DropdownButtonFormField<String>(
                        value: _selectedFactoryId,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        hint: const Text('Sélectionner une usine', style: TextStyle(fontSize: 15, color: Color(0xFF4B5563))),
                        items: factories.map((f) {
                          return DropdownMenuItem(
                            value: f.id,
                            child: Text(f.name, style: const TextStyle(fontSize: 15)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedFactoryId = val),
                      ),
                      loading: () => const Center(child: LinearProgressIndicator(color: Color(0xFFE53935))),
                      error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(height: 40),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () => context.pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF3F4F6),
                                foregroundColor: const Color(0xFF4B5563),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Annuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Valider le tri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
