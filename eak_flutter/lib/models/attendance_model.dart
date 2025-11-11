class Attendance {
  final int id;
  final int userId;
  final int companyId;
  final DateTime clockIn;
  final double? clockInLatitude;
  final double? clockInLongitude;
  final String? clockInPhoto;
  final String? clockInNotes;
  final DateTime? clockOut;
  final double? clockOutLatitude;
  final double? clockOutLongitude;
  final String? clockOutPhoto;
  final String? clockOutNotes;
  final int? workDuration;
  final String status;

  Attendance({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.clockIn,
    this.clockInLatitude,
    this.clockInLongitude,
    this.clockInPhoto,
    this.clockInNotes,
    this.clockOut,
    this.clockOutLatitude,
    this.clockOutLongitude,
    this.clockOutPhoto,
    this.clockOutNotes,
    this.workDuration,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'],
      companyId: json['company_id'],
      clockIn: DateTime.parse(json['clock_in']),
      clockInLatitude: json['clock_in_latitude'] != null
          ? double.parse(json['clock_in_latitude'].toString())
          : null,
      clockInLongitude: json['clock_in_longitude'] != null
          ? double.parse(json['clock_in_longitude'].toString())
          : null,
      clockInPhoto: json['clock_in_photo'],
      clockInNotes: json['clock_in_notes'],
      clockOut: json['clock_out'] != null
          ? DateTime.parse(json['clock_out'])
          : null,
      clockOutLatitude: json['clock_out_latitude'] != null
          ? double.parse(json['clock_out_latitude'].toString())
          : null,
      clockOutLongitude: json['clock_out_longitude'] != null
          ? double.parse(json['clock_out_longitude'].toString())
          : null,
      clockOutPhoto: json['clock_out_photo'],
      clockOutNotes: json['clock_out_notes'],
      workDuration: json['work_duration'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_id': companyId,
      'clock_in': clockIn.toIso8601String(),
      'clock_in_latitude': clockInLatitude,
      'clock_in_longitude': clockInLongitude,
      'clock_in_photo': clockInPhoto,
      'clock_in_notes': clockInNotes,
      'clock_out': clockOut?.toIso8601String(),
      'clock_out_latitude': clockOutLatitude,
      'clock_out_longitude': clockOutLongitude,
      'clock_out_photo': clockOutPhoto,
      'clock_out_notes': clockOutNotes,
      'work_duration': workDuration,
      'status': status,
    };
  }

  String get clockInPhotoUrl {
    if (clockInPhoto == null) return '';
    return 'http://127.0.0.1:8000/storage/$clockInPhoto';
  }

  String get clockOutPhotoUrl {
    if (clockOutPhoto == null) return '';
    return 'http://127.0.0.1:8000/storage/$clockOutPhoto';
  }

  String get formattedDuration {
    if (workDuration == null) return '-';
    final hours = workDuration! ~/ 60;
    final minutes = workDuration! % 60;
    return '${hours}h ${minutes}m';
  }

  bool get isClockOutAvailable => clockOut == null;
}
