/// API Configuration
///
/// Pusat konfigurasi untuk semua endpoint API
/// Ganti baseUrl sesuai dengan environment yang digunakan
class ApiConfig {
  // ==================== BASE URL ====================
  //
  // PRODUCTION: Ganti dengan domain production Anda
  // static const String baseUrl = 'https://yourdomain.com/api';
  //
  // DEVELOPMENT (Local Network): Ganti dengan IP komputer server Laravel
  // Cara cek IP:
  // - Windows: buka CMD → ketik "ipconfig" → lihat IPv4 Address
  // - Mac/Linux: buka Terminal → ketik "ifconfig" → lihat inet
  //
  // PENTING:
  // - Pastikan handphone dan komputer dalam jaringan WiFi yang sama
  // - Jangan gunakan 127.0.0.1 atau localhost (tidak bisa diakses dari HP)
  // - Gunakan IP address komputer (contoh: 192.168.1.100)

  static const String baseUrl = 'http://192.168.1.2:8000/api';

  // Base URL untuk storage (foto, dokumen, dll)
  static const String storageUrl = 'http://192.168.1.2:8000/storage';

  // ==================== TIMEOUT ====================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ==================== API ENDPOINTS ====================

  // Authentication
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/profile';

  // Company
  static const String companyEndpoint = '/company';

  // Attendance
  static const String clockInEndpoint = '/attendance/clock-in';
  static const String clockOutEndpoint = '/attendance/clock-out';
  static const String todayAttendanceEndpoint = '/attendance/today';
  static const String attendanceHistoryEndpoint = '/attendance/history';

  // Leave Requests
  static const String leaveRequestsEndpoint = '/leave-requests';

  // ==================== HELPER METHODS ====================

  /// Get full API URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Get storage URL untuk foto/file
  static String getStorageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    // Jika path sudah full URL, return langsung
    if (path.startsWith('http')) return path;

    // Jika path dimulai dengan '/', hapus karena storageUrl sudah include /storage
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return '$storageUrl/$cleanPath';
  }

  /// Check apakah dalam mode development
  static bool get isDevelopment {
    return baseUrl.contains('192.168') ||
        baseUrl.contains('localhost') ||
        baseUrl.contains('127.0.0.1');
  }

  /// Get environment name
  static String get environmentName {
    if (isDevelopment) return 'Development';
    return 'Production';
  }
}
