import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_driving_car/controller/model/network.dart';
import 'package:self_driving_car/controller/race_controller.dart';
import 'package:self_driving_car/utils.dart';

class NetworkVisualizer extends StatefulWidget {
  const NetworkVisualizer({super.key});

  @override
  State<NetworkVisualizer> createState() => _NetworkVisualizerState();
}

class _NetworkVisualizerState extends State<NetworkVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: double.infinity,
      child: Consumer<RaceController>(
        builder: (__, value, _) {
          if (value.isLoading || value.bestCar.brain == null) {
            return const Center(child: Text('Loading...'));
          }

          return CustomPaint(
            painter: VisualizerPainter(value.bestCar.brain!),
          );
        },
      ),
    );
  }
}

class VisualizerPainter extends CustomPainter {
  VisualizerPainter(this.network, {super.repaint});
  static const nodeRadius = 18.0;
  static List<String> outputLabels = ['⬆', '⬅', '➡', '⬇'];
  final NeuralNetwork network;

  static final strokeTextStyle = TextStyle(
    fontFamily: "NotoSansJP",
    fontSize: nodeRadius,
    foreground: Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white,
  );

  static const textStyle = TextStyle(
    fontFamily: "NotoSansJP",
    fontSize: nodeRadius * 1,
    color: Colors.black,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    drawNetwork(canvas, size, network);
  }

  @override
  bool shouldRepaint(VisualizerPainter oldDelegate) {
    return true;
  }

  static drawNetwork(Canvas canvas, Size size, NeuralNetwork network) {
    const margin = 50.0;
    const left = margin;
    const top = margin;
    final width = size.width - margin * 2;
    final height = size.height - margin * 2;

    final levelHeight = height / network.levels.length;

    for (var i = network.levels.length - 1; i >= 0; i--) {
      final levelTop = top +
          lerp(
            height - levelHeight,
            0,
            network.levels.length == 1 ? 0.5 : i / (network.levels.length - 1),
          );

      // canvas.setLineDash([7, 3]);
      VisualizerPainter.drawLevel(
        canvas: canvas,
        level: network.levels[i],
        left: left,
        top: levelTop,
        width: width,
        height: levelHeight,
        showLabels: i == network.levels.length - 1,
      );
    }
  }

  static drawLevel({
    required Canvas canvas,
    required Level level,
    required double left,
    required double top,
    required double width,
    required double height,
    required bool showLabels,
  }) {
    final right = left + width;
    final bottom = top + height;

    final inputs = level.inputs;
    final outputs = level.outputs;
    final weights = level.weights;
    final biases = level.biases;

    final paint = Paint();
    for (var i = 0; i < inputs.length; i++) {
      for (var j = 0; j < outputs.length; j++) {
        Offset p1 = Offset(
          VisualizerPainter._getNodeX(inputs, i, left, right),
          bottom,
        );

        Offset p2 = Offset(
          VisualizerPainter._getNodeX(outputs, j, left, right),
          top,
        );

        paint
          ..strokeWidth = 2
          ..color = getRGBA(weights[i].data[j])
          ..style = PaintingStyle.stroke;

        canvas.drawLine(p1, p2, paint);
      }
    }

    for (var i = 0; i < inputs.length; i++) {
      final x = VisualizerPainter._getNodeX(inputs, i, left, right);
      final center = Offset(x, bottom);
      canvas.drawCircle(
        center,
        nodeRadius,
        paint
          ..color = Colors.black
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        center,
        nodeRadius * .6,
        paint..color = getRGBA(inputs[i]),
      );
    }

    drawOutputs(
      biases: biases,
      canvas: canvas,
      left: left,
      outputs: outputs,
      paint: paint,
      right: right,
      top: top,
      showLabels: showLabels,
    );
  }

  static drawOutputs({
    required Canvas canvas,
    required double top,
    required double left,
    required double right,
    required List<double> outputs,
    required List<double> biases,
    required Paint paint,
    required bool showLabels,
  }) {
    for (var i = 0; i < outputs.length; i++) {
      final x = VisualizerPainter._getNodeX(outputs, i, left, right);
      final center = Offset(x, top);
      canvas.drawCircle(
        center,
        nodeRadius,
        paint
          ..color = Colors.black
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        center,
        nodeRadius * .6,
        paint..color = getRGBA(outputs[i]),
      );

      canvas.drawCircle(
        center,
        nodeRadius * .8,
        paint
          ..color = getRGBA(biases[i])
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      if (showLabels) {
        drawLabels(
          canvas: canvas,
          label: outputLabels[i],
          top: top,
          x: x,
        );
      }
    }
  }

  static drawLabels({
    required Canvas canvas,
    required double x,
    required double top,
    required String label,
  }) {
    final txtPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      textWidthBasis: TextWidthBasis.parent,
    );

    final offset = Offset(x - nodeRadius * 0.5, top - nodeRadius * 0.8);

    //Stroke
    txtPainter.text = TextSpan(text: label, style: strokeTextStyle);
    txtPainter.layout(maxWidth: 20);
    txtPainter.paint(canvas, offset);

    //Fill
    txtPainter.text = TextSpan(text: label, style: textStyle);
    txtPainter.layout(maxWidth: 20);
    txtPainter.paint(canvas, offset);
  }

  static _getNodeX(nodes, index, left, right) {
    return lerp(
        left, right, nodes.length == 1 ? 0.5 : index / (nodes.length - 1));
  }
}
