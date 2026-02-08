import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../controller/scan_cubit.dart';
import '../../controller/scan_state.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/focus_indicator.dart';
import '../widgets/zoom_controls.dart';
import '../widgets/capture_controls.dart';
import '../widgets/image_counter_badge.dart';
import 'results_screen.dart';

class CameraScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  void _handleStopCapture(BuildContext context, ScanCubit cubit) {
    if (cubit.state.capturedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images captured')),
      );
      return;
    }

    cubit.stopCapturing(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
            imagePaths: List.from(cubit.state.capturedImagePaths)),
      ),
    ).then((_) {
      cubit.clearImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScanCubit(cameras)..initializeCamera(),
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: BlocBuilder<ScanCubit, ScanState>(
          builder: (context, state) {
            final cubit = context.read<ScanCubit>();

            if (!state.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            final focusPoint = state.focusPoint;

            return Stack(
              children: [
                // Preview
                Positioned.fill(
                  child: CameraPreviewWidget(state: state, cubit: cubit),
                ),

                // Focus Indicator
                if (state.showFocusIndicator && focusPoint != null)
                  FocusIndicator(position: focusPoint),

                // Image Counter (Top Right)
                if (state.isCapturing)
                  Positioned(
                    top: 60,
                    right: 20,
                    child: ImageCounterBadge(
                        count: state.capturedImagePaths.length),
                  ),

                // Zoom Controls (Bottom Center, above capture area)
                if (state.availableZoomLevels.length > 1 && !state.isCapturing)
                  Positioned(
                    bottom: 180,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ZoomControls(state: state, cubit: cubit),
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
                        state: state,
                        cubit: cubit,
                        onStop: () => _handleStopCapture(context, cubit),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
