// Run: dart run tool/extract_header_cross_logo.dart [optional-source-path]

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _defaultSource =
    'assets/design/myhealth-splash-extract-source.png';
const _outPath = 'assets/icon/myhealth_header_cross.png';

void main(List<String> args) {
  final sourcePath = args.isNotEmpty ? args.first : _defaultSource;
  final file = File(sourcePath);
  if (!file.existsSync()) {
    stderr.writeln('Missing source: $sourcePath');
    exit(1);
  }

  final decoded = img.decodeImage(file.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not decode image');
    exit(1);
  }

  // Cross sits in upper-center of splash art (~22–48% vertical).
  final cropSize = (decoded.width * 0.52).round();
  final left = (decoded.width - cropSize) ~/ 2;
  final top = (decoded.height * 0.2).round();

  final cropped = img.copyCrop(
    decoded,
    x: left,
    y: top,
    width: math.min(cropSize, decoded.width - left),
    height: math.min(cropSize, decoded.height - top),
  );

  final stripped = _stripSplashBackground(cropped);
  final bounds = _opaqueBounds(stripped);
  if (bounds == null) {
    stderr.writeln('No logo pixels found after strip');
    exit(1);
  }

  final graphic = img.copyCrop(
    stripped,
    x: bounds.$1,
    y: bounds.$2,
    width: bounds.$3,
    height: bounds.$4,
  );

  const outSize = 256;
  final resized = img.copyResize(
    graphic,
    width: outSize,
    height: outSize,
    interpolation: img.Interpolation.cubic,
  );

  Directory('assets/icon').createSync(recursive: true);
  File(_outPath).writeAsBytesSync(img.encodePng(resized));
  stdout.writeln('Wrote $_outPath (${resized.width}x${resized.height})');
}

img.Image _stripSplashBackground(img.Image image) {
  final out = img.Image.from(image);
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final p = out.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final a = p.a.toInt();
      if (a == 0) continue;

      final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
      final luminance = 0.299 * r + 0.587 * g + 0.114 * b;

      final knockOut = (luminance > 200 && saturation < 0.22) ||
          (luminance > 170 && saturation < 0.12) ||
          (luminance > 140 && saturation < 0.08);

      if (knockOut) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return out;
}

(int, int, int, int)? _opaqueBounds(img.Image image) {
  var minX = image.width;
  var minY = image.height;
  var maxX = 0;
  var maxY = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a > 8) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX <= minX) return null;
  return (minX, minY, maxX - minX + 1, maxY - minY + 1);
}
