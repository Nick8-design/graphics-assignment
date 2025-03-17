import 'package:flutter/material.dart';

enum GateType { and, or, not }

class Gate {
  final GateType type;
  Offset position;
  List<Offset> inputPositions = [];
  Offset outputPosition = Offset.zero;
  List<int> inputValues;
  int outputValue = 0;

  Gate({required this.type, required this.position, List<int>? inputs})
      : inputValues = inputs ?? (type == GateType.not ? [0] : [0, 0]) {
    updatePositions();
  }

  void updatePositions() {
    outputPosition = Offset(position.dx + 50, position.dy + 20);

    if (type == GateType.and || type == GateType.or) {
      inputPositions = [
        Offset(position.dx, position.dy + 10),
        Offset(position.dx, position.dy + 30),
      ];
    } else {
      inputPositions = [Offset(position.dx, position.dy + 20)];
    }
  }

  void computeOutput() {
    if (type == GateType.and) {
      outputValue = inputValues.reduce((a, b) => a & b);
    } else if (type == GateType.or) {
      outputValue = inputValues.reduce((a, b) => a | b);
    } else if (type == GateType.not) {
      outputValue = inputValues[0] == 0 ? 1 : 0;
    }
  }
}

class Connection {
  Offset start;
  Offset end;

  Connection({required this.start, required this.end});
}
