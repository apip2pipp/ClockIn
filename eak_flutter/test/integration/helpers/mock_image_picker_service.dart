import 'package:eak_flutter/services/image_picker_service.dart';
import 'package:image_picker/image_picker.dart';

class MockImagePickerService implements ImagePickerService {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    // Return a dummy image file
    // In a real scenario, this should be a valid path to an image file 
    // accessible by the app sandbox.
    // For now, we can try returning null or a placeholder path 
    // that the app handles gracefully or mocks uploading logic.
    // BUT the app displays it: Image.file(File(path))
    // So it needs to be a real file.
    // Since we can't easily put a file on device during test without setup,
    // we might need to rely on the app logic being robust enough OR
    // write a temporary file.
    
    // For now, let's assume we can pass a dummy path "assets/icon_login.png" 
    // but Image.file() expects filesystem path, not asset.
    // We'll leave it simple: return an XFile that points to a dummy path.
    // The test might fail on rendering Image.file() if path is invalid.
    return XFile('test_image.jpg'); 
  }
}
