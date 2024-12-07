import 'package:flutter/material.dart';
import 'package:foodpundit/config/environment_config.dart';
import 'package:provider/provider.dart';
import '../../../../models/product.dart';
import '../../../../providers/app_auth_provider.dart';
import '../../../../utils/ui_constants.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../../../../widgets/network_aware_image.dart';
import '../../../../widgets/product_details_shimmer.dart';
import '../../../../widgets/user_avatar.dart';
import 'package:foodpundit/screens/profile_page.dart';
import '../widgets/product_header.dart';
import '../widgets/ingredients_list.dart';
import '../widgets/nutrition_facts.dart';
import '../widgets/product_info_grid.dart';
import '../widgets/report_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  final bool fromCamera;

  const ProductDetailsPage({
    Key? key,
    required this.product,
    this.fromCamera = false,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _reportIncorrectInfo(List<String> incorrectFields) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please login to report incorrect information')),
        );
        return;
      }

      final userDoc = await _firestore
          .collection(EnvironmentConfig.usersCollection)
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
        return;
      }

      final data = userDoc.data();
      final productHistory =
          List<Map<String, dynamic>>.from(data?['product_history'] ?? []);

      // Find the existing product entry
      final productIndex = productHistory
          .indexWhere((item) => item['doc_id'] == widget.product.id);

      if (productIndex != -1) {
        // Update existing entry
        var product = productHistory[productIndex];
        var existingIncorrectFields =
            Set<String>.from(product['incorrect_fields'] ?? []);
        existingIncorrectFields.addAll(incorrectFields);
        product['incorrect_fields'] = existingIncorrectFields.toList();
        product['status'] = 'reported';
        productHistory[productIndex] = product;
      } else {
        // Create new entry if product doesn't exist in history
        productHistory.add({
          'doc_id': widget.product.id,
          'created_at': FieldValue.serverTimestamp(),
          'incorrect_fields': incorrectFields,
          'status': 'reported',
        });
      }

      // Update the user document
      await _firestore
          .collection(EnvironmentConfig.usersCollection)
          .doc(user.uid)
          .update({
        'product_history': productHistory,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Thank you for reporting. We will review this information.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error reporting information: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Details',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.fromCamera) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: const [],
      ),
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? const ProductDetailsShimmer()
          : CustomScrollView(
              slivers: [
                _buildImageSection(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(UIConstants.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductHeader(product: widget.product),
                        if (widget.product.ingredients.isNotEmpty) ...[
                          const SizedBox(height: UIConstants.spacingXL),
                          Text(
                            'Ingredients',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          IngredientsList(product: widget.product),
                        ],
                        if (widget.product.aggregatedNutrients != null &&
                            widget.product.aggregatedNutrients!.isNotEmpty) ...[
                          const SizedBox(height: UIConstants.spacingXL),
                          Text(
                            'Nutrition Facts (per 100g)',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          NutritionFacts(product: widget.product),
                        ],
                        const SizedBox(height: UIConstants.spacingXL),
                        ProductInfoGrid(product: widget.product),
                        if (widget.product.allergenDeclarations != null) ...[
                          const SizedBox(height: UIConstants.spacingXL),
                          Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: theme.colorScheme.error,
                                size: 24,
                              ),
                              const SizedBox(width: UIConstants.spacingS),
                              Text(
                                'Allergen Information',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          Container(
                            padding: const EdgeInsets.all(UIConstants.spacingM),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius:
                                  BorderRadius.circular(UIConstants.radiusM),
                            ),
                            child: Text(
                              widget.product.allergenDeclarations!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: UIConstants.spacingXL),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => _showReportDialog(context),
                            icon: const Icon(Icons.flag_outlined),
                            label: const Text('Report Incorrect Information'),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: UIConstants.spacingL,
                                vertical: UIConstants.spacingM,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildImageSection() {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Hero(
                    tag: 'product-${widget.product.id}',
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.spacingL),
                      child: NetworkAwareImage(
                        imageUrl: widget.product.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.product.legacyNutriScore != null)
                        Padding(
                          padding: const EdgeInsets.all(UIConstants.spacingM),
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(0.1)
                              ..rotateY(-0.1),
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: UIConstants.spacingM,
                                vertical: UIConstants.spacingS,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius:
                                    BorderRadius.circular(UIConstants.radiusL),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    offset: const Offset(0, 8),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/icons/nutriscore/Nutri-score-${widget.product.legacyNutriScore}.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      if (widget.product.novaGroup != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.spacingM,
                            vertical: UIConstants.spacingXS,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: UIConstants.spacingXS,
                                  vertical: UIConstants.spacingXXS,
                                ),
                                constraints: const BoxConstraints(
                                  maxWidth: 80,
                                  maxHeight: 40,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.radiusS),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/icons/novagroup/NOVA-${widget.product.novaGroup}_group.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingXS),
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 100),
                                child: Text(
                                  _getNovaGroupDescription(
                                      widget.product.novaGroup!),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                        fontSize: 8,
                                        height: 1.2,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getNovaGroupDescription(int novaGroup) {
    switch (novaGroup) {
      case 1:
        return 'Unprocessed or minimally processed foods';
      case 2:
        return 'Processed culinary ingredients';
      case 3:
        return 'Processed foods';
      case 4:
        return 'Ultra-processed food and drink products';
      default:
        return '';
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        productId: widget.product.id,
        onReport: (incorrectFields) => _reportIncorrectInfo(incorrectFields),
      ),
    );
  }
}
