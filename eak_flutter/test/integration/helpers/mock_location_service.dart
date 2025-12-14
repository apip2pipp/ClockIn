import 'package:eak_flutter/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class MockLocationService implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return true; // Simulate GPS enabled
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return LocationPermission.always; // Simulate permission granted
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return LocationPermission.always;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
  }) async {
    // Return a fixed mock position (e.g., Office Location)
    // -6.2088, 106.8456 (Jakarta Central)
    return Position(
      longitude: 106.8456,
      latitude: -6.2088,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
}
