import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
    ),
  );

  Future<List<Face>> detectFaces(InputImage image) async {
    return await faceDetector.processImage(image);
  }

  void dispose() {
    faceDetector.close();
  }
}
