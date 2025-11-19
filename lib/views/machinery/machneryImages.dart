import 'package:flutter/material.dart';


class MachineryImages {
  static const String _basePath = 'assets/machinery/machine_type/';
  static const String defaultImage = 'assets/machinery/default_machine.png';

  // Machinery mapped with image path
  static final Map<String, String> _imageMap = {
    'Tractor': '${_basePath}tractor.jpg',
    'Mini Tractor': '${_basePath}rotavator.jpg',
    'Harwest Machine': '${_basePath}harvester.jpg',
    'JCB': '${_basePath}JCB.jpeg',
  };

  // Get image path with fallback
  static String _getImagePath(String machineryName) {
    // Try exact match first
    if (_imageMap.containsKey(machineryName)) {
      return _imageMap[machineryName]!;
    }

    // Fallback to case-insensitive search
    final key = _imageMap.keys.firstWhere(
      (key) => key.toLowerCase() == machineryName.toLowerCase(),
      orElse: () => '',
    );

    return key.isNotEmpty ? _imageMap[key]! : defaultImage;
  }

  // Image Widget
  static Widget getImageWidget(
    String machineryName, {
    double size = 80,
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
            _getImagePath(machineryName),
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
        Icons.agriculture,
        size: size * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}