import 'dart:ui';

lerp(num a, num b, num t) {
  return a + (b - a) * t;
}

Intersection? getIntersection(Offset a, Offset b, Offset c, Offset d) {
  final tTop = (d.dx - c.dx) * (a.dy - c.dy) - (d.dy - c.dy) * (a.dx - c.dx);
  final uTop = (c.dy - a.dy) * (a.dx - b.dx) - (c.dx - a.dx) * (a.dy - b.dy);
  final bottom = (d.dy - c.dy) * (b.dx - a.dx) - (d.dx - c.dx) * (b.dy - a.dy);

  if (bottom != 0) {
    final t = tTop / bottom;
    final u = uTop / bottom;
    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      return Intersection(
        x: lerp(a.dx, b.dx, t),
        y: lerp(a.dy, b.dy, t),
        offset: t,
      );
    }
  }

  return null;
}

bool polysIntersect(poly1, poly2) {
  for (var i = 0; i < poly1.length; i++) {
    for (var j = 0; j < poly2.length; j++) {
      final touch = getIntersection(
        poly1[i],
        poly1[(i + 1) % poly1.length],
        poly2[j],
        poly2[(j + 1) % poly2.length],
      );

      if (touch != null) {
        return true;
      }
    }
  }

  return false;
}

Color getRGBA(double value) {
  final alpha = (value.abs() * 255).toInt();
  final R = value < 0 ? 0 : 255;
  final G = R;
  final B = value > 0 ? 0 : 255;
  return Color.fromARGB(alpha, R, G, B);
}

class Intersection {
  final double x;
  final double y;
  final double offset;

  const Intersection({required this.x, required this.y, required this.offset});
}
