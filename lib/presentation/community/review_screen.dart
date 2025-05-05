import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:taprobana_trails/bloc/review/review_bloc.dart';
import 'dart:io';

import '../../data/models/user.dart';
import '../../core/utils/connectivity.dart';
import '../../core/utils/validation.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';
import '../common/widgets/notifications.dart';

class ReviewScreen extends StatefulWidget {
  final String? entityId;
  final String?
      entityType; // 'accommodation', 'restaurant', 'destination', etc.
  final String? entityName;
  final String? entityImage;
  final double? currentRating;
  final bool editMode;
  final Map<String, dynamic>? existingReview;

  const ReviewScreen({
    super.key,
    this.entityId,
    this.entityType,
    this.entityName,
    this.entityImage,
    this.currentRating,
    this.editMode = false,
    this.existingReview,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late ReviewBloc _reviewBloc;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reviewController = TextEditingController();
  final _imagePicker = ImagePicker();
  double _rating = 0;
  bool _isRecommended = true;
  bool _isLoading = false;
  final List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  final List<String> _ratingCategoryTitles = [];
  final Map<String, double> _categoryRatings = {};
  DateTime? _visitDate;

  get ConnectivityHelper => null;

  @override
  void initState() {
    super.initState();
    _reviewBloc = BlocProvider.of<ReviewBloc>(context);
    _initReviewData();
    _setupRatingCategories();
  }

  void _initReviewData() {
    if (widget.editMode && widget.existingReview != null) {
      _titleController.text = widget.existingReview!['title'] as String? ?? '';
      _reviewController.text =
          widget.existingReview!['review'] as String? ?? '';
      _rating = widget.existingReview!['rating'] as double? ?? 0.0;
      _isRecommended = widget.existingReview!['recommended'] as bool? ?? true;
      _existingImageUrls =
          List<String>.from(widget.existingReview!['imageUrls'] ?? []);

      if (widget.existingReview!['visitDate'] != null) {
        _visitDate =
            DateTime.tryParse(widget.existingReview!['visitDate'] as String);
      }

      // Initialize category ratings if they exist
      final categoryRatings =
          widget.existingReview!['categoryRatings'] as Map<String, dynamic>?;
      if (categoryRatings != null) {
        categoryRatings.forEach((key, value) {
          _categoryRatings[key] = (value as num).toDouble();
        });
      }
    } else {
      _rating = widget.currentRating ?? 0.0;
    }
  }

  void _setupRatingCategories() {
    // Set up categories based on entity type
    switch (widget.entityType) {
      case 'accommodation':
        _ratingCategoryTitles.addAll([
          'Cleanliness',
          'Location',
          'Staff',
          'Comfort',
          'Value for Money',
          'Facilities',
        ]);
        break;
      case 'restaurant':
        _ratingCategoryTitles.addAll([
          'Food Quality',
          'Service',
          'Ambiance',
          'Value for Money',
          'Cleanliness',
        ]);
        break;
      case 'destination':
        _ratingCategoryTitles.addAll([
          'Attractions',
          'Accessibility',
          'Safety',
          'Value for Money',
          'Family Friendliness',
        ]);
        break;
      case 'transport':
        _ratingCategoryTitles.addAll([
          'Comfort',
          'Reliability',
          'Cleanliness',
          'Value for Money',
          'Staff Service',
        ]);
        break;
      default:
        // No categories for other entity types
        break;
    }

    // Initialize category ratings
    for (final category in _ratingCategoryTitles) {
      if (!_categoryRatings.containsKey(category)) {
        _categoryRatings[category] = _rating;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _visitDate) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages
              .addAll(images.map((image) => File(image.path)).toList());
        });
      }
    } catch (e) {
      ToastNotification.showError('Failed to pick images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating == 0) {
      ToastNotification.showWarning('Please provide a rating');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check connectivity first
      final isConnected = await ConnectivityHelper.isConnected();
      if (!isConnected) {
        throw Exception(
            'No internet connection. Please check your connection and try again.');
      }

      // Create the review data
      final Map<String, dynamic> reviewData = {
        'entityId': widget.entityId,
        'entityType': widget.entityType,
        'title': _titleController.text.trim(),
        'review': _reviewController.text.trim(),
        'rating': _rating,
        'recommended': _isRecommended,
        'visitDate': _visitDate?.toIso8601String(),
        'categoryRatings': _categoryRatings,
      };

      // Submit the review
      if (widget.editMode) {
        _reviewBloc.add(
          ReviewUpdate(
            reviewId: widget.existingReview!['id'] as String,
            reviewData: reviewData,
            newImages: _selectedImages,
            existingImageUrls: _existingImageUrls,
          ),
        );
      } else {
        _reviewBloc.add(
          ReviewSubmit(
            reviewData: reviewData,
            images: _selectedImages,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastNotification.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.editMode ? 'Edit Review' : 'Write a Review',
        showBackButton: true,
      ),
      body: BlocListener<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ReviewSuccess) {
            setState(() {
              _isLoading = false;
            });
            ToastNotification.showSuccess(
                'Review ${widget.editMode ? 'updated' : 'submitted'} successfully');
            Navigator.pop(context, true); // Return success result
          } else if (state is ReviewError) {
            setState(() {
              _isLoading = false;
            });
            ToastNotification.showError(state.message);
          }
        },
        child: Stack(
          children: [
            _buildReviewForm(),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entity info if available
            if (widget.entityName != null) _buildEntityInfo(),

            const SizedBox(height: 24.0),

            // Overall Rating
            _buildSectionTitle('Overall Rating'),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 36.0,
                glow: false,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontSize: 16.0,
                  color: _getRatingColor(_rating),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Category Ratings if available
            if (_ratingCategoryTitles.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              _buildSectionTitle('Rate Specific Aspects'),
              ..._ratingCategoryTitles
                  .map((category) => _buildCategoryRating(category)),
            ],

            const SizedBox(height: 24.0),

            // Recommended
            _buildSectionTitle('Would you recommend this place?'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRecommended = true),
                    child: _buildRecommendationButton(
                      text: 'Yes',
                      icon: Icons.thumb_up,
                      isSelected: _isRecommended,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRecommended = false),
                    child: _buildRecommendationButton(
                      text: 'No',
                      icon: Icons.thumb_down,
                      isSelected: !_isRecommended,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // Visit Date
            _buildSectionTitle('When did you visit?'),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12.0),
                    Text(
                      _visitDate != null
                          ? DateFormat('MMMM d, yyyy').format(_visitDate!)
                          : 'Select visit date',
                      style: _visitDate == null
                          ? TextStyle(color: Theme.of(context).hintColor)
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),

            // Review Title
            _buildSectionTitle('Title your review'),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Summarize your experience',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide a title';
                }
                return null;
              },
            ),

            const SizedBox(height: 24.0),

            // Review Content
            _buildSectionTitle('Write your review'),
            TextFormField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Share your experience with others',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              minLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please write your review';
                }
                if (value.length < 10) {
                  return 'Review is too short';
                }
                return null;
              },
            ),

            const SizedBox(height: 24.0),

            // Photo Upload
            _buildSectionTitle('Add Photos (Optional)'),
            _buildImageSection(),

            const SizedBox(height: 32.0),

            // Submit Button
            PrimaryButton(
              text: widget.editMode ? 'Update Review' : 'Submit Review',
              onPressed: _submitReview,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.entityImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: widget.entityImage!,
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surface,
                  highlightColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60.0,
                  height: 60.0,
                  color: Theme.of(context).colorScheme.surface,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.entityName!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'You are reviewing: ${_getEntityTypeLabel()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (widget.currentRating != null) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(
                        'Current rating: ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      RatingBar.builder(
                        initialRating: widget.currentRating!,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 12.0,
                        ignoreGestures: true,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildCategoryRating(String category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              category,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 7,
            child: RatingBar.builder(
              initialRating: _categoryRatings[category] ?? _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 24.0,
              glow: false,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _categoryRatings[category] = rating;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationButton({
    required String text,
    required IconData icon,
    required bool isSelected,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color:
            isSelected ? color.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected ? color : Theme.of(context).dividerColor,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? color : Theme.of(context).iconTheme.color,
          ),
          const SizedBox(width: 8.0),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? color : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display existing images if in edit mode
        if (_existingImageUrls.isNotEmpty) ...[
          SizedBox(
            height: 100.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImageUrls.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: CachedNetworkImage(
                          imageUrl: _existingImageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Theme.of(context).colorScheme.surface,
                            highlightColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4.0,
                      right: 12.0,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
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
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
        ],

        // Display selected images
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 100.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4.0,
                      right: 12.0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
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
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
        ],

        // Add photos button
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add Photos'),
          style: OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Add up to 5 photos to help others see what you experienced',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _getEntityTypeLabel() {
    switch (widget.entityType) {
      case 'accommodation':
        return 'Accommodation';
      case 'restaurant':
        return 'Restaurant';
      case 'destination':
        return 'Destination';
      case 'transport':
        return 'Transportation';
      case 'activity':
        return 'Activity';
      default:
        return widget.entityType ?? 'Place';
    }
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.0) return 'Good';
    if (rating >= 2.0) return 'Fair';
    if (rating > 0) return 'Poor';
    return 'Not Rated';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.0) return Colors.amber;
    if (rating >= 2.0) return Colors.orange;
    if (rating > 0) return Colors.red;
    return Colors.grey;
  }
}
