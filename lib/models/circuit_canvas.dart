import 'package:flutter/material.dart';
import 'models.dart';

class CircuitCanvas extends StatefulWidget {
  final List<Gate> gates;
  final List<Connection> connections;
  final Function(Offset, Offset) onConnectionAdded;
  final Function(Connection) onConnectionRemoved;

  CircuitCanvas({
    required this.gates,
    required this.connections,
    required this.onConnectionAdded,
    required this.onConnectionRemoved,
  });

  @override
  State<CircuitCanvas> createState() => _CircuitCanvasState();
}

class _CircuitCanvasState extends State<CircuitCanvas> {
  Offset? selectedOutput;
  String nextLabel = 'A';
  Map<Offset, String> labels = {};
  Gate? draggingGate;
  Offset? dragStart;

  void handleTap(Offset tapPosition) {
    // Select gate output
    for (Gate gate in widget.gates) {
      if ((tapPosition - gate.outputPosition).distance < 15) {
        setState(() {
          selectedOutput = gate.outputPosition;
        });
        return;
      }

      // Select input and create a connection
      for (Offset inputPos in gate.inputPositions) {
        if ((tapPosition - inputPos).distance < 15 && selectedOutput != null) {


          widget.onConnectionAdded(selectedOutput!, inputPos);


          labels[selectedOutput!] = getNextLabel();


          labels[inputPos] = labels[selectedOutput!]!;
          setState(() {
            selectedOutput = null;
          });
          return;
        }
      }
    }

    // Check if a connection is clicked for deletion
    for (Connection connection in widget.connections) {
      if (isNearLine(connection.start, connection.end, tapPosition)) {



        widget.onConnectionRemoved(connection);



        setState(() {});
        return;
      }
    }
  }

  bool isNearLine(Offset start, Offset end, Offset point) {
    double distance = (end - start).distance;
    double d1 = (point - start).distance;
    double d2 = (point - end).distance;
    return (d1 + d2 - distance).abs() < 5;
  }

  String getNextLabel() {
    String label = nextLabel;
    nextLabel = String.fromCharCode(nextLabel.codeUnitAt(0) + 1);
    return label;
  }

  // Handle gate dragging
  void startDragging(Offset position) {
    for (Gate gate in widget.gates) {
      if ((position - gate.position).distance < 30) {
        draggingGate = gate;
        dragStart = position - gate.position;
        return;
      }
    }
  }

  void updateDragging(Offset position) {
    if (draggingGate != null) {
      setState(() {
        draggingGate!.position = position - dragStart!;
        draggingGate!.updatePositions(); // Update input/output positions
      });
    }
  }

  void stopDragging() {
    draggingGate = null;
    dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (pos) => handleTap(pos.localPosition),
      onPanStart: (pos) => startDragging(pos.localPosition),
      onPanUpdate: (pos) => updateDragging(pos.localPosition),
      onPanEnd: (_) => stopDragging(),
      child: CustomPaint(
        painter: CircuitPainter(
            widget.gates,
            widget.connections,
            selectedOutput,
            labels
        ),
        child: Container(),
      ),
    );
  }
}

class CircuitPainter extends CustomPainter {
  final List<Gate> gates;
  final List<Connection> connections;
  final Offset? selectedOutput;
  final Map<Offset, String> labels;

  CircuitPainter(this.gates, this.connections, this.selectedOutput, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    final paintGate = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;


    final paintConnection = Paint()
      ..color = Colors.black54
      ..strokeWidth = 3;


    final textPainter = TextPainter(
        textDirection: TextDirection.ltr
    );

    // Draw gates
    for (Gate gate in gates) {
      _drawGate(canvas, gate, paintGate);

      // Draw input circles and labels
      for (Offset input in gate.inputPositions) {
        canvas.drawCircle(input, 3, paintGate);
        _drawLabel(canvas, textPainter, input, labels[input] ?? '');
      }

      // Draw output circle and label
      canvas.drawCircle(gate.outputPosition, 3, paintGate);
      _drawLabel(canvas, textPainter, gate.outputPosition, labels[gate.outputPosition] ?? '');
    }

    // Draw connections
    for (Connection connection in connections) {
      canvas.drawLine(connection.start, connection.end, paintConnection);
    }

    // Highlight selected output
    if (selectedOutput != null) {
      canvas.drawCircle(
          selectedOutput!,
          3, Paint()..color = Colors.green
      );
    }
  }

  void _drawGate(Canvas canvas, Gate gate, Paint paint) {
    Path path = Path();
    Offset pos = gate.position;

    switch (gate.type) {
      case GateType.and:
        path.moveTo(pos.dx, pos.dy);
        path.lineTo(pos.dx + 25, pos.dy);
        path.arcToPoint(Offset(pos.dx + 25, pos.dy + 40),
            radius: Radius.circular(25));
        path.lineTo(pos.dx, pos.dy + 40);
        path.close();
        break;

      case GateType.or:
        path.moveTo(pos.dx, pos.dy);
        path.quadraticBezierTo(pos.dx + 20, pos.dy + 20, pos.dx, pos.dy + 40);
        path.lineTo(pos.dx + 30, pos.dy + 40);
        path.arcToPoint(Offset(pos.dx + 30, pos.dy),
            radius: Radius.circular(20), clockwise: false);
        path.close();
        break;

      case GateType.not:
        path.moveTo(pos.dx, pos.dy);
        path.lineTo(pos.dx + 30, pos.dy + 20);
        path.lineTo(pos.dx, pos.dy + 40);
        path.close();
        canvas.drawCircle(Offset(pos.dx + 35, pos.dy + 20), 5, paint);
        break;
    }

    canvas.drawPath(path, paint);
  }

  void _drawLabel(Canvas canvas, TextPainter textPainter, Offset position, String text) {
    if (text.isNotEmpty) {
      final textSpan = TextSpan(text: text, style: TextStyle(color: Colors.black, fontSize: 14));
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, position + Offset(5, -10));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}