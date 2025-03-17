import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'models/circuit_canvas.dart';
import 'models/models.dart';
import 'models/gate_painter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CircuitDesignerScreen(),
    );
  }
}

class CircuitDesignerScreen extends StatefulWidget {
  const CircuitDesignerScreen({super.key});

  @override
  State<CircuitDesignerScreen>  createState() => _CircuitDesignerScreenState();
}

class _CircuitDesignerScreenState extends State<CircuitDesignerScreen> {
  List<Gate> gates = [];
  List<Connection> connections = [];
  int labelCounter = 0;

  void addGate(GateType type, Offset position) {
    setState(() {
      gates.add(Gate(type: type, position: position));
    });
  }

  void updateGateInput(Gate gate, int index, int value) {
    setState(() {
      gate.inputValues[index] = value;
      gate.computeOutput();
      propagateSignal();
    });
  }

  void propagateSignal() {
    for (var gate in gates) {
      for (var connection in connections) {
        if (connection.start == gate.outputPosition) {
          var targetGate = gates.firstWhere(
                (g) => g.inputPositions.contains(connection.end),
            orElse: () => Gate(type: GateType.and, position: Offset.zero),
          );

          int inputIndex = targetGate.inputPositions.indexOf(connection.end);
          if (inputIndex != -1) {
            targetGate.inputValues[inputIndex] = gate.outputValue;
            targetGate.computeOutput();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("CircuitIt"),
        backgroundColor: Colors.blue[400],
        actions: [
          IconButton(
              onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Buy a cup of coffee for the developers or update to premium"),
                    duration: Duration(seconds: 4),
                    backgroundColor: Colors.lightBlue,
                    elevation: 8,

                    dismissDirection: DismissDirection.endToStart,
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  )
                );

              },
              icon: Icon(Icons.connect_without_contact_outlined)
          ),
        ],


      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 180,
                  color: Colors.black87,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                          "Gates",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: CupertinoColors.white,
                          )
                      ),
Divider(),
                      SizedBox(height: 8,),
                      Draggable<GateType>(
                        data: GateType.and,
                        feedback: GateWidget(GateType.and),
                        child: GateWidget(GateType.and),
                      ),
                      SizedBox(height: 8,),
                      Divider(),
                      SizedBox(height: 8,),
                      Draggable<GateType>(
                        data: GateType.or,
                        feedback: GateWidget(GateType.or),
                        child: GateWidget(GateType.or),
                      ),
                      SizedBox(height: 8,),
                      Divider(),
                      SizedBox(height: 8,),

                      Draggable<GateType>(
                        data: GateType.not,
                        feedback: GateWidget(GateType.not),
                        child: GateWidget(GateType.not),
                      ),

                      SizedBox(height: 8,),
                      Divider(),
                      SizedBox(height: 8,),
                    ],
                  ),
                ),
                Expanded(
                  child: DragTarget<GateType>(
                    onAcceptWithDetails: (details) {
                      addGate(details.data, details.offset);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Stack(
                        children: [
                          CircuitCanvas(
                            gates: gates,
                            connections: connections,
                            onConnectionAdded: (start, end) {
                              setState(() {
                                connections.add(Connection(start: start, end: end));
                                propagateSignal();
                              });
                            },
                            onConnectionRemoved: (connection) {
                              setState(() {
                                connections.remove(connection);
                              });
                            },
                          ),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: Column(
                              children: gates.map((gate) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${gate.type}"),
                                    for (int i = 0; i < gate.inputValues.length; i++)
                                      DropdownButton<int>(
                                        value: gate.inputValues[i],
                                        items: [
                                          DropdownMenuItem(value: 0, child: Text("0")),
                                          DropdownMenuItem(value: 1, child: Text("1")),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) updateGateInput(gate, i, value);
                                        },
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Circuit Output: ${gates.isNotEmpty ? gates.last.outputValue : "N/A"}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GateWidget extends StatelessWidget {
  final GateType type;
  GateWidget(this.type);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GatePainter(type),
      child: Container(width: 50, height: 40),
    );
  }
}

