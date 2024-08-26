import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:map/services/location_service.dart';

class MapView extends StatefulWidget {
  final LatLng? lastPosition;
  final LatLng? destinationPosition;
  final Function(Position) onLocationUpdated;
  final Function(LatLng) onDestinationSet;
  final Function(String, String) onDistanceAndTimeUpdated;

  const MapView({
    super.key,
    this.lastPosition,
    this.destinationPosition,
    required this.onLocationUpdated,
    required this.onDestinationSet,
    required this.onDistanceAndTimeUpdated,
  });

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];
  late Timer _locationUpdateTimer;
  MapType _currentMapType = MapType.normal; // Default map type

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  /// Initializes location tracking by fetching the current location and setting up a timer.
  void _initializeLocationTracking() async {
    Position position = await _locationService.getCurrentLocation();
    widget.onLocationUpdated(position);
    _addMarker(position, 'currentLocation');

    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      Position newPosition = await _locationService.getCurrentLocation();
      widget.onLocationUpdated(newPosition);
      _updateCurrentLocationMarker(newPosition);
    });
  }

  /// Adds a marker at the given position on the map.
  void _addMarker(Position position, String markerId,
      {String? infoTitle, String? infoSnippet}) {
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(
        title: infoTitle ?? 'My current location',
        snippet: infoSnippet ?? '${position.latitude}, ${position.longitude}',
      ),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  /// Updates the current location marker on the map.
  void _updateCurrentLocationMarker(Position position) {
    final updatedMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(
        title: 'My current location',
        snippet: '${position.latitude}, ${position.longitude}',
      ),
    );

    setState(() {
      _markers
          .removeWhere((marker) => marker.markerId.value == 'currentLocation');
      _markers.add(updatedMarker);
    });
  }

  /// Sets the destination and adds a marker for it.
  void _setDestination(LatLng destination) {
    widget.onDestinationSet(destination);
    _addDestinationMarker(destination);
    _drawPolyline();
    _calculateDistanceAndTime();
  }

  /// Adds a marker for the destination.
  void _addDestinationMarker(LatLng position) {
    final destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: position,
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: '${position.latitude}, ${position.longitude}',
      ),
    );

    setState(() {
      _markers.add(destinationMarker);
    });
  }

  /// Draws the polyline between the current location and the destination.
  void _drawPolyline() {
    if (widget.lastPosition != null && widget.destinationPosition != null) {
      PolylinePoints polylinePoints = PolylinePoints();
      polylinePoints
          .getRouteBetweenCoordinates(
        'AIzaSyDkL97pRmF-wXpbd7qjTvvBE2XagjwsR4Y', // Your Google Maps API Key
        PointLatLng(
            widget.lastPosition!.latitude, widget.lastPosition!.longitude),
        PointLatLng(widget.destinationPosition!.latitude,
            widget.destinationPosition!.longitude),
      )
          .then((result) {
        if (result.points.isNotEmpty) {
          _polylineCoordinates.clear();
          result.points.forEach((PointLatLng point) {
            _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
          setState(() {
            _polylines.clear();
            _polylines.add(Polyline(
              polylineId: const PolylineId('routePolyline'),
              points: _polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ));
          });
        } else {
          print('Error: No points to draw the polyline');
        }
      }).catchError((error) {
        print('Error fetching polyline: $error');
      });
    }
  }

  /// Calculates the distance and estimated travel time between the current location and the destination.
  void _calculateDistanceAndTime() {
    if (widget.lastPosition != null && widget.destinationPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        widget.lastPosition!.latitude,
        widget.lastPosition!.longitude,
        widget.destinationPosition!.latitude,
        widget.destinationPosition!.longitude,
      );

      double distanceInKm = distanceInMeters / 1000;
      double estimatedTimeInMinutes = (distanceInKm / 50) * 60;

      widget.onDistanceAndTimeUpdated(
        distanceInKm.toStringAsFixed(2) + ' km',
        estimatedTimeInMinutes.toStringAsFixed(0) + ' mins',
      );
    }
  }

  /// Toggles the map type between normal and satellite.
  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: widget.lastPosition ??
                const LatLng(0, 0), // Default starting position
            zoom: 14,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: _currentMapType, // Set the current map type here
          onLongPress: (LatLng latLng) {
            _setDestination(latLng);
          },
        ),
        Positioned(
          bottom: 80,
          left: 10,
          child: FloatingActionButton(
            onPressed: _toggleMapType,
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.blue,
            child: const Icon(
              Icons.layers,
              size: 36.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
