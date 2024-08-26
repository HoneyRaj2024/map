import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMarker extends Marker {
  LocationMarker({
    required String markerId,
    required super.position,
    required String infoTitle,
    required String infoSnippet,
  }) : super(
          markerId: MarkerId(markerId),
          infoWindow: InfoWindow(title: infoTitle, snippet: infoSnippet),
        );
}
