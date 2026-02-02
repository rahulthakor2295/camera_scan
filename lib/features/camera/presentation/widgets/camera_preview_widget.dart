import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../controller/scan_controller.dart';

class CameraPreviewWidget extends StatelessWidget {
  final ScanController controller;

  const CameraPreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.isInitialized || controller.cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => controller.onTapToFocus(details, constraints),
          child: SizedBox.expand(
            child: CameraPreview(controller.cameraController!),
          ),
        );
      },
    );
  }
}
