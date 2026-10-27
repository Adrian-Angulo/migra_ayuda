import 'package:latlong2/latlong.dart';

class GeocodingResult {
  final LatLng point;
  final String placeName;
  final bool isManualSelection;

  const GeocodingResult({
    required this.point,
    required this.placeName,
    this.isManualSelection = false,
  });

  GeocodingResult copyWith({
    LatLng? point,
    String? placeName,
    bool? isManualSelection,
  }) {
    return GeocodingResult(
      point: point ?? this.point,
      placeName: placeName ?? this.placeName,
      isManualSelection: isManualSelection ?? this.isManualSelection,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeocodingResult &&
          runtimeType == other.runtimeType &&
          point == other.point &&
          placeName == other.placeName &&
          isManualSelection == other.isManualSelection;

  @override
  int get hashCode =>
      point.hashCode ^ placeName.hashCode ^ isManualSelection.hashCode;

  @override
  String toString() =>
      'GeocodingResult(point: $point, placeName: $placeName, isManual: $isManualSelection)';
}
