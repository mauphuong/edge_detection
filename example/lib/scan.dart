import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:edge_detection_example/cropping_preview.dart';

import 'camera_view.dart';
import 'edge_detector.dart';
import 'image_view.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  ScanState createState() => ScanState();
}

class ScanState extends State<Scan> {
  late final CameraController controller;
  late List<CameraDescription> cameras;
  late String imagePath="";
  late String croppedImagePath="";
  late EdgeDetectionResult edgeDetectionResult = EdgeDetectionResult(topLeft: Offset(0.2,0.2), topRight: Offset(0.2,0.5), bottomLeft: Offset(0.5,0.2), bottomRight: Offset(0.5,0.5));

  @override
  void initState() {
    super.initState();
    checkForCameras().then((value) {
    _initializeController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _getMainWidget(),
          _getBottomBar(),
        ],
      ),
    );
  }

  Widget _getMainWidget() {
    if (croppedImagePath != "") {
      return ImageView(imagePath: croppedImagePath);
    }
    else if (imagePath == ""){// && edgeDetectionResult == null) {
      return CameraView(
        controller: controller
      );
    }
    else {
      return ImagePreview(
        imagePath: imagePath,
        edgeDetectionResult: edgeDetectionResult,
      );
    }
  }

  Future<void> checkForCameras() async {
    cameras = await availableCameras();
  }

  Future<void> _initializeController() async {

    checkForCameras();
    if (cameras.isEmpty) {
      log('No cameras detected');
      return;
    }

    controller = CameraController(
        cameras[0],
        ResolutionPreset.veryHigh,
        enableAudio: false
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    await controller.lockCaptureOrientation();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _getButtonRow() {
    if (imagePath != "") {
      return Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          child: const Icon(Icons.check),
          onPressed: () async {
            if (croppedImagePath == "") {
              await _processImage(
                imagePath, edgeDetectionResult
              );
            }

            setState(() {
              imagePath = "";
              //edgeDetectionResult = 0 as EdgeDetectionResult;
              croppedImagePath = "";
            });
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          foregroundColor: Colors.white,
          onPressed: onTakePictureButtonPressed,
          child: const Icon(Icons.camera_alt),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          foregroundColor: Colors.white,
          onPressed: _onGalleryButtonPressed,
          child: const Icon(Icons.image),
        ),
      ]
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      log('Error: select a camera first.');
      return "";
    }

    //final Directory extDir = await getTemporaryDirectory();
    //final String dirPath = '${extDir.path}/Pictures/flutter_test';
    //await Directory(dirPath).create(recursive: true);
    //final String filePath = '$dirPath/${timestamp()}.jpg';
    //if the camera is busy
    if (controller.value.isTakingPicture) {
      return "";
    }
    XFile file;
    try {
      file = await controller.takePicture();
    } on CameraException catch (e) {
      log(e.toString());
      return "";
    }
    return file.path;
  }

  Future _detectEdges(String filePath) async {
    if (!mounted || filePath == "") {
      return;
    }

    setState(() {
      imagePath = filePath;
    });

    EdgeDetectionResult result = await EdgeDetector().detectEdges(filePath);

    setState(() {
      edgeDetectionResult = result;
    });
  }

  Future _processImage(String filePath, EdgeDetectionResult edgeDetectionResult) async {
    if (!mounted || filePath == "") {
      return;
    }

    bool result = await EdgeDetector().processImage(filePath, edgeDetectionResult);

    if (result == false) {
      return;
    }

    setState(() {
      imageCache.clearLiveImages();
      imageCache.clear();
      croppedImagePath = imagePath;
    });
  }

  void onTakePictureButtonPressed() async {
    String filePath = await takePicture();

    log('Picture saved to $filePath');

    await _detectEdges(filePath);
  }

  void _onGalleryButtonPressed() async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final String? filePath = pickedFile?.path;

    log('Picture saved to $filePath');

    _detectEdges(filePath!);
  }

  Padding _getBottomBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _getButtonRow()
      )
    );
  }
}