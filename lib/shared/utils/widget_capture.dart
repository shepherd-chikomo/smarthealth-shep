import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Captures a [RepaintBoundary] widget as PNG bytes.
Future<Uint8List?> captureRepaintBoundary(GlobalKey boundaryKey, {double pixelRatio = 2}) async {
  final context = boundaryKey.currentContext;
  if (context == null) return null;

  final boundary = context.findRenderObject();
  if (boundary is! RenderRepaintBoundary) return null;

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
