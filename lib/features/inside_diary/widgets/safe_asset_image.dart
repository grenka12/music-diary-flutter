import 'package:flutter/material.dart';

class SafeAssetImage extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SafeAssetImage({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  static const String _placeholderAsset = 'assets/images/placeholder.png';

  @override
  Widget build(BuildContext context) {
    Widget child = _buildImage(asset);
    if (borderRadius != null) {
      child = ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: child,
      );
    }
    return child;
  }

  Widget _buildImage(String path) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (path == _placeholderAsset) {
          return Container(
            width: width,
            height: height,
            color: Colors.white12,
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported, color: Colors.white54),
          );
        }
        return _buildImage(_placeholderAsset);
      },
    );
  }
}
