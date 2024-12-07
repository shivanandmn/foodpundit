import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../config/environment_config.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _cacheKey = 'product_cache';
  Map<String, Product> _productCache = {};

  Future<void> initCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      final Map<String, dynamic> decoded = json.decode(cachedData);
      _productCache = decoded.map((key, value) {
        final Map<String, dynamic> productData = value as Map<String, dynamic>;
        return MapEntry(
          key,
          Product(
            id: productData['id'],
            productName: productData['product_name'],
            imageUrl: productData['image_url'],
            scannedAt: DateTime.parse(productData['timestamp']),
            allergenDeclarations: productData['allergen_declarations'],
            approximateServingsPerPack:
                productData['approximate_servings_per_pack'],
            batchNumber: productData['batch_number'],
            bestBeforeDate: productData['best_before_date'],
            dateOfManufacture: productData['date_of_manufacture'],
            description: productData['description'],
            expiryDate: productData['expiry_date'],
            foodType: productData['food_type'],
            fssaiNumber: productData['fssai_number'],
            mrp: productData['mrp'],
            netQuantity: productData['net_quantity'],
            rawIngredientsText: productData['raw_ingredients_text'],
            servingSize: productData['serving_size'],
            servingsPerContainer: productData['servings_per_container'],
            vegNonVegStatus: productData['veg_non_veg_status'],
            legacyNutriScore: productData['legacy_nutri_score'],
            novaGroup: productData['nova_group'],
            ingredients: (productData['ingredients'] as List<dynamic>?)
                    ?.map((ingredientData) => Ingredient.fromMap(
                        ingredientData as Map<String, dynamic>))
                    .toList() ??
                [],
            aggregatedNutrients: (productData['aggregated_nutrients'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> cacheData = _productCache.map(
      (key, product) => MapEntry(key, {
        'id': product.id,
        'product_name': product.productName,
        'image_url': product.imageUrl,
        'timestamp': product.scannedAt.toIso8601String(),
        'allergen_declarations': product.allergenDeclarations,
        'approximate_servings_per_pack': product.approximateServingsPerPack,
        'batch_number': product.batchNumber,
        'best_before_date': product.bestBeforeDate,
        'date_of_manufacture': product.dateOfManufacture,
        'description': product.description,
        'expiry_date': product.expiryDate,
        'food_type': product.foodType,
        'fssai_number': product.fssaiNumber,
        'mrp': product.mrp,
        'net_quantity': product.netQuantity,
        'raw_ingredients_text': product.rawIngredientsText,
        'serving_size': product.servingSize,
        'servings_per_container': product.servingsPerContainer,
        'veg_non_veg_status': product.vegNonVegStatus,
        'legacy_nutri_score': product.legacyNutriScore,
        'nova_group': product.novaGroup,
        'ingredients': product.ingredients
            .map((ingredient) => ingredient.toMap())
            .toList(),
        'aggregated_nutrients': product.aggregatedNutrients,
      }),
    );
    await prefs.setString(_cacheKey, json.encode(cacheData));
  }

  // Clear product cache
  Future<void> clearCache() async {
    _productCache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  Future<Product?> getProduct(String productId) async {
    // Check cache first
    if (_productCache.containsKey(productId)) {
      return _productCache[productId];
    }

    try {
      final doc = await _firestore.collection(EnvironmentConfig.productsCollection).doc(productId).get();
      if (!doc.exists) return null;

      final product = Product.fromFirestore(doc);
      // Add to cache
      _productCache[productId] = product;
      await _saveCache();
      return product;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<List<Product>> getProductsFromHistory(
      List<Map<String, dynamic>> history) async {
    final List<Product> products = [];

    for (final entry in history) {
      final productId = entry['doc_id'];
      if (productId == null) continue;

      final product = await getProduct(productId);
      if (product != null) {
        products.add(product);
      }
    }

    return products;
  }
}
