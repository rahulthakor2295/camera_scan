import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../camera/presentation/screens/camera_screen.dart';

class HomeController {
  void navigateToCamera(BuildContext context, List<CameraDescription> cameras) {
    // Using named route is cleaner, but for now explicitly pushing to match existing flow logic
    // or we can use the route definition if we set it up.
    // Given the prompt asked for "routes", let's try to use generic navigation or keep it simple.
    // For now, I will keep the direct push but prepare for named routes.

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(cameras: cameras),
      ),
    );
  }
}
