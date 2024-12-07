import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user_details.dart';
import '../providers/app_auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added import for Timestamp

class OfflineProfileService {
  static const String _offlineProfileKey = 'offline_profile_data';
  static const String _pendingUpdatesKey = 'pending_profile_updates';
  
  // Save profile data locally only
  Future<void> saveProfileData(Map<String, dynamic> profileData) async {
    // Convert any remaining Timestamp objects to milliseconds
    Map<String, dynamic> encodableData = Map.from(profileData);
    _convertTimestamps(encodableData);
    await _savePendingUpdate(encodableData);
  }

  void _convertTimestamps(dynamic data) {
    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        if (value is Timestamp) {
          data[key] = value.toDate().millisecondsSinceEpoch;
        } else if (value is Map || value is List) {
          _convertTimestamps(value);
        }
      });
    } else if (data is List) {
      for (var i = 0; i < data.length; i++) {
        if (data[i] is Timestamp) {
          data[i] = (data[i] as Timestamp).toDate().millisecondsSinceEpoch;
        } else if (data[i] is Map || data[i] is List) {
          _convertTimestamps(data[i]);
        }
      }
    }
  }

  // Save a pending update
  Future<void> _savePendingUpdate(Map<String, dynamic> profileData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> pendingUpdates = prefs.getStringList(_pendingUpdatesKey) ?? [];
    
    // Add new update to pending list
    pendingUpdates.add(jsonEncode(profileData));
    
    // Save updated list
    await prefs.setStringList(_pendingUpdatesKey, pendingUpdates);
  }

  // Convert string to HealthCondition enum
  HealthCondition _stringToHealthCondition(String value) {
    return HealthCondition.values.firstWhere(
      (e) => e.toString() == 'HealthCondition.$value',
      orElse: () => HealthCondition.none,
    );
  }

  // Sync all pending updates and return success status
  Future<bool> syncPendingUpdates(AppAuthProvider authProvider) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isOnline = connectivityResult != ConnectivityResult.none;
      
      if (!isOnline) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      List<String> pendingUpdates = prefs.getStringList(_pendingUpdatesKey) ?? [];
      
      if (pendingUpdates.isEmpty) return true;

      final currentUser = authProvider.userDetails;
      if (currentUser == null) return false;

      // Combine all updates into one
      Map<String, dynamic> finalUpdate = {};
      for (var update in pendingUpdates) {
        try {
          final updateData = jsonDecode(update) as Map<String, dynamic>;
          finalUpdate.addAll(updateData);
        } catch (e) {
          print('Error parsing update: $e');
        }
      }

      // Convert and apply the final update
      try {
        // Convert stored data back to appropriate types
        DateTime? birthDate;
        if (finalUpdate['birthDate'] != null) {
          try {
            birthDate = DateTime.parse(finalUpdate['birthDate']);
          } catch (e) {
            print('Error parsing birth date: $e');
          }
        }

        // Convert health conditions from strings to enum values
        List<HealthCondition>? healthConditions;
        if (finalUpdate['healthConditions'] != null) {
          try {
            healthConditions = (finalUpdate['healthConditions'] as List)
                .map((e) => _stringToHealthCondition(e.toString().split('.').last))
                .toList();
          } catch (e) {
            print('Error converting health conditions: $e');
          }
        }

        final updatedUser = currentUser.copyWith(
          birthDate: birthDate ?? currentUser.birthDate,
          heightCm: finalUpdate['heightCm']?.toDouble() ?? currentUser.heightCm,
          weightKg: finalUpdate['weightKg']?.toDouble() ?? currentUser.weightKg,
          workoutLevel: finalUpdate['workoutLevel'] != null 
              ? WorkoutLevel.values[finalUpdate['workoutLevel']] 
              : currentUser.workoutLevel,
          healthConditions: healthConditions ?? currentUser.healthConditions,
          allergies: (finalUpdate['allergies'] as List?)
              ?.map((e) => e.toString())
              .toList() 
              ?? currentUser.allergies,
        );

        await authProvider.updateUserDetails(updatedUser);
        
        // Clear pending updates after successful sync
        await prefs.setStringList(_pendingUpdatesKey, []);
        return true;
      } catch (e) {
        print('Error applying final update: $e');
        return false;
      }
    } catch (e) {
      print('Error in sync process: $e');
      return false;
    }
  }

  // Check if there are pending updates
  Future<bool> hasPendingUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingUpdates = prefs.getStringList(_pendingUpdatesKey) ?? [];
    return pendingUpdates.isNotEmpty;
  }

  // Clear all offline profile data
  Future<void> clearOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineProfileKey);
    await prefs.remove(_pendingUpdatesKey);
  }
}
