import 'package:flutter/material.dart';
import '../../controller/scan_controller.dart';
import '../../../../core/constants/app_colors.dart';

class CaptureControls extends StatefulWidget {
  final ScanController controller;
  final VoidCallback onStop;

  const CaptureControls({
    super.key,
    required this.controller,
    required this.onStop,
  });

  @override
  State<CaptureControls> createState() => _CaptureControlsState();
}

class _CaptureControlsState extends State<CaptureControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _shutterController;

  @override
  void initState() {
    super.initState();
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void didUpdateWidget(CaptureControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.showShutterEffect) {
      _shutterController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _shutterController.reset();
        });
      });
    }
  }

  @override
  void dispose() {
    _shutterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.controller.isCapturing)
          GestureDetector(
            onTap: widget.controller.captureImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.controller.showShutterEffect)
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: RotationTransition(
                      turns: _shutterController,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.controller.isCapturing
                    ? null
                    : widget.controller.startCapturing,
                icon: const Icon(Icons.play_arrow),
                label: const Text('START'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.controller.isCapturing ? widget.onStop : null,
                icon: const Icon(Icons.stop),
                label: const Text('STOP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
