// gallery_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Part 1: Define Events
abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object> get props => [];
}

class GalleryPhotosRequested extends GalleryEvent {
  final String entityId;
  final String entityType;

  const GalleryPhotosRequested({
    required this.entityId,
    required this.entityType,
  });

  @override
  List<Object> get props => [entityId, entityType];
}

class GalleryPhotoDelete extends GalleryEvent {
  final String entityId;
  final String entityType;
  final String photoId;

  const GalleryPhotoDelete({
    required this.entityId,
    required this.entityType,
    required this.photoId,
  });

  @override
  List<Object> get props => [entityId, entityType, photoId];
}

class GalleryPhotoAdd extends GalleryEvent {
  final String entityId;
  final String entityType;
  final String photoPath;

  const GalleryPhotoAdd({
    required this.entityId,
    required this.entityType,
    required this.photoPath,
  });

  @override
  List<Object> get props => [entityId, entityType, photoPath];
}

// Part 2: Define States
abstract class GalleryState extends Equatable {
  final List<Map<String, dynamic>> photos;

  const GalleryState({this.photos = const []});

  @override
  List<Object> get props => [photos];
}

class GalleryInitial extends GalleryState {
  const GalleryInitial() : super();
}

class GalleryLoading extends GalleryState {
  const GalleryLoading({super.photos});
}

class GalleryLoaded extends GalleryState {
  const GalleryLoaded(List<Map<String, dynamic>> photos)
      : super(photos: photos);
}

class GalleryError extends GalleryState {
  final String message;

  const GalleryError(this.message, {super.photos});

  @override
  List<Object> get props => [message, photos];
}

// Part 3: Implement the GalleryBloc
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  // You would typically inject an API service here
  // final GalleryApiService galleryService;

  GalleryBloc() : super(const GalleryInitial()) {
    on<GalleryPhotosRequested>(_onPhotosRequested);
    on<GalleryPhotoDelete>(_onPhotoDelete);
    on<GalleryPhotoAdd>(_onPhotoAdd);
  }

  Future<void> _onPhotosRequested(
    GalleryPhotosRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(const GalleryLoading());

    try {
      // In a real app, you would call your API service here
      // final photos = await galleryService.getPhotos(event.entityId, event.entityType);

      // For now, we'll use mock data
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network request
      final photos = _getMockPhotos(event.entityId, event.entityType);

      emit(GalleryLoaded(photos));
    } catch (e) {
      emit(GalleryError('Failed to load photos: $e'));
    }
  }

  Future<void> _onPhotoDelete(
    GalleryPhotoDelete event,
    Emitter<GalleryState> emit,
  ) async {
    // Preserve current photos
    final currentPhotos = state.photos;

    // Optimistically update UI
    final updatedPhotos =
        currentPhotos.where((photo) => photo['id'] != event.photoId).toList();

    emit(GalleryLoading(photos: updatedPhotos));

    try {
      // In a real app, you would call your API service here
      // await galleryService.deletePhoto(event.entityId, event.entityType, event.photoId);

      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 500));

      // If successful, keep the updated list
      emit(GalleryLoaded(updatedPhotos));
    } catch (e) {
      // If failed, revert to original list
      emit(GalleryError('Failed to delete photo: $e', photos: currentPhotos));
    }
  }

  Future<void> _onPhotoAdd(
    GalleryPhotoAdd event,
    Emitter<GalleryState> emit,
  ) async {
    // Preserve current photos
    final currentPhotos = List<Map<String, dynamic>>.from(state.photos);

    // Create a new mock photo
    final newPhoto = {
      'id': 'new-photo-${DateTime.now().millisecondsSinceEpoch}',
      'url': event.photoPath,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Optimistically update UI
    final updatedPhotos = [...currentPhotos, newPhoto];
    emit(GalleryLoading(photos: updatedPhotos));

    try {
      // In a real app, you would upload the photo to your API
      // final uploadedPhoto = await galleryService.uploadPhoto(
      //   event.entityId,
      //   event.entityType,
      //   event.photoPath
      // );

      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));

      // If successful, keep the updated list (in a real app, you'd use the
      // response from the API which would have the real photo ID and URL)
      emit(GalleryLoaded(updatedPhotos));
    } catch (e) {
      // If failed, revert to original list
      emit(GalleryError('Failed to add photo: $e', photos: currentPhotos));
    }
  }

  // Helper method to generate mock data
  List<Map<String, dynamic>> _getMockPhotos(
      String entityId, String entityType) {
    // This is just for demonstration; in a real app you would get data from your API
    return List.generate(
      5,
      (index) => {
        'id': 'photo-$index',
        'url': 'https://picsum.photos/500/300?random=$index',
        'createdAt':
            DateTime.now().subtract(Duration(days: index)).toIso8601String(),
      },
    );
  }
}
