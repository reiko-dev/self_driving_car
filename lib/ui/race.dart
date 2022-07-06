import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:self_driving_car/controller/model/car.dart';
import 'package:self_driving_car/controller/model/sensor.dart';
import 'package:self_driving_car/controller/race_controller.dart';
import 'package:self_driving_car/ui/road.dart';
import 'package:self_driving_car/utils.dart';

class Race extends StatefulWidget {
  const Race({super.key});

  @override
  State<Race> createState() => _RaceState();
}

class _RaceState extends State<Race> with SingleTickerProviderStateMixin {
  static const bgColor = Color(0xFF808080);

  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      init();
    });
  }

  void init() async {
    final orchestrator = Provider.of<RaceController>(context, listen: false);
    final box = context.findRenderObject() as RenderBox;
    final road = Road(width: 300, x: box.paintBounds.center.dx);
    await orchestrator.init(road);

    controller.addListener(() {
      orchestrator.animate();
    });

    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: bgColor,
          ),
          child: Consumer<RaceController>(
            builder: (context, orchestrator, _) {
              if (orchestrator.isLoading) {
                return const SizedBox.shrink();
              }

              return CustomPaint(
                painter: RacePainter(
                  repaint: controller,
                  orchestrator: orchestrator,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class RacePainter extends CustomPainter {
  static const bestCarColor = Color(0xFF0000FF);
  static final defaultCarColor = bestCarColor.withOpacity(.2);
  static const trafficCarColor = Color(0xFFFF0000);
  static const raysColor = Color(0xFFFFFF00);
  static const asphaltColor = Color(0xFFd3d3d3);

  RacePainter({
    required Animation repaint,
    required this.orchestrator,
  }) : super(repaint: repaint);

  final RaceController orchestrator;
  late Car bestCar;
  late Road road;
  late List<Car> trafficCars;
  late List<Car> cars;
  late double cameraPosition;

  void load(Size size) {
    bestCar = orchestrator.bestCar;
    road = orchestrator.road;
    trafficCars = orchestrator.traffic;
    cars = orchestrator.cars;
    cameraPosition = -bestCar.y + size.height * 0.75;
  }

  @override
  void paint(Canvas canvas, Size size) {
    load(size);

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.translate(0, cameraPosition);

    drawRoad(canvas, road, size, cameraPosition);

    for (var i = 0; i < trafficCars.length; i++) {
      drawCar(trafficCars[i], canvas, color: trafficCarColor);
    }

    for (var i = 0; i < cars.length; i++) {
      drawCar(cars[i], canvas, color: defaultCarColor);
    }

    drawCar(bestCar, canvas, color: bestCarColor);
    drawSensor(canvas, bestCar.sensor!);

    canvas.restore();
  }

  void drawRoad(Canvas canvas, Road road, Size size, double cameraPosition) {
    final paint = Paint()..color = asphaltColor;
    canvas.drawRect(
        Rect.fromLTWH(0, -cameraPosition, size.width, size.height), paint);
    paint
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    for (var i = 1; i <= road.laneCount - 1; i++) {
      final x = lerp(road.left, road.right, i / road.laneCount);

      // ctx.setLineDash([20, 20]);
      canvas.drawLine(Offset(x, road.top), Offset(x, road.bottom), paint);
    }

    // canvas.setLineDash([]);

    for (var border in road.borders) {
      {
        canvas.drawLine(
          Offset(border[0].dx, border[0].dy),
          Offset(border[1].dx, border[1].dy),
          paint,
        );
      }
    }
  }

  void drawCar(Car car, Canvas canvas, {required Color color}) {
    final paint = Paint();

    if (car.isDamaged) {
      paint.color = Colors.grey;
    } else {
      paint.color = color;
    }
    final path = Path()
      ..moveTo(car.polygon.first.dx, car.polygon.first.dy)
      ..lineTo(car.polygon[1].dx, car.polygon[1].dy)
      ..lineTo(car.polygon[2].dx, car.polygon[2].dy)
      ..lineTo(car.polygon[3].dx, car.polygon[3].dy);

    canvas.drawPath(path, paint);
  }

  void drawSensor(Canvas canvas, Sensor sensor) {
    Intersection? reading;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < sensor.rayCount; i++) {
      var end = sensor.rays[i][1];

      reading = sensor.readings[i];
      if (reading != null) {
        end = Offset(reading.x, reading.y);
      }

      paint.color = raysColor;
      canvas.drawLine(
        Offset(sensor.rays[i][0].dx, sensor.rays[i][0].dy),
        Offset(end.dx, end.dy),
        paint,
      );

      paint.color = Colors.black;

      canvas.drawLine(
        Offset(sensor.rays[i][1].dx, sensor.rays[i][1].dy),
        Offset(end.dx, end.dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RacePainter oldDelegate) => true;
}
