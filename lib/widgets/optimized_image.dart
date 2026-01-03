import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'animated_widgets.dart';

/// Optimized network image with caching, placeholder, and error handling.
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width != null ? (width! * 2).toInt() : 800,
      memCacheHeight: height != null ? (height! * 2).toInt() : 800,
      placeholder: (context, url) => ShimmerSkeleton(
        width: width ?? double.infinity,
        height: height ?? 200,
        borderRadius: borderRadius,
      ),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
      ),
    );
  }
}

/// Optimized image with a hero animation.
class HeroImage extends StatelessWidget {
  final String tag;
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const HeroImage({
    super.key,
    required this.tag,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: OptimizedImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Placeholder image for when no URL is available.
class PlaceholderImage extends StatelessWidget {
  final double? width;
  final double? height;
  final IconData icon;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const PlaceholderImage({
    super.key,
    this.width,
    this.height,
    this.icon = Icons.image,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget container = Container(
      width: width,
      height: height,
      color: backgroundColor ?? (isDark ? Colors.grey[800] : Colors.grey[200]),
      child: Center(
        child: Icon(
          icon,
          size: (height ?? 100) * 0.4,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );

    if (borderRadius != null) {
      container = ClipRRect(borderRadius: borderRadius!, child: container);
    }

    return container;
  }
}
