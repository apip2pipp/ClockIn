import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  final _notesController = TextEditingController();
  File? _selectedPhoto;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      // Check location permission
      final permission = await Permission.location.request();

      if (!permission.isGranted) {
        setState(() {
          _errorMessage = 'Izin lokasi diperlukan untuk absensi';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Layanan lokasi tidak aktif. Silakan aktifkan GPS.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mendapatkan lokasi: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final permission = await Permission.camera.request();

      if (!permission.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kamera diperlukan untuk mengambil foto'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedPhoto = File(photo.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum ditemukan. Silakan coba lagi.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto selfie diperlukan untuk absensi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    final todayAttendance = attendanceProvider.todayAttendance;

    bool success;

    if (todayAttendance == null) {
      // Clock In
      success = await attendanceProvider.clockIn(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        photo: _selectedPhoto!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      // Clock Out
      success = await attendanceProvider.clockOut(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        photo: _selectedPhoto!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            todayAttendance == null
                ? 'Clock In berhasil!'
                : 'Clock Out berhasil!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendanceProvider.errorMessage ?? 'Absensi gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final todayAttendance = attendanceProvider.todayAttendance;
    final isClockOut =
        todayAttendance != null && todayAttendance.clockOut == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isClockOut ? 'Clock Out' : 'Clock In'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              elevation: 2,
              color: isClockOut ? Colors.orange.shade50 : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isClockOut ? Icons.logout : Icons.login,
                          color: isClockOut ? Colors.orange : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isClockOut ? 'Clock Out' : 'Clock In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isClockOut
                                ? Colors.orange.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authProvider.company?.name ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      authProvider.company?.address ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location Status
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _currentPosition != null
                              ? Icons.location_on
                              : Icons.location_off,
                          color: _currentPosition != null
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Lokasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingLocation)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Mencari lokasi...'),
                        ],
                      )
                    else if (_currentPosition != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Akurasi: ${_currentPosition!.accuracy.toStringAsFixed(1)} meter',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _errorMessage ?? 'Lokasi tidak tersedia',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photo Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Foto Selfie',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedPhoto != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedPhoto!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPhoto = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada foto',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _capturePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          _selectedPhoto == null ? 'Ambil Foto' : 'Ambil Ulang',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notes, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Catatan (Opsional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan catatan jika perlu...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isSubmitting ||
                        _currentPosition == null ||
                        _selectedPhoto == null
                    ? null
                    : _submitAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isClockOut ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isClockOut
                            ? 'Konfirmasi Clock Out'
                            : 'Konfirmasi Clock In',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
