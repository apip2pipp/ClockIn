import 'package:eak_flutter/config/api_config.dart';

class Attendance {
  final int id;
  final int userId;
  final int companyId;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String? clockInNotes;
  final String? clockOutNotes;
  final double? clockInLatitude;
  final double? clockInLongitude;
  final double? clockOutLatitude;
  final double? clockOutLongitude;
  final String? clockInPhoto;
  final String? clockOutPhoto;
  final int? workDuration;
  final String status;

  Attendance({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.clockIn,
    this.clockOut,
    this.clockInNotes,
    this.clockOutNotes,
    this.clockInLatitude,
    this.clockInLongitude,
    this.clockOutLatitude,
    this.clockOutLongitude,
    this.clockInPhoto,
    this.clockOutPhoto,
    this.workDuration,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['user_id'],
      companyId: json['company_id'],
      clockIn: DateTime.parse(json['clock_in']),
      clockOut: json['clock_out'] != null 
          ? DateTime.parse(json['clock_out']) 
          : null,
      clockInNotes: json['clock_in_notes'],
      clockOutNotes: json['clock_out_notes'],
      
      clockInLatitude: _parseDouble(json['clock_in_latitude']),
      clockInLongitude: _parseDouble(json['clock_in_longitude']),
      clockOutLatitude: _parseDouble(json['clock_out_latitude']),
      clockOutLongitude: _parseDouble(json['clock_out_longitude']),
      
      clockInPhoto: json['clock_in_photo'] != null
          ? ApiConfig.getFullUrl('/storage/${json['clock_in_photo']}')
          : null,
      clockOutPhoto: json['clock_out_photo'] != null
          ? ApiConfig.getFullUrl('/storage/${json['clock_out_photo']}')
          : null,
      workDuration: json['work_duration'],
      status: json['status'] ?? 'on_time',
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_id': companyId,
      'clock_in': clockIn.toIso8601String(),
      'clock_out': clockOut?.toIso8601String(),
      'clock_in_notes': clockInNotes,
      'clock_out_notes': clockOutNotes,
      'clock_in_latitude': clockInLatitude,
      'clock_in_longitude': clockInLongitude,
      'clock_out_latitude': clockOutLatitude,
      'clock_out_longitude': clockOutLongitude,
      'clock_in_photo': clockInPhoto,
      'clock_out_photo': clockOutPhoto,
      'work_duration': workDuration,
      'status': status,
    };
  }

  String get clockInTime => '${clockIn.hour.toString().padLeft(2, '0')}:${clockIn.minute.toString().padLeft(2, '0')}';
  
  String get clockOutTime => clockOut != null
      ? '${clockOut!.hour.toString().padLeft(2, '0')}:${clockOut!.minute.toString().padLeft(2, '0')}'
      : '-';

  String get formattedWorkDuration {
    if (workDuration == null) return '-';
    final hours = workDuration! ~/ 60;
    final minutes = workDuration! % 60;
    return '${hours}h ${minutes}m';
  }
}