import 'package:flutter/material.dart';
import '../../controller/scan_controller.dart';
import '../../../../core/constants/app_colors.dart';

class ZoomControls extends StatelessWidget {
  final ScanController controller;

  const ZoomControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blackOpacity60,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: controller.availableZoomLevels.map((zoom) {
          final isSelected = controller.currentZoomLevel == zoom;
          String label = zoom == 0.5
              ? '0.5x'
              : zoom == 1.0
                  ? '1x'
                  : '${zoom.toInt()}x';

          return GestureDetector(
            onTap: () => controller.switchZoomLevel(zoom),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.black : AppColors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
