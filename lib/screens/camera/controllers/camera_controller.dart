import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodpundit/config/environment_config.dart';
import 'package:foodpundit/models/error_code.dart';
import '../../../models/process_image_response.dart';
import '../../../models/error_response.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'dart:io';

class CameraPageController extends ChangeNotifier {
  final CameraController cameraController;
  final ImagePicker _imagePicker = ImagePicker();
  final Connectivity _connectivity = Connectivity();
  final String _baseUrl = EnvironmentConfig.baseUrl;

  CameraPageController({required this.cameraController});

  Future<bool> checkInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<XFile?> captureImage() async {
    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<void> toggleFlash() async {
    try {
      final FlashMode currentMode = cameraController.value.flashMode;
      FlashMode newMode;

      switch (currentMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.off;
          break;
        default:
          newMode = FlashMode.auto;
      }

      await cameraController.setFlashMode(newMode);
      notifyListeners(); // Notify UI about flash mode change
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> initializeCamera() async {
    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(FlashMode.auto);
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  FlashMode getCurrentFlashMode() {
    return cameraController.value.flashMode;
  }

  IconData getFlashIcon() {
    switch (cameraController.value.flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_auto;
    }
  }

  Future<ProcessImageResponse> processImage(XFile image, String userId) async {
    try {
      debugPrint('🚀 Starting API call to process image...');
      final url = Uri.parse('$_baseUrl/$userId');

      // Get file extension
      final String extension = image.path.split('.').last.toLowerCase();
      List<int> processedImageBytes;

      // Handle HEIC format first
      if (extension == 'heic' || extension == 'heif') {
        debugPrint('🔄 Converting HEIC image to JPEG...');
        try {
          final String? jpgPath = await HeicToJpg.convert(image.path);
          if (jpgPath == null) {
            throw Exception('Failed to convert HEIC to JPEG');
          }
          processedImageBytes = await File(jpgPath).readAsBytes();
          debugPrint('✅ HEIC image converted to JPEG successfully');
        } catch (e) {
          debugPrint('❌ Error converting HEIC: $e');
          // Fallback to reading original bytes
          processedImageBytes = await image.readAsBytes();
        }
      } else {
        // Handle other formats
        final imageBytes = await image.readAsBytes();
        debugPrint(
            '📸 Image read successfully, size: ${imageBytes.length} bytes');

        if (extension != 'jpg' && extension != 'jpeg') {
          debugPrint(
              '🔄 Converting ${extension.toUpperCase()} image to JPEG...');
          try {
            final decodedImage = img.decodeImage(imageBytes);
            if (decodedImage == null) {
              throw Exception('Failed to decode image');
            }
            processedImageBytes = img.encodeJpg(decodedImage, quality: 85);
            debugPrint('✅ Image converted to JPEG successfully');
          } catch (e) {
            debugPrint('❌ Error converting image: $e');
            processedImageBytes = imageBytes;
          }
        } else {
          processedImageBytes = imageBytes;
        }
      }

      final request = http.MultipartRequest('POST', url)
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            processedImageBytes,
            filename: '${image.name.split('.')[0]}.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        )
        ..fields['userId'] = userId;

      debugPrint('📤 Sending request to: $url');
      final response = await request.send();
      debugPrint('📥 Got response with status: ${response.statusCode}');

      final responseData = await response.stream.bytesToString();
      debugPrint('📦 Response data received: $responseData');

      final jsonResponse = json.decode(responseData);
      debugPrint('✅ Response parsed: $jsonResponse');

      if (response.statusCode != 200) {
        debugPrint('❌ Server error: ${response.statusCode}');
        final errorMessage = response.statusCode == 422
            ? 'Failed to upload image. Please try again.'
            : 'Server error: ${jsonResponse['message'] ?? 'Unknown error'}';

        return ProcessImageResponse(
          success: false,
          error: ErrorResponse(
            code: ErrorCode.processingError,
            message: errorMessage,
            shouldReturnToCamera: response.statusCode == 422,
          ),
        );
      }

      return ProcessImageResponse.fromJson(jsonResponse);
    } catch (e) {
      debugPrint('❌ Error processing image: $e');
      return ProcessImageResponse(
        success: false,
        error: ErrorResponse(
          code: ErrorCode.processingError,
          message: 'Failed to process image: ${e.toString()}',
        ),
      );
    }
  }

  // Helper method to determine MIME type
  String _getMimeType(String extension) {
    switch (extension) {
      case 'heic':
        return 'heic';
      case 'heif':
        return 'heif';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'webp':
        return 'webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'jpeg';
    }
  }

  @override
  void dispose() {
    if (cameraController.value.isInitialized) {
      cameraController.dispose();
    }
    super.dispose();
  }
}
