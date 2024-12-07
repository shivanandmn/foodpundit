import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodpundit/config/environment_config.dart';
import 'dart:convert'; // Import json library

enum WorkoutLevel { none, beginner, intermediate, advanced }

enum HealthCondition {
  none, // No specific health condition
  diabetic, // Requires monitoring sugar intake
  thyroid, // Affects metabolism and dietary needs
  highBloodPressure, // Requires monitoring sodium intake
  glutenIntolerant, // Cannot consume gluten
  lactoseIntolerant, // Cannot digest dairy products
  vegetarian, // Does not eat meat
  vegan, // Does not consume any animal products
  kosher, // Follows kosher dietary laws
  halal // Follows halal dietary laws
}

class UserDetails {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final DateTime? birthDate;
  final double? heightCm;
  final double? weightKg;
  final WorkoutLevel workoutLevel;
  final List<HealthCondition> healthConditions;
  final List<String> allergies;
  final bool isCalorieCounter;
  final DateTime? dateJoined;
  final int totalScans;
  final Map<String, bool> preferences;
  final String? phoneNumber;
  final List<Map<String, dynamic>> product_history;
  final List<Map<String, dynamic>> favorites;

  UserDetails({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.workoutLevel = WorkoutLevel.none,
    this.healthConditions = const [],
    this.allergies = const [],
    this.isCalorieCounter = false,
    this.dateJoined,
    this.totalScans = 0,
    this.preferences = const {},
    this.phoneNumber,
    this.product_history = const [],
    this.favorites = const [],
  });

  // Calculate BMI if height and weight are available
  double? get bmi {
    if (heightCm != null && weightKg != null && heightCm! > 0) {
      final heightMeters = heightCm! / 100;
      return weightKg! / (heightMeters * heightMeters);
    }
    return null;
  }

  // Calculate age from birthDate
  int? get age {
    if (birthDate != null) {
      return DateTime.now().difference(birthDate!).inDays ~/ 365;
    }
    return null;
  }

  // Calculate profile completion percentage
  double get profileCompletionPercentage {
    int totalFields = 6; // Total number of required profile fields
    int completedFields = 0;

    // if (displayName != null && displayName!.isNotEmpty) completedFields++;
    // if (photoURL != null && photoURL!.isNotEmpty) completedFields++;
    if (birthDate != null) completedFields++;
    if (heightCm != null) completedFields++;
    if (weightKg != null) completedFields++;
    if (workoutLevel != WorkoutLevel.none) completedFields++;
    if (healthConditions.isNotEmpty) completedFields++;
    if (allergies.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  // Get incomplete profile fields
  List<String> get incompleteFields {
    List<String> fields = [];

    // if (displayName == null || displayName!.isEmpty) fields.add('Display Name');
    // if (photoURL == null || photoURL!.isEmpty) fields.add('Profile Photo');
    if (birthDate == null) fields.add('Birth Date');
    if (heightCm == null) fields.add('Height');
    if (weightKg == null) fields.add('Weight');
    if (workoutLevel == WorkoutLevel.none) fields.add('Workout Level');
    if (healthConditions.isEmpty) fields.add('Health Conditions');
    if (allergies.isEmpty) fields.add('Allergies');

    return fields;
  }

  // Factory constructor to create UserDetails from Firebase User
  static Future<UserDetails?> fromFirebaseUser(User user) async {
    try {
      // Try to fetch user details from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection(EnvironmentConfig.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // If user exists in Firestore, return the UserDetails
        return UserDetails.fromFirestore(userDoc);
      }

      // If user doesn't exist in Firestore, create new UserDetails
      final newUser = UserDetails(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        emailVerified: user.emailVerified,
        birthDate: null,
        heightCm: null,
        weightKg: null,
        workoutLevel: WorkoutLevel.none,
        healthConditions: [HealthCondition.none],
        allergies: [],
        isCalorieCounter: false,
        dateJoined: DateTime.now(),
        totalScans: 0,
        preferences: const {
          'showCalories': true,
          'showAllergens': true,
          'showNutritionScore': true,
          'enableScanHistory': true,
        },
        phoneNumber: null,
        product_history: [],
        favorites: [],
      );

      // Save new user to Firestore
      await FirebaseFirestore.instance
          .collection(EnvironmentConfig.usersCollection)
          .doc(user.uid)
          .set(newUser.toFirestore());

      return newUser;
    } catch (e) {
      print('Error creating UserDetails from Firebase User: $e');
      // Fallback to basic user details if Firestore operations fail
      return UserDetails(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        emailVerified: user.emailVerified,
        product_history: [],
        favorites: [],
      );
    }
  }

  // Create empty user details
  factory UserDetails.empty() {
    return UserDetails();
  }

  // Convert UserDetails to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'workoutLevel': workoutLevel.index,
      'healthConditions': healthConditions.map((e) => e.index).toList(),
      'allergies': allergies,
      'isCalorieCounter': isCalorieCounter,
      'dateJoined': dateJoined?.millisecondsSinceEpoch,
      'totalScans': totalScans,
      'preferences': preferences,
      'phoneNumber': phoneNumber,
      'product_history': _convertListForStorage(product_history),
      'favorites': _convertListForStorage(favorites),
    };
  }

  // Helper method to convert lists containing Timestamp objects for storage
  List<Map<String, dynamic>> _convertListForStorage(
      List<Map<String, dynamic>> list) {
    return list.map((item) {
      var newItem = Map<String, dynamic>.from(item);
      newItem.forEach((key, value) {
        if (value is Timestamp) {
          newItem[key] = value.toDate().millisecondsSinceEpoch;
        } else if (value is DateTime) {
          newItem[key] = value.millisecondsSinceEpoch;
        } else if (value is Map) {
          newItem[key] = _convertMapForStorage(value);
        } else if (value is List) {
          newItem[key] = _convertListItemsForStorage(value);
        }
      });
      return newItem;
    }).toList();
  }

  // Helper method to convert maps containing Timestamp objects for storage
  Map<String, dynamic> _convertMapForStorage(Map<dynamic, dynamic> map) {
    var newMap = Map<String, dynamic>.from(map);
    newMap.forEach((key, value) {
      if (value is Timestamp) {
        newMap[key] = value.toDate().millisecondsSinceEpoch;
      } else if (value is DateTime) {
        newMap[key] = value.millisecondsSinceEpoch;
      } else if (value is Map) {
        newMap[key] = _convertMapForStorage(value);
      } else if (value is List) {
        newMap[key] = _convertListItemsForStorage(value);
      }
    });
    return newMap;
  }

  // Helper method to convert list items containing Timestamp objects for storage
  List<dynamic> _convertListItemsForStorage(List<dynamic> list) {
    return list.map((item) {
      if (item is Timestamp) {
        return item.toDate().millisecondsSinceEpoch;
      } else if (item is DateTime) {
        return item.millisecondsSinceEpoch;
      } else if (item is Map) {
        return _convertMapForStorage(item);
      } else if (item is List) {
        return _convertListItemsForStorage(item);
      }
      return item;
    }).toList();
  }

  // Convert UserDetails to JSON string
  String toJson() {
    return json.encode(toMap());
  }

  // Create UserDetails from JSON string
  factory UserDetails.fromJson(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return UserDetails.fromMap(map);
  }

  // Create UserDetails from a map
  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      emailVerified: map['emailVerified'] as bool? ?? false,
      birthDate: map['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['birthDate'] as int)
          : null,
      heightCm: map['heightCm']?.toDouble(),
      weightKg: map['weightKg']?.toDouble(),
      workoutLevel: map['workoutLevel'] != null
          ? WorkoutLevel.values[map['workoutLevel'] as int]
          : WorkoutLevel.none,
      healthConditions: map['healthConditions'] != null
          ? (map['healthConditions'] as List)
              .map((e) => HealthCondition.values[e as int])
              .toList()
          : [HealthCondition.none],
      allergies: map['allergies'] != null
          ? List<String>.from(map['allergies'] as List)
          : [],
      isCalorieCounter: map['isCalorieCounter'] as bool? ?? false,
      dateJoined: map['dateJoined'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateJoined'] as int)
          : null,
      totalScans: map['totalScans'] as int? ?? 0,
      preferences: map['preferences'] != null
          ? Map<String, bool>.from(map['preferences'] as Map)
          : {},
      phoneNumber: map['phoneNumber'] as String?,
      product_history: map['product_history'] != null
          ? List<Map<String, dynamic>>.from(map['product_history'] as List)
          : [],
      favorites: map['favorites'] != null
          ? List<Map<String, dynamic>>.from(map['favorites'] as List)
          : [],
    );
  }

  // Create a copy of UserDetails with optional field updates
  UserDetails copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    WorkoutLevel? workoutLevel,
    List<HealthCondition>? healthConditions,
    List<String>? allergies,
    bool? isCalorieCounter,
    DateTime? dateJoined,
    int? totalScans,
    Map<String, bool>? preferences,
    String? phoneNumber,
    List<Map<String, dynamic>>? product_history,
    List<Map<String, dynamic>>? favorites,
  }) {
    return UserDetails(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      workoutLevel: workoutLevel ?? this.workoutLevel,
      healthConditions: healthConditions ?? List.from(this.healthConditions),
      allergies: allergies ?? List.from(this.allergies),
      isCalorieCounter: isCalorieCounter ?? this.isCalorieCounter,
      dateJoined: dateJoined ?? this.dateJoined,
      totalScans: totalScans ?? this.totalScans,
      preferences: preferences ?? Map.from(this.preferences),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      product_history: product_history ?? List.from(this.product_history),
      favorites: favorites ?? List.from(this.favorites),
    );
  }

  factory UserDetails.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserDetails(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      workoutLevel: WorkoutLevel.values.firstWhere(
          (e) => e.toString() == data['workoutLevel'],
          orElse: () => WorkoutLevel.none),
      healthConditions: (data['healthConditions'] as List<dynamic>?)
              ?.map((condition) => HealthCondition.values.firstWhere(
                  (e) => e.toString() == condition,
                  orElse: () => HealthCondition.none))
              .toList() ??
          [],
      allergies: (data['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
      isCalorieCounter: data['isCalorieCounter'] as bool? ?? false,
      dateJoined: data['dateJoined'] != null
          ? (data['dateJoined'] as Timestamp).toDate()
          : null,
      totalScans: data['totalScans'] as int? ?? 0,
      preferences: (data['preferences'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as bool)) ??
          {},
      phoneNumber: data['phoneNumber'] as String?,
      product_history: (data['product_history'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      favorites: (data['favorites'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'workoutLevel': workoutLevel.toString(),
      'healthConditions':
          healthConditions.map((condition) => condition.toString()).toList(),
      'allergies': allergies,
      'isCalorieCounter': isCalorieCounter,
      'dateJoined': dateJoined != null ? Timestamp.fromDate(dateJoined!) : null,
      'totalScans': totalScans,
      'preferences': preferences,
      'phoneNumber': phoneNumber,
      'product_history': product_history,
      'favorites': favorites,
    };
  }
}
