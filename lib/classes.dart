extension JSList<T> on List<T> {
  static final _startValues = Expando<double>();
  static final _sizeValues = Expando<double>();
  static final _endValues = Expando<double>();

  double get start => _startValues[this] ?? 0;
  set start(double value) => _startValues[this] = value;

  double get size => _sizeValues[this] ?? 0;
  set size(double value) => _sizeValues[this] = value;

  double get end => _endValues[this] ?? 0;
  set end(double value) => _endValues[this] = value;
}

enum FeatureType {
  Point,
  MultiPoint,
  LineString,
  MultiLineString,
  Feature,
  FeatureCollection,
  Polygon,
  MultiPolygon,
  GeometryCollection, // not really a feature type, but helps here...
  None, // Also not a feature type, but allows us to identify invalid feature types
}

class TileFeature {
  List<dynamic> geometry;
  int type;
  Map<String, dynamic> tags;
  String? id;

  TileFeature(
      {this.geometry = const [],
      required this.type,
      this.tags = const {},
      this.id});

  @override
  String toString() {
    return "$geometry, $type, $tags, $id";
  }
}

class Feature {
  List<dynamic> geometry;
  String? id;
  FeatureType type;
  Map<String, dynamic>? tags;
  double minX;
  double maxX;
  double minY;
  double maxY;

  static const Map typeLookup = {
    "point": FeatureType.Point,
    "multipoint": FeatureType.MultiPoint,
    "linestring": FeatureType.LineString,
    "multilinestring": FeatureType.MultiLineString,
    "polygon": FeatureType.Polygon,
    "multipolygon": FeatureType.MultiPolygon,
    "feature": FeatureType.Feature,
    "featurecollection": FeatureType.FeatureCollection,
    "geometrycollection": FeatureType
        .GeometryCollection, // bit naught, not really a feature type..
  };

  Feature(
      {this.geometry = const [],
      this.id,
      this.type = FeatureType.Feature,
      this.tags,
      this.minX = double.infinity,
      this.maxX = -double.infinity,
      this.minY = double.infinity,
      this.maxY = -double.infinity});

  static FeatureType stringToFeatureType(String type) {
    return typeLookup[type.toLowerCase()] ?? FeatureType.None;
  }

  @override
  String toString() {
    return "$geometry, $type, $tags, $id, $minX, $maxX, $minY, $maxY";
  }
}

class SimpTile {
  List<TileFeature> features = [];
  int numPoints = 0;
  int numSimplified = 0;
  int numFeatures = -1; // = features.length;
  List<Feature>? source;
  int x;
  int y;
  int z;
  bool transformed = false;
  double minX = 2;
  double minY = 1;
  double maxX = -1;
  double maxY = 0;

  SimpTile(this.features, this.z, [this.x = 0, this.y = 0]);

  @override
  String toString() {
    return "SimpTile:    numPoints: $numPoints numSimplified: $numSimplified numFeatures: $numFeatures source: $source xyz $x,$y,$z transformed: $transformed minX: $minX minY $minY maxX: $maxX maxY: $maxY features: $features";
  }
}

class GeoJSONVTOptions {
  int maxZoom; // max zoom to preserve detail on
  int indexMaxZoom; // max zoom in the tile index
  int indexMaxPoints; // max number of points per tile in the tile index
  int tolerance; // simplification tolerance (higher means simpler)
  int extent; // tile extent (pixels)
  int buffer; // tile buffer on each side
  bool lineMetrics; // whether to calculate line metrics
  String? promoteId; // name of a feature property to be promoted to feature.id
  bool
      generateId; // whether to generate feature ids. Cannot be used with promoteId
  int debug; // logging level (0, 1 or 2)

  GeoJSONVTOptions(
      {this.maxZoom = 14,
      this.indexMaxZoom = 5,
      this.indexMaxPoints = 100000,
      this.tolerance = 3,
      this.extent = 4096,
      this.buffer = 64,
      this.lineMetrics = false,
      this.promoteId,
      this.generateId = false,
      this.debug = 2});
}
