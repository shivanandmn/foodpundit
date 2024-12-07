import 'package:flutter/material.dart';
import '../../../../models/product.dart';
import '../../../../utils/ui_constants.dart';

class ProductHeader extends StatelessWidget {
  final Product product;

  const ProductHeader({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          product.productName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),

        // Product Description
        if (product.description != null) ...[
          const SizedBox(height: UIConstants.spacingM),
          Text(
            product.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
