import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../bloc/forum/forum_bloc.dart';
import '../../../bloc/forum/forum_event.dart';
import '../../../bloc/forum/forum_state.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;

/// A widget that displays a forum discussion thread in a list
class DiscussionThread extends StatelessWidget {
  final Map<String, dynamic> threadData;
  final bool isDetailed;
  final bool showFullContent;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final bool isPreview;

  const DiscussionThread({
    super.key,
    required this.threadData,
    this.isDetailed = false,
    this.showFullContent = false,
    this.onTap,
    this.onUpvote,
    this.onShare,
    this.onSave,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = DateTime.parse(threadData['createdAt'] as String);
    final String timeAgo = timeago.format(createdAt);
    
    final int upvotes = threadData['upvotes'] as int? ?? 0;
    final int commentCount = threadData['commentCount'] as int? ?? 0;
    final bool isUpvoted = threadData['isUpvoted'] as bool? ?? false;
    final bool hasAttachment = (threadData['attachments'] as List<dynamic>?)?.isNotEmpty ?? false;
    final bool hasImage = (threadData['imageUrls'] as List<dynamic>?)?.isNotEmpty ?? false;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isPreview || isDetailed
            ? null 
            : BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
        padding: isPreview || isDetailed 
            ? EdgeInsets.zero 
            : const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thread header (user info and date)
            _buildThreadHeader(context, timeAgo),
            
            // Thread title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                threadData['title'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Thread content
            _buildThreadContent(context),
            
            // Thread images
            if (hasImage) _buildImagePreview(context),
            
            // Thread categories/tags
            if ((threadData['tags'] as List<dynamic>?)?.isNotEmpty ?? false)
              _buildTagsList(context),
            
            // Thread actions (upvote, comment, share)
            const SizedBox(height: 12.0),
            _buildThreadActions(context, upvotes, commentCount, isUpvoted),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadHeader(BuildContext context, String timeAgo) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: 16.0,
          backgroundImage: threadData['authorPhotoUrl'] != null
              ? CachedNetworkImageProvider(threadData['authorPhotoUrl'] as String)
              : null,
          child: threadData['authorPhotoUrl'] == null
              ? Text((threadData['authorName'] as String).substring(0, 1).toUpperCase())
              : null,
        ),
        const SizedBox(width: 8.0),
        
        // User name and post time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                threadData['authorName'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timeAgo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        
        // Category pill
        if (threadData['category'] != null && !isPreview)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: _getCategoryColor(threadData['category'] as String).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              threadData['category'] as String,
              style: TextStyle(
                color: _getCategoryColor(threadData['category'] as String),
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThreadContent(BuildContext context) {
    final String content = threadData['content'] as String;
    
    if (showFullContent) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(content),
      );
    }
    
    // Show a preview of the content
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        content.length > 150 && !isDetailed
            ? '${content.substring(0, 150)}...'
            : content,
        maxLines: isDetailed ? 4 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final List<String> imageUrls = List<String>.from(threadData['imageUrls'] as List<dynamic>);
    
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: imageUrls.length == 1
            ? _buildSingleImage(context, imageUrls.first)
            : _buildMultipleImages(context, imageUrls),
      ),
    );
  }

  Widget _buildSingleImage(BuildContext context, String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      height: 200.0,
      width: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surface,
        highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        child: Container(
          height: 200.0,
          width: double.infinity,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 200.0,
        width: double.infinity,
        color: Colors.grey.shade300,
        child: const Icon(Icons.error, color: Colors.grey),
      ),
    );
  }

  Widget _buildMultipleImages(BuildContext context, List<String> imageUrls) {
    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length > 3 ? 4 : imageUrls.length,
        itemBuilder: (context, index) {
          // Show +X overlay for the last item if there are more than 3 images
          final bool isLastWithMore = index == 3 && imageUrls.length > 4;
          final String imageUrl = isLastWithMore 
              ? imageUrls[3] 
              : imageUrls[index];
              
          return Container(
            width: 120.0,
            margin: const EdgeInsets.only(right: 8.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.surface,
                      highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                ),
                if (isLastWithMore)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '+${imageUrls.length - 3}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagsList(BuildContext context) {
    final List<String> tags = List<String>.from(threadData['tags'] as List<dynamic>);
    
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              '#$tag',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThreadActions(BuildContext context, int upvotes, int commentCount, bool isUpvoted) {
    return Row(
      children: [
        // Upvote button
        InkWell(
          onTap: onUpvote ?? () {
            context.read<ForumBloc>().add(ForumThreadUpvote(
              threadId: threadData['id'] as String,
              isUpvoting: !isUpvoted,
            ));
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  isUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 16.0,
                  color: isUpvoted
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 4.0),
                Text(
                  upvotes.toString(),
                  style: TextStyle(
                    color: isUpvoted ? Theme.of(context).primaryColor : null,
                    fontWeight: isUpvoted ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16.0),
        
        // Comments count
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.comment_outlined,
                  size: 16.0,
                ),
                const SizedBox(width: 4.0),
                Text(commentCount.toString()),
              ],
            ),
          ),
        ),
        
        const Spacer(),
        
        // Share button
        if (onShare != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 16.0),
            onPressed: onShare,
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(),
          ),
        
        const SizedBox(width: 16.0),
        
        // Save/bookmark button
        if (onSave != null)
          IconButton(
            icon: Icon(
              threadData['isSaved'] as bool? ?? false
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              size: 16.0,
            ),
            onPressed: onSave,
            padding: const EdgeInsets.all(8.0),
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'destinations':
        return Colors.purple;
      case 'accommodation':
        return Colors.blue;
      case 'transportation':
        return Colors.green;
      case 'food & dining':
        return Colors.orange;
      case 'activities':
        return Colors.red;
      case 'tips & advice':
        return Colors.teal;
      case 'meetups':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

/// A compact version of the discussion thread for use in limited space
class CompactDiscussionThread extends StatelessWidget {
  final Map<String, dynamic> threadData;
  final VoidCallback? onTap;

  const CompactDiscussionThread({
    super.key,
    required this.threadData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = DateTime.parse(threadData['createdAt'] as String);
    final String timeAgo = timeago.format(createdAt);
    final int commentCount = threadData['commentCount'] as int? ?? 0;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User avatar
            CircleAvatar(
              radius: 14.0,
              backgroundImage: threadData['authorPhotoUrl'] != null
                  ? CachedNetworkImageProvider(threadData['authorPhotoUrl'] as String)
                  : null,
              child: threadData['authorPhotoUrl'] == null
                  ? Text((threadData['authorName'] as String).substring(0, 1).toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12.0),
            
            // Thread content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    threadData['title'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Row(
                    children: [
                      Text(
                        threadData['authorName'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Comment count
            if (commentCount > 0) ...[
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 12.0,
                    ),
                    const SizedBox(width: 2.0),
                    Text(
                      commentCount.toString(),
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}