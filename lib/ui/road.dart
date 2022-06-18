import 'dart:math';

import 'package:flutter/material.dart';

const _infinity = 1000000.0;

class Road {
  final double top = -_infinity;

  final double bottom = _infinity;

  final double x;
  final double width;
  final int laneCount;

  late final double left;
  late final double right;

  late final List<List<Offset>> borders;

  Road({required this.x, required this.width, this.laneCount = 3}) {
    left = x - width / 2;
    right = x + width / 2;

    final topLeft = Offset(left, top);
    final bottomLeft = Offset(left, bottom);

    final topRight = Offset(right, top);

    final bottomRight = Offset(right, bottom);

    borders = [
      [topLeft, bottomLeft],
      [topRight, bottomRight],
    ];
  }

  double getLaneCenter(int laneIndex) {
    final laneWidth = width / laneCount;

    return left + laneWidth / 2 + min(laneIndex, laneCount - 1) * laneWidth;
  }
}
