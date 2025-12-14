import 'package:geolocator/geolocator.dart';

/// Wrapper service for Geolocator to enable mocking in tests
class LocationService {
  // Singleton instance
  static LocationService _instance = LocationService();
  static LocationService get instance => _instance;

  // Allow injection of mock instance for testing
  static void setInstance(LocationService mock) {
    _instance = mock;
  }

  // Reset to default instance
  static void resetInstance() {
    _instance = LocationService();
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  /// Check validation permission status
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  /// Get current position
  Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
  }) {
    return Geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);
  }
}
