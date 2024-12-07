import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:foodpundit/screens/camera/painters/camera_overlay_painters.dart';
import 'package:foodpundit/utils/ui_constants.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_auth_provider.dart';
import '../../../widgets/error_dialog.dart';
import '../../../models/process_image_response.dart';
import 'package:foodpundit/features/product_details/presentation/pages/product_details_page.dart';
import 'components/camera_overlay.dart';
import 'components/custom_painted_text.dart';
import 'controllers/camera_controller.dart';
import 'package:foodpundit/screens/loading/ai_processing_page.dart';

class CameraPage extends StatefulWidget {
  final CameraController controller;

  const CameraPage({
    super.key,
    required this.controller,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late CameraPageController _cameraController;
  bool _isCameraActive = true;
  bool _isProcessing = false;
  String? _processingError;
  XFile? _capturedImage;
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _cameraController = CameraPageController(cameraController: _controller);
    _setupAnimations();
    _initializeCamera();
    _cameraController.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild UI when controller state changes
      }
    });
  }

  void _setupAnimations() {
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _arrowAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(_arrowAnimationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _arrowAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _arrowAnimationController.forward();
        }
      });

    _arrowAnimationController.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isCameraActive = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
    }
  }

  Future<void> _resetCamera() async {
    try {
      debugPrint('📸 Resetting camera...');
      final cameras = await availableCameras();
      final newController = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );

      // Initialize new controller before disposing old one
      await newController.initialize();

      if (!mounted) {
        await newController.dispose();
        return;
      }

      // Dispose old controller and update state
      final oldController = _controller;
      setState(() {
        _controller = newController;
        _cameraController =
            CameraPageController(cameraController: newController);
        _isCameraActive = true;
        _isProcessing = false;
        _capturedImage = null;
      });

      // Dispose old controller after state is updated
      await oldController.dispose();
    } catch (e) {
      debugPrint('❌ Error resetting camera: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showError(String title, String message,
      {VoidCallback? onRetry,
      VoidCallback? onDismiss,
      bool showOkButton = true}) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        onDismiss: onDismiss,
        showOkButton: showOkButton,
      ),
    );
  }

  Future<void> _processImage(XFile image) async {
    try {
      debugPrint('🔍 Checking internet connection...');
      final hasInternet = await _cameraController.checkInternetConnection();
      if (!hasInternet) {
        debugPrint('❌ No internet connection detected');
        throw Exception('No internet connection');
      }
      debugPrint('✅ Internet connection available');

      debugPrint('🔑 Getting user ID...');
      final userId =
          Provider.of<AppAuthProvider>(context, listen: false).user!.uid;
      debugPrint('📤 Starting image processing with userId: $userId');

      // Show AI Processing dialog and deactivate camera
      if (!mounted) return;
      setState(() {
        _isCameraActive = false;
      });
      debugPrint('🔄 Showing AI Processing dialog...');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const AiProcessingPage(),
          );
        },
      );

      // Start API call
      debugPrint('📍 Starting image processing...');
      final Future<ProcessImageResponse> futureResponse =
          _cameraController.processImage(image, userId);

      // Wait for API response
      debugPrint('⏳ Waiting for API response...');
      final response = await futureResponse;
      debugPrint('📥 Received API response: ${response.success}');

      if (!mounted) {
        debugPrint('❌ Widget not mounted, returning early');
        return;
      }

      if (response == null) {
        debugPrint('❌ Response is null');
        throw Exception('Failed to get response from server');
      }

      debugPrint('📍 Checking response success: ${response.success}');

      if (!response.success) {
        debugPrint('❌ Response unsuccessful: ${response.error?.message}');
        setState(() {
          _isProcessing = false;
          _processingError = response.error?.message;
        });

        // Remove AI Processing dialog
        if (Navigator.of(context).canPop()) {
          debugPrint('🔄 Removing AI Processing dialog...');
          Navigator.of(context).pop();
        }

        if (!mounted) return;

        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'We couldn\'t process this image. Please try taking valid photo.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.withOpacity(0.8),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        if (response.error?.shouldReturnToCamera == true) {
          setState(() {
            _capturedImage = null;
          });
        }
        return;
      }

      if (response.success && response.imageUrl != null) {
        debugPrint('✅ Processing successful, creating product...');
        final product = response.toProduct();
        if (product != null) {
          debugPrint('🎯 Navigating to Product Details page...');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                product: product,
                fromCamera: true,
              ),
            ),
          );
          return;
        }
      }

      // Handle error cases with specific messages
      debugPrint('📍 Entering error handling section');
      String errorMessage =
          'We couldn\'t process this image. Please try taking another photo.';
      debugPrint('❌ Error in response: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('📍 Caught exception: ${e.toString()}');

      // Ensure AI Processing dialog is removed in case of error
      if (Navigator.of(context).canPop()) {
        debugPrint('🔄 Removing AI Processing dialog (error case)...');
        Navigator.of(context).pop();
      }

      // Reset camera with new instance
      await _resetCamera();

      if (!mounted) return;

      // Show error message as an overlay on the camera screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('Exception:')
                ? e.toString().split('Exception: ')[1]
                : 'We couldn\'t process this image. Please try taking another valid photo.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.withOpacity(0.8),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_capturedImage != null) {
          setState(() {
            _capturedImage = null;
            _isProcessing = false;
            _processingError = null;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_isCameraActive && !_isProcessing)
              Center(
                child: CameraPreview(_controller),
              ),
            if (_capturedImage != null)
              Image.file(
                File(_capturedImage!.path),
                fit: BoxFit.cover,
              ),
            // Add camera overlay with guidance
            if (!_isProcessing && _capturedImage == null)
              CustomPaint(
                painter: CameraOverlayPainter(),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            // Header Text
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPaintedText(
                    text: 'Snap the Back Label',
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 40,
                  ),
                  CustomPaintedText(
                    text: 'Ingredients & Nutrition Info',
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 30,
                  ),
                ],
              ),
            ),
            if (!_isProcessing) ...[
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () {
                    // Clean up temporary file when closing without upload
                    if (_capturedImage != null) {
                      final file = File(_capturedImage!.path);
                      if (file.existsSync()) {
                        file.deleteSync();
                      }
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom +
                      UIConstants.spacingXL,
                  top: UIConstants.spacingXL,
                  left: UIConstants.spacingXL,
                  right: UIConstants.spacingXL,
                ),
                child: _isProcessing
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_processingError != null) ...[
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              Text(
                                _processingError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingXL),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isProcessing = false;
                                    _processingError = null;
                                    _capturedImage = null;
                                  });
                                },
                                child: const Text(
                                  'Try Again',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ] else ...[
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              const Text(
                                'Processing image...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_capturedImage == null) ...[
                            _buildCameraButton(
                              context,
                              icon: _cameraController.getFlashIcon(),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _cameraController.toggleFlash();
                              },
                            ),
                            _buildCameraButton(
                              context,
                              icon: Icons.camera,
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _captureImage();
                              },
                              isMain: true,
                            ),
                            _buildCameraButton(
                              context,
                              icon: Icons.photo_library,
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _pickImageFromGallery();
                              },
                            ),
                          ] else ...[
                            _buildCameraButton(
                              context,
                              icon: Icons.close,
                              onPressed: () {
                                setState(() {
                                  _capturedImage = null;
                                });
                              },
                            ),
                            _buildCameraButton(
                              context,
                              icon: Icons.check,
                              onPressed: () async {
                                // Check internet connectivity first
                                final hasInternet = await _cameraController
                                    .checkInternetConnection();
                                if (!hasInternet) {
                                  _showError(
                                    'No Internet Connection',
                                    'Please check your internet connection and try again.',
                                    onRetry: () async {
                                      final hasInternet =
                                          await _cameraController
                                              .checkInternetConnection();
                                      if (hasInternet) {
                                        _processImage(_capturedImage!);
                                      } else {
                                        _showError(
                                          'Still No Connection',
                                          'Please ensure you have a stable internet connection.',
                                        );
                                      }
                                    },
                                  );
                                  return;
                                }

                                setState(() {
                                  _isProcessing = true;
                                  _processingError = null;
                                });

                                _processImage(_capturedImage!);
                              },
                              isMain: true,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _captureImage() async {
    try {
      final image = await _controller.takePicture();
      if (mounted) {
        setState(() {
          _capturedImage = image;
          _isProcessing =
              false; // Ensure processing is false to show the preview
          _processingError = null;
        });
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      _showError(
        'Camera Error',
        'Failed to capture image. Please try again.',
        showOkButton: true,
      );
    }
  }

  void _pickImageFromGallery() async {
    try {
      final XFile? image = await _cameraController.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showError(
        'Image Pick Error',
        'Failed to pick image from gallery. Please try again.',
        showOkButton: true,
      );
    }
  }

  Widget _buildCameraButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    bool isMain = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = isMain ? UIConstants.spacingXXL * 1.5 : UIConstants.spacingXXL;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMain
                ? colorScheme.primary.withOpacity(UIConstants.opacityHigh)
                : colorScheme.surface.withOpacity(UIConstants.opacityLow),
          ),
          child: Icon(
            icon,
            color: isMain
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withOpacity(UIConstants.opacityHigh),
            size: isMain ? UIConstants.spacingXL : UIConstants.spacingL,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
