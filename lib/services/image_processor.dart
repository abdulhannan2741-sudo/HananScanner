import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Image processing: auto edge detection (auto-crop), perspective correction,
/// HD enhancement, and color modes. Pure-Dart implementation using the
/// `image` package so it works without native OpenCV bindings.
class ImageProcessor {
  ImageProcessor._();
  static final ImageProcessor instance = ImageProcessor._();

  /// Apply a color mode to an image file and return the new file path.
  /// Writes the result next to the source with a mode suffix.
  Future<String> applyColorMode(String sourcePath, ColorMode mode) async {
    final srcFile = File(sourcePath);
    final bytes = await srcFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image');

    img.Image processed;
    switch (mode) {
      case ColorMode.original:
        processed = image;
        break;
      case ColorMode.colorEnhanced:
        processed = _enhanceColor(image);
        break;
      case ColorMode.grayscale:
        processed = img.grayscale(image);
        break;
      case ColorMode.blackWhite:
        processed = _binarize(img.grayscale(image));
        break;
    }

    final outPath = _withSuffix(sourcePath, '_${mode.name}');
    final encoded = img.encodeJpg(processed, quality: 92);
    await File(outPath).writeAsBytes(encoded);
    return outPath;
  }

  /// Auto-crop: detect the bounding box of non-background content and crop.
  /// Uses a simple brightness-threshold edge detector — effective for
  /// documents photographed on a contrasting surface.
  Future<String> autoCrop(String sourcePath) async {
    final srcFile = File(sourcePath);
    final bytes = await srcFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image');

    final cropped = _detectAndCrop(image);
    final outPath = _withSuffix(sourcePath, '_crop');
    await File(outPath).writeAsBytes(img.encodeJpg(cropped, quality: 92));
    return outPath;
  }

  /// Perspective correction: given a source image and four corner points
  /// (in source pixel coordinates), produce a rectangular output of the
  /// requested size. Uses a bilinear forward-mapping approximation.
  Future<String> correctPerspective({
    required String sourcePath,
    required List<Offset> corners,
    required int outputWidth,
    required int outputHeight,
  }) async {
    final srcFile = File(sourcePath);
    final bytes = await srcFile.readAsBytes();
    final src = img.decodeImage(bytes);
    if (src == null) throw Exception('Could not decode image');

    final dst = img.Image(width: outputWidth, height: outputHeight);
    final tl = corners[0], tr = corners[1], br = corners[2], bl = corners[3];

    for (int y = 0; y < outputHeight; y++) {
      final v = y / outputHeight;
      for (int x = 0; x < outputWidth; x++) {
        final u = x / outputWidth;
        // Bilinear interpolation across the quadrilateral.
        final sx = (1 - u) * (1 - v) * tl.dx +
            u * (1 - v) * tr.dx +
            u * v * br.dx +
            (1 - u) * v * bl.dx;
        final sy = (1 - u) * (1 - v) * tl.dy +
            u * (1 - v) * tr.dy +
            u * v * br.dy +
            (1 - u) * v * bl.dy;
        final pixel = src.getPixelSafe(sx.round(), sy.round());
        dst.setPixel(x, y, pixel);
      }
    }

    final outPath = _withSuffix(sourcePath, '_persp');
    await File(outPath).writeAsBytes(img.encodeJpg(dst, quality: 92));
    return outPath;
  }

  /// Generate a thumbnail (max 400px wide) for list/grid display.
  Future<String> generateThumbnail(String sourcePath) async {
    final srcFile = File(sourcePath);
    final bytes = await srcFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image');

    final thumb = img.copyResize(image, width: 400);
    final outPath = _withSuffix(sourcePath, '_thumb');
    await File(outPath).writeAsBytes(img.encodeJpg(thumb, quality: 80));
    return outPath;
  }

  // ---- Internal helpers --------------------------------------------------

  img.Image _enhanceColor(img.Image src) {
    final out = img.Image(width: src.width, height: src.height);
    for (final pixel in out) {
      final p = src.getPixel(pixel.x, pixel.y);
      // Boost saturation & contrast.
      final r = _clamp((p.r - 128) * 1.25 + 128);
      final g = _clamp((p.g - 128) * 1.25 + 128);
      final b = _clamp((p.b - 128) * 1.25 + 128);
      out.setPixelRgb(pixel.x, pixel.y, r.round(), g.round(), b.round());
    }
    return out;
  }

  img.Image _binarize(img.Image src) {
    final out = img.Image(width: src.width, height: src.height);
    for (final pixel in out) {
      final p = src.getPixel(pixel.x, pixel.y);
      final lum = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
      final v = lum > 128 ? 255 : 0;
      out.setPixelRgb(pixel.x, pixel.y, v, v, v);
    }
    return out;
  }

  img.Image _detectAndCrop(img.Image src) {
    // Estimate background brightness from the corners.
    final tl = _avgBrightness(src, 0, 0, 10, 10);
    final tr = _avgBrightness(src, src.width - 10, 0, src.width, 10);
    final bl = _avgBrightness(src, 0, src.height - 10, 10, src.height);
    final br = _avgBrightness(src, src.width - 10, src.height - 10, src.width, src.height);
    final bg = (tl + tr + bl + br) / 4;
    final threshold = (bg * 0.7).round();

    int minX = src.width, minY = src.height, maxX = 0, maxY = 0;
    final step = (src.width / 120).ceil().clamp(1, 8);
    for (int y = 0; y < src.height; y += step) {
      for (int x = 0; x < src.width; x += step) {
        final p = src.getPixel(x, y);
        final lum = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
        if ((lum - bg).abs() > 25 && lum < threshold + 60) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    if (maxX <= minX || maxY <= minY) return src;
    // Add small padding.
    final pad = 8;
    minX = (minX - pad).clamp(0, src.width - 1);
    minY = (minY - pad).clamp(0, src.height - 1);
    maxX = (maxX + pad).clamp(0, src.width - 1);
    maxY = (maxY + pad).clamp(0, src.height - 1);
    return img.copyCrop(src, x: minX, y: minY, width: maxX - minX, height: maxY - minY);
  }

  double _avgBrightness(img.Image src, int x0, int y0, int x1, int y1) {
    double sum = 0;
    int count = 0;
    for (int y = y0; y < y1; y++) {
      for (int x = x0; x < x1; x++) {
        final p = src.getPixel(x, y);
        sum += 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }

  double _clamp(double v) => v.clamp(0, 255).toDouble();

  String _withSuffix(String path, String suffix) {
    final dir = p.dirname(path);
    final name = p.basenameWithoutExtension(path);
    final ext = p.extension(path);
    return p.join(dir, '$name$suffix$ext');
  }
}

/// A simple 2D point used for perspective correction input.
class Offset {
  const Offset(this.dx, this.dy);
  final double dx;
  final double dy;
}
