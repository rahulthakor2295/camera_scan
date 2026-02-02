import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'results_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _showShutterEffect = false;

  final List<String> _capturedImagePaths = [];

  late AnimationController _shutterAnimationController;
  late AnimationController _focusAnimationController;
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  int _currentCameraIndex = 0;
  double _currentZoomLevel = 1.0;
  List<double> _availableZoomLevels = [1.0];

  @override
  void initState() {
    super.initState();
    _shutterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _focusAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;

    _detectAvailableZoomLevels();

    _cameraController = CameraController(
      widget.cameras[_currentCameraIndex],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();

      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.setExposureMode(ExposureMode.auto);
      await _cameraController!.prepareForVideoRecording();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _onTapToFocus(
      TapDownDetails details, BoxConstraints constraints) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    setState(() {
      _focusPoint = details.localPosition;
      _showFocusIndicator = true;
    });

    _focusAnimationController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _showFocusIndicator = false);
        }
      });
    });

    try {
      await _cameraController!.setFocusPoint(offset);
      await _cameraController!.setExposurePoint(offset);
    } catch (e) {
      setState(() => _showFocusIndicator = false);
    }
  }

  void _detectAvailableZoomLevels() {
    _availableZoomLevels = [1.0];

    if (widget.cameras.length > 1) {
      for (var camera in widget.cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          if (camera.name.contains('wide')) {
            if (!_availableZoomLevels.contains(0.5)) {
              _availableZoomLevels.insert(0, 0.5);
            }
          } else if (camera.name.contains('telephoto') ||
              camera.name.contains('tele')) {
            if (!_availableZoomLevels.contains(2.0)) {
              _availableZoomLevels.add(2.0);
            }
          }
        }
      }
    }

    _availableZoomLevels.sort();
  }

  Future<void> _switchZoomLevel(double zoomLevel) async {
    if (_currentZoomLevel == zoomLevel || _isCapturing) return;

    setState(() {
      _currentZoomLevel = zoomLevel;
      _isInitialized = false;
    });

    await _cameraController?.dispose();

    int targetCameraIndex = 0;
    if (zoomLevel == 0.5) {
      targetCameraIndex = widget.cameras.indexWhere((c) =>
          c.lensDirection == CameraLensDirection.back &&
          c.name.contains('wide'));
    } else if (zoomLevel == 2.0) {
      targetCameraIndex = widget.cameras.indexWhere((c) =>
          c.lensDirection == CameraLensDirection.back &&
          (c.name.contains('telephoto') || c.name.contains('tele')));
    } else {
      targetCameraIndex = widget.cameras.indexWhere((c) =>
          c.lensDirection == CameraLensDirection.back &&
          !c.name.contains('wide') &&
          !c.name.contains('telephoto') &&
          !c.name.contains('tele'));
    }

    if (targetCameraIndex == -1) {
      targetCameraIndex = 0;
    }

    _currentCameraIndex = targetCameraIndex;
    await _initializeCamera();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      setState(() => _showShutterEffect = true);
      _shutterAnimationController.forward(from: 0);

      final XFile image = await _cameraController!.takePicture();

      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(() => _showShutterEffect = false);
          _shutterAnimationController.reset();
        }
      });

      final tempPath = image.path;

      if (mounted) {
        setState(() => _capturedImagePaths.add(tempPath));
      }

      _saveImageInBackground(tempPath);
    } catch (e) {
      _shutterAnimationController.reset();
      setState(() => _showShutterEffect = false);
    }
  }

  Future<void> _saveImageInBackground(String tempPath) async {
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String fileName =
          'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = path.join(dir.path, fileName);

      await File(tempPath).copy(newPath);

      if (mounted) {
        setState(() {
          final index = _capturedImagePaths.indexOf(tempPath);
          if (index != -1) {
            _capturedImagePaths[index] = newPath;
          }
        });
      }

      try {
        await File(tempPath).delete();
      } catch (_) {}
    } catch (e) {
      // Handle error silently
    }
  }

  void _startCapturing() {
    setState(() => _isCapturing = true);
  }

  void _stopCapturing() {
    if (_capturedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images captured')),
      );
      return;
    }

    setState(() => _isCapturing = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResultsScreen(imagePaths: List.from(_capturedImagePaths)),
      ),
    ).then((_) {
      setState(() => _capturedImagePaths.clear());
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _shutterAnimationController.dispose();
    _focusAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _onTapToFocus(details, constraints),
                  child: CameraPreview(_cameraController!),
                );
              },
            ),
          ),
          if (_showFocusIndicator && _focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 40,
              top: _focusPoint!.dy - 40,
              child: AnimatedBuilder(
                animation: _focusAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - (_focusAnimationController.value * 0.2),
                    child: Opacity(
                      opacity: 1.0 - _focusAnimationController.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.yellow,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (_isCapturing)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${_capturedImagePaths.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_availableZoomLevels.length > 1 && !_isCapturing)
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _availableZoomLevels.map((zoom) {
                      final isSelected = _currentZoomLevel == zoom;
                      String label = zoom == 0.5
                          ? '0.5x'
                          : zoom == 1.0
                              ? '1x'
                              : '${zoom.toInt()}x';

                      return GestureDetector(
                        onTap: () => _switchZoomLevel(zoom),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isCapturing)
                      GestureDetector(
                        onTap: _captureImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_showShutterEffect)
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: RotationTransition(
                                  turns: _shutterAnimationController,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
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
                            onPressed: _isCapturing ? null : _startCapturing,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('START'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isCapturing ? _stopCapturing : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('STOP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
