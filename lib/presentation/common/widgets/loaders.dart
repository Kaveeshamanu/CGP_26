import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

/// A collection of loading widgets for the Taprobana Trails app

/// Basic circular progress indicator with fade-in animation
class FadeInLoader extends StatefulWidget {
  final Color? color;
  final double size;
  final double strokeWidth;
  final Duration fadeInDuration;

  const FadeInLoader({
    super.key,
    this.color,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  State<FadeInLoader> createState() => _FadeInLoaderState();
}

class _FadeInLoaderState extends State<FadeInLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: widget.strokeWidth,
          color: widget.color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

/// Fullscreen loader with optional message
class FullscreenLoader extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? loaderColor;
  final bool useAnimation;
  final String? animationAsset;

  const FullscreenLoader({
    super.key,
    this.message,
    this.backgroundColor,
    this.loaderColor,
    this.useAnimation = false,
    this.animationAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (useAnimation && animationAsset != null)
              Lottie.asset(
                animationAsset!,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              )
            else
              FadeInLoader(
                color: loaderColor ?? Colors.white,
                size: 52.0,
              ),
            if (message != null) ...[
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  message!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Three dots loader animation
class ThreeDotsLoader extends StatefulWidget {
  final Color? color;
  final double dotSize;
  final double spacing;
  final Duration animationDuration;

  const ThreeDotsLoader({
    super.key,
    this.color,
    this.dotSize = 10.0,
    this.spacing = 8.0,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<ThreeDotsLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.3;
              final startValue = 0.0 + delay;
              // ignore: unused_local_variable
              final endValue = 1.0 + delay;
              
              final time = _controller.value;
              final transformedTime = (time - startValue) % 1.0;
              
              final scale = transformedTime < 0.5
                  ? 1.0 + transformedTime
                  : 2.0 - transformedTime;
              
              return Transform.scale(
                scale: scale >= 1.0 ? scale : 1.0,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// Pull to refresh loader
class PullToRefreshIndicator extends StatelessWidget {
  final Color? color;
  final String? message;

  const PullToRefreshIndicator({
    super.key,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? Theme.of(context).primaryColor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30.0,
          width: 30.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: indicatorColor,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 8.0),
          Text(
            message!,
            style: TextStyle(
              color: indicatorColor,
              fontSize: 12.0,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shimmer loading placeholder for cards
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool hasImage;
  final bool hasContent;
  final double imageHeight;
  final bool showFooter;
  final int contentLines;

  const ShimmerCard({
    super.key,
    this.height = 180.0,
    this.width,
    this.borderRadius = 12.0,
    this.margin,
    this.hasImage = true,
    this.hasContent = true,
    this.imageHeight = 120.0,
    this.showFooter = false,
    this.contentLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    
    return Container(
      margin: margin ?? const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              if (hasImage)
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadius),
                      topRight: Radius.circular(borderRadius),
                    ),
                  ),
                ),
              
              // Content placeholder
              if (hasContent)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title placeholder
                        Container(
                          width: double.infinity,
                          height: 14.0,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8.0),
                        
                        // Content lines
                        ...List.generate(contentLines, (index) {
                          final width = index == contentLines - 1 ? 0.7 : 1.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Container(
                              width: double.infinity * width,
                              height: 10.0,
                              color: Colors.white,
                            ),
                          );
                        }),
                        
                        // Footer placeholder
                        if (showFooter) ...[
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 80.0,
                                height: 10.0,
                                color: Colors.white,
                              ),
                              Container(
                                width: 40.0,
                                height: 10.0,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated loading indicator with Lottie
class LottieLoader extends StatelessWidget {
  final String animationAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool repeat;
  final String? message;
  final TextStyle? messageStyle;

  const LottieLoader({
    super.key,
    required this.animationAsset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.message,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          animationAsset,
          width: width,
          height: height,
          fit: fit,
          repeat: repeat,
        ),
        if (message != null) ...[
          const SizedBox(height: 16.0),
          Text(
            message!,
            style: messageStyle ?? Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Content loading placeholder
class ContentLoader extends StatelessWidget {
  final int itemCount;
  final bool showImage;
  final bool isGrid;
  final int gridCrossAxisCount;
  final double height;
  final double spacing;

  const ContentLoader({
    super.key,
    this.itemCount = 5,
    this.showImage = true,
    this.isGrid = false,
    this.gridCrossAxisCount = 2,
    this.height = 180.0,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCrossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.75,
        ),
        itemCount: itemCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ShimmerCard(
            height: height,
            hasImage: showImage,
            imageHeight: height * 0.6,
            contentLines: 1,
          );
        },
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(spacing),
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: ShimmerCard(
            height: height,
            hasImage: showImage,
            contentLines: 2,
            showFooter: true,
          ),
        );
      },
    );
  }
}