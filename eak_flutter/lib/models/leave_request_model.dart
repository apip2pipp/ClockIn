class LeaveRequest {
  final int id;
  final String jenis;
  final String startDate;
  final String endDate;
  final String reason;
  final String? attachment;
  final String status;

  LeaveRequest({
    required this.id,
    required this.jenis,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachment,
    required this.status,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      jenis: json['jenis'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      reason: json['reason'],
      attachment: json['attachment'],
      status: json['status'],
    );
  }
}
