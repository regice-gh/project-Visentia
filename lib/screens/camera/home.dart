import 'package:eindopdrachtmad/services/camera-service.dart';
import 'package:eindopdrachtmad/services/tensorflow-service.dart';
import 'package:eindopdrachtmad/screens/camera/recognition/recognition.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:eindopdrachtmad/screens/camera/camera-header.dart';

import 'camera-screen.dart';

class Home extends StatefulWidget {
  final CameraDescription camera;
  final bool isActive;

  const Home({
    super.key,
    required this.camera,
    this.isActive = false, // Default to false
  });

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Services injection
  final TensorflowService _tensorflowService = TensorflowService();
  final CameraService _cameraService = CameraService();

  // Future for camera initialization
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial startup if already active (e.g., if camera tab is the default)
    if (widget.isActive) {
      startUp();
    }
  }

  @override
  void didUpdateWidget(covariant Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Tab became active
      startUp();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Tab became inactive
      stopAndDisposeCamera();
    }
  }

  Future<void> startUp() async {
    if (!mounted) {
      return;
    }
    // Initialize the camera service
    _initializeControllerFuture =
        _cameraService.startService(widget.camera).then((_) async {
      // After the camera is initialized, load the model
      await _tensorflowService.loadModel();
      // Then start the recognition stream
      startRecognitions();
    });
  }

  void startRecognitions() {
    try {
      _cameraService.startStreaming();
    } catch (e) {
      print('Error streaming camera image: $e');
    }
  }

  Future<void> stopRecognitions() async {
    await _cameraService.stopImageStream();
  }

  Future<void> stopAndDisposeCamera() async {
    await stopRecognitions();
    _cameraService.dispose();
    _tensorflowService.dispose();
    _initializeControllerFuture = null; // Clear the future
  }

  @override
  Widget build(BuildContext context) {
    // Only build the FutureBuilder if the widget is active
    if (!widget.isActive || _initializeControllerFuture == null) {
      return const Center(child: Text("Camera Inactive")); // Or any placeholder
    }

    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                // Shows the camera preview
                CameraScreen(
                  controller: _cameraService.cameraController!,
                ),

                // Shows the header with the icon
                CameraHeader(),

                // Shows the recognition on the bottom
                const Recognition(),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only act on lifecycle changes if the camera tab is currently active
    if (!widget.isActive) return;

    if (state == AppLifecycleState.resumed) {
      // Restarts the camera when the app is resumed
      startUp();
    } else if (state == AppLifecycleState.paused) {
      // Stops and disposes of camera resources when the app is paused
      stopAndDisposeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Ensure resources are disposed if the widget is truly removed from the tree
    if (widget.isActive) {
      stopAndDisposeCamera();
    }
    super.dispose();
  }
}
