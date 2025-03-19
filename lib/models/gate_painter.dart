import 'package:flutter/material.dart';
import 'models.dart';

class GatePainter extends CustomPainter {
  final GateType type;

  GatePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    switch (type) {
      case GateType.and:
        _drawAndGate(canvas, paint, size);
        break;
      case GateType.or:
        _drawOrGate(canvas, paint, size);
        break;
      case GateType.not:
        _drawNotGate(canvas, paint, size);
        break;
    }
  }

  void _drawAndGate(Canvas canvas, Paint paint, Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.5, 0);
    path.arcToPoint(Offset(size.width * 0.5, size.height),
        radius: Radius.circular(size.width * 0.5));
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawOrGate(Canvas canvas, Paint paint, Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.5, 0, size.height);
    path.lineTo(size.width * 0.7, size.height);
    path.arcToPoint(Offset(size.width * 0.7, 0),
        radius: Radius.circular(size.width * 0.5), clockwise: false);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawNotGate(Canvas canvas, Paint paint, Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.width + 5, size.height * 0.5), 3, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}