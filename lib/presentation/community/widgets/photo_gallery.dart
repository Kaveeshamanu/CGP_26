import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taprobana_trails/bloc/gallery/gallery_bloc.dart';

import '../../common/widgets/loaders.dart';

/// A widget for displaying a grid of photos with fullscreen gallery view
class PhotoGallery extends StatefulWidget {
  final List<String> photoUrls;
  final String? title;
  final String? subtitle;
  final int crossAxisCount;
  final double spacing;
  final bool showViewAll;
  final int maxDisplayed;
  final VoidCallback? onTapViewAll;
  final bool canDelete;
  final Function(int)? onDelete;

  const PhotoGallery({
    super.key,
    required this.photoUrls,
    this.title,
    this.subtitle,
    this.crossAxisCount = 3,
    this.spacing = 8.0,
    this.showViewAll = true,
    this.maxDisplayed = 6,
    this.onTapViewAll,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  @override
  Widget build(BuildContext context) {
    if (widget.photoUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCount =
        widget.showViewAll && widget.photoUrls.length > widget.maxDisplayed
            ? widget.maxDisplayed
            : widget.photoUrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header if provided
        if (widget.title != null || widget.subtitle != null) _buildHeader(),

        // Photo grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: widget.spacing,
            mainAxisSpacing: widget.spacing,
          ),
          itemCount: widget.showViewAll &&
                  widget.photoUrls.length > widget.maxDisplayed
              ? displayCount + 1 // +1 for the "View All" tile
              : displayCount,
          itemBuilder: (context, index) {
            if (index == displayCount &&
                widget.showViewAll &&
                widget.photoUrls.length > widget.maxDisplayed) {
              // "View All" tile
              return _buildViewAllTile();
            }

            return _buildPhotoTile(index);
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (widget.onTapViewAll != null &&
              widget.photoUrls.length > widget.maxDisplayed)
            TextButton(
              onPressed: widget.onTapViewAll,
              child: Text('View All (${widget.photoUrls.length})'),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(int index) {
    return GestureDetector(
      onTap: () => _openGallery(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.photoUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surface,
                  highlightColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
              if (widget.canDelete)
                Positioned(
                  top: 4.0,
                  right: 4.0,
                  child: GestureDetector(
                    onTap: () => widget.onDelete?.call(index),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewAllTile() {
    final remainingCount = widget.photoUrls.length - widget.maxDisplayed;

    return GestureDetector(
      onTap: widget.onTapViewAll ?? () => _openGallery(widget.maxDisplayed),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.photoUrls[widget.maxDisplayed],
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surface,
                  highlightColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Text(
                    '+$remainingCount more',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenGallery(
          photoUrls: widget.photoUrls,
          initialIndex: initialIndex,
          title: widget.title,
          canDelete: widget.canDelete,
          onDelete: widget.onDelete,
        ),
      ),
    );
  }
}

/// A fullscreen gallery for viewing photos
class FullscreenGallery extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;
  final String? title;
  final bool canDelete;
  final Function(int)? onDelete;

  const FullscreenGallery({
    super.key,
    required this.photoUrls,
    this.initialIndex = 0,
    this.title,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isShowingControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _isShowingControls = !_isShowingControls;
    });
  }

  void _shareImage() {
    final imageUrl = widget.photoUrls[_currentIndex];
    Share.share('Check out this photo: $imageUrl');
  }

  void _deleteImage() {
    if (widget.onDelete != null) {
      widget.onDelete!(_currentIndex);

      // If we're deleting the last image, go back
      if (_currentIndex == widget.photoUrls.length - 1) {
        if (widget.photoUrls.length == 1) {
          // If it's the only image, just go back
          Navigator.pop(context);
        } else {
          // Otherwise move to previous image
          setState(() {
            _currentIndex--;
            _pageController.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gallery
          GestureDetector(
            onTap: _toggleControls,
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider:
                      CachedNetworkImageProvider(widget.photoUrls[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  heroAttributes: PhotoViewHeroAttributes(
                      tag: 'photo_${widget.photoUrls[index]}'),
                );
              },
              itemCount: widget.photoUrls.length,
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                  ),
                ),
              ),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),

          // Controls
          if (_isShowingControls) ...[
            // App bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8.0,
                  bottom: 16.0,
                  left: 8.0,
                  right: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: _shareImage,
                        ),
                        if (widget.canDelete)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: _deleteImage,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Image counter
            Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.photoUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A photo gallery with BLoC integration for managing photos
class ManagedPhotoGallery extends StatelessWidget {
  final String entityId;
  final String entityType;
  final String? title;
  final String? subtitle;
  final int crossAxisCount;
  final double spacing;
  final bool canDelete;

  const ManagedPhotoGallery({
    super.key,
    required this.entityId,
    required this.entityType,
    this.title,
    this.subtitle,
    this.crossAxisCount = 3,
    this.spacing = 8.0,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        if (state is GalleryInitial) {
          // If initial state, dispatch event to load photos
          context.read<GalleryBloc>().add(GalleryPhotosRequested(
                entityId: entityId,
                entityType: entityType,
              ));

          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is GalleryLoading && state.photos.isEmpty) {
          return _buildLoadingGrid();
        }

        if (state is GalleryError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48.0),
                const SizedBox(height: 16.0),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    context.read<GalleryBloc>().add(GalleryPhotosRequested(
                          entityId: entityId,
                          entityType: entityType,
                        ));
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final photos = state is GalleryLoaded
            ? state.photos
            : state is GalleryLoading
                ? state.photos
                : [];

        if (photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_library_outlined,
                    color: Colors.grey, size: 48.0),
                const SizedBox(height: 16.0),
                Text(
                  'No photos available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return PhotoGallery(
          photoUrls: photos.map((photo) => photo['url'] as String).toList(),
          title: title,
          subtitle: subtitle,
          crossAxisCount: crossAxisCount,
          spacing: spacing,
          canDelete: canDelete,
          onDelete: canDelete
              ? (index) {
                  final photoId = photos[index]['id'] as String;
                  context.read<GalleryBloc>().add(GalleryPhotoDelete(
                        entityId: entityId,
                        entityType: entityType,
                        photoId: photoId,
                      ));
                }
              : null,
          onTapViewAll: () {
            // Navigate to a dedicated gallery view if needed
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullscreenGallery(
                  photoUrls:
                      photos.map((photo) => photo['url'] as String).toList(),
                  title: title,
                  canDelete: canDelete,
                  onDelete: canDelete
                      ? (index) {
                          final photoId = photos[index]['id'] as String;
                          context.read<GalleryBloc>().add(GalleryPhotoDelete(
                                entityId: entityId,
                                entityType: entityType,
                                photoId: photoId,
                              ));
                        }
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: 6, // Show 6 placeholder items
      itemBuilder: (context, index) {
        return ShimmerCard(
          height: 120.0,
          width: 120.0,
          borderRadius: 8.0,
          hasContent: false,
        );
      },
    );
  }
}
