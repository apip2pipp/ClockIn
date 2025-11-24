import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class ImageConverter {
  static img.Image convertCameraImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final img.Image grayscaleImage = img.Image(width: width, height: height);

    // Convert Y-plane (brightness) to grayscale
    final Uint8List bytes = image.planes[0].bytes;

    int pixelIndex = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int brightness = bytes[pixelIndex];
        grayscaleImage.setPixel(
          x,
          y,
          img.ColorRgb8(brightness, brightness, brightness),
        );
        pixelIndex++;
      }
    }

    return grayscaleImage;
  }
}
