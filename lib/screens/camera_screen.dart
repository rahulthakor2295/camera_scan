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
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _showShutterEffect = false;

  final List<String> _capturedImagePaths = [];

  late AnimationController _shutterAnimationController;

  @override
  void initState() {
    super.initState();
    _shutterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;

    _cameraController = CameraController(
      widget.cameras.first,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();

      await _cameraController!.setFocusMode(FocusMode.locked);
      await _cameraController!.setExposureMode(ExposureMode.locked);
      await _cameraController!.prepareForVideoRecording();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      // Handle error silently
    }
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
          Positioned.fill(child: CameraPreview(_cameraController!)),
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
