import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:managify_hr/models/attendances_records_model.dart';

class AttendancesRecordsScreen extends StatefulWidget {
  const AttendancesRecordsScreen({super.key});

  @override
  _AttendancesRecordsScreenState createState() => _AttendancesRecordsScreenState();
}

class _AttendancesRecordsScreenState extends State<AttendancesRecordsScreen> {
  List<AttendanceRecord> _allRecords = [];
  List<AttendanceRecord> _filteredRecords = [];
  bool _isLoading = true;
  int subadminId = 0;
  String employeeFullName = '';
  DateTime _selectedMonth = DateTime.now();
  String? _errorMessage;
  Map<String, dynamic> _summaryData = {
    'presentDays': 0,
    'presentPercentage': 0.0,
    'absentDays': 0,
    'absentPercentage': 0.0,
    'halfDay': 0,
    'halfDayPercentage': 0.0,
    'paidLeave': 0,
    'paidLeavePercentage': 0.0,
    'weekOff': 0,
    'weekOffPercentage': 0.0,
    'holiday': 0,
    'holidayPercentage': 0.0,
    'totalDays': 0,
    'totalAttendancePercentage': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadUserData();
      await _loadSummaryFromPreferences();
      await fetchAttendanceRecords();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize data: $e';
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subadminId = prefs.getInt('subadminId') ?? 0;
      employeeFullName = prefs.getString('fullName') ?? '';
    });
  }

  Future<void> fetchAttendanceRecords() async {
    if (subadminId == 0 || employeeFullName.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid user data. Please check your credentials.';
      });
      return;
    }

    final encodedName = Uri.encodeComponent(employeeFullName);
    final url = Uri.parse(
      'https://api.managifyhr.com/api/employee/$subadminId/$encodedName/attendance/all',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<AttendanceRecord> records =
        data.map((json) => AttendanceRecord.fromJson(json)).toList();
        setState(() {
          _allRecords = records;
          _isLoading = false;
          _errorMessage = null;
        });
        _filterRecordsByMonth();
        await _saveSummaryToPreferences();
        await _loadSummaryFromPreferences();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching records: $e';
      });
    }
  }

  void _filterRecordsByMonth() {
    final filtered = _allRecords.where((record) {
      final recordDate = DateFormat('yyyy-MM-dd').parse(record.date);
      return recordDate.year == _selectedMonth.year &&
          recordDate.month == _selectedMonth.month;
    }).toList();

    filtered.sort((a, b) {
      final dateA = DateFormat('yyyy-MM-dd').parse(a.date);
      final dateB = DateFormat('yyyy-MM-dd').parse(b.date);
      return dateB.compareTo(dateA);
    });

    setState(() {
      _filteredRecords = filtered;
    });
  }

  Future<void> _saveSummaryToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    int presentDays = _filteredRecords
        .where((r) => r.status.toLowerCase().replaceAll('-', ' ') == 'present')
        .length;
    int absentDays = _filteredRecords
        .where((r) => r.status.toLowerCase().replaceAll('-', ' ') == 'absent')
        .length;
    int halfDay = _filteredRecords
        .where((r) => r.status.toLowerCase().replaceAll('-', ' ') == 'half day')
        .length;
    int paidLeave = _filteredRecords
        .where((r) => r.status.toLowerCase().replaceAll('-', ' ') == 'paid leave')
        .length;
    int weekOff = _filteredRecords
        .where((r) => r.status.toLowerCase().replaceAll('-', ' ') == 'week off')
        .length;
    int holiday = _filteredRecords
        .where((r) => r.status.toLowerCase().replaceAll('-', ' ') == 'holiday')
        .length;

    // Calculate total days in the selected month
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    int totalDays = lastDayOfMonth.day;

    double presentPercentage = totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;
    double absentPercentage = totalDays > 0 ? (absentDays / totalDays) * 100 : 0.0;
    double halfDayPercentage = totalDays > 0 ? (halfDay * 0.5 / totalDays) * 100 : 0.0;
    double paidLeavePercentage = totalDays > 0 ? (paidLeave / totalDays) * 100 : 0.0;
    double weekOffPercentage = totalDays > 0 ? (weekOff / totalDays) * 100 : 0.0;
    double holidayPercentage = totalDays > 0 ? (holiday / totalDays) * 100 : 0.0;
    double totalAttendancePercentage = totalDays > 0
        ? ((presentDays + (halfDay * 0.5) + paidLeave + weekOff + holiday) / totalDays) * 100
        : 0.0;

    String monthKey = DateFormat('yyyy_MM').format(_selectedMonth);
    await prefs.setInt('presentDays_$monthKey', presentDays);
    await prefs.setInt('absentDays_$monthKey', absentDays);
    await prefs.setInt('halfDay_$monthKey', halfDay);
    await prefs.setInt('paidLeave_$monthKey', paidLeave);
    await prefs.setInt('weekOff_$monthKey', weekOff);
    await prefs.setInt('holiday_$monthKey', holiday);
    await prefs.setInt('totalDays_$monthKey', totalDays);
    await prefs.setDouble('presentPercentage_$monthKey', presentPercentage);
    await prefs.setDouble('absentPercentage_$monthKey', absentPercentage);
    await prefs.setDouble('halfDayPercentage_$monthKey', halfDayPercentage);
    await prefs.setDouble('paidLeavePercentage_$monthKey', paidLeavePercentage);
    await prefs.setDouble('weekOffPercentage_$monthKey', weekOffPercentage);
    await prefs.setDouble('holidayPercentage_$monthKey', holidayPercentage);
    await prefs.setDouble('totalAttendancePercentage_$monthKey', totalAttendancePercentage);

    setState(() {
      _summaryData = {
        'presentDays': presentDays,
        'presentPercentage': presentPercentage,
        'absentDays': absentDays,
        'absentPercentage': absentPercentage,
        'halfDay': halfDay,
        'halfDayPercentage': halfDayPercentage,
        'paidLeave': paidLeave,
        'paidLeavePercentage': paidLeavePercentage,
        'weekOff': weekOff,
        'weekOffPercentage': weekOffPercentage,
        'holiday': holiday,
        'holidayPercentage': holidayPercentage,
        'totalDays': totalDays,
        'totalAttendancePercentage': totalAttendancePercentage,
      };
    });
  }

  Future<void> _loadSummaryFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String monthKey = DateFormat('yyyy_MM').format(_selectedMonth);
    setState(() {
      _summaryData = {
        'presentDays': prefs.getInt('presentDays_$monthKey') ?? 0,
        'presentPercentage': prefs.getDouble('presentPercentage_$monthKey') ?? 0.0,
        'absentDays': prefs.getInt('absentDays_$monthKey') ?? 0,
        'absentPercentage': prefs.getDouble('absentPercentage_$monthKey') ?? 0.0,
        'halfDay': prefs.getInt('halfDay_$monthKey') ?? 0,
        'halfDayPercentage': prefs.getDouble('halfDayPercentage_$monthKey') ?? 0.0,
        'paidLeave': prefs.getInt('paidLeave_$monthKey') ?? 0,
        'paidLeavePercentage': prefs.getDouble('paidLeavePercentage_$monthKey') ?? 0.0,
        'weekOff': prefs.getInt('weekOff_$monthKey') ?? 0,
        'weekOffPercentage': prefs.getDouble('weekOffPercentage_$monthKey') ?? 0.0,
        'holiday': prefs.getInt('holiday_$monthKey') ?? 0,
        'holidayPercentage': prefs.getDouble('holidayPercentage_$monthKey') ?? 0.0,
        'totalDays': prefs.getInt('totalDays_$monthKey') ?? 0,
        'totalAttendancePercentage': prefs.getDouble('totalAttendancePercentage_$monthKey') ?? 0.0,
      };
    });
  }

  void _changeMonth(int monthChange) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + monthChange,
        1,
      );
    });
    _filterRecordsByMonth();
    _loadSummaryFromPreferences();
  }

  Color _getWorkingHoursColor(String? workingHours) {
    if (workingHours == null || workingHours == '-' || workingHours == '0h 0m') {
      return Colors.grey;
    }

    try {
      final regex = RegExp(r'(\d+)h\s*(\d+)m');
      final match = regex.firstMatch(workingHours);
      if (match != null) {
        final hours = int.parse(match.group(1)!);
        final minutes = int.parse(match.group(2)!);
        final totalHours = hours + (minutes / 60);
        return totalHours >= 8.0 ? Colors.green : Colors.red;
      }
      return Colors.grey;
    } catch (e) {
      return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    final normalizedStatus = status.toLowerCase().replaceAll('-', ' ');
    switch (normalizedStatus) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'half day':
        return Colors.orange;
      case 'paid leave':
        return Colors.blue;
      case 'week off':
        return Colors.purple;
      case 'holiday':
        return Colors.teal;
      case 'late':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildSummaryCard(
            title: 'Present',
            value: '${_summaryData['presentDays']}',
            percentage: '${_summaryData['presentPercentage'].toStringAsFixed(1)}%',
            color: Colors.green,
          ),
          _buildSummaryCard(
            title: 'Absent',
            value: '${_summaryData['absentDays']}',
            percentage: '${_summaryData['absentPercentage'].toStringAsFixed(1)}%',
            color: Colors.red,
          ),
          _buildSummaryCard(
            title: 'Half-Day',
            value: '${_summaryData['halfDay']}',
            percentage: '${_summaryData['halfDayPercentage'].toStringAsFixed(1)}%',
            color: Colors.orange,
          ),
          _buildSummaryCard(
            title: 'Paid Leave',
            value: '${_summaryData['paidLeave']}',
            percentage: '${_summaryData['paidLeavePercentage'].toStringAsFixed(1)}%',
            color: Colors.blue,
          ),
          _buildSummaryCard(
            title: 'Week Off',
            value: '${_summaryData['weekOff']}',
            percentage: '${_summaryData['weekOffPercentage'].toStringAsFixed(1)}%',
            color: Colors.purple,
          ),
          _buildSummaryCard(
            title: 'Holiday',
            value: '${_summaryData['holiday']}',
            percentage: '${_summaryData['holidayPercentage'].toStringAsFixed(1)}%',
            color: Colors.teal,
          ),
          _buildSummaryCard(
            title: 'Total Days',
            value: '${_summaryData['totalDays']}',
            color: Colors.grey,
          ),
          _buildSummaryCard(
            title: 'Total',
            value: '${_summaryData['totalAttendancePercentage'].toStringAsFixed(1)}%',
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    String? percentage,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (percentage != null) ...[
              const SizedBox(height: 4),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              const Color(0xFF667eea).withOpacity(0.1),
            ),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
              fontSize: 14,
            ),
            dataTextStyle: const TextStyle(fontSize: 13, color: Colors.black87),
            columnSpacing: 20,
            horizontalMargin: 16,
            columns: const [
              DataColumn(label: Text('Date'), numeric: false),
              DataColumn(label: Text('Day'), numeric: false),
              DataColumn(label: Text('Status'), numeric: false),
              DataColumn(label: Text('Reason'), numeric: false),
              DataColumn(label: Text('Punch In'), numeric: false),
              DataColumn(label: Text('Punch Out'), numeric: false),
              DataColumn(label: Text('Lunch In'), numeric: false),
              DataColumn(label: Text('Lunch Out'), numeric: false),
              DataColumn(label: Text('Break Duration'), numeric: false),
              DataColumn(label: Text('Working Hours'), numeric: false),
              DataColumn(label: Text('Work Type'), numeric: false),
            ],
            rows: _filteredRecords.map((record) {
              final recordDate = DateFormat('yyyy-MM-dd').parse(record.date);
              final dayName = DateFormat('EEE').format(recordDate);
              final formattedDate = DateFormat('dd/MM').format(recordDate);

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      formattedDate,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      dayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(record.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(record.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        record.status,
                        style: TextStyle(
                          color: _getStatusColor(record.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      record.reason ?? '-',
                      style: TextStyle(
                        color: record.reason != null && record.reason != '-'
                            ? Colors.redAccent.shade700
                            : Colors.grey.shade600,
                        fontStyle: record.reason != null && record.reason != '-'
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.login,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.punchInTime ?? '-',
                          style: TextStyle(
                            color: record.punchInTime != null &&
                                record.punchInTime != '-'
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Icon(
                          Icons.logout,
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.punchOutTime ?? '-',
                          style: TextStyle(
                            color: record.punchOutTime != null &&
                                record.punchOutTime != '-'
                                ? Colors.red.shade700
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          record.lunchInTime ?? '-',
                          style: TextStyle(
                            color: record.lunchInTime != null &&
                                record.lunchInTime != '-'
                                ? Colors.orange.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          record.lunchOutTime ?? '-',
                          style: TextStyle(
                            color: record.lunchOutTime != null &&
                                record.lunchOutTime != '-'
                                ? Colors.orange.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 20),
                        Text(
                          record.breakDuration ?? '-',
                          style: TextStyle(
                            color: record.breakDuration != null &&
                                record.breakDuration != '-'
                                ? Colors.blue.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getWorkingHoursColor(record.workingHours)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getWorkingHoursColor(record.workingHours)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: _getWorkingHoursColor(record.workingHours),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            record.workingHours ?? '-',
                            style: TextStyle(
                              color: _getWorkingHoursColor(record.workingHours),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work,
                          size: 16,
                          color: Colors.purple.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          record.workType ?? '-',
                          style: TextStyle(
                            color: record.workType != null &&
                                record.workType != '-'
                                ? Colors.purple.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Attendance Records',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : Column(
        children: [
          _buildMonthSelector(),
          if (_filteredRecords.isNotEmpty) _buildSummaryCards(),
          Expanded(
            child: _filteredRecords.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No attendance records found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : _buildDataTable(),
          ),
        ],
      ),
    );
  }
}