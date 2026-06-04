// Run: dart run tool/prepare_myhealth_icons.dart
//
// Builds square launcher PNGs from the final white+cross artwork.

import 'dart:io';

import 'package:image/image.dart' as img;

const _referencePath = 'assets/design/myhealth-launcher-icon.png';
const _outDir = 'assets/icon';
const _size = 1024;
const _foregroundScale = 0.78;

void main() {
  final refFile = File(_referencePath);
  if (!refFile.existsSync()) {
    stderr.writeln('Missing reference: $_referencePath');
    exit(1);
  }

  final decoded = img.decodeImage(refFile.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not decode reference PNG');
    exit(1);
  }

  final square = _toSquare(decoded);
  final fullIcon = img.copyResize(
    square,
    width: _size,
    height: _size,
    interpolation: img.Interpolation.cubic,
  );

  final working = img.Image.from(fullIcon);
  final graphic = _extractGraphic(_stripWhiteBackground(working));
  final foreground = _centerGraphic(
    graphic,
    _size,
    scale: _foregroundScale,
  );

  Directory(_outDir).createSync(recursive: true);
  File('$_outDir/app_icon.png').writeAsBytesSync(img.encodePng(fullIcon));
  File('$_outDir/app_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(foreground));

  stdout.writeln('Wrote $_outDir/app_icon.png (${fullIcon.width}x${fullIcon.height})');
  stdout.writeln(
    'Wrote $_outDir/app_icon_foreground.png (${foreground.width}x${foreground.height})',
  );
}

img.Image _toSquare(img.Image source) {
  final side = source.width > source.height ? source.width : source.height;
  final canvas = img.Image(width: side, height: side, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(255, 255, 255, 255));
  final dx = (side - source.width) ~/ 2;
  final dy = (side - source.height) ~/ 2;
  img.compositeImage(canvas, source, dstX: dx, dstY: dy);
  return canvas;
}

img.Image _stripWhiteBackground(img.Image image) {
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

      final knockOutWhite = luminance > 235 && saturation < 0.18;

      if (knockOutWhite) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return out;
}

img.Image _extractGraphic(img.Image stripped) {
  var minX = stripped.width;
  var minY = stripped.height;
  var maxX = 0;
  var maxY = 0;

  for (var y = 0; y < stripped.height; y++) {
    for (var x = 0; x < stripped.width; x++) {
      if (stripped.getPixel(x, y).a > 0) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }

  if (maxX <= minX || maxY <= minY) {
    stderr.writeln('No opaque pixels left after background strip');
    exit(1);
  }

  return img.copyCrop(
    stripped,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
}

img.Image _centerGraphic(
  img.Image graphic,
  int canvasSize, {
  required double scale,
}) {
  final canvas = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  final target = (canvasSize * scale).round();
  final resized = img.copyResize(
    graphic,
    width: target,
    height: target,
    interpolation: img.Interpolation.cubic,
  );
  final dx = (canvasSize - resized.width) ~/ 2;
  final dy = (canvasSize - resized.height) ~/ 2;
  img.compositeImage(canvas, resized, dstX: dx, dstY: dy);
  return canvas;
}
