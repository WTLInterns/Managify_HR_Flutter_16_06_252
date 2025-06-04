import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrm_dump_flutter/models/attendances_records_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AttendancesRecordsScreen extends StatefulWidget {
  const AttendancesRecordsScreen({super.key});

  @override
  _AttendancesRecordsScreenState createState() => _AttendancesRecordsScreenState();
}

class _AttendancesRecordsScreenState extends State<AttendancesRecordsScreen> {
  List<AttendanceRecord> _records = [];
  bool _isLoading = true;
  int subadminId = 0;
  String employeeFullName = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    await fetchAttendanceRecords();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subadminId = prefs.getInt('subadminId') ?? 0;
      employeeFullName = prefs.getString('fullName') ?? '';
    });
  }

  Future<void> fetchAttendanceRecords() async {

    final encodedName = Uri.encodeComponent(employeeFullName);
    final url = Uri.parse('https://api.managifyhr.com/api/employee/$subadminId/$encodedName/attendance/all');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<AttendanceRecord> records = data.map((json) => AttendanceRecord.fromJson(json)).toList();

        // Filter to latest 1 month
        final oneMonthAgo = DateTime.now().subtract(Duration(days: 30));
        final filtered = records.where((record) {
          final recordDate = DateFormat('yyyy-MM-dd').parse(record.date);
          return recordDate.isAfter(oneMonthAgo);
        }).toList();

        // Sort filtered records by date descending
        filtered.sort((a, b) {
          final dateA = DateFormat('yyyy-MM-dd').parse(a.date);
          final dateB = DateFormat('yyyy-MM-dd').parse(b.date);
          return dateB.compareTo(dateA); // For descending order
        });

        setState(() {
          _records = filtered;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('reason')),
            DataColumn(label: Text('Punch In')),
            DataColumn(label: Text('Punch Out')),
            DataColumn(label: Text('Lunch In')),
            DataColumn(label: Text('Lunch Out')),
            DataColumn(label: Text('breakDuration')),
            DataColumn(label: Text('workingHours')),
            DataColumn(label: Text('workType')),
          ],
          rows: _records.map((record) {
            return DataRow(cells: [
              DataCell(Text(record.date)),
              DataCell(Text(record.status)),
              DataCell(Text(record.reason ?? '-')),
              DataCell(Text(record.punchInTime ?? '-')),
              DataCell(Text(record.punchOutTime ?? '-')),
              DataCell(Text(record.lunchInTime ?? '-')),
              DataCell(Text(record.lunchOutTime ?? '-')),
              DataCell(Text(record.breakDuration ?? '-')),
              DataCell(Text(record.workingHours ?? '-')),
              DataCell(Text(record.workType ?? '-')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // ← Back arrow color
        title: const Text(
          'Month Attendance',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? Center(child: Text('No attendance data in the last 1 month.'))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: buildDataTable(),
      ),
    );
  }
}
