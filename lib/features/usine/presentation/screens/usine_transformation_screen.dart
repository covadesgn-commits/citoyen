import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usine_providers.dart';
import '../../domain/models/factory_product.dart';
import '../../../../core/theme/app_colors.dart';

class UsineTransformationScreen extends ConsumerWidget {
  const UsineTransformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(factoryProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Transformation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppColors.getBackgroundColor(context),
        foregroundColor: AppColors.getTextPrimaryColor(context),
        elevation: 0,
      ),
      body: productsAsync.when(
        data: (products) => DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.getTextSecondaryColor(context),
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Créer un produit'),
                  Tab(text: 'Mes Produits'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCreateProductForm(context, ref),
                    _buildProductsList(context, products),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildCreateProductForm(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    String? selectedCategory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: nameController,
            label: 'Nom du produit',
            hint: 'Ex: Granulés Plastiques HDPE',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: descriptionController,
            label: 'Description',
            hint: 'Détails sur le produit valorisé...',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: priceController,
                  label: 'Prix (GNF)',
                  hint: 'Ex: 5000',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: stockController,
                  label: 'Stock initial',
                  hint: 'Quantité',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Catégorie',
              labelStyle: TextStyle(color: AppColors.getTextSecondaryColor(context)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.getBorderColor(context))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.getBorderColor(context))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
              filled: true,
              fillColor: AppColors.getSurfaceColor(context),
            ),
            items: ['Plastique Recyclé', 'Compost', 'Matériaux de construction', 'Énergie', 'Autre']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => selectedCategory = val,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || selectedCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir les champs obligatoires')),
                );
                return;
              }

              final profile = ref.read(usineProfileProvider).value;
              final userId = profile?['id'];
              if (userId == null) return;

              final product = FactoryProduct(
                id: '', 
                factoryId: userId,
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0,
                stock: int.tryParse(stockController.text) ?? 0,
                category: selectedCategory!,
                createdat: DateTime.now(),
              );

              try {
                await ref.read(usineRepositoryProvider).createProduct(product);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produit créé avec succès !'), backgroundColor: AppColors.success),
                  );
                  ref.invalidate(factoryProductsProvider);
                  ref.invalidate(usineStatsProvider);
                  DefaultTabController.of(context).animateTo(1);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.all(18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('CRÉER LE PRODUIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList(BuildContext context, List<FactoryProduct> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.precision_manufacturing_outlined, size: 64, color: AppColors.getTextSecondaryColor(context).withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Aucun produit créé',
              style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22),
            ),
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('${product.category} • ${product.stock} en stock', style: TextStyle(color: AppColors.getTextSecondaryColor(context), fontSize: 13)),
            ),
            trailing: Text(
              '${product.price} GNF',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
            ),
          ),
        );
      },
    );
  }
}
