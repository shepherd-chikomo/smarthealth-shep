import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smarthealth_shep/features/home/home_dashboard_colors.dart';

/// Renders a home category icon from bundled raster or vector assets.
class CategoryIcon extends StatelessWidget {
  CategoryIcon({
    super.key,
    required this.assetPath,
    this.size = 48,
    this.color,
    this.applyTint = true,
    this.fit = BoxFit.contain,
    this.removeLightMatte = false,
  });

  final String assetPath;
  final double size;
  final Color? color;
  final bool applyTint;
  final BoxFit fit;

  /// Strips near-white / light-grey rectangular mattes from generated PNG icons.
  final bool removeLightMatte;

  bool get _isRaster {
    final lower = assetPath.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.jpg');
  }

  @override
  Widget build(BuildContext context) {
    final tintColor = color ?? HomeDashboardColors.of(context).primary;

    if (_isRaster && removeLightMatte) {
      return _KnockoutMatteImage(
        assetPath: assetPath,
        size: size,
        fit: fit,
      );
    }

    if (_isRaster) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: fit,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );
    }

    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      colorFilter: applyTint
          ? ColorFilter.mode(tintColor, BlendMode.srcIn)
          : null,
    );
  }
}

/// Loads a raster asset and removes light rectangular PNG mattes.
class _KnockoutMatteImage extends StatefulWidget {
  const _KnockoutMatteImage({
    required this.assetPath,
    required this.size,
    required this.fit,
  });

  final String assetPath;
  final double size;
  final BoxFit fit;

  @override
  State<_KnockoutMatteImage> createState() => _KnockoutMatteImageState();
}

class _KnockoutMatteImageState extends State<_KnockoutMatteImage> {
  static final Map<String, ui.Image> _cache = {};

  ui.Image? _image;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _KnockoutMatteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _load();
    }
  }

  Future<void> _load() async {
    final cached = _cache[widget.assetPath];
    if (cached != null) {
      if (mounted) setState(() => _image = cached);
      return;
    }

    try {
      final bytes = await rootBundle.load(widget.assetPath);
      final data = bytes.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      final processed = await _knockOutLightMatte(frame.image);
      _cache[widget.assetPath] = processed;
      if (mounted) setState(() => _image = processed);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<ui.Image> _knockOutLightMatte(ui.Image source) async {
    final byteData = await source.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return source;

    final pixels = byteData.buffer.asUint8List();
    final width = source.width;
    final height = source.height;

    for (var i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      final a = pixels[i + 3];
      if (a == 0) continue;

      final maxC = math.max(r, math.max(g, b));
      final minC = math.min(r, math.min(g, b));
      final saturation = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
      final luminance = 0.299 * r + 0.587 * g + 0.114 * b;

      final isLightMatte = luminance > 235 && saturation < 0.18;
      final isFringe = luminance > 200 && saturation < 0.1 && a < 250;
      final isSoftBox = luminance > 185 && saturation < 0.06;

      if (isLightMatte || isFringe || isSoftBox) {
        pixels[i + 3] = 0;
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image != null) {
      return RawImage(
        image: image,
        width: widget.size,
        height: widget.size,
        fit: widget.fit,
        filterQuality: FilterQuality.high,
      );
    }

    if (_error != null) {
      return Image.asset(
        widget.assetPath,
        width: widget.size,
        height: widget.size,
        fit: widget.fit,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
    );
  }
}
