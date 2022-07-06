import 'dart:math';
import 'dart:ui';

import 'package:self_driving_car/controller/model/car.dart';
import 'package:self_driving_car/utils.dart';

class Sensor {
  final Car car;
  final int rayCount = 13;
  final int rayLength = 150;
  final double raySpread = pi;
  List<List<Offset>> rays = [];
  List<Intersection?> readings = [];

  Sensor(this.car);

  update(List<List<Offset>> roadBorders, List<Car> traffic) {
    _castRays();
    readings = [];

    for (var i = 0; i < rays.length; i++) {
      readings.add(
        _getReading(
          rays[i],
          roadBorders,
          traffic,
        ),
      );
    }
  }

  Intersection? _getReading(
      List<Offset> ray, List<List<Offset>> roadBorders, List<Car> traffic) {
    var touches = <Intersection>[];

    for (var i = 0; i < roadBorders.length; i++) {
      final touch = getIntersection(
        ray[0],
        ray[1],
        roadBorders[i][0],
        roadBorders[i][1],
      );

      if (touch != null) {
        touches.add(touch);
      }
    }

    for (var i = 0; i < traffic.length; i++) {
      final poly = traffic[i].polygon;

      for (var j = 0; j < poly.length; j++) {
        final value = getIntersection(
          ray[0],
          ray[1],
          poly[j],
          poly[(j + 1) % poly.length],
        );

        if (value != null) {
          touches.add(value);
        }
      }
    }

    if (touches.isEmpty) {
      return null;
    } else {
      final offsets = touches.map((e) => e.offset);

      final minOffset = offsets.reduce(min);

      return touches.firstWhere((e) => e.offset == minOffset);
    }
  }

  void _castRays() {
    rays = [];

    for (var i = 0; i < rayCount; i++) {
      final rayAngle = lerp(raySpread / 2, -raySpread / 2,
              rayCount == 1 ? 0.5 : i / (rayCount - 1)) +
          car.angle;

      final start = Offset(car.x, car.y);
      final end = Offset(
        car.x - sin(rayAngle) * rayLength,
        car.y - cos(rayAngle) * rayLength,
      );

      rays.add([start, end]);
    }
  }
}
