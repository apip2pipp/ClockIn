import 'dart:convert';
import 'dart:io';
import 'package:eak_flutter/providers/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  File? _image;
  String _description = '';
  bool _loading = false;

  double? latitude;
  double? longitude;
  bool _locationLoading = false;

  bool _mapReady = false;

  final picker = ImagePicker();

  final MapController _mapController = MapController();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() => _locationLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('GPS is not enabled')));
      setState(() => _locationLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      setState(() => _locationLoading = false);
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = pos.latitude;
      longitude = pos.longitude;
      _locationLoading = false;
    });

    if (latitude != null && longitude != null) {
      _mapController.move(LatLng(latitude!, longitude!), 16);
    }
  }

  Future<void> submitClockIn() async {
    if (_image == null || _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add description and photo first')),
      );
      return;
    }

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get location first')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);

      final success = await provider.clockIn(
        latitude: latitude!,
        longitude: longitude!,
        photo: _image!,
        notes: _description,
      );

      if (success) {
        Navigator.pushReplacementNamed(context, '/clock-out');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Clock in failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clock In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_image != null)
                Image.file(_image!, height: 200)
              else
                const Text('No photo yet'),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Take Photo'),
              ),

              const SizedBox(height: 12),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Activity Description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _description = v,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _locationLoading ? null : getCurrentLocation,
                child: _locationLoading
                    ? const CircularProgressIndicator()
                    : const Text('Get Location'),
              ),

              const SizedBox(height: 12),

              if (latitude != null && longitude != null) ...[
                Text('Latitude: $latitude'),
                Text('Longitude: $longitude'),
                const SizedBox(height: 12),

                SizedBox(
                  height: 250,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(latitude!, longitude!),
                      initialZoom: 16,
                      onMapReady: () {
                        setState(() => _mapReady = true);

                        _mapController.move(LatLng(latitude!, longitude!), 16);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude!, longitude!),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],

              ElevatedButton(
                onPressed: _loading ? null : submitClockIn,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Clock In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
