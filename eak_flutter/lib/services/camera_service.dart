import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );

    controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();
  }

  CameraController getCamera() {
    return controller!;
  }

  void dispose() {
    controller?.dispose();
  }
}
