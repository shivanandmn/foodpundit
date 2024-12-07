import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foodpundit/utils/ui_constants.dart';
import 'package:foodpundit/screens/home/home_page.dart';
import '../history_page.dart';

class AiProcessingPage extends StatefulWidget {
  final String? status;
  final double? progress;
  final String? error;
  final VoidCallback? onRetry;

  const AiProcessingPage({
    super.key,
    this.status,
    this.progress,
    this.error,
    this.onRetry,
  });

  @override
  State<AiProcessingPage> createState() => _AiProcessingPageState();
}

class _AiProcessingPageState extends State<AiProcessingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  int _currentTextIndex = 0;

  final List<String> _processingStages = [
    '🧐 Just checking out your photo!',
    '🌿 Pulling details from the label!',
    '🍎 Gathering nutritional data!',
    '🔍 Fine-tuning the specifics!',
    '💡 Compiling the good stuff!',
    '✨ Just polishing things up!'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Change text every 3 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % _processingStages.length;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.error == null) ...[
                  // Custom animated loading indicator
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating circle
                        AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: widget.progress,
                                    strokeWidth: 4,
                                    color: Colors.white,
                                  ),
                                  // Add small circles around the main circle
                                  ...List.generate(8, (index) {
                                    final angle = (index * 3.14159 * 2) / 8;
                                    return Transform.translate(
                                      offset: Offset(
                                        cos(angle) * 60,
                                        sin(angle) * 60,
                                      ),
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                        // Pulsing inner circle
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXL),

                  // Progress indicator
                  if (widget.progress != null) ...[
                    LinearProgressIndicator(
                      value: widget.progress,
                      backgroundColor: Colors.grey[800],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                  ],

                  // Animated status text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      widget.status ?? _processingStages[_currentTextIndex],
                      key: ValueKey<String>(widget.status ??
                          _processingStages[_currentTextIndex]),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXL),
                  // Processing time message
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingL,
                      vertical: UIConstants.spacingM,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'This might take a few minutes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: UIConstants.spacingS),
                        Text(
                          'You can exit now and check your results later in the history page',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingL),
                  // Exit to History button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(
                              initialIndex:
                                  1), // 1 is the index for history tab
                        ),
                      );
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit to History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.spacingXL,
                        vertical: UIConstants.spacingM,
                      ),
                    ),
                  ),
                ] else ...[
                  // Error state with shake animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(sin(value * 3 * pi) * 10, 0),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        Text(
                          'Error',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        Text(
                          widget.error!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        if (widget.onRetry != null)
                          ElevatedButton.icon(
                            onPressed: widget.onRetry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: UIConstants.spacingL,
                                vertical: UIConstants.spacingM,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
