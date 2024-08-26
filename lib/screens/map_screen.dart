import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map/services/location_service.dart';
import 'package:map/widgets/location_marker.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];
  late Timer _locationUpdateTimer;
  LatLng? _lastPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  /// Initializes location tracking by fetching the current location and setting up a timer.
  void _initializeLocationTracking() async {
    Position position = await _locationService.getCurrentLocation();
    _updateLocation(position);

    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      Position newPosition = await _locationService.getCurrentLocation();
      _updateLocation(newPosition);
    });
  }

  /// Animates the camera to a new position on the map.
  void _animateCameraToPosition(LatLng position) {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  /// Adds a marker at the given position on the map.
  void _addMarker(LatLng position) {
    final marker = LocationMarker(
      markerId: 'currentLocation',
      position: position,
      infoTitle: 'My current location',
      infoSnippet: '${position.latitude}, ${position.longitude}',
    );

    setState(() {
      _markers.add(marker);
    });
  }

  /// Updates the user's location on the map, adds a marker, and updates the polyline.
  void _updateLocation(Position position) {
    LatLng newPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers.clear();
      _addMarker(newPosition);
      _polylineCoordinates.add(newPosition);

      if (_polylineCoordinates.length > 1) {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('trackingPolyline'),
          points: _polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      }
    });

    _animateCameraToPosition(newPosition);
  }

  @override
  void dispose() {
    _locationUpdateTimer.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text(
          'Real-Time Location Tracker',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _lastPosition ?? const LatLng(0, 0), // Default starting position
          zoom: 14,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,

      ),
    );
  }
}
