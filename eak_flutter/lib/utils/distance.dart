import 'dart:math';

double calculateDistanceMeters(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const R = 6371000;

  double dLat = (lat2 - lat1) * pi / 180;
  double dLng = (lon2 - lon1) * pi / 180;

  double a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLng / 2) *
          sin(dLng / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}
