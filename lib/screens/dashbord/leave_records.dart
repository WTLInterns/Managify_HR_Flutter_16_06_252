import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrm_dump_flutter/screens/dashbord/dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LeaveRecordsTable extends StatefulWidget {
  final int subadminId;
  final String name;
  final bool showPopup;

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

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  bool showStatusPopup = false;
  String? statusMessage;
  Color? statusColor;

  @override
  void initState() {
    super.initState();
    hasShownPopup = !widget.showPopup;
    showStatusPopup = false;
    statusMessage = null;
    statusColor = null;
    fetchLeaveData();
  }

  Future<void> fetchLeaveData() async {
    print('Employee ID: ${widget.subadminId}');
    print('Employee Name: ${widget.name}');

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.managifyhr.com/api/leaveform/${widget.subadminId}/${widget.name}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<Map<String, dynamic>> allLeaves = List<Map<String, dynamic>>.from(jsonData);

        if (allLeaves.isNotEmpty) {
          // Sort by date (newest first)
          allLeaves.sort((a, b) {
            final dateA = DateFormat('yyyy-MM-dd').parse(a['fromDate']);
            final dateB = DateFormat('yyyy-MM-dd').parse(b['fromDate']);
            return dateB.compareTo(dateA);
          });

          // Check for status popup with date validation
          final latestNonPendingLeave = allLeaves.firstWhere(
                (leave) => leave['status'] != null && leave['status'] != 'Pending',
            orElse: () => {},
          );

          if (latestNonPendingLeave.isNotEmpty) {
            final status = latestNonPendingLeave['status'];
            if (status == 'Approved' || status == 'Rejected') {
              // Check if current date is within the popup show period
              final shouldShowPopup = _shouldShowStatusPopup(latestNonPendingLeave);

              if (shouldShowPopup) {
                showStatusPopup = true;
                statusMessage = status;
                statusColor = status == 'Approved' ? Colors.green : Colors.red;
              }
            }
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
      print('Error fetching leave data: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  bool _shouldShowStatusPopup(Map<String, dynamic> leave) {
    try {
      final now = DateTime.now();
      final currentDate = DateTime(now.year, now.month, now.day);

      // Parse the leave dates
      final fromDate = DateFormat('yyyy-MM-dd').parse(leave['fromDate']);
      final toDate = DateFormat('yyyy-MM-dd').parse(leave['toDate']);

      // The popup should be shown from approval/rejection date until the leave end date
      // Since we don't have the exact approval/rejection date, we assume it was approved/rejected
      // before the leave start date, so we show popup until the leave end date

      // Show popup only if current date is before or equal to the leave end date
      return currentDate.isBefore(toDate.add(Duration(days: 1))) || currentDate.isAtSameMomentAs(toDate);

    } catch (e) {
      print('Error checking popup date condition: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> get filteredLeaveData {
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
    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MonthYearPicker(
        initialMonth: selectedMonth,
        initialYear: selectedYear,
      ),
    );

    if (result != null) {
      setState(() {
        selectedMonth = result['month']!;
        selectedYear = result['year']!;
      });
    }
  }

  String getFilterLabel() {
    return '${DateFormat.MMMM().format(DateTime(0, selectedMonth))} $selectedYear';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLeaveCard(Map<String, dynamic> leave) {
    final fromDate = DateFormat('yyyy-MM-dd').parse(leave['fromDate']);
    final toDate = DateFormat('yyyy-MM-dd').parse(leave['toDate']);
    final duration = toDate.difference(fromDate).inDays + 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave Period',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMM dd').format(fromDate)} - ${DateFormat('MMM dd, yyyy').format(toDate)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$duration day${duration > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(leave['status'] ?? 'Pending'),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leave['reason'] ?? 'No reason provided',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show status popup if needed
    if (showStatusPopup && statusMessage != null && !hasShownPopup) {
      hasShownPopup = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  statusMessage == 'Approved' ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Leave Status',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your leave has been ${statusMessage!.toLowerCase()}.',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    showStatusPopup = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Leave Records',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
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
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filter: ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectMonth(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF667eea)),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF667eea).withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            getFilterLabel(),
                            style: const TextStyle(
                              color: Color(0xFF667eea),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${filteredLeaveData.length} record${filteredLeaveData.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                  SizedBox(height: 16),
                  Text('Loading leave records...'),
                ],
              ),
            )
                : hasError
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading leave records',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchLeaveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
                : filteredLeaveData.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No leave records for ${getFilterLabel()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try selecting a different month',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: fetchLeaveData,
              color: const Color(0xFF667eea),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredLeaveData.length,
                itemBuilder: (context, index) {
                  return _buildLeaveCard(filteredLeaveData[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthYearPicker extends StatefulWidget {
  final int initialMonth;
  final int initialYear;

  const _MonthYearPicker({
    required this.initialMonth,
    required this.initialYear,
  });

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (i) => DateFormat.MMMM().format(DateTime(0, i + 1)));
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (i) => currentYear - 2 + i);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Month & Year',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Month Selection
                const Text(
                  'Month',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = month == selectedMonth;

                      return GestureDetector(
                        onTap: () => setState(() => selectedMonth = month),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF667eea) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              months[index].substring(0, 3),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Year Selection
                const Text(
                  'Year',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: years.length,
                    itemBuilder: (context, index) {
                      final year = years[index];
                      final isSelected = year == selectedYear;

                      return GestureDetector(
                        onTap: () => setState(() => selectedYear = year),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF667eea) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              year.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF667eea)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xFF667eea)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'month': selectedMonth,
                            'year': selectedYear,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}