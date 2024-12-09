import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String ingredientName;
  final String? briefSummary;

  Ingredient({
    required this.ingredientName,
    this.briefSummary,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      ingredientName: map['ingredient_name'] ?? '',
      briefSummary: map['important_points'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredient_name': ingredientName,
      'important_points': briefSummary,
    };
  }
}

class Product {
  final String id;
  final String productName;
  final String imageUrl;
  final DateTime scannedAt;
  final String? allergenDeclarations;
  final dynamic approximateServingsPerPack;
  final String? batchNumber;
  final String? bestBeforeDate;
  final String? dateOfManufacture;
  final String? description;
  final String? expiryDate;
  final String? foodType;
  final String? fssaiNumber;
  final String? mrp;
  final String? netQuantity;
  final String? rawIngredientsText;
  final String? servingSize;
  final dynamic servingsPerContainer;
  final String? vegNonVegStatus;
  final String? legacyNutriScore;
  final int? novaGroup;
  final List<Ingredient> ingredients;
  final Map<String, double>? aggregatedNutrients;

  Product({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.scannedAt,
    this.allergenDeclarations,
    this.approximateServingsPerPack,
    this.batchNumber,
    this.bestBeforeDate,
    this.dateOfManufacture,
    this.description,
    this.expiryDate,
    this.foodType,
    this.fssaiNumber,
    this.mrp,
    this.netQuantity,
    this.rawIngredientsText,
    this.servingSize,
    this.servingsPerContainer,
    this.vegNonVegStatus,
    this.legacyNutriScore,
    this.novaGroup,
    this.ingredients = const [],
    this.aggregatedNutrients,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> ingredientsData = data['ingredients'] ?? [];
    final Map<String, dynamic>? nutrientsData = data['aggregated_nutrients'];

    return Product(
      id: doc.id,
      productName: data['product_name'] ?? 'Food Product',
      imageUrl: data['image_url'] ?? '',
      scannedAt: (data['timestamp'] as Timestamp).toDate(),
      allergenDeclarations: data['allergen_declarations'],
      approximateServingsPerPack: data['approximate_servings_per_pack'],
      batchNumber: data['batch_number'],
      bestBeforeDate: data['best_before_date'],
      dateOfManufacture: data['date_of_manufacture'],
      description: data['description'],
      expiryDate: data['expiry_date'],
      foodType: data['food_type'],
      fssaiNumber: data['fssai_number'],
      mrp: data['mrp'],
      netQuantity: data['net_quantity'],
      rawIngredientsText: data['raw_ingredients_text'],
      servingSize: data['serving_size'],
      servingsPerContainer: data['servings_per_container'],
      vegNonVegStatus: data['veg_non_veg_status'],
      legacyNutriScore: data['legacy_nutri_score'],
      novaGroup: data['nova_group'],
      ingredients: ingredientsData
          .map((ingredient) => Ingredient.fromMap(ingredient))
          .toList(),
      aggregatedNutrients: nutrientsData?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  factory Product.fromHistoryEntry(Map<String, dynamic> entry) {
    final List<dynamic> ingredientsData = entry['ingredients'] ?? [];

    return Product(
      id: entry['doc_id'] ?? '',
      productName: entry['product_name'] ?? '',
      imageUrl: entry['image_url'] ?? '',
      scannedAt: (entry['timestamp'] as Timestamp).toDate(),
      allergenDeclarations: entry['allergen_declarations'],
      approximateServingsPerPack: entry['approximate_servings_per_pack'],
      batchNumber: entry['batch_number'],
      bestBeforeDate: entry['best_before_date'],
      dateOfManufacture: entry['date_of_manufacture'],
      description: entry['description'],
      expiryDate: entry['expiry_date'],
      foodType: entry['food_type'],
      fssaiNumber: entry['fssai_number'],
      mrp: entry['mrp'],
      netQuantity: entry['net_quantity'],
      rawIngredientsText: entry['raw_ingredients_text'],
      servingSize: entry['serving_size'],
      servingsPerContainer: entry['servings_per_container'],
      vegNonVegStatus: entry['veg_non_veg_status'],
      legacyNutriScore: entry['legacy_nutri_score'],
      novaGroup: entry['nova_group'],
      ingredients: ingredientsData
          .map((ingredient) => Ingredient.fromMap(ingredient))
          .toList(),
      aggregatedNutrients: entry['aggregated_nutrients'],
    );
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? id}) {
    final List<dynamic> ingredientsData = map['ingredients'] ?? [];

    return Product(
      id: id ?? '',
      productName: map['product_name'] ?? '',
      imageUrl: map['image_url'] ?? '',
      scannedAt: (map['timestamp'] as Timestamp).toDate(),
      allergenDeclarations: map['allergen_declarations'],
      approximateServingsPerPack: map['approximate_servings_per_pack'],
      batchNumber: map['batch_number'],
      bestBeforeDate: map['best_before_date'],
      dateOfManufacture: map['date_of_manufacture'],
      description: map['description'],
      expiryDate: map['expiry_date'],
      foodType: map['food_type'],
      fssaiNumber: map['fssai_number'],
      mrp: map['mrp'],
      netQuantity: map['net_quantity'],
      rawIngredientsText: map['raw_ingredients_text'],
      servingSize: map['serving_size'],
      servingsPerContainer: map['servings_per_container'],
      vegNonVegStatus: map['veg_non_veg_status'],
      legacyNutriScore: map['legacy_nutri_score'],
      novaGroup: map['nova_group'],
      ingredients: ingredientsData
          .map((ingredient) => Ingredient.fromMap(ingredient))
          .toList(),
      aggregatedNutrients: map['aggregated_nutrients'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_name': productName,
      'image_url': imageUrl,
      'timestamp': scannedAt,
      'allergen_declarations': allergenDeclarations,
      'approximate_servings_per_pack': approximateServingsPerPack,
      'batch_number': batchNumber,
      'best_before_date': bestBeforeDate,
      'date_of_manufacture': dateOfManufacture,
      'description': description,
      'expiry_date': expiryDate,
      'food_type': foodType,
      'fssai_number': fssaiNumber,
      'mrp': mrp,
      'net_quantity': netQuantity,
      'raw_ingredients_text': rawIngredientsText,
      'serving_size': servingSize,
      'servings_per_container': servingsPerContainer,
      'veg_non_veg_status': vegNonVegStatus,
      'legacy_nutri_score': legacyNutriScore,
      'nova_group': novaGroup,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'aggregated_nutrients': aggregatedNutrients,
    };
  }
}
