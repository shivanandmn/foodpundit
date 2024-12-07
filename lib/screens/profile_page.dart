import 'package:flutter/material.dart';
import '../utils/ui_constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:foodpundit/providers/app_auth_provider.dart';
import 'package:foodpundit/models/user_details.dart';
import 'package:foodpundit/widgets/profile_completion_card.dart';
import 'package:foodpundit/widgets/network_aware_image.dart';
import 'package:foodpundit/screens/auth/sign_in_screen.dart';
import 'profile/profile_setup_flow.dart';
import 'edit_profile_page.dart';
import 'scan_history_screen.dart';
import '../utils/slide_up_route.dart'; // Import the SlideUpRoute

class ProfilePage extends StatefulWidget {
  final UserDetails userDetails;

  const ProfilePage({
    super.key,
    required this.userDetails,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, _) {
        final userDetails = authProvider.userDetails ?? widget.userDetails;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface
                        .withOpacity(UIConstants.opacityHigh),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileSetupFlow(
                        existingDetails: userDetails,
                      ),
                    ),
                  );
                  setState(() {}); // Refresh the UI after returning
                },
                tooltip: 'Edit Profile',
              ),
            ],
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, userDetails),
                const SizedBox(height: UIConstants.spacingL),
                _buildProfileCompletionSection(context, userDetails),
                const SizedBox(height: UIConstants.spacingXL),
                _buildHealthSection(context, userDetails),
                const SizedBox(height: UIConstants.spacingM),
                _buildSettingsSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserDetails userDetails) {
    final colorScheme = Theme.of(context).colorScheme;

    final profileItems = [
      {
        'icon': Icons.person,
        'label': userDetails.displayName ?? 'Set your name',
        'onTap': () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                userDetails: userDetails,
                field: 'name',
              ),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
      },
      {
        'icon': Icons.email,
        'label': userDetails.email ?? 'Add email',
        'onTap': () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                userDetails: userDetails,
                field: 'email',
              ),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
      },
      {
        'icon': Icons.phone,
        'label': userDetails.phoneNumber ?? 'Add phone number',
        'onTap': () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                userDetails: userDetails,
                field: 'phone',
              ),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Text(
                (userDetails.displayName?.isNotEmpty == true)
                    ? userDetails.displayName![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 32,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...profileItems
                .map((item) => ListTile(
                      leading: Icon(item['icon'] as IconData,
                          color: colorScheme.primary),
                      title: Text(item['label'] as String),
                      onTap: item['onTap'] as void Function(),
                      dense: true,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSection(BuildContext context, UserDetails userDetails) {
    // Only show if profile completion > 10% and has health/diet data
    if (userDetails.profileCompletionPercentage <= 20 ||
        (userDetails.workoutLevel == WorkoutLevel.none &&
            userDetails.healthConditions.isEmpty &&
            userDetails.allergies.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health & Diet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (userDetails.workoutLevel != WorkoutLevel.none)
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Workout Level'),
                subtitle:
                    Text(userDetails.workoutLevel.toString().split('.').last),
              ),
            if (userDetails.healthConditions.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text('Health Conditions'),
                subtitle: Wrap(
                  spacing: 4,
                  children: userDetails.healthConditions
                      .map((condition) => Chip(
                            label: Text(condition.toString().split('.').last),
                          ))
                      .toList(),
                ),
              ),
            if (userDetails.allergies.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Allergies'),
                subtitle: Wrap(
                  spacing: 4,
                  children: userDetails.allergies
                      .map((allergy) => Chip(
                            label: Text(allergy),
                          ))
                      .toList(),
                ),
              ),
            if (userDetails.isCalorieCounter)
              const ListTile(
                leading: Icon(Icons.monitor_weight),
                title: Text('Calorie Counter'),
                subtitle: Text('Tracking calorie intake'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCompletionSection(
      BuildContext context, UserDetails userDetails) {
    return ProfileCompletionCard(
      userDetails: userDetails,
      onEditProfile: () {
        // TODO: Navigate to edit profile
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AppAuthProvider>(context);

    final settingsItems = [
      {
        'icon': Icons.edit,
        'label': 'Edit Profile',
        'onTap': () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileSetupFlow(
                existingDetails:
                    Provider.of<AppAuthProvider>(context, listen: false)
                        .userDetails,
              ),
            ),
          );
          setState(() {}); // Refresh the UI after returning
        },
      },
      {
        'icon': Icons.history,
        'label': 'Scan History',
        'onTap': () {
          Navigator.push(
            context,
            SlideUpRoute(
              // Use SlideUpRoute for slide-up animation
              page: const ScanHistoryScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.help,
        'label': 'Help & Support',
        'onTap': () {
          Navigator.of(context).pushNamed('/help');
        },
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: settingsItems.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: colorScheme.onSurface.withOpacity(0.1),
            ),
            itemBuilder: (context, index) {
              final item = settingsItems[index];
              return ListTile(
                leading: Icon(
                  item['icon'] as IconData,
                  color: colorScheme.primary,
                ),
                title: Text(item['label'] as String),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                onTap: item['onTap'] as void Function(),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: colorScheme.error,
            ),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: authProvider.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.error),
                    ),
                  )
                : null,
            onTap: authProvider.isLoading
                ? null
                : () async {
                    try {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Sign out error in profile page: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Failed to sign out. Please try again.'),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
    );
  }
}
