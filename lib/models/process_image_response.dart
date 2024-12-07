import 'package:foodpundit/models/product.dart';
import 'package:foodpundit/models/error_response.dart';

class ProcessImageResponse {
  final bool success;
  final String? imageUrl;
  final String? productDocId;
  final String? rawProductDocId;
  final Map<String, dynamic>? productDetails;
  final List<Map<String, dynamic>>? ingredientProfile;
  final ErrorResponse? error;

  ProcessImageResponse({
    this.success = true,
    this.imageUrl,
    this.productDocId,
    this.rawProductDocId,
    this.productDetails,
    this.ingredientProfile,
    this.error,
  });

  factory ProcessImageResponse.fromJson(Map<String, dynamic> json) {
    return ProcessImageResponse(
      success: json['success'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
      productDocId: json['product_doc_id'] as String?,
      rawProductDocId: json['raw_product_doc_id'] as String?,
      productDetails: json['product_details'] as Map<String, dynamic>?,
      ingredientProfile: json['ingredient_profile'] != null
          ? (json['ingredient_profile'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : null,
      error: json['error'] != null
          ? ErrorResponse.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  Product? toProduct() {
    if (productDetails == null || imageUrl == null) {
      return null;
    }

    List<Ingredient> ingredients = ingredientProfile
            ?.map((ingredient) => Ingredient(
                  ingredientName: ingredient['ingredient_name'] as String,
                  briefSummary: ingredient['important_points'] as String?,
                ))
            .toList() ??
        [];

    return Product(
      id: productDocId ?? '',
      productName:
          productDetails?['product_name'] as String? ?? 'Unknown Product',
      imageUrl: imageUrl!,
      scannedAt: DateTime.now(),
      ingredients: ingredients,
      allergenDeclarations: productDetails?['allergen_declarations'] as String?,
      approximateServingsPerPack:
          productDetails?['approximate_servings_per_pack'] as int?,
      batchNumber: productDetails?['batch_number'] as String?,
      bestBeforeDate: productDetails?['best_before_date'] as String?,
      dateOfManufacture: productDetails?['date_of_manufacture'] as String?,
      description: productDetails?['description'] as String?,
      expiryDate: productDetails?['expiry_date'] as String?,
      foodType: productDetails?['food_type'] as String?,
      fssaiNumber: productDetails?['fssai_number'] as String?,
      mrp: productDetails?['mrp'] as String?,
      netQuantity: productDetails?['net_quantity'] as String?,
      rawIngredientsText: productDetails?['raw_ingredients_text'] as String?,
      servingSize: productDetails?['serving_size'] as String?,
      servingsPerContainer: productDetails?['servings_per_container'] as int?,
      vegNonVegStatus: productDetails?['veg_non_veg_status'] as String?,
      legacyNutriScore: productDetails?['legacy_nutri_score'] as String?,
      novaGroup: productDetails?['nova_group'] as int?,
      aggregatedNutrients:
          (productDetails?['aggregated_nutrients'] as Map<String, dynamic>?)
              ?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }
}
