import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key,
    required this.controller
  });

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return _getCameraPreview();
  }

  Widget _getCameraPreview() {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    return RotatedBox(
      quarterTurns: 0,
      child: Transform.scale(
        scale: 1 ,/// controller.value.aspectRatio,
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}