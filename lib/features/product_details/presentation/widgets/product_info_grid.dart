import 'package:flutter/material.dart';
import '../../../../models/product.dart';
import '../../../../utils/ui_constants.dart';

class ProductInfoGrid extends StatelessWidget {
  final Product product;

  const ProductInfoGrid({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: UIConstants.spacingM,
              runSpacing: UIConstants.spacingM,
              children: [
                if (product.vegNonVegStatus != null)
                  SizedBox(
                    width: (constraints.maxWidth - UIConstants.spacingM) / 2,
                    child: _buildInfoCard(
                      theme,
                      'Type',
                      product.vegNonVegStatus!,
                      Icons.eco,
                    ),
                  ),
                if (product.servingSize != null)
                  SizedBox(
                    width: (constraints.maxWidth - UIConstants.spacingM) / 2,
                    child: _buildInfoCard(
                      theme,
                      'Serving Size',
                      product.servingSize!,
                      Icons.restaurant,
                    ),
                  ),
                if (product.mrp != null)
                  SizedBox(
                    width: (constraints.maxWidth - UIConstants.spacingM) / 2,
                    child: _buildInfoCard(
                      theme,
                      'MRP',
                      product.mrp!,
                      Icons.currency_rupee,
                    ),
                  ),
                if (product.netQuantity != null)
                  SizedBox(
                    width: (constraints.maxWidth - UIConstants.spacingM) / 2,
                    child: _buildInfoCard(
                      theme,
                      'Net Quantity',
                      product.netQuantity!,
                      Icons.scale,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(ThemeData theme, String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingXS),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
