// frontend/lib/services/face_detection_service.dart

import 'dart:convert';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceDetectionService {
  late FaceDetector _faceDetector;
  bool _isInitialized = false;

  FaceDetectionService() {
    final options = FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      enableLandmarks: true,
      minFaceSize: 0.1,
    );

    _faceDetector = FaceDetector(options: options);
  }

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  Future<List<Face>> detectFaces(CameraImage image, int rotation) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = _inputImageFromCameraImage(image, rotation);

      if (inputImage == null) {
        return [];
      }

      final faces = await _faceDetector.processImage(inputImage);

      return faces;
    } catch (e) {
      debugPrint('Error detecting faces: $e');
      return [];
    }
  }

  Future<String?> extractFaceBase64(CameraImage image, Face face) async {
    try {
      final img.Image? converted = _convertCameraImageToImage(image);
      if (converted == null) {
        return null;
      }

      final faceBox = face.boundingBox;
      final x = faceBox.left.toInt().clamp(0, converted.width - 1);
      final y = faceBox.top.toInt().clamp(0, converted.height - 1);
      final width = faceBox.width.toInt().clamp(1, converted.width - x);
      final height = faceBox.height.toInt().clamp(1, converted.height - y);

      final croppedFace = img.copyCrop(
        converted,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      final resizedFace = img.copyResize(
        croppedFace,
        width: 256,
        height: 256,
      );

      final encoded = img.encodeJpg(resizedFace, quality: 80);
      return base64Encode(encoded);
    } catch (e) {
      debugPrint('Error extracting face image: $e');
      return null;
    }
  }

  Future<List<int>> getFaceEmbedding(
    CameraImage image,
    Face face,
  ) async {
    try {
      final faceBytes = await _extractFaceRegion(image, face);

      return faceBytes;
    } catch (e) {
      debugPrint('Error extracting face embedding: $e');
      return [];
    }
  }

  Future<List<int>> _extractFaceRegion(
    CameraImage image,
    Face face,
  ) async {
    try {
      final faceBox = face.boundingBox;

      final imgImage = _convertCameraImageToImage(image);

      if (imgImage == null) {
        return [];
      }

      int x = faceBox.left.toInt().clamp(0, imgImage.width - 1);
      int y = faceBox.top.toInt().clamp(0, imgImage.height - 1);

      int width = faceBox.width.toInt().clamp(1, imgImage.width - x);

      int height = faceBox.height.toInt().clamp(1, imgImage.height - y);

      final croppedFace = img.copyCrop(
        imgImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      final resized = img.copyResize(
        croppedFace,
        width: 160,
        height: 160,
      );

      final grayscale = img.grayscale(resized);

      List<int> pixels = grayscale.getBytes().toList();

      return pixels;
    } catch (e) {
      debugPrint('Error extracting face region: $e');
      return [];
    }
  }

  img.Image? _convertCameraImageToImage(
    CameraImage cameraImage,
  ) {
    try {
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToImage(cameraImage);
      }

      return null;
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  img.Image? _convertYUV420ToImage(
    CameraImage cameraImage,
  ) {
    try {
      final width = cameraImage.width;
      final height = cameraImage.height;

      final planes = cameraImage.planes;

      final uvPixelStride = planes[1].bytesPerPixel ?? 1;

      final image = img.Image(
        width: width,
        height: height,
      );

      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          final uvIndex = uvPixelStride * (x / 2).floor() +
              (y / 2).floor() * planes[1].bytesPerRow;

          final index = y * width + x;

          final yp = planes[0].bytes[index];
          final up = planes[1].bytes[uvIndex];
          final vp = planes[2].bytes[uvIndex];

          int r = (yp + vp * 1436 / 1024 - 179.456).round().clamp(0, 255);

          int g = (yp - up * 46549 / 131072 + 44.1 - vp * 93604 / 131072 + 91.6)
              .round()
              .clamp(0, 255);

          int b = (yp + up * 1814 / 1024 - 227.638).round().clamp(0, 255);

          image.setPixelRgba(
            x,
            y,
            r,
            g,
            b,
            255,
          );
        }
      }

      return image;
    } catch (e) {
      debugPrint('Error in YUV420 conversion: $e');
      return null;
    }
  }

  img.Image? _convertBGRA8888ToImage(
    CameraImage cameraImage,
  ) {
    try {
      final width = cameraImage.width;
      final height = cameraImage.height;

      final bytes = cameraImage.planes[0].bytes;

      final image = img.Image(
        width: width,
        height: height,
      );

      int index = 0;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          int b = bytes[index];
          int g = bytes[index + 1];
          int r = bytes[index + 2];
          int a = bytes[index + 3];

          image.setPixelRgba(
            x,
            y,
            r,
            g,
            b,
            a,
          );

          index += 4;
        }
      }

      return image;
    } catch (e) {
      debugPrint('Error in BGRA8888 conversion: $e');
      return null;
    }
  }

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    int rotation,
  ) {
    try {
      final allBytes = Uint8List(
        image.planes.fold(0, (sum, plane) => sum + plane.bytes.length),
      );
      int offset = 0;
      for (final plane in image.planes) {
        allBytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
        offset += plane.bytes.length;
      }

      final size = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final imageRotation = _rotationIntToImageRotation(rotation);
      final imageFormat = image.format.group == ImageFormatGroup.bgra8888
          ? InputImageFormat.bgra8888
          : InputImageFormat.yuv420;

      return InputImage.fromBytes(
        bytes: allBytes,
        metadata: InputImageMetadata(
          size: size,
          rotation: imageRotation,
          format: imageFormat,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('Input image conversion error: $e');
      return null;
    }
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  double calculateSimilarity(
    List<int> embedding1,
    List<int> embedding2,
  ) {
    if (embedding1.isEmpty || embedding2.isEmpty) {
      return 0.0;
    }

    if (embedding1.length != embedding2.length) {
      return 0.0;
    }

    double sum = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      double diff = (embedding1[i] - embedding2[i]).toDouble();

      sum += diff * diff;
    }

    double distance = Math.sqrt(sum);

    return 1.0 / (1.0 + distance / 1000.0);
  }

  void dispose() {
    _faceDetector.close();
    _isInitialized = false;
  }
}

class Math {
  static double sqrt(double x) {
    return x == 0.0 ? 0.0 : _sqrt(x);
  }

  static double _sqrt(double x) {
    double z = x;

    double y = (z + 1) / 2;

    while (y < z) {
      z = y;
      y = (z + x / z) / 2;
    }

    return z;
  }
}
