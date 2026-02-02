import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../core/constants/app_colors.dart';
import '../../controller/scan_controller.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/focus_indicator.dart';
import '../widgets/zoom_controls.dart';
import '../widgets/capture_controls.dart';
import '../widgets/image_counter_badge.dart';
import 'results_screen.dart'; // We need this import or we need to move it

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late ScanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScanController(widget.cameras);
    _controller.initializeCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleStopCapture() {
    if (_controller.capturedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images captured')),
      );
      return;
    }

    _controller.isCapturing = false;
    // Notify listeners if needed or just navigate
    // In strict patterns, controller should notify, but for navigation we do it here

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
            imagePaths: List.from(_controller.capturedImagePaths)),
      ),
    ).then((_) {
      _controller.clearImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (!_controller.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // Preview
              Positioned.fill(
                child: CameraPreviewWidget(controller: _controller),
              ),

              // Focus Indicator
              if (_controller.showFocusIndicator &&
                  _controller.focusPoint != null)
                FocusIndicator(position: _controller.focusPoint!),

              // Image Counter (Top Right)
              if (_controller.isCapturing)
                Positioned(
                  top: 60,
                  right: 20,
                  child: ImageCounterBadge(
                      count: _controller.capturedImagePaths.length),
                ),

              // Zoom Controls (Bottom Center, above capture area)
              if (_controller.availableZoomLevels.length > 1 &&
                  !_controller.isCapturing)
                Positioned(
                  bottom: 180,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ZoomControls(controller: _controller),
                  ),
                ),

              // Capture Controls (Bottom Area)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: CaptureControls(
                      controller: _controller,
                      onStop: _handleStopCapture,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
