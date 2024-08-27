import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map/services/location_service.dart';
import 'package:map/widgets/distance_info.dart';
import 'package:map/widgets/map_view.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _destinationController = TextEditingController();
  LatLng? _lastPosition;
  LatLng? _destinationPosition;
  String _distance = '';
  String _duration = '';

  @override
  void initState() {
    super.initState();
  }

  // Updates the current location
  void _updateLocation(Position position) {
    setState(() {
      _lastPosition = LatLng(position.latitude, position.longitude);
    });
  }

  // Sets the destination on the map
  void _setDestination(LatLng destination) {
    setState(() {
      _destinationPosition = destination;
    });
  }

  // Updates the distance and estimated time display
  void _updateDistanceAndTime(String distance, String duration) {
    setState(() {
      _distance = distance;
      _duration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text(
          'Real-Time Location Tracker',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MapView(
            lastPosition: _lastPosition,
            destinationPosition: _destinationPosition,
            onLocationUpdated: _updateLocation,
            onDestinationSet: _setDestination,
            onDistanceAndTimeUpdated: _updateDistanceAndTime,
          ),
          if (_distance.isNotEmpty && _duration.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              child: DistanceInfo(distance: _distance, duration: _duration),
            ),
        ],
      ),
    );
  }
}
