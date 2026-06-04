// Run: dart run tool/generate_home_header_sample.dart
//
// Composites a home header mockup with the cross logo + MyHealth wordmark.

import 'dart:io';

import 'package:image/image.dart' as img;

const _outPath = 'assets/design/home-header-with-new-logo-sample.png';
const _logoPath = 'assets/icon/app_icon_foreground.png';
const _headerBlue = 0xFF0072BC;

void main() {
  const w = 1080;
  const h = 520;

  final canvas = img.Image(width: w, height: h, numChannels: 4);
  img.fill(canvas, color: img.ColorRgb8(0, 114, 188));

  // Subtle top highlight
  for (var y = 0; y < h * 0.4; y++) {
    final t = 1 - y / (h * 0.4);
    final alpha = (18 * t).round();
    for (var x = 0; x < w; x++) {
      final p = canvas.getPixel(x, y);
      final r = p.r.toInt() + alpha;
      final g = p.g.toInt() + alpha;
      final b = p.b.toInt() + alpha;
      canvas.setPixelRgba(x, y, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255), 255);
    }
  }

  final logoFile = File(_logoPath);
  if (!logoFile.existsSync()) {
    stderr.writeln('Missing $_logoPath');
    exit(1);
  }
  final logo = img.decodeImage(logoFile.readAsBytesSync());
  if (logo == null) exit(1);

  const logoSize = 96;
  final logoResized = img.copyResize(logo, width: logoSize, height: logoSize);
  final logoX = (w - logoSize) ~/ 2;
  const logoY = 72;
  img.compositeImage(canvas, logoResized, dstX: logoX, dstY: logoY);

  _drawCenteredText(
    canvas,
    'MyHealth',
    y: logoY + logoSize + 20,
    size: 44,
    color: img.ColorRgb8(255, 255, 255),
    bold: true,
  );
  _drawCenteredText(
    canvas,
    'Powered by SmartHealth',
    y: logoY + logoSize + 72,
    size: 18,
    color: img.ColorRgb8(255, 255, 255),
  );

  _drawCenteredText(
    canvas,
    'Good afternoon',
    y: logoY + logoSize + 118,
    size: 22,
    color: img.ColorRgb8(220, 235, 245),
  );
  _drawCenteredText(
    canvas,
    'Tendai 👋',
    y: logoY + logoSize + 148,
    size: 36,
    color: img.ColorRgb8(255, 255, 255),
    bold: true,
  );

  // Location pill
  const pillW = 200;
  const pillH = 40;
  final pillX = (w - pillW) ~/ 2;
  const pillY = logoY + logoSize + 200;
  img.fillRect(
    canvas,
    x1: pillX,
    y1: pillY,
    x2: pillX + pillW,
    y2: pillY + pillH,
    color: img.ColorRgb8(0, 90, 150),
  );
  _drawCenteredText(
    canvas,
    'Harare',
    y: pillY + 10,
    size: 18,
    color: img.ColorRgb8(255, 255, 255),
    width: pillW,
    centerX: pillX,
  );

  // Search bar
  const barW = w - 80;
  const barH = 52;
  final barX = 40;
  final barY = pillY + pillH + 24;
  img.fillRect(
    canvas,
    x1: barX,
    y1: barY,
    x2: barX + barW,
    y2: barY + barH,
    color: img.ColorRgb8(255, 255, 255),
  );
  _drawCenteredText(
    canvas,
    'Search doctors, hospitals, pharmacies',
    y: barY + 16,
    size: 17,
    color: img.ColorRgb8(117, 117, 117),
    width: barW,
    centerX: barX,
    alignLeft: true,
    padding: 20,
  );

  Directory('assets/design').createSync(recursive: true);
  File(_outPath).writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('Wrote $_outPath (${w}x$h)');
}

void _drawCenteredText(
  img.Image canvas,
  String text, {
  required int y,
  required int size,
  required img.ColorRgb8 color,
  bool bold = false,
  int? width,
  int? centerX,
  bool alignLeft = false,
  int padding = 0,
}) {
  final font = bold ? img.arial24 : img.arial14;
  final scale = size / (bold ? 24 : 14);
  final tw = (text.length * (bold ? 14 : 8) * scale).round();
  var x = centerX ?? (canvas.width - tw) ~/ 2;
  if (alignLeft && width != null && centerX != null) {
    x = centerX + padding;
  } else if (width != null) {
    x = centerX! + (width - tw) ~/ 2;
  }
  img.drawString(
    canvas,
    text,
    font: font,
    x: x,
    y: y,
    color: color,
  );
}
