import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/file_utils.dart';

class ScanController extends ChangeNotifier {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  bool isInitialized = false;
  bool isCapturing = false;
  bool showShutterEffect = false;

  // Focus
  Offset? focusPoint;
  bool showFocusIndicator = false;

  // Zoom
  int currentCameraIndex = 0;
  double currentZoomLevel = 1.0;
  List<double> availableZoomLevels = [1.0];

  final List<String> capturedImagePaths = [];

  ScanController(this.cameras);

  Future<void> initializeCamera() async {
    if (cameras.isEmpty) return;

    _detectAvailableZoomLevels();

    cameraController = CameraController(
      cameras[currentCameraIndex],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController!.initialize();
      await cameraController!.setFocusMode(FocusMode.auto);
      await cameraController!.setExposureMode(ExposureMode.auto);

      isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _detectAvailableZoomLevels() {
    availableZoomLevels = [1.0];
    if (cameras.length > 1) {
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          if (camera.name.contains('wide')) {
            if (!availableZoomLevels.contains(0.5)) {
              availableZoomLevels.insert(0, 0.5);
            }
          } else if (camera.name.contains('telephoto') ||
              camera.name.contains('tele')) {
            if (!availableZoomLevels.contains(2.0)) {
              availableZoomLevels.add(2.0);
            }
          }
        }
      }
    }
    availableZoomLevels.sort();
  }

  Future<void> switchZoomLevel(double zoomLevel) async {
    if (currentZoomLevel == zoomLevel || isCapturing) return;

    currentZoomLevel = zoomLevel;
    isInitialized = false;
    notifyListeners();

    await cameraController?.dispose();

    int targetCameraIndex = 0;
    // Simple logic to find best camera for zoom; same as original
    if (zoomLevel == 0.5) {
      targetCameraIndex = cameras.indexWhere((c) =>
          c.lensDirection == CameraLensDirection.back &&
          c.name.contains('wide'));
    } else if (zoomLevel == 2.0) {
      targetCameraIndex = cameras.indexWhere((c) =>
          c.lensDirection == CameraLensDirection.back &&
          (c.name.contains('telephoto') || c.name.contains('tele')));
    } else {
      targetCameraIndex = cameras.indexWhere((c) =>
          c.lensDirection == CameraLensDirection.back &&
          !c.name.contains('wide') &&
          !c.name.contains('telephoto') &&
          !c.name.contains('tele'));
    }

    if (targetCameraIndex == -1) targetCameraIndex = 0;

    currentCameraIndex = targetCameraIndex;
    await initializeCamera();
  }

  Future<void> onTapToFocus(
      TapDownDetails details, BoxConstraints constraints) async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    focusPoint = details.localPosition;
    showFocusIndicator = true;
    notifyListeners();

    try {
      await cameraController!.setFocusPoint(offset);
      await cameraController!.setExposurePoint(offset);
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 800), () {
      showFocusIndicator = false;
      notifyListeners();
    });
  }

  Future<void> captureImage() async {
    if (cameraController == null ||
        !cameraController!.value.isInitialized ||
        cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      showShutterEffect = true;
      notifyListeners();

      final XFile image = await cameraController!.takePicture();

      showShutterEffect = false;
      // Add temp path immediately for UI speed
      capturedImagePaths.add(image.path);
      notifyListeners();

      // Save in background WITHOUT awaiting the result for the UI
      // We start the operation but don't block any future UI interactions on it
      FileUtils.saveImageToAppDir(image.path).then((newPath) {
        if (newPath != null) {
          final index = capturedImagePaths.indexOf(image.path);
          if (index != -1) {
            capturedImagePaths[index] = newPath;
            notifyListeners();
          }
        }
      });
    } catch (e) {
      showShutterEffect = false;
      notifyListeners();
    }
  }

  void startCapturing() {
    isCapturing = true;
    notifyListeners();
  }

  void stopCapturing(BuildContext context) {
    if (capturedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images captured')),
      );
      return;
    }

    isCapturing = false;
    notifyListeners();

    // Return or navigate to results
    // For now we just print or let the UI handle navigation based on state,
    // but the controller usually shouldn't handle navigation directly unless passed context
    // The original code navigated to ResultsScreen.
  }

  void clearImages() {
    capturedImagePaths.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
