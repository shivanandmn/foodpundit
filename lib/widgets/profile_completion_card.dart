import 'package:flutter/material.dart';
import '../models/user_details.dart';
import '../utils/ui_constants.dart';

class ProfileCompletionCard extends StatelessWidget {
  final UserDetails userDetails;
  final VoidCallback onEditProfile;
  final bool showEditButton;

  const ProfileCompletionCard({
    super.key,
    required this.userDetails,
    required this.onEditProfile,
    this.showEditButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completion = userDetails.profileCompletionPercentage;
    final incompleteFields = userDetails.incompleteFields;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Profile Completion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${completion.toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),
            ClipRRect(
              borderRadius: BorderRadius.circular(UIConstants.radiusXS),
              child: LinearProgressIndicator(
                value: completion / 100,
                minHeight: UIConstants.progressBarHeight,
                backgroundColor:
                    colorScheme.surface.withOpacity(UIConstants.opacityLow),
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary.withOpacity(UIConstants.opacityHigh),
                ),
              ),
            ),
            if (completion < 100) ...[
              const SizedBox(height: UIConstants.spacingM),
              Text(
                'Complete your profile for personalized nutrition insights',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface
                          .withOpacity(UIConstants.opacityHigh),
                    ),
              ),
              if (incompleteFields.isNotEmpty) ...[
                const SizedBox(height: UIConstants.spacingS),
                Wrap(
                  spacing: UIConstants.spacingXS,
                  runSpacing: UIConstants.spacingXS,
                  children: incompleteFields.map((field) {
                    return Chip(
                      label: Text(
                        field,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface
                              .withOpacity(UIConstants.opacityMedium),
                        ),
                      ),
                      backgroundColor: colorScheme.surfaceVariant,
                    );
                  }).toList(),
                ),
              ],
              if (showEditButton) ...[
                const SizedBox(height: UIConstants.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onEditProfile,
                    child: const Text('Complete Profile'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
