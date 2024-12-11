import 'package:flutter/material.dart';
import '../../../../models/product.dart';
import '../../../../utils/ui_constants.dart';

class NutritionFacts extends StatelessWidget {
  final Product product;

  const NutritionFacts({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (product.aggregatedNutrients == null ||
        product.aggregatedNutrients!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.aggregatedNutrients!.entries
                .where((e) => e.key != 'fruit_percentage')
                .length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              final nutrient = product.aggregatedNutrients!.entries
                  .where((e) => e.key != 'fruit_percentage')
                  .elementAt(index);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingM,
                  vertical: UIConstants.spacingS,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatNutrientName(nutrient.key),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _formatNutrientValue(nutrient.key, nutrient.value),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatNutrientName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatNutrientValue(String key, double value) {
    if (key == 'energy') {
      return '${value.toStringAsFixed(1)} kcal';
    }

    // Handle very low values
    if (value < 0.01) {
      // For extremely low values, use scientific notation
      return '${value.toStringAsExponential(2)} g';
    } else if (value < 0.1) {
      // For very low values, show 3 decimal places
      return '${value.toStringAsFixed(3)} g';
    } else if (value < 1) {
      // For values less than 1, show 2 decimal places
      return '${value.toStringAsFixed(2)} g';
    } else {
      // For values >= 1, show 1 decimal place
      return '${value.toStringAsFixed(1)} g';
    }
  }
}
