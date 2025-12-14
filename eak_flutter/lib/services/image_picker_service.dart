import 'package:image_picker/image_picker.dart';

/// Wrapper service for ImagePicker to enable mocking in tests
class ImagePickerService {
  // Singleton instance
  static ImagePickerService _instance = ImagePickerService();
  static ImagePickerService get instance => _instance;

  // Allow injection of mock instance for testing
  static void setInstance(ImagePickerService mock) {
    _instance = mock;
  }

  // Reset to default instance
  static void resetInstance() {
    _instance = ImagePickerService();
  }

  final ImagePicker _picker = ImagePicker();

  /// Pick image from source
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) {
    return _picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }
}
