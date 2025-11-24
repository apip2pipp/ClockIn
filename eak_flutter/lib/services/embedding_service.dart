import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class EmbeddingService {
  Interpreter? _interpreter;
  final int inputSize = 112; // ukuran MobileFaceNet

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/mobilefacenet.tflite',
      options: InterpreterOptions()..threads = 4,
    );
  }

  bool isLoaded() => _interpreter != null;

  /// Crop wajah dari full image berdasarkan bounding box MLKit
  img.Image cropFace(img.Image fullImage, Face face) {
    final rect = face.boundingBox;

    int x = rect.left.toInt().clamp(0, fullImage.width);
    int y = rect.top.toInt().clamp(0, fullImage.height);
    int w = rect.width.toInt();
    int h = rect.height.toInt();

    return img.copyCrop(fullImage, x: x, y: y, width: w, height: h);
  }

  /// Resize + normalize ke tensor
  TensorImage _preprocess(img.Image faceImage) {
    TensorImage tensor = TensorImage.fromImage(faceImage);

    final ImageProcessor processor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.NEAREST_NEIGHBOUR))
        .add(NormalizeOp(128, 128)) // mean=128 std=128
        .build();

    return processor.process(tensor);
  }

  /// Generate 128-dim embedding
  List<double> generateEmbedding(img.Image face, Face faceInfo) {
    // 1. Crop
    final cropped = cropFace(face, faceInfo);

    // 2. Preprocess
    final tensorInput = _preprocess(cropped);

    // 3. Buat output tensor 1x128
    var output = List.filled(128, 0.0).reshape([1, 128]);

    // 4. Run model
    _interpreter!.run(tensorInput.buffer, output);

    // 5. Convert to List<double>
    return List<double>.from(output[0]);
  }
}
