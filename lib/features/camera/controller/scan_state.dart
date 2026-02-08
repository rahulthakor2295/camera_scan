import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ScanState extends Equatable {
  final CameraController? cameraController;
  final bool isInitialized;
  final bool isCapturing;
  final bool showShutterEffect;
  final Offset? focusPoint;
  final bool showFocusIndicator;
  final double currentZoomLevel;
  final List<double> availableZoomLevels;
  final List<String> capturedImagePaths;
  final int currentCameraIndex;

  const ScanState({
    this.cameraController,
    this.isInitialized = false,
    this.isCapturing = false,
    this.showShutterEffect = false,
    this.focusPoint,
    this.showFocusIndicator = false,
    this.currentZoomLevel = 1.0,
    this.availableZoomLevels = const [1.0],
    this.capturedImagePaths = const [],
    this.currentCameraIndex = 0,
  });

  ScanState copyWith({
    CameraController? cameraController,
    bool? isInitialized,
    bool? isCapturing,
    bool? showShutterEffect,
    Offset? focusPoint,
    bool? showFocusIndicator,
    double? currentZoomLevel,
    List<double>? availableZoomLevels,
    List<String>? capturedImagePaths,
    int? currentCameraIndex,
  }) {
    return ScanState(
      cameraController: cameraController ?? this.cameraController,
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      showShutterEffect: showShutterEffect ?? this.showShutterEffect,
      focusPoint: focusPoint ?? this.focusPoint,
      showFocusIndicator: showFocusIndicator ?? this.showFocusIndicator,
      currentZoomLevel: currentZoomLevel ?? this.currentZoomLevel,
      availableZoomLevels: availableZoomLevels ?? this.availableZoomLevels,
      capturedImagePaths: capturedImagePaths ?? this.capturedImagePaths,
      currentCameraIndex: currentCameraIndex ?? this.currentCameraIndex,
    );
  }

  @override
  List<Object?> get props => [
        cameraController,
        isInitialized,
        isCapturing,
        showShutterEffect,
        focusPoint,
        showFocusIndicator,
        currentZoomLevel,
        availableZoomLevels,
        capturedImagePaths,
        currentCameraIndex,
      ];
}
