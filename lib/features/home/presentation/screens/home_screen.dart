import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/home_logo.dart';
import '../widgets/app_title.dart';
import '../widgets/feature_item.dart';
import '../widgets/action_button.dart';
import '../../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final HomeController _controller = HomeController();

  HomeScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const HomeLogo(),
                  const SizedBox(height: 32),
                  const AppTitle(),
                  const SizedBox(height: 48),
                  const FeatureItem(
                    icon: Icons.camera_alt,
                    text: 'Fast Image Capture',
                  ),
                  const SizedBox(height: 16),
                  const FeatureItem(
                    icon: Icons.qr_code_2,
                    text: 'QR Code Detection',
                  ),
                  const SizedBox(height: 16),
                  const FeatureItem(
                    icon: Icons.barcode_reader,
                    text: 'Barcode Detection',
                  ),
                  const SizedBox(height: 16),
                  const FeatureItem(
                    icon: Icons.collections,
                    text: 'Multiple Codes per Image',
                  ),
                  const SizedBox(height: 48),
                  ActionButton(
                    text: 'Open Camera',
                    icon: Icons.camera_alt,
                    onPressed: () =>
                        _controller.navigateToCamera(context, cameras),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
