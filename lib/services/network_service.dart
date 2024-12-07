import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService extends ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  final Connectivity _connectivity = Connectivity();
  bool _hasConnection = true;
  bool _isCheckingConnection = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  DateTime? _lastCheckTime;
  static const _minCheckInterval = Duration(seconds: 2);

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal() {
    _initConnectivity();
  }

  bool get hasConnection => _hasConnection;
  bool get isCheckingConnection => _isCheckingConnection;

  Future<void> _initConnectivity() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
      _connectivitySubscription?.cancel();
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    } catch (e) {
      debugPrint('Connectivity initialization error: $e');
      _hasConnection = true;
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    bool hasInternet = false;

    if (result != ConnectivityResult.none) {
      try {
        final lookupResult = await InternetAddress.lookup('google.com');
        hasInternet =
            lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        hasInternet = false;
      }
    }

    if (_hasConnection != hasInternet) {
      _hasConnection = hasInternet;
      notifyListeners();
    }
  }

  String getConnectionType() {
    return _hasConnection ? 'Connected' : 'Disconnected';
  }

  Future<bool> checkConnection() async {
    // Prevent multiple simultaneous checks
    if (_isCheckingConnection) return _hasConnection;

    // Rate limit checks
    if (_lastCheckTime != null) {
      final timeSinceLastCheck = DateTime.now().difference(_lastCheckTime!);
      if (timeSinceLastCheck < _minCheckInterval) {
        return _hasConnection;
      }
    }

    _isCheckingConnection = true;
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(results);
    } finally {
      _isCheckingConnection = false;
      _lastCheckTime = DateTime.now();
    }
    return _hasConnection;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
