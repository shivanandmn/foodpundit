import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../../../models/user_details.dart';
import '../../../utils/ui_constants.dart';

class HealthConditionsPage extends StatelessWidget {
  final Set<HealthCondition> selectedConditions;
  final Function(Set<HealthCondition>) onConditionsChanged;

  const HealthConditionsPage({
    super.key,
    required this.selectedConditions,
    required this.onConditionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Do you have any health conditions?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Select all that apply. This helps us provide relevant nutrition advice.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
                ),
          ),
          const SizedBox(height: UIConstants.spacingXL),
          _buildConditionOption(
            context,
            HealthCondition.diabetic,
            'Diabetes',
            'Type 1 or Type 2 Diabetes',
            LineIcons.syringe,
            colorScheme.error,
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildConditionOption(
            context,
            HealthCondition.highBloodPressure,
            'Hypertension',
            'High Blood Pressure',
            LineIcons.heartbeat,
            colorScheme.error,
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildConditionOption(
            context,
            HealthCondition.glutenIntolerant,
            'Celiac Disease',
            'Gluten Sensitivity',
            LineIcons.breadSlice,
            colorScheme.tertiary,
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildConditionOption(
            context,
            HealthCondition.lactoseIntolerant,
            'Lactose Intolerance',
            'Dairy Sensitivity',
            LineIcons.glassWhiskey,
            colorScheme.secondary,
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildConditionOption(
            context,
            HealthCondition.thyroid,
            'Thyroid',
            'Thyroid Issues',
            LineIcons.hamburger,
            colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionOption(
    BuildContext context,
    HealthCondition condition,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedConditions.contains(condition);

    return InkWell(
      onTap: () {
        final newConditions = Set<HealthCondition>.from(selectedConditions);
        if (isSelected) {
          newConditions.remove(condition);
        } else {
          newConditions.add(condition);
        }
        onConditionsChanged(newConditions);
      },
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withOpacity(UIConstants.opacityLow),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? color : colorScheme.outline.withOpacity(UIConstants.opacityLow),
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected ? color : null,
                borderRadius: BorderRadius.circular(UIConstants.radiusS),
              ),
              child: isSelected
                  ? Icon(
                      LineIcons.check,
                      size: 16,
                      color: colorScheme.surface,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
