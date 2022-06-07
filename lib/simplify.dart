void simplify(List<dynamic> coords, int first, int last, double sqTolerance) {
  final mid = (last - first) >> 1;
  var maxSqDist = sqTolerance;
  var minPosToMid = last - first;
  int index = 0;

  final ax = coords[first];
  final ay = coords[first + 1];
  final bx = coords[last];
  final by = coords[last + 1];

  for (int i = first + 3; i < last; i += 3) {
    final d = getSqSegDist(coords[i], coords[i + 1], ax, ay, bx, by);

    if (d > maxSqDist) {
      index = i;
      maxSqDist = d;
    } else if (d == maxSqDist) {
      // a workaround to ensure we choose a pivot close to the middle of the list,
      // reducing recursion depth, for certain degenerate inputs
      // https://github.com/mapbox/geojson-vt/issues/104
      final posToMid = (i - mid).abs();
      if (posToMid < minPosToMid) {
        index = i;
        minPosToMid = posToMid;
      }
    }
  }

  if (maxSqDist > sqTolerance) {
    if (index - first > 3) simplify(coords, first, index, sqTolerance);
    coords[index + 2] = maxSqDist;
    if (last - index > 3) simplify(coords, index, last, sqTolerance);
  }
}

double getSqSegDist(
    double px, double py, double x, double y, double bx, double by) {
  var dx = bx - x;
  var dy = by - y;

  if (dx != 0 || dy != 0) {
    final t = ((px - x) * dx + (py - y) * dy) / (dx * dx + dy * dy);

    if (t > 1) {
      x = bx;
      y = by;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = px - x;
  dy = py - y;

  return dx * dx + dy * dy;
}
