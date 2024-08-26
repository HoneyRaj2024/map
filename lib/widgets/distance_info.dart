import 'package:flutter/material.dart';

class DistanceInfo extends StatelessWidget {
  final String distance;
  final String duration;

  const DistanceInfo(
      {super.key, required this.distance, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Distance: $distance'),
          Text('Estimated Time: $duration'),
        ],
      ),
    );
  }
}
