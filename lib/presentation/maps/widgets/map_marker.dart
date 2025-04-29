import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';

import '../../../config/theme.dart';

enum MarkerType {
  attraction,
  hotel,
  restaurant,
  transport,
  custom,
  userLocation,
}

class MapMarkerHelper {
  // Singleton pattern
  static final MapMarkerHelper _instance = MapMarkerHelper._internal();
  factory MapMarkerHelper() => _instance;
  MapMarkerHelper._internal();

  // Cache for marker icons to avoid recreating them
  final Map<MarkerType, BitmapDescriptor> _markerIcons = {};

  /// Creates a marker with the appropriate icon based on its type
  Future<Marker> createMarker({
    required String id,
    required LatLng position,
    required MarkerType type,
    String? title,
    String? snippet,
    VoidCallback? onTap,
    bool draggable = false,
    Function(LatLng)? onDragEnd,
  }) async {
    // Get or create the appropriate icon
    final icon = await _getMarkerIcon(type);
    
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: icon,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      draggable: draggable,
      onDragEnd: onDragEnd,
      onTap: onTap,
    );
  }

  /// Gets the marker icon for the specified type, creating it if necessary
  Future<BitmapDescriptor> _getMarkerIcon(MarkerType type) async {
    // Return from cache if available
    if (_markerIcons.containsKey(type)) {
      return _markerIcons[type]!;
    }
    
    // Create new icon based on marker type
    BitmapDescriptor icon;
    
    switch (type) {
      case MarkerType.attraction:
        icon = await _createMarkerIcon(
          backgroundColor: Colors.blue,
          icon: Icons.attractions,
        );
        break;
      case MarkerType.hotel:
        icon = await _createMarkerIcon(
          backgroundColor: Colors.purple,
          icon: Icons.hotel,
        );
        break;
      case MarkerType.restaurant:
        icon = await _createMarkerIcon(
          backgroundColor: Colors.orange,
          icon: Icons.restaurant,
        );
        break;
      case MarkerType.transport:
        icon = await _createMarkerIcon(
          backgroundColor: Colors.green,
          icon: Icons.directions_bus,
        );
        break;
      case MarkerType.custom:
        icon = await _createMarkerIcon(
          backgroundColor: Colors.red,
          icon: Icons.location_on,
        );
        break;
      case MarkerType.userLocation:
        icon = await _createMarkerIcon(
          backgroundColor: AppTheme.primaryColor,
          icon: Icons.person_pin_circle,
          size: 100,
        );
        break;
    }
    
    // Cache the icon
    _markerIcons[type] = icon;
    
    return icon;
  }
  
  /// Creates a custom marker icon with the specified color and icon
  Future<BitmapDescriptor> _createMarkerIcon({
    required Color backgroundColor,
    required IconData icon,
    double size = 80,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = backgroundColor;
    
    // Draw circle
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, borderPaint);
    
    // Draw icon
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.5,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size / 2 - textPainter.width / 2,
        size / 2 - textPainter.height / 2,
      ),
    );
    
    // Convert to image
    final image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
  
  /// A simpler alternative that uses pre-defined assets
  Future<BitmapDescriptor> getMarkerIconFromAsset(String assetPath) async {
    return BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      assetPath,
    );
  }
  
  /// Creates a custom marker icon from an asset image with a colored circle background
  Future<BitmapDescriptor> createCustomMarkerFromAsset(
    String assetPath,
    Color backgroundColor,
    double size,
  ) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: (size * 0.6).toInt(),
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    
    // Draw background circle
    final paint = Paint()..color = backgroundColor;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    
    // Draw image on top of circle
    canvas.drawImage(
      fi.image,
      Offset(
        size / 2 - fi.image.width / 2,
        size / 2 - fi.image.height / 2,
      ),
      Paint(),
    );
    
    // Convert to image
    final image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}

class CustomMarkerWidget extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final double size;
  
  const CustomMarkerWidget({
    super.key,
    required this.backgroundColor,
    required this.icon,
    this.iconColor = Colors.white,
    this.size = 40,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: size * 0.6,
      ),
    );
  }
}

class AnimatedMarkerWidget extends StatefulWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final double size;
  
  const AnimatedMarkerWidget({
    super.key,
    required this.backgroundColor,
    required this.icon,
    this.iconColor = Colors.white,
    this.size = 40,
  });
  
  @override
  State<AnimatedMarkerWidget> createState() => _AnimatedMarkerWidgetState();
}

class _AnimatedMarkerWidgetState extends State<AnimatedMarkerWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing background
            Container(
              width: widget.size * _pulseAnimation.value,
              height: widget.size * _pulseAnimation.value,
              decoration: BoxDecoration(
                color: widget.backgroundColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            // Main marker
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.size * 0.6,
              ),
            ),
          ],
        );
      },
    );
  }
}