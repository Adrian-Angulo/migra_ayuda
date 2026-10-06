import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MarkerIconGenerator {
  static Uint8List? _cachedDefaultPin;
  static Uint8List? _cachedSelectedPin;

  static Future<Uint8List> getMarkerBytes({bool isSelected = false}) async {
    if (isSelected && _cachedSelectedPin != null) return _cachedSelectedPin!;
    if (!isSelected && _cachedDefaultPin != null) return _cachedDefaultPin!;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 120.0;
    const centerHead = Offset(60, 44);
    const tipPoint = Offset(60, 106);

    // 1. Sombra suave de contacto (Ground Drop Shadow)
    final groundShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 108), width: 36, height: 12),
      groundShadowPaint,
    );

    // 2. Trazado geométrico del Pin (Teardrop / Location Pointer)
    final path = Path();
    path.moveTo(tipPoint.dx, tipPoint.dy);
    // Lado izquierdo: Curva suave desde la punta hasta la cabeza circular
    path.cubicTo(
      60 - 4,
      98,
      60 - 28,
      68,
      60 - 28,
      44,
    );
    // Arco superior circular perfecto
    path.arcToPoint(
      const Offset(60 + 28, 44),
      radius: const Radius.circular(28),
      largeArc: true,
    );
    // Lado derecho: Curva suave de regreso a la punta
    path.cubicTo(
      60 + 28,
      58,
      60 + 4,
      98,
      tipPoint.dx,
      tipPoint.dy,
    );
    path.close();

    // 3. Gradiente vertical de alta gama
    final gradientColors = isSelected
        ? [const Color(0xFFFF5252), const Color(0xFFC62828)]
        : [const Color(0xFF00BFA5), const Color(0xFF00695C)];

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(60, 16),
        const Offset(60, 106),
        gradientColors,
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // 4. Borde blanco brillante nítido (High-contrast stroke)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);

    // 5. Ojo de buey central (Bullseye Pointer / White Disc + Inner Core)
    // Disco blanco exterior
    final outerDiscPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerHead, 12.0, outerDiscPaint);

    // Núcleo interior de color
    final innerCorePaint = Paint()
      ..color = isSelected ? const Color(0xFFD32F2F) : const Color(0xFF00796B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(centerHead, 6.0, innerCorePaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    if (isSelected) {
      _cachedSelectedPin = bytes;
    } else {
      _cachedDefaultPin = bytes;
    }

    return bytes;
  }
}
