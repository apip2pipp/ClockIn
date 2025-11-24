import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LivenessService {
  bool isBlink(Face face, {double threshold = 0.25}) {
    final left = face.leftEyeOpenProbability ?? 1.0;
    final right = face.rightEyeOpenProbability ?? 1.0;

    return left < threshold && right < threshold;
  }
}
