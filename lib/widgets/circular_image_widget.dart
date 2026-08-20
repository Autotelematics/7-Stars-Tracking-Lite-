import 'package:flutter/material.dart';

class CircularImageWidget extends StatelessWidget {
  final String imagePath;
  final double imageSize;
  final double containerSize;
  final Color containerColor;
  final Color borderColor;
  final double borderWidth;

  const CircularImageWidget({
    super.key,
    required this.imagePath,
    this.imageSize = 40,
    this.containerSize = 40, // Adjust the default size as needed
    this.containerColor = Colors.transparent,
    this.borderColor = Colors.blueGrey,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        imagePath,
        width: imageSize,
        height: imageSize,
      ),
    );
  }
}
