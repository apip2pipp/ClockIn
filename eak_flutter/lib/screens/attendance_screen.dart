import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/distance.dart';
import '../services/api_services.dart';
import '../services/face_matching.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final faceMatcher = FaceMatchingService();
  final api = ApiService();

  final double officeLat = -6.200;
  final double officeLng = 106.816;
  final double maxRadius = 50;

  Position? _pos;
  double? _distance;

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final dist = calculateDistanceMeters(
      pos.latitude,
      pos.longitude,
      officeLat,
      officeLng,
    );

    setState(() {
      _pos = pos;
      _distance = dist;
    });
  }

  Future<void> checkIn() async {
    await api.checkIn(
      lat: _pos!.latitude,
      lng: _pos!.longitude,
      distance: _distance!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pos == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final allowCheckIn = _distance! <= maxRadius;

    return Scaffold(
      appBar: AppBar(title: Text("Absensi")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Distance: ${_distance!.toStringAsFixed(2)} m"),
          SizedBox(height: 20),

          if (allowCheckIn)
            ElevatedButton(onPressed: checkIn, child: Text("CHECK IN"))
          else
            Text("Anda berada di luar area absensi"),
        ],
      ),
    );
  }
}
