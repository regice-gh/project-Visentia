import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorflowService {
  static final TensorflowService _tensorflowService =
      TensorflowService._internal();

  factory TensorflowService() {
    return _tensorflowService;
  }
  TensorflowService._internal();

  final StreamController<List<dynamic>> _recognitionController =
      StreamController.broadcast();
  Stream<List<dynamic>> get recognitionStream => _recognitionController.stream;

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isProcessing = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        "assets/camera/mobilenet_v1_1.0_224.tflite",
      );

      final labelsData =
          await rootBundle.loadString('assets/camera/labels.txt');
      _labels = labelsData.split('\n');
      print('Model and labels loaded successfully');
    } catch (e) {
      print('Error loading model or labels');
      print(e);
    }
  }

  Future<void> runModel(CameraImage cameraImage) async {
    if (_interpreter == null || _labels == null || _isProcessing) {
      return;
    }

    _isProcessing = true;
    try {
      final image = _convertCameraImage(cameraImage);
      if (image == null) {
        return;
      }

      final resizedImage = img.copyResize(image, width: 224, height: 224);

      // Normalize the image to the range [-1, 1] and convert to a Float32List
      var imageBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);
      var normalizedBuffer = Float32List(1 * 224 * 224 * 3);
      int bufferIndex = 0;
      for (int i = 0; i < imageBytes.length; i++) {
        normalizedBuffer[bufferIndex++] = (imageBytes[i] - 127.5) / 127.5;
      }

      // Reshape the input to the format the model expects
      final input = normalizedBuffer.reshape([1, 224, 224, 3]);
      var output =
          List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

      _interpreter!.run(input, output);

      List<Map<String, dynamic>> recognitions = [];
      for (int i = 0; i < _labels!.length; i++) {
        if (output[0][i] > 0.4) {
          // Increased confidence threshold
          recognitions.add({
            "label": _labels![i],
            "confidence": output[0][i],
          });
        }
      }

      recognitions.sort((a, b) => b['confidence'].compareTo(a['confidence']));

      var top3 = recognitions.take(3).toList();

      if (!_recognitionController.isClosed) {
        _recognitionController.add(top3);
      }
    } catch (e) {
      print("Error running model: $e");
    } finally {
      _isProcessing = false;
    }
  }

  img.Image? _convertCameraImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    final image = img.Image(width: width, height: height);
    final planeY = cameraImage.planes[0].bytes;
    final planeU = cameraImage.planes[1].bytes;
    final planeV = cameraImage.planes[2].bytes;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = planeY[index];
        final up = planeU[uvIndex];
        final vp = planeV[uvIndex];

        int r = (yp + vp * 1.402).round().clamp(0, 255);
        int g = (yp - up * 0.344 - vp * 0.714).round().clamp(0, 255);
        int b = (yp + up * 1.772).round().clamp(0, 255);

        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }

  void dispose() async {
    _interpreter?.close();
    if (!_recognitionController.isClosed) {
      _recognitionController.close();
    }
  }
}
