import 'package:flutter/material.dart';
import '/services/tensorflow-service.dart';

class Recognition extends StatelessWidget {
  const Recognition({super.key});

  @override
  Widget build(BuildContext context) {
    final TensorflowService tensorflowService = TensorflowService();

    return Align(
      alignment: Alignment.bottomCenter,
      child: StreamBuilder<List<dynamic>>(
        stream: tensorflowService.recognitionStream,
        builder: (context, snapshot) {
          // If we have no data or the model is not ready, show a simple "scanning" message.
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Scanning...',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final recognitions = snapshot.data!;

          // Build the new user-friendly display for top 3
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recognitions.length,
              itemBuilder: (context, index) {
                final recognition = recognitions[index];
                final label = recognition['label'] as String? ?? 'Unknown';
                final confidence = recognition['confidence'] as double? ?? 0.0;
                final displayLabel =
                    '${label[0].toUpperCase()}${label.substring(1)}';

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildConfidenceBar(confidence),
                    const SizedBox(height: 4),
                    Text(
                      '${(confidence * 100).toStringAsFixed(0)}% Confidence',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 15),
            ),
          );
        },
      ),
    );
  }

  /// A custom widget to display a colored confidence bar.
  Widget _buildConfidenceBar(double confidence) {
    // Pick a color based on the confidence level
    final color = Color.lerp(Colors.red, Colors.green, confidence);

    return Container(
      height: 8,
      clipBehavior:
          Clip.hardEdge, // This is important for the borderRadius to work
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withOpacity(0.3),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: confidence,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
