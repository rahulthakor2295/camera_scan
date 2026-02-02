import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: cameras.isEmpty
          ? const Scaffold(
              body: Center(
                child: Text(
                  'No cameras available',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          : SplashScreen(cameras: cameras),
    );
  }
}
