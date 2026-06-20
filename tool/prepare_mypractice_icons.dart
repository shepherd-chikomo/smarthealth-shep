// Run from repo root: dart run tool/prepare_mypractice_icons.dart
//
// Builds MyPractice launcher PNGs: cross sized like MyHealth, pure black surround.

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _myHealthRef = 'assets/design/myhealth-launcher-icon.png';
const _myPracticeRef = 'assets/design/mypractice-launcher-icon.png';
const _outDir = 'my_practice/assets/icon';
const _headerOut = 'my_practice/assets/icon/mypractice_header_cross.png';
const _size = 1024;
const _adaptiveForegroundScale = 0.78;
final _pureBlack = img.ColorRgba8(0, 0, 0, 255);

void main() {
  final healthFile = File(_myHealthRef);
  final practiceFile = File(_myPracticeRef);
  if (!healthFile.existsSync() || !practiceFile.existsSync()) {
    stderr.writeln('Missing MyHealth or MyPractice reference artwork');
    exit(1);
  }

  final healthCross = _extractCross(
    _loadSquare(healthFile, pad: img.ColorRgba8(255, 255, 255, 255)),
    strip: _stripLightBackground,
  );
  final practiceCross = _extractCross(
    _loadSquare(practiceFile, pad: _pureBlack),
    strip: _stripToCrossOnly,
  );

  // Match MyHealth cross footprint on the launcher canvas.
  final healthFill = math.max(healthCross.width, healthCross.height) / _size;
  final targetCrossSize = (_size * healthFill).round();
  final scaledCross = img.copyResize(
    practiceCross,
    width: targetCrossSize,
    height: targetCrossSize,
    interpolation: img.Interpolation.cubic,
  );

  final fullIcon = _flattenSurround(
    _composeOnBackground(scaledCross, background: _pureBlack),
  );
  final foreground = _centerGraphic(
    practiceCross,
    _size,
    scale: _adaptiveForegroundScale,
  );
  final headerGraphic = _centerGraphic(practiceCross, _size, scale: 0.92);

  Directory(_outDir).createSync(recursive: true);
  File('$_outDir/app_icon.png').writeAsBytesSync(img.encodePng(fullIcon));
  File('$_outDir/app_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(foreground));
  File(_headerOut).writeAsBytesSync(img.encodePng(headerGraphic));

  stdout.writeln(
    'MyHealth cross fill: ${(healthFill * 100).toStringAsFixed(1)}%',
  );
  stdout.writeln('Wrote $_outDir/app_icon.png (${fullIcon.width}x${fullIcon.height})');
  stdout.writeln(
    'Wrote $_outDir/app_icon_foreground.png (${foreground.width}x${foreground.height})',
  );
  stdout.writeln('Wrote $_headerOut');
}

img.Image _loadSquare(File file, {required img.ColorRgba8 pad}) {
  final decoded = img.decodeImage(file.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not decode ${file.path}');
    exit(1);
  }
  final side = math.max(decoded.width, decoded.height);
  final canvas = img.Image(width: side, height: side, numChannels: 4);
  img.fill(canvas, color: pad);
  final dx = (side - decoded.width) ~/ 2;
  final dy = (side - decoded.height) ~/ 2;
  img.compositeImage(canvas, decoded, dstX: dx, dstY: dy);
  return img.copyResize(
    canvas,
    width: _size,
    height: _size,
    interpolation: img.Interpolation.cubic,
  );
}

img.Image _extractCross(
  img.Image source, {
  required img.Image Function(img.Image) strip,
}) {
  return _extractGraphic(strip(img.Image.from(source)));
}

img.Image _composeOnBackground(
  img.Image graphic, {
  required img.ColorRgba8 background,
}) {
  final canvas = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(canvas, color: background);
  final dx = (_size - graphic.width) ~/ 2;
  final dy = (_size - graphic.height) ~/ 2;
  img.compositeImage(canvas, graphic, dstX: dx, dstY: dy);
  return canvas;
}

img.Image _stripLightBackground(img.Image image) {
  final out = img.Image.from(image);
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final p = out.getPixel(x, y);
      if (p.a == 0) continue;
      if (_isKnockoutLight(p)) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return out;
}

img.Image _stripToCrossOnly(img.Image image) {
  final out = img.Image.from(image);
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final p = out.getPixel(x, y);
      if (p.a == 0) continue;
      if (!_isCrossContent(p)) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return out;
}

bool _isCrossContent(img.Pixel p) {
  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();
  final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
  final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
  final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
  final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
  // Keep gradient cross arms and white stethoscope linework.
  if (luminance > 210 && saturation < 0.25) return true;
  return saturation >= 0.22;
}

img.Image _stripDarkBackground(img.Image image) {
  final out = img.Image.from(image);
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final p = out.getPixel(x, y);
      if (p.a == 0) continue;
      if (_isKnockoutLight(p) || _isKnockoutDark(p)) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return out;
}

bool _isKnockoutLight(img.Pixel p) {
  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();
  final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
  final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
  final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
  final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
  return luminance > 235 && saturation < 0.18;
}

bool _isKnockoutDark(img.Pixel p) {
  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();
  final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
  final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
  final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
  final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
  // Drop navy surround, outer squircle, and soft drop shadow.
  return luminance < 72 && saturation < 0.55;
}

img.Image _flattenSurround(img.Image icon) {
  final out = img.Image.from(icon);
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final p = out.getPixel(x, y);
      if (p.a == 0) {
        out.setPixelRgba(x, y, 0, 0, 0, 255);
        continue;
      }
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
      final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
      if (luminance < 20 && saturation < 0.4) {
        out.setPixelRgba(x, y, 0, 0, 0, 255);
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
