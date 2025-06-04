import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrm_dump_flutter/screens/dashbord/dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LeaveRecordsTable extends StatefulWidget {
  final int subadminId;
  final String name;
  final bool showPopup; // Flag to control popup display

  const LeaveRecordsTable({
    super.key,
    required this.subadminId,
    required this.name,
    this.showPopup = true,
  });

  @override
  State<LeaveRecordsTable> createState() => _LeaveRecordsTableState();
}

class _LeaveRecordsTableState extends State<LeaveRecordsTable> {
  List<Map<String, dynamic>> leaveData = [];
  bool isLoading = true;
  bool hasError = false;
  bool hasShownPopup = false;

  int? selectedMonth;
  int? selectedYear;

  bool showStatusPopup = false;
  String? statusMessage;
  Color? statusColor;

  @override
  void initState() {
    super.initState();

    // Set popup state based on incoming flag
    hasShownPopup = !widget.showPopup;
    showStatusPopup = false;
    statusMessage = null;
    statusColor = null;

    fetchLeaveData();
  }

  Future<void> fetchLeaveData() async {
    print('Employee ID: ${widget.subadminId}');
    print('Employee Name: ${widget.name}');
    try {
      final response = await http.get(
        Uri.parse('https://api.managifyhr.com/api/leaveform/${widget.subadminId}/${widget.name}'),
      );


      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Map<String, dynamic>> allLeaves = List<Map<String, dynamic>>.from(jsonData);

        if (allLeaves.isNotEmpty) {
          allLeaves.sort((a, b) {
            final dateA = DateFormat('yyyy-MM-dd').parse(a['fromDate']);
            final dateB = DateFormat('yyyy-MM-dd').parse(b['fromDate']);
            return dateB.compareTo(dateA);
          });

          DateTime latest = DateFormat('yyyy-MM-dd').parse(allLeaves.first['fromDate']);
          selectedMonth = latest.month;
          selectedYear = latest.year;
        }

        final latestNonPendingLeave = allLeaves.firstWhere(
              (leave) => leave['status'] != null && leave['status'] != 'Pending',
          orElse: () => {},
        );

        if (latestNonPendingLeave.isNotEmpty) {
          final status = latestNonPendingLeave['status'];
          if (status == 'Approved' || status == 'Rejected') {
            showStatusPopup = true;
            statusMessage = status;
            statusColor = status == 'Approved' ? Colors.green : Colors.red;
          }
        }

        setState(() {
          leaveData = allLeaves;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredLeaveData {
    if (selectedMonth == null || selectedYear == null) {
      return leaveData;
    }
    return leaveData.where((leave) {
      try {
        final fromDate = DateFormat('yyyy-MM-dd').parse(leave['fromDate']);
        return (fromDate.month == selectedMonth && fromDate.year == selectedYear);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final monthNames = List.generate(12, (i) => DateFormat.MMMM().format(DateTime(0, i + 1)));
    int? pickedMonth = selectedMonth ?? DateTime.now().month;
    int? pickedYear = selectedYear ?? DateTime.now().year;

    await showDialog(
      context: context,
      builder: (context) {
        int tempMonth = pickedMonth!;
        int tempYear = pickedYear!;

        return AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                DropdownButton<int>(
                  value: tempMonth,
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(monthNames[index]),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => tempMonth = val);
                    }
                  },
                ),
                Row(
                  children: [
                    const Text('Year: '),
                    Expanded(
                      child: TextFormField(
                        initialValue: tempYear.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final y = int.tryParse(val);
                          if (y != null) {
                            tempYear = y;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                pickedMonth = tempMonth;
                pickedYear = tempYear;
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (pickedMonth != null && pickedYear != null) {
      setState(() {
        selectedMonth = pickedMonth;
        selectedYear = pickedYear;
      });
    }
  }

  String getFilterLabel() {
    if (selectedMonth == null || selectedYear == null) return 'All';
    return '${DateFormat.MMMM().format(DateTime(0, selectedMonth!))} $selectedYear';
  }

  @override
  Widget build(BuildContext context) {
    if (showStatusPopup && statusMessage != null && !hasShownPopup) {
      hasShownPopup = true;
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Leave Status', style: TextStyle(color: statusColor)),
            content: Text('Your leave has been $statusMessage.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    showStatusPopup = false;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Records', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => _selectMonth(context),
            icon: const Icon(Icons.filter_list),
            label: Text(getFilterLabel()),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>DashboardScreen()));
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text('Error loading leave records'))
          : filteredLeaveData.isEmpty
          ? Center(child: Text('No leave records for ${getFilterLabel()}'))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('From Date')),
              DataColumn(label: Text('To Date')),
              DataColumn(label: Text('Reason')),
              DataColumn(label: Text('Status')),
            ],
            rows: filteredLeaveData.map((leave) {
              final status = leave['status'] ?? '';
              final statusColor = status == 'Approved'
                  ? Colors.green
                  : status == 'Rejected'
                  ? Colors.red
                  : Colors.black;

              return DataRow(
                cells: [
                  DataCell(Text(leave['fromDate'] ?? '')),
                  DataCell(Text(leave['toDate'] ?? '')),
                  DataCell(Text(leave['reason'] ?? '')),
                  DataCell(Text(status, style: TextStyle(color: statusColor))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
