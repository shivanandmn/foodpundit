import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/ui_constants.dart';

class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomScrollView(
      slivers: [
        // Image Shimmer
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: theme.colorScheme.surfaceVariant,
            highlightColor: theme.colorScheme.surface,
            child: Container(
              height: MediaQuery.of(context).size.width,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ),

        // Details Shimmer
        SliverPadding(
          padding: const EdgeInsets.all(UIConstants.spacingL),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Product ID Shimmer
              Shimmer.fromColors(
                baseColor: theme.colorScheme.surfaceVariant,
                highlightColor: theme.colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(height: UIConstants.spacingXS),
                    Container(
                      width: 200,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: UIConstants.spacingL),
                  ],
                ),
              ),

              // Ingredients Title Shimmer
              Shimmer.fromColors(
                baseColor: theme.colorScheme.surfaceVariant,
                highlightColor: theme.colorScheme.surface,
                child: Container(
                  width: 120,
                  height: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: UIConstants.spacingM),

              // Ingredients List Shimmer
              ...List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
                child: Shimmer.fromColors(
                  baseColor: theme.colorScheme.surfaceVariant,
                  highlightColor: theme.colorScheme.surface,
                  child: Card(
                    elevation: 0,
                    child: Container(
                      padding: const EdgeInsets.all(UIConstants.spacingM),
                      height: 80,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),
            ]),
          ),
        ),
      ],
    );
  }
}
