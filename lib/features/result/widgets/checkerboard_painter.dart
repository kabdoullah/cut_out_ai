import 'package:flutter/material.dart';

/// Paints a checkerboard pattern to represent transparency.
class CheckerboardPainter extends CustomPainter {
  const CheckerboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 6.0;
    final light = Paint()..color = Colors.grey.shade200;
    final dark = Paint()..color = Colors.grey.shade400;

    var row = 0;
    for (var y = 0.0; y < size.height; y += cellSize) {
      var col = 0;
      for (var x = 0.0; x < size.width; x += cellSize) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          (row + col).isEven ? light : dark,
        );
        col++;
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
