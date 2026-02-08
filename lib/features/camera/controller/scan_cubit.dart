import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/file_utils.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final List<CameraDescription> cameras;

  ScanCubit(this.cameras) : super(const ScanState());

  Future<void> initializeCamera() async {
    if (cameras.isEmpty) return;

    final zoomLevels = _detectAvailableZoomLevels();

    final controller = CameraController(
      cameras[state.currentCameraIndex],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);

      emit(state.copyWith(
        cameraController: controller,
        isInitialized: true,
        availableZoomLevels: zoomLevels,
      ));
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  List<double> _detectAvailableZoomLevels() {
    List<double> levels = [1.0];
    if (cameras.length > 1) {
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          if (camera.name.contains('wide')) {
            if (!levels.contains(0.5)) {
              levels.insert(0, 0.5);
            }
          } else if (camera.name.contains('telephoto') ||
              camera.name.contains('tele')) {
            if (!levels.contains(2.0)) {
              levels.add(2.0);
            }
          }
        }
      }
    }
    levels.sort();
    return levels;
  }

  Future<void> switchZoomLevel(double zoomLevel) async {
    if (state.currentZoomLevel == zoomLevel || state.isCapturing) return;

    emit(state.copyWith(
      currentZoomLevel: zoomLevel,
      isInitialized: false,
    ));

    await state.cameraController?.dispose();

    int targetCameraIndex = 0;
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

    emit(state.copyWith(currentCameraIndex: targetCameraIndex));
    await initializeCamera();
  }

  Future<void> onTapToFocus(
      TapDownDetails details, BoxConstraints constraints) async {
    final controller = state.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    emit(state.copyWith(
      focusPoint: details.localPosition,
      showFocusIndicator: true,
    ));

    try {
      await controller.setFocusPoint(offset);
      await controller.setExposurePoint(offset);
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!isClosed) {
        emit(state.copyWith(showFocusIndicator: false));
      }
    });
  }

  Future<void> captureImage() async {
    final controller = state.cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      emit(state.copyWith(showShutterEffect: true));

      final XFile image = await controller.takePicture();

      // Update state with new image path AND removed shutter effect
      final updatedPaths = List<String>.from(state.capturedImagePaths)
        ..add(image.path);

      emit(state.copyWith(
        showShutterEffect: false,
        capturedImagePaths: updatedPaths,
      ));

      // Save in background
      FileUtils.saveImageToAppDir(image.path).then((newPath) {
        if (newPath != null && !isClosed) {
          final currentPaths = List<String>.from(state.capturedImagePaths);
          final index = currentPaths.indexOf(image.path);
          if (index != -1) {
            currentPaths[index] = newPath;
            emit(state.copyWith(capturedImagePaths: currentPaths));
          }
        }
      });
    } catch (e) {
      emit(state.copyWith(showShutterEffect: false));
    }
  }

  void startCapturing() {
    emit(state.copyWith(isCapturing: true));
  }

  void stopCapturing(BuildContext context) {
    if (state.capturedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images captured')),
      );
      return;
    }

    emit(state.copyWith(isCapturing: false));
  }

  void clearImages() {
    emit(state.copyWith(capturedImagePaths: []));
  }

  @override
  Future<void> close() {
    state.cameraController?.dispose();
    return super.close();
  }
}
