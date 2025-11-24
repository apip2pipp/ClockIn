import '../utils/euclidean.dart';

class FaceMatchingService {
  final double defaultThreshold = 1.0;

  bool isMatch({
    required List<double> embedding1,
    required List<double> embedding2,
    double? threshold,
  }) {
    final dist = euclideanDistance(embedding1, embedding2);
    final limit = threshold ?? defaultThreshold;

    return dist <= limit;
  }

  Map<String, dynamic> verify({
    required List<double> embedding1,
    required List<double> embedding2,
    double? threshold,
  }) {
    final dist = euclideanDistance(embedding1, embedding2);
    final limit = threshold ?? defaultThreshold;

    return {"match": dist <= limit, "distance": dist, "threshold": limit};
  }
}
