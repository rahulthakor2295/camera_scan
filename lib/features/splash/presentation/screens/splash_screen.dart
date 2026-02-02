import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const SplashScreen({super.key, required this.cameras});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(cameras: widget.cameras),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Using error handling if asset missing, or just assume it's there as per original
              Image.asset(
                'assets/images/ic_logo.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.qr_code_scanner,
                    size: 100,
                    color: AppColors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'FlashScan',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lightning Fast Detection',
                style: TextStyle(
                  color: AppColors.whiteOpacity60,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
