import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClockOutScreen extends StatefulWidget {
  const ClockOutScreen({super.key});

  @override
  State<ClockOutScreen> createState() => _ClockOutScreenState();
}

class _ClockOutScreenState extends State<ClockOutScreen> {
  File? _image;
  String _description = '';
  bool _loading = false;

  double? latitude;
  double? longitude;
  bool _locationLoading = false;

  final picker = ImagePicker();
  final MapController _mapController = MapController();

  // GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // PICK IMAGE
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  // GET LOCATION
  Future<void> getCurrentLocation() async {
    setState(() => _locationLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS is not enabled')),
      );
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

  // SUBMIT CLOCK OUT
  Future<void> submitClockOut() async {
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
      final token = await getToken();

      final bytes = await _image!.readAsBytes();
      final imgBase64 = base64Encode(bytes);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.111.112:8000/api/attendance/clock-out'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['description'] = _description;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['photo'] = imgBase64;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        throw Exception(data['message'] ?? 'Clock out failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clock Out')),
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
                              color: Colors.blue,
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
                onPressed: _loading ? null : submitClockOut,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Clock Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
