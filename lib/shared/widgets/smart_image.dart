import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smarthealth_shep/core/assets.dart';

/// Loads a bundled asset or remote URL with a shared placeholder.
class SmartImage extends StatelessWidget {
  const SmartImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.error,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? error;
  final int? memCacheWidth;
  final int? memCacheHeight;

  static bool isAssetPath(String value) => value.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final resolved = source;
    if (resolved == null || resolved.isEmpty) {
      return _wrap(error ?? placeholder ?? _defaultPlaceholder());
    }

    if (isAssetPath(resolved)) {
      return _wrap(
        Image.asset(
          resolved,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) =>
              error ?? placeholder ?? _defaultPlaceholder(),
        ),
      );
    }

    return _wrap(
      CachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: (_, _) => placeholder ?? _defaultPlaceholder(),
        errorWidget: (_, _, _) =>
            error ?? placeholder ?? _defaultPlaceholder(),
      ),
    );
  }

  Widget _defaultPlaceholder() {
    return Image.asset(
      AppAssets.providerPlaceholder,
      width: width,
      height: height,
      fit: fit,
    );
  }

  Widget _wrap(Widget child) {
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}
