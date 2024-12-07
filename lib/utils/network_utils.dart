import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  static Future<bool> hasInternetConnection() async {
    try {
      // Try multiple reliable hosts
      final List<String> lookupAddresses = [
        'google.com',
        'apple.com',
        'cloudflare.com',
        '8.8.8.8', // Google DNS
      ];

      bool isConnected = false;
      
      for (final address in lookupAddresses) {
        try {
          debugPrint('🔍 Checking connection to $address...');
          final result = await InternetAddress.lookup(address)
              .timeout(const Duration(seconds: 5));
          
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            // Also try to establish a socket connection
            final socket = await Socket.connect(address, 80, 
                timeout: const Duration(seconds: 5));
            await socket.close();
            
            isConnected = true;
            debugPrint('✅ Connected successfully to $address');
            break;
          }
        } catch (e) {
          debugPrint('❌ Failed to connect to $address: $e');
          continue;
        }
      }

      if (!isConnected) {
        debugPrint('❌ No internet connection available');
      }
      
      return isConnected;
    } catch (e) {
      debugPrint('❌ Error checking internet connection: $e');
      return false;
    }
  }
}
