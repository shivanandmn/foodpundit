import 'package:flutter/material.dart';
import '../../../../models/product.dart';
import '../../../../utils/ui_constants.dart';

class IngredientsList extends StatefulWidget {
  final Product product;

  const IngredientsList({Key? key, required this.product}) : super(key: key);

  @override
  State<IngredientsList> createState() => _IngredientsListState();
}

class _IngredientsListState extends State<IngredientsList> {
  bool _showAllIngredients = false;
  static const int _initialIngredientsCount = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ingredients = widget.product.ingredients;
    final displayedIngredients = _showAllIngredients
        ? ingredients
        : ingredients.take(_initialIngredientsCount).toList();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedIngredients.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              final ingredient = displayedIngredients[index];
              return Padding(
                padding: const EdgeInsets.all(UIConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.ingredientName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (ingredient.briefSummary != null) ...[
                      const SizedBox(height: UIConstants.spacingXS),
                      Text(
                        ingredient.briefSummary!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        if (ingredients.length > _initialIngredientsCount) ...[
          const SizedBox(height: UIConstants.spacingS),
          InkWell(
            onTap: () {
              setState(() {
                _showAllIngredients = !_showAllIngredients;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingM,
                vertical: UIConstants.spacingS,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showAllIngredients
                        ? 'Show Less'
                        : 'Show All ${ingredients.length} Ingredients',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingXS),
                  Icon(
                    _showAllIngredients
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
