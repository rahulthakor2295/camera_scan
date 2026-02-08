import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../controller/scan_cubit.dart';
import '../../controller/scan_state.dart';

class CameraPreviewWidget extends StatelessWidget {
  final ScanState state;
  final ScanCubit cubit;

  const CameraPreviewWidget({
    super.key,
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    // Local variable for safe access
    final cameraController = state.cameraController;

    if (!state.isInitialized || cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) => cubit.onTapToFocus(details, constraints),
          child: SizedBox.expand(
            child: CameraPreview(cameraController),
          ),
        );
      },
    );
  }
}
