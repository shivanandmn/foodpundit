import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../../../utils/ui_constants.dart';

class AllergiesPage extends StatefulWidget {
  final List<String> allergies;
  final bool isCalorieCounter;
  final Function(List<String>) onAllergiesChanged;
  final Function(bool) onCalorieCounterChanged;

  const AllergiesPage({
    super.key,
    required this.allergies,
    required this.isCalorieCounter,
    required this.onAllergiesChanged,
    required this.onCalorieCounterChanged,
  });

  @override
  State<AllergiesPage> createState() => _AllergiesPageState();
}

class _AllergiesPageState extends State<AllergiesPage> {
  final TextEditingController _allergyController = TextEditingController();
  final List<String> _commonAllergies = [
    'Peanuts',
    'Tree Nuts',
    'Milk',
    'Eggs',
    'Soy',
    'Wheat',
    'Fish',
    'Shellfish',
  ];

  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

  void _addAllergy(String allergy) {
    if (allergy.isNotEmpty && !widget.allergies.contains(allergy)) {
      widget.onAllergiesChanged([...widget.allergies, allergy]);
      _allergyController.clear();
    }
  }

  void _removeAllergy(String allergy) {
    widget.onAllergiesChanged(
      widget.allergies.where((a) => a != allergy).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Any food allergies?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'Add your allergies to get personalized alerts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
                ),
          ),
          const SizedBox(height: UIConstants.spacingXL),
          _buildAllergyInput(context),
          if (widget.allergies.isNotEmpty) ...[
            const SizedBox(height: UIConstants.spacingL),
            _buildSelectedAllergies(context),
          ],
          const SizedBox(height: UIConstants.spacingL),
          _buildCommonAllergies(context),
          const SizedBox(height: UIConstants.spacingXL),
          _buildCalorieCounterOption(context),
        ],
      ),
    );
  }

  Widget _buildAllergyInput(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingS),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Icon(
                LineIcons.exclamationTriangle,
                color: colorScheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            Text(
              'Add Custom Allergy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingS),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _allergyController,
                decoration: InputDecoration(
                  hintText: 'Type allergy and press enter',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  ),
                ),
                onFieldSubmitted: _addAllergy,
              ),
            ),
            const SizedBox(width: UIConstants.spacingS),
            IconButton.filled(
              onPressed: () => _addAllergy(_allergyController.text),
              icon: const Icon(LineIcons.plus),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedAllergies(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingS),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Icon(
                LineIcons.list,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            Text(
              'Your Allergies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingS),
        Wrap(
          spacing: UIConstants.spacingS,
          runSpacing: UIConstants.spacingS,
          children: widget.allergies.map((allergy) {
            return Chip(
              label: Text(allergy),
              deleteIcon: const Icon(LineIcons.times, size: 16),
              onDeleted: () => _removeAllergy(allergy),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCommonAllergies(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingS),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Icon(
                LineIcons.starAlt,
                color: colorScheme.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            Text(
              'Common Allergies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingS),
        Wrap(
          spacing: UIConstants.spacingS,
          runSpacing: UIConstants.spacingS,
          children: _commonAllergies.map((allergy) {
            final isSelected = widget.allergies.contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _addAllergy(allergy);
                } else {
                  _removeAllergy(allergy);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalorieCounterOption(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withOpacity(UIConstants.opacityLow),
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.spacingS),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
            child: Icon(
              LineIcons.calculator,
              color: colorScheme.tertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calorie Counter',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Track your daily calorie intake',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.isCalorieCounter,
            onChanged: widget.onCalorieCounterChanged,
          ),
        ],
      ),
    );
  }
}
