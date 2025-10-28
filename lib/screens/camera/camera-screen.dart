import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  final CameraController controller;

  const CameraScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // The camera preview will fill the available space.
    return CameraPreview(controller);
  }
}
