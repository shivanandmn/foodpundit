import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:foodpundit/services/offline_profile_service.dart';
import 'package:provider/provider.dart';
import '../../../models/user_details.dart';
import '../../../providers/app_auth_provider.dart';
import '../../../utils/error_handler.dart';
import 'package:line_icons/line_icons.dart';
import '../../../utils/ui_constants.dart';

class ReviewPage extends StatelessWidget {
  final DateTime? birthDate;
  final double? heightCm;
  final double? weightKg;
  final WorkoutLevel workoutLevel;
  final Set<HealthCondition> healthConditions;
  final List<String> allergies;
  final bool isCalorieCounter;

  const ReviewPage({
    super.key,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.workoutLevel,
    required this.healthConditions,
    required this.allergies,
    required this.isCalorieCounter,
  });

  String _formatHealthCondition(HealthCondition condition) {
    return condition
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim()
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatList(List<String> items) {
    if (items.isEmpty) return 'None';
    return items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(', ');
  }

  Future<void> _saveProfile(BuildContext context) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final currentUser = authProvider.userDetails;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not found')),
      );
      return;
    }

    try {
      // Show saving dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Saving profile...'),
            ],
          ),
        ),
      );

      // Create updated user details
      final updatedDetails = currentUser.copyWith(
        birthDate: birthDate,
        heightCm: heightCm,
        weightKg: weightKg,
        workoutLevel: workoutLevel,
        healthConditions: healthConditions.toList(),
        allergies: allergies,
        isCalorieCounter: isCalorieCounter,
      );

      // Update user details through the provider
      await authProvider.updateUserDetails(updatedDetails);

      // Also save to offline storage
      final offlineService = OfflineProfileService();
      await offlineService.saveProfileData(updatedDetails.toMap());

      if (context.mounted) {
        // Dismiss saving dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Pop back to profile page
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Dismiss saving dialog if showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildSection(String title, String content, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Review Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please verify your information below',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Birth Date',
                    birthDate != null
                        ? DateFormat('MMMM d, y').format(birthDate!)
                        : 'Not specified',
                    Icons.calendar_today,
                  ),
                  _buildSection(
                    'Height',
                    heightCm != null
                        ? '${heightCm!.toStringAsFixed(1)} cm'
                        : 'Not specified',
                    Icons.height,
                  ),
                  _buildSection(
                    'Weight',
                    weightKg != null
                        ? '${weightKg!.toStringAsFixed(1)} kg'
                        : 'Not specified',
                    Icons.monitor_weight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health & Fitness',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Workout Level',
                    workoutLevel.toString().split('.').last,
                    Icons.fitness_center,
                  ),
                  if (healthConditions.isNotEmpty)
                    _buildSection(
                      'Health Conditions',
                      healthConditions.isEmpty
                          ? 'None'
                          : healthConditions
                              .where((c) => c != HealthCondition.none)
                              .map(_formatHealthCondition)
                              .join(', '),
                      Icons.medical_services,
                    ),
                  if (allergies.isNotEmpty)
                    _buildSection(
                      'Allergies',
                      _formatList(allergies),
                      Icons.warning,
                    ),
                  _buildSection(
                    'Calorie Counter',
                    isCalorieCounter ? 'Enabled' : 'Disabled',
                    Icons.restaurant_menu,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonal(
              onPressed: () => _saveProfile(context),
              child: const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
