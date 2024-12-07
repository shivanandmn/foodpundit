import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_details.dart';
import '../../providers/app_auth_provider.dart';
import 'pages/basic_info_page.dart';
import 'pages/workout_level_page.dart';
import 'pages/health_conditions_page.dart';
import 'pages/allergies_page.dart';
import 'pages/review_page.dart';

class ProfileSetupFlow extends StatefulWidget {
  final UserDetails? existingDetails;
  
  const ProfileSetupFlow({
    Key? key,
    this.existingDetails,
  }) : super(key: key);

  @override
  State<ProfileSetupFlow> createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends State<ProfileSetupFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // User details being collected
  DateTime? _birthDate;
  double? _heightCm;
  double? _weightKg;
  WorkoutLevel _workoutLevel = WorkoutLevel.none;
  var _healthConditions = <HealthCondition>{};
  var _allergies = <String>[];
  bool _isCalorieCounter = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingDetails != null) {
      // If we have existing details, use them immediately
      _initializeWithExistingDetails(widget.existingDetails!);
      _isLoading = false;
    } else {
      // Otherwise fetch from the provider
      _loadUserData();
    }
  }

  void _initializeWithExistingDetails(UserDetails details) {
    _birthDate = details.birthDate;
    _heightCm = details.heightCm;
    _weightKg = details.weightKg;
    _workoutLevel = details.workoutLevel;
    _healthConditions = details.healthConditions.toSet();
    _allergies = details.allergies;
    _isCalorieCounter = details.isCalorieCounter;
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final userDetails = await authProvider.fetchUserDetails();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (userDetails != null) {
          _initializeWithExistingDetails(userDetails);
        }
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = [
      'Basic Information',
      'Workout Level',
      'Health Conditions',
      'Allergies',
      'Review',
    ][_currentPage];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
            key: _formKey,
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                BasicInfoPage(
                  birthDate: _birthDate,
                  height: _heightCm,
                  weight: _weightKg,
                  onBirthDateChanged: (date) => setState(() => _birthDate = date),
                  onHeightChanged: (height) => setState(() => _heightCm = height),
                  onWeightChanged: (weight) => setState(() => _weightKg = weight),
                ),
                WorkoutLevelPage(
                  workoutLevel: _workoutLevel,
                  onWorkoutLevelChanged: (level) =>
                      setState(() => _workoutLevel = level),
                ),
                HealthConditionsPage(
                  selectedConditions: _healthConditions,
                  onConditionsChanged: (conditions) =>
                      setState(() => _healthConditions = conditions),
                ),
                AllergiesPage(
                  allergies: _allergies,
                  isCalorieCounter: _isCalorieCounter,
                  onAllergiesChanged: (allergies) =>
                      setState(() => _allergies = allergies),
                  onCalorieCounterChanged: (value) =>
                      setState(() => _isCalorieCounter = value),
                ),
                ReviewPage(
                  birthDate: _birthDate,
                  heightCm: _heightCm,
                  weightKg: _weightKg,
                  workoutLevel: _workoutLevel,
                  healthConditions: _healthConditions,
                  allergies: _allergies,
                  isCalorieCounter: _isCalorieCounter,
                ),
              ],
            ),
          ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(width: 88),
                    if (_currentPage < 4)
                      FilledButton.tonal(
                        onPressed: _nextPage,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(width: 120),
                  ],
                ),
              ),
            ),
    );
  }
}
