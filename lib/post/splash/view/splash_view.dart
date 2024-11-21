import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product_app/post/splash/controller/splash_controller.dart';

class SplashView extends StatefulWidget {
  SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Subtle zoom-out effect duration
    )..forward(); // Start the animation
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashController = Get.put(SplashController());

    return Scaffold(
      body: Stack(
        children: [
          // Animated background image with subtle zoom-out effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final scale = 1.2 - _animationController.value * 0.2;
                return Transform.scale(
                  scale: scale, // Subtle zoom-out from 1.2 to 1.0
                  child: child,
                );
              },
              child: Image.asset(
                'assets/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                const SizedBox(height: 100),
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
