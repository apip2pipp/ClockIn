import 'dart:math';

double euclideanDistance(List<double> a, List<double> b) {
  double sum = 0.0;

  for (int i = 0; i < a.length; i++) {
    sum += pow(a[i] - b[i], 2);
  }

  return sqrt(sum);
}
