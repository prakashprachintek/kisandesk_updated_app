import 'package:flutter/material.dart';

class WorkTypeImages {
  static const String _basePath = 'assets/machinery/work_type/';
  static const String defaultImage = 'assets/machinery/default_work_type.png';

  // Map work type names to their image paths
  static final Map<String, String> _imageMap = {
    'Ploughing': '${_basePath}ploughing.png',
  };

  // Get image path with fallback
  static String _getImagePath(String workType) {
    // Try exact match first
    if (_imageMap.containsKey(workType)) {
      return _imageMap[workType]!;
    }

    // Fallback to case-insensitive search
    final key = _imageMap.keys.firstWhere(
      (key) => key.toLowerCase() == workType.toLowerCase(),
      orElse: () => '',
    );

    return key.isNotEmpty ? _imageMap[key]! : defaultImage;
  }

  // Enhanced image widget with multiple styling options
  static Widget getImageWidget(
    String workType, {
    double size = 60,
    BoxFit fit = BoxFit.cover,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
    bool showShadow = true,
    Color borderColor = Colors.transparent,
    double borderWidth = 0,
  }) {
    try {
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ]
              : null,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Image.asset(
            _getImagePath(workType),
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => _buildFallbackIcon(size),
          ),
        ),
      );
    } catch (e) {
      return _buildFallbackIcon(size);
    }
  }

  static Widget _buildFallbackIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.construction,
        size: size * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}