import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerMaker {
  static Future<ui.Image> getImageFromPath(String imagePath) async {
    var bd = await rootBundle.load(imagePath);
    Uint8List imageBytes = Uint8List.view(bd.buffer);

    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }

  static Future<ui.Image> getImageFromPathUrl(String imagePath) async {
    final File markerImageFile =
        await DefaultCacheManager().getSingleFile(imagePath);
    Uint8List imageBytes = await markerImageFile.readAsBytes();

    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }

  static Future<BitmapDescriptor> getMarkerIcon(String imagePath,
      String infoText, Color color, double rotateDegree, bool showTitle) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Size
    Size canvasSize = const Size(700.0, 220.0);
    Size markerSize = const Size(120.0, 120.0);
    late TextPainter textPainter;
    if (showTitle) {
      // Add info text
      textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: infoText,
        style: TextStyle(
            fontSize: 20.0, fontWeight: FontWeight.w600, color: color),
      );
      textPainter.layout();
    }

    final Paint infoPaint = Paint()..color = Colors.white;
    final Paint infoStrokePaint = Paint()..color = color;
    const double infoHeight = 40.0;
    const double strokeWidth = 2.0;
    const double shadowWidth = 40.0;

    final Paint borderPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double imageOffset = shadowWidth * .5;

    // Center the canvas at the marker's center
    canvas.translate(canvasSize.width / 2, canvasSize.height / 2);

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        -markerSize.width / 2 + .5 * shadowWidth,
        -markerSize.height / 2 + .5 * shadowWidth,
        markerSize.width - shadowWidth,
        markerSize.height - shadowWidth);

    // Save canvas before rotate
    canvas.save();

    double rotateRadian = (pi / 180.0) * rotateDegree;

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));

    ui.Image image;
    image = await getImageFromPathUrl(imagePath);

    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitHeight);

    canvas.restore();

    if (showTitle) {
      // Position info box exactly at the top of the marker (zero space)
      double infoBoxTop = -markerSize.height / 2 - infoHeight;

      // Add info box stroke
      canvas.drawPath(
          Path()
            ..addRRect(RRect.fromLTRBR(
                -textPainter.width / 2 - infoHeight / 2,
                infoBoxTop,
                textPainter.width / 2 + infoHeight / 2,
                infoBoxTop + infoHeight,
                const Radius.circular(35.0)))
            ..moveTo(
                -10, infoBoxTop + infoHeight) // Smaller triangle to reduce gap
            ..lineTo(0, infoBoxTop + infoHeight + 10) // Reduced triangle height
            ..lineTo(10, infoBoxTop + infoHeight),
          infoStrokePaint);

      // Info box fill
      canvas.drawPath(
          Path()
            ..addRRect(RRect.fromLTRBR(
                -textPainter.width / 2 - infoHeight / 2 + strokeWidth,
                infoBoxTop + strokeWidth,
                textPainter.width / 2 + infoHeight / 2 - strokeWidth,
                infoBoxTop + infoHeight - strokeWidth,
                const Radius.circular(32.0)))
            ..moveTo(
                -10 + strokeWidth / 2, infoBoxTop + infoHeight - strokeWidth)
            ..lineTo(0, infoBoxTop + infoHeight + 10 - strokeWidth * 2)
            ..lineTo(
                10 - strokeWidth / 2, infoBoxTop + infoHeight - strokeWidth),
          infoPaint);

      // Paint text centered in the info box
      textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2,
              infoBoxTop + infoHeight / 2 - textPainter.height / 2));
    }

    // Convert canvas to image
    final ui.Image markerImage = await pictureRecorder
        .endRecording()
        .toImage(canvasSize.width.toInt(), canvasSize.height.toInt());

    // Convert image to bytes
    final ByteData? byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? uint8List = byteData?.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List!);
  }
}
