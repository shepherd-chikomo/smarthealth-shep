// Run: dart run tool/strip_category_matte.dart assets/icons/categories/lab.png
// Requires: dart pub add dev:image

import 'dart:io';

import 'package:image/image.dart' as img;

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/strip_category_matte.dart <png-path>');
    exit(1);
  }

  final path = args.first;
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('File not found: $path');
    exit(1);
  }

  final image = img.decodeImage(file.readAsBytesSync());
  if (image == null) {
    stderr.writeln('Could not decode: $path');
    exit(1);
  }

  var cleared = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final a = p.a.toInt();
      if (a == 0) continue;

      final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
      final luminance = 0.299 * r + 0.587 * g + 0.114 * b;

      final knockOut = (luminance > 235 && saturation < 0.18) ||
          (luminance > 200 && saturation < 0.1 && a < 250) ||
          (luminance > 185 && saturation < 0.06);

      if (knockOut) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
        cleared++;
      }
    }
  }

  // Downscale large generated assets for faster load.
  final resized = image.width > 160
      ? img.copyResize(image, width: 128, height: 128)
      : image;

  file.writeAsBytesSync(img.encodePng(resized));
  stdout.writeln('Stripped $cleared pixels from $path (${resized.width}x${resized.height})');
}
