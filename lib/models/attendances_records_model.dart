class AttendanceRecord {
  final int id;
  final String date;
  final String status;
  final String? reason;
  final String? workingHours;
  final String? breakDuration;
  final String? punchInTime;
  final String? punchOutTime;
  final String? lunchInTime;
  final String? lunchOutTime;
  final String? workType;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.status,
    this.reason,
    this.workingHours,
    this.breakDuration,
    this.punchInTime,
    this.punchOutTime,
    this.lunchInTime,
    this.lunchOutTime,
    required this.workType
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      date: json['date'],
      status: json['status'],
      reason: json['reason'],
      workingHours: json['workingHours'],
      breakDuration: json['breakDuration'],
      punchInTime: json['punchInTime'],
      punchOutTime: json['punchOutTime'],
      lunchInTime: json['lunchInTime'],
      lunchOutTime: json['lunchOutTime'],
      workType: json['workType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'status': status,
      'reason': reason,
      'workingHours': workingHours,
      'breakDuration': breakDuration,
      'punchInTime': punchInTime,
      'punchOutTime': punchOutTime,
      'lunchInTime': lunchInTime,
      'lunchOutTime': lunchOutTime,
      'workType': workType,
    };
  }
}
