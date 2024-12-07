import 'package:flutter/material.dart';
import '../utils/ui_constants.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  static const _headerDecoration = BorderRadius.all(
    Radius.circular(UIConstants.radiusM),
  );

  static const _textDecoration = BorderRadius.all(
    Radius.circular(UIConstants.radiusS),
  );

  static const _avatarDecoration = BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shimmerBaseColor =
        colorScheme.surfaceTint.withOpacity(UIConstants.shimmerOpacityBase);
    final shimmerHighlightColor = colorScheme.surfaceTint
        .withOpacity(UIConstants.shimmerOpacityHighlight);

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      period: UIConstants.durationShimmer,
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              height: UIConstants.shimmerHeaderHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: _headerDecoration,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),

            // Profile section
            Row(
              children: [
                // Avatar placeholder
                Container(
                  width: UIConstants.shimmerAvatarSize,
                  height: UIConstants.shimmerAvatarSize,
                  decoration: _avatarDecoration,
                ),
                const SizedBox(width: UIConstants.spacingM),

                // Text placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: UIConstants.shimmerTextHeight,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: _textDecoration,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      Container(
                        width: UIConstants.shimmerSubtitleWidth,
                        height: UIConstants.shimmerTextHeight,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: _textDecoration,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingL),

            // Content placeholder
            Container(
              width: double.infinity,
              height: UIConstants.shimmerContentHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: _headerDecoration,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
