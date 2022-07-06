import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:self_driving_car/controller/model/network.dart';
import 'package:self_driving_car/controller/model/sensor.dart';
import 'package:self_driving_car/ui/controls.dart';
import 'package:self_driving_car/utils.dart';

enum ControlType { ia, dummy, keys }

class Car {
  double x;
  double y;
  double width;
  double height;
  ControlType controlType;
  double maxSpeed;
  double _speed = 0;
  final double _acceleration = .2;
  final double _friction = .05;

  double angle = 0;
  bool isDamaged = false;
  late bool useBrain;
  Sensor? sensor;
  NeuralNetwork? brain;
  late Controls controls;
  late List<Offset> polygon;

  Car({
    required this.x,
    required this.y,
    this.width = 50,
    this.height = 70,
    this.controlType = ControlType.dummy,
    this.maxSpeed = 3,
  }) {
    useBrain = controlType == ControlType.ia;

    if (controlType != ControlType.dummy) {
      sensor = Sensor(this);

      brain = NeuralNetwork(
        //Specify the size of the layers.
        [sensor!.rayCount, 6, 4],
      );
    }
    controls = Controls(controlType);
  }

  void update(List<List<Offset>> roadBorders, List<Car> traffic) {
    if (!isDamaged) {
      _move();
      polygon = _createPolygon();
      isDamaged = _assessDamage(roadBorders, traffic);
    }

    if (sensor != null) {
      sensor!.update(roadBorders, traffic);

      //Gives low values if the objects the sensor see are farway or
      //high values if the objects are close.
      final List<double?> offsets = [];

      for (var s in sensor!.readings) {
        offsets.add(s == null ? 0 : 1 - s.offset);
      }

      final outputs = NeuralNetwork.feedForward(offsets, brain!);

      if (useBrain) {
        controls.forward = outputs[0] == 1;
        controls.left = outputs[1] == 1;
        controls.right = outputs[2] == 1;
        controls.reverse = outputs[3] == 1;
      }
    }
  }

  _assessDamage(List<List<Offset>> roadBorders, List<Car> traffic) {
    for (var i = 0; i < roadBorders.length; i++) {
      if (polysIntersect(polygon, roadBorders[i])) {
        return true;
      }
    }

    for (var i = 0; i < traffic.length; i++) {
      if (polysIntersect(polygon, traffic[i].polygon)) {
        return true;
      }
    }

    return false;
  }

  double hypotenuse(double x, double y) {
    return sqrt(pow(x, 2) + pow(y, 2));
  }

  List<Offset> _createPolygon() {
    final points = <Offset>[];

    //Distance from a vertex point to the center. E.g: From TopLeft to center.
    final rad = hypotenuse(width, height) / 2;

    //The angle given the width and height
    final alpha = atan2(width, height);

    //TopRight
    points.add(
      Offset(x - sin(angle - alpha) * rad, y - cos(angle - alpha) * rad),
    );

    //TopLeft
    points.add(
      Offset(x - sin(angle + alpha) * rad, y - cos(angle + alpha) * rad),
    );

    //BottomLeft
    points.add(
      Offset(
          x - sin(pi + angle - alpha) * rad, y - cos(pi + angle - alpha) * rad),
    );

    //BottomRight
    points.add(
      Offset(
          x - sin(pi + angle + alpha) * rad, y - cos(pi + angle + alpha) * rad),
    );

    return points;
  }

  void _move() {
    if (controls.forward) {
      _speed += _acceleration;
    }

    if (controls.reverse) {
      _speed -= _acceleration;
    }

    if (_speed > maxSpeed) {
      _speed = maxSpeed;
    }
    if (_speed < -maxSpeed / 2) {
      _speed = -maxSpeed / 2;
    }

    if (_speed > 0) {
      _speed -= _friction;
    }

    if (_speed < 0) {
      _speed += _friction;
    }

    if (_speed.abs() < _friction) {
      _speed = 0;
    }

    if (_speed != 0) {
      final flip = _speed > 0 ? 1 : -1;

      if (controls.left) {
        angle += 0.03 * flip;
      }
      if (controls.right) {
        angle -= 0.03 * flip;
      }
    }

    x -= sin(angle) * _speed;
    y -= cos(angle) * _speed;
  }
}
