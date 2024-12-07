import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import '../../../utils/ui_constants.dart';

class BasicInfoPage extends StatelessWidget {
  final DateTime? birthDate;
  final double? height;
  final double? weight;
  final Function(DateTime?) onBirthDateChanged;
  final Function(double?) onHeightChanged;
  final Function(double?) onWeightChanged;

  const BasicInfoPage({
    super.key,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.onBirthDateChanged,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  String getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your height';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height < 50 || height > 300) {
      return 'Please enter a height between 50 and 300 cm';
    }
    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your weight';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }
    if (weight < 20 || weight > 500) {
      return 'Please enter a weight between 20 and 500 kg';
    }
    return null;
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
            'Tell us about yourself',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: UIConstants.spacingS),
          Text(
            'This information helps us provide personalized nutrition insights',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
                ),
          ),
          const SizedBox(height: UIConstants.spacingXL),
          _buildDateField(context),
          const SizedBox(height: UIConstants.spacingL),
          _buildHeightField(context),
          const SizedBox(height: UIConstants.spacingL),
          _buildWeightField(context),
          if (bmi != null) ...[
            const SizedBox(height: UIConstants.spacingXL),
            Text(
              'Your BMI',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(UIConstants.radiusM),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.blue,    // Underweight
                          Colors.green,   // Normal
                          Colors.orange,  // Overweight
                          Colors.red,     // Obese
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // BMI Marker
                        Positioned(
                          left: ((bmi! - 15).clamp(0, 25) / 25 * 
                            (MediaQuery.of(context).size.width - 32)).clamp(
                              0, MediaQuery.of(context).size.width - 34),
                          child: Container(
                            width: 2,
                            height: 40,
                            color: Colors.white,
                          ),
                        ),
                        // Category Labels
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text('18.5', 
                                style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            Text('25', 
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                            Text('30', 
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                            Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text('40', 
                                style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              'BMI: ${bmi!.toStringAsFixed(1)} - ${getBmiCategory(bmi!)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: getBmiColor(bmi!),
              ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              _getBmiDescription(bmi!),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = birthDate != null ? DateFormat('yyyy-MM-dd').format(birthDate!) : 'Select Date';

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
                LineIcons.calendar,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            Text(
              'Birth Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingS),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: birthDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            onBirthDateChanged(date);
          },
          child: Container(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withOpacity(UIConstants.opacityLow),
              ),
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: birthDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
                        ),
                  ),
                ),
                Icon(
                  LineIcons.angleRight,
                  color: colorScheme.onSurface.withOpacity(UIConstants.opacityMedium),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeightField(BuildContext context) {
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
                LineIcons.ruler,
                color: colorScheme.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            Text(
              'Height',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingS),
        TextFormField(
          initialValue: height?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter height in cm',
            suffixText: 'cm',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
          ),
          validator: validateHeight,
          onChanged: (value) {
            final heightValue = double.tryParse(value);
            if (validateHeight(value) == null) {
              onHeightChanged(heightValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeightField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.spacingS),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Icon(
                LineIcons.weight,
                color: colorScheme.tertiary,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingM),
            Text(
              'Weight',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.spacingS),
        TextFormField(
          initialValue: weight?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter weight in kg',
            suffixText: 'kg',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
          ),
          validator: validateWeight,
          onChanged: (value) {
            final weightValue = double.tryParse(value);
            if (validateWeight(value) == null) {
              onWeightChanged(weightValue);
            }
          },
        ),
      ],
    );
  }

  String _getBmiDescription(double bmi) {
    if (bmi < 18.5) {
      return 'You may need to gain some weight. Consider consulting a healthcare provider.';
    }
    if (bmi < 25) {
      return 'Your weight is in the healthy range. Keep up the good work!';
    }
    if (bmi < 30) {
      return 'You may need to lose some weight. Consider increasing physical activity.';
    }
    return 'You may need to lose weight. Consider consulting a healthcare provider.';
  }
}
