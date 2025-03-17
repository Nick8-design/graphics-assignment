// import 'package:flutter/material.dart';
//
// class Connection {
//   final Offset start;
//   final Offset end;
//   Connection({required this.start, required this.end});
// }
//
// class ConnectionWidget extends StatelessWidget {
//   final Offset start;
//   final Offset end;
//
//   ConnectionWidget({required this.start, required this.end});
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _ConnectionPainter(start, end),
//     );
//   }
// }
//
// class _ConnectionPainter extends CustomPainter {
//   final Offset start;
//   final Offset end;
//
//   _ConnectionPainter(this.start, this.end);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 2.0;
//     canvas.drawLine(start, end, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
