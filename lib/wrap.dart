import 'clip.dart';
import 'classes.dart';
import 'feature.dart';

List<Feature> wrap(List<Feature> features, GeoJSONVTOptions options) {
  final double buffer = options.buffer / options.extent;
  var merged = features;
  final left = clip(
      features, 1, -1 - buffer, buffer, 0, -1, 2, options); // left world copy
  final right = clip(features, 1, 1 - buffer, 2 + buffer, 0, -1, 2,
      options); // right world copy

  if (left.isNotEmpty || right.isNotEmpty) {
    merged = clip(features, 1, -buffer, 1 + buffer, 0, -1, 2,
        options); // center world copy

    if (left.isNotEmpty) {
      // merge left into center
      merged = shiftFeatureCoords(left, 1) + merged;
    }
    if (right.isNotEmpty) {
      // merge right into center
      merged = merged + shiftFeatureCoords(right, -1);
    }
  }

  return merged;
}

List<Feature> shiftFeatureCoords(List<Feature> features, double offset) {
  final newFeatures = <Feature>[];

  for (var feature in features) {
    final type = feature.type;

    var newGeometry = [];

    if (type == FeatureType.Point ||
        type == FeatureType.MultiPoint ||
        type == FeatureType.LineString) {
      newGeometry = shiftCoords(feature.geometry as List<double>, offset);
    } else if (type == FeatureType.MultiLineString ||
        type == FeatureType.Polygon) {
      newGeometry = [];
      for (var line in feature.geometry) {
        newGeometry.add(shiftCoords(line, offset));
      }
    } else if (type == FeatureType.MultiPolygon) {
      newGeometry = [];
      for (var polygon in feature.geometry) {
        final newPolygon = [];
        for (var line in polygon) {
          newPolygon.add(shiftCoords(line, offset));
        }
        newGeometry.add(newPolygon);
      }
    }
    newFeatures.add(createFeature(feature.id, type, newGeometry, feature.tags));
  }

  return newFeatures;
}

List<double> shiftCoords(List<double> points, double offset) {
  List<double> newPoints = [];
  newPoints.size = points.size;

  newPoints.start = points.start;
  newPoints.end = points.end;

  for (int i = 0; i < points.length; i += 3) {
    newPoints.addAll([points[i] + offset, points[i + 1], points[i + 2]]);
  }
  return newPoints;
}
