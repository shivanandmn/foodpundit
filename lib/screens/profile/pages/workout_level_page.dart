import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../../../models/user_details.dart';
import '../../../utils/ui_constants.dart';

class WorkoutLevelPage extends StatelessWidget {
  final WorkoutLevel workoutLevel;
  final Function(WorkoutLevel) onWorkoutLevelChanged;

  const WorkoutLevelPage({
    super.key,
    required this.workoutLevel,
    required this.onWorkoutLevelChanged,
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
            'What\'s your activity level?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'This helps us calculate your daily calorie needs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
                ),
          ),
          const SizedBox(height: UIConstants.spacingXL),
          _buildWorkoutOption(
            context,
            WorkoutLevel.none,
            'Sedentary',
            'Little to no exercise',
            LineIcons.couch,
            colorScheme.error,
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildWorkoutOption(
            context,
            WorkoutLevel.beginner,
            'Light',
            'Light exercise 1-3 days/week',
            LineIcons.walking,
            colorScheme.tertiary,
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildWorkoutOption(
            context,
            WorkoutLevel.intermediate,
            'Moderate',
            'Moderate exercise 3-5 days/week',
            LineIcons.running,
            colorScheme.secondary,
          ),
          const SizedBox(height: UIConstants.spacingM),
          _buildWorkoutOption(
            context,
            WorkoutLevel.advanced,
            'Active',
            'Hard exercise 6-7 days/week',
            LineIcons.dumbbell,
            colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutOption(
    BuildContext context,
    WorkoutLevel level,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = workoutLevel == level;

    return InkWell(
      onTap: () => onWorkoutLevelChanged(level),
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
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(UIConstants.spacingXS),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LineIcons.check,
                  color: colorScheme.surface,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
