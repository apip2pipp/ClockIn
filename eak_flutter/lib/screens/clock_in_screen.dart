import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/attendance_provider.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _capturedImage;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Request location permission
      final permission = await Permission.location.request();

      if (permission.isDenied || permission.isPermanentlyDenied) {
        if (mounted) {
          _showError('Izin lokasi diperlukan untuk melakukan absensi');
        }
        return;
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showError('Mohon aktifkan layanan lokasi');
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      debugPrint('📍 Location obtained: ${position.latitude}, ${position.longitude}');

      // Move camera to current location
      if (_mapController != null && mounted) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      if (mounted) {
        _showError('Gagal mendapatkan lokasi: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final permission = await Permission.camera.request();

      if (permission.isDenied || permission.isPermanentlyDenied) {
        if (mounted) {
          _showError('Izin kamera diperlukan untuk mengambil foto');
        }
        return;
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });
        debugPrint('📸 Photo captured: ${photo.path}');
      }
    } catch (e) {
      debugPrint('❌ Error capturing photo: $e');
      if (mounted) {
        _showError('Gagal mengambil foto: $e');
      }
    }
  }

  Future<void> _submitClockIn() async {
    if (!_formKey.currentState!.validate()) return;

    if (_capturedImage == null) {
      _showError('Silakan ambil foto terlebih dahulu');
      return;
    }

    if (_currentPosition == null) {
      _showError('Lokasi belum ditemukan. Silakan refresh lokasi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      debugPrint('🔄 Submitting clock in...');
      debugPrint('   Latitude: ${_currentPosition!.latitude}');
      debugPrint('   Longitude: ${_currentPosition!.longitude}');
      debugPrint('   Photo: ${_capturedImage!.path}');
      debugPrint('   Notes: ${_notesController.text}');

      final success = await attendanceProvider.clockIn(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        photo: _capturedImage!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        if (success) {
          debugPrint('✅ Clock in successful, popping screen...');

          // Pop screen with success result
          Navigator.pop(context, true);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clock in berhasil!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          final errorMsg = attendanceProvider.errorMessage ?? 'Gagal melakukan clock in';
          _showError(errorMsg);
        }
      }
    } catch (e) {
      debugPrint('❌ Error submitting clock in: $e');
      if (mounted) {
        _showError('Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitClockOut() async {
    if (_currentPosition == null) {
      _showError('Lokasi belum ditemukan. Silakan refresh lokasi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      debugPrint('🔄 Submitting clock out...');
      debugPrint('   Latitude: ${_currentPosition!.latitude}');
      debugPrint('   Longitude: ${_currentPosition!.longitude}');
      debugPrint('   Photo: ${_capturedImage?.path ?? "No photo"}');
      debugPrint('   Notes: ${_notesController.text}');

      final success = await attendanceProvider.clockOut(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        photo: _capturedImage ?? File(''),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        if (success) {
          debugPrint('✅ Clock out successful, popping screen...');

          // Pop screen with success result
          Navigator.pop(context, true);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clock out berhasil!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          final errorMsg = attendanceProvider.errorMessage ?? 'Gagal melakukan clock out';
          _showError(errorMsg);
        }
      }
    } catch (e) {
      debugPrint('❌ Error submitting clock out: $e');
      if (mounted) {
        _showError('Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final todayAttendance = attendanceProvider.todayAttendance;
    final isClockOut = todayAttendance != null && todayAttendance.clockOut == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isClockOut ? 'Clock Out' : 'Clock In',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF26667F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Photo Card
            _buildPhotoCard(isClockOut),

            const SizedBox(height: 20),

            // Location Card
            _buildLocationCard(),

            const SizedBox(height: 20),

            // Notes Card
            _buildNotesCard(isClockOut),

            const SizedBox(height: 30),

            // Submit Button
            _buildSubmitButton(isClockOut),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(bool isClockOut) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt, color: Color(0xFF26667F)),
                const SizedBox(width: 10),
                const Text(
                  'Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isClockOut)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            if (_capturedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _capturedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Belum ada foto',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _capturePhoto,
                icon: const Icon(Icons.camera_alt),
                label: Text(_capturedImage == null ? 'Ambil Foto' : 'Ambil Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26667F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF26667F)),
                    SizedBox(width: 10),
                    Text(
                      'Lokasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  color: const Color(0xFF26667F),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (_currentPosition != null)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Lokasi belum terdeteksi',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 15),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _currentPosition != null
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          zoom: 16,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('current_location'),
                            position: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(bool isClockOut) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_note, color: Color(0xFF26667F)),
                SizedBox(width: 10),
                Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' (Opsional)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan (opsional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF26667F)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isClockOut) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSubmitting
            ? null
            : (isClockOut ? _submitClockOut : _submitClockIn),
        style: ElevatedButton.styleFrom(
          backgroundColor: isClockOut ? Colors.red : const Color(0xFF26667F),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isClockOut ? Icons.logout : Icons.login),
                  const SizedBox(width: 10),
                  Text(
                    isClockOut ? 'Submit Clock Out' : 'Submit Clock In',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}