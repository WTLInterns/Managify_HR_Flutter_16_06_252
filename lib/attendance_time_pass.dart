// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
// // import 'package:intl/intl.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // class AttendanceFormPage extends StatefulWidget {
// //   @override
// //   _AttendanceFormPageState createState() => _AttendanceFormPageState();
// // }
// //
// // class _AttendanceFormPageState extends State<AttendanceFormPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final Completer<GoogleMapController> _controller = Completer();
// //
// //   int subadminId = 0;
// //   String employeeFullName = '';
// //   bool _isSubmitting = false;
// //
// //   final TextEditingController _dateController = TextEditingController();
// //   final TextEditingController _inTimeController = TextEditingController();
// //   final TextEditingController _outTimeController = TextEditingController();
// //   final TextEditingController _lunchInTimeController = TextEditingController();
// //   final TextEditingController _lunchOutTimeController = TextEditingController();
// //
// //   DateTime? selectedDate;
// //   String awayFromOffice = '200 M';
// //   Position? _currentPosition;
// //
// //   static const LatLng companyLocation = LatLng(
// //     18.561310,
// //     73.944481,
// //   ); //18.561310, 73.944481
// //   static const CameraPosition _kGoogleplex = CameraPosition(
// //     target: companyLocation,
// //     zoom: 14,
// //   );
// //
// //   final List<Marker> _markers = <Marker>[
// //     Marker(
// //       markerId: MarkerId('1'),
// //       position: companyLocation,
// //       infoWindow: InfoWindow(title: 'WTL Tourism'),
// //     ),
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadUserData();
// //   }
// //
// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     final now = TimeOfDay.now();
// //     _inTimeController.text = now.format(context);
// //   }
// //
// //   Future<void> _loadUserData() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       subadminId = prefs.getInt('subadminId') ?? 0;
// //       employeeFullName = prefs.getString('fullName') ?? '';
// //     });
// //   }
// //
// //   Future<void> _selectDate() async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: selectedDate ?? DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2101),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         selectedDate = picked;
// //         _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
// //       });
// //     }
// //   }
// //
// //   Future<void> _selectTime({
// //     required BuildContext context,
// //     required TextEditingController controller,
// //   }) async {
// //     final TimeOfDay? picked = await showTimePicker(
// //       context: context,
// //       initialTime: TimeOfDay.now(),
// //       builder: (BuildContext context, Widget? child) {
// //         // Force 24-hour format in UI
// //         return MediaQuery(
// //           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
// //           child: child!,
// //         );
// //       },
// //     );
// //
// //     if (picked != null) {
// //       // Manually format to 24-hour string (no AM/PM)
// //       final String formattedTime =
// //           '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString()
// //           .padLeft(2, '0')}';
// //       controller.text = formattedTime;
// //     }
// //   }
// //
// //   Future<void> _submitAttendance() async {
// //     if (_currentPosition == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Current location not available')),
// //       );
// //       return;
// //     }
// //
// //     final String postUrl =
// //         'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/add/bulk';
// //     final String putUrl =
// //         'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/update/bulk';
// //
// //     // Clean attendance payload
// //     final attendancePayload = {
// //       "date": _dateController.text.trim(),
// //       "status": "Present",
// //       "reason": "",
// //       "punchInTime": _inTimeController.text.trim().isEmpty ? null : _inTimeController.text.trim(),
// //       "punchOutTime": _outTimeController.text.trim().isEmpty ? null : _outTimeController.text.trim(),
// //       "lunchInTime": _lunchInTimeController.text.trim().isEmpty ? null : _lunchInTimeController.text.trim(),
// //       "lunchOutTime": _lunchOutTimeController.text.trim().isEmpty ? null : _lunchOutTimeController.text.trim(),
// //     };
// //
// //     try {
// //       // 1. Submit ADD (POST)
// //       final postResponse = await http.post(
// //         Uri.parse(postUrl),
// //         headers: {"Content-Type": "application/json"},
// //         body: jsonEncode([attendancePayload]),
// //       );
// //
// //       if (postResponse.statusCode == 200) {
// //         print("POST success: ${postResponse.body}");
// //
// //         // 2. Only send PUT if OutTime is provided (simulate a manual update)
// //         if (_outTimeController.text.trim().isNotEmpty) {
// //           final updatePayload = {
// //             ...attendancePayload,
// //             "date": _dateController.text.trim(),
// //             "status": "Present",
// //             "reason": "",
// //             "punchInTime": _inTimeController.text.trim().isEmpty ? null : _inTimeController.text.trim(),
// //             "punchOutTime": _outTimeController.text.trim().isEmpty ? null : _outTimeController.text.trim(),
// //             "lunchInTime": _lunchInTimeController.text.trim().isEmpty ? null : _lunchInTimeController.text.trim(),
// //             "lunchOutTime": _lunchOutTimeController.text.trim().isEmpty ? null : _lunchOutTimeController.text.trim(),
// //             "breakDuration": "1h 0m",
// //             "workingHours": "8h 0m",
// //           };
// //
// //           final putResponse = await http.put(
// //             Uri.parse(putUrl),
// //             headers: {"Content-Type": "application/json"},
// //             body: jsonEncode([updatePayload]),
// //           );
// //
// //           if (putResponse.statusCode == 200) {
// //             print("PUT success: ${putResponse.body}");
// //           } else {
// //             print("PUT error: ${putResponse.body}");
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(content: Text('Update failed: ${putResponse.statusCode}')),
// //             );
// //           }
// //         }
// //
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Attendance submitted successfully')),
// //         );
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(builder: (_) => AttendancesRecordsScreen()),
// //         );
// //       } else {
// //         print("POST error: ${postResponse.body}");
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Add Failed: ${postResponse.statusCode}')),
// //         );
// //       }
// //     } catch (e) {
// //       print('Exception: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error: $e')),
// //       );
// //     }
// //   }
// //
// //
// //   Widget _buildButtons() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         MaterialButton(
// //           minWidth: 120,
// //           height: 40,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10),
// //             side: BorderSide(color: Colors.black),
// //           ),
// //           onPressed: () => Navigator.pop(context),
// //           child: Text("Cancel", style: TextStyle(color: Colors.red)),
// //         ),
// //         SizedBox(width: 30),
// //         MaterialButton(
// //           minWidth: 120,
// //           height: 40,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10),
// //             side: BorderSide(color: Colors.black),
// //           ),
// //           onPressed: () async {
// //             if (_isSubmitting) return;
// //
// //             if (_formKey.currentState!.validate()) {
// //               setState(() => _isSubmitting = true);
// //               showDialog(
// //                 context: context,
// //                 barrierDismissible: false,
// //                 builder: (_) => Center(child: CircularProgressIndicator()),
// //               );
// //
// //               try {
// //                 bool serviceEnabled =
// //                 await Geolocator.isLocationServiceEnabled();
// //                 if (!serviceEnabled) throw 'Location services are disabled';
// //
// //                 LocationPermission permission =
// //                 await Geolocator.checkPermission();
// //                 if (permission == LocationPermission.denied) {
// //                   permission = await Geolocator.requestPermission();
// //                   if (permission == LocationPermission.denied)
// //                     throw 'Permission denied';
// //                 }
// //                 if (permission == LocationPermission.deniedForever) {
// //                   throw 'Permission permanently denied';
// //                 }
// //
// //                 Position position = await Geolocator.getCurrentPosition(
// //                   desiredAccuracy: LocationAccuracy.high,
// //                 );
// //
// //                 LatLng userLatLng = LatLng(
// //                   position.latitude,
// //                   position.longitude,
// //                 );
// //                 double distance = Geolocator.distanceBetween(
// //                   userLatLng.latitude,
// //                   userLatLng.longitude,
// //                   companyLocation.latitude,
// //                   companyLocation.longitude,
// //                 );
// //
// //                 setState(() {
// //                   _currentPosition = position;
// //                   awayFromOffice = '${distance.toStringAsFixed(2)} M';
// //                 });
// //
// //                 final GoogleMapController controller = await _controller.future;
// //                 await controller.animateCamera(
// //                   CameraUpdate.newCameraPosition(
// //                     CameraPosition(target: userLatLng, zoom: 16),
// //                   ),
// //                 );
// //
// //                 _markers.removeWhere(
// //                       (marker) => marker.markerId.value == 'current',
// //                 );
// //                 _markers.add(
// //                   Marker(
// //                     markerId: MarkerId('current'),
// //                     position: userLatLng,
// //                     infoWindow: InfoWindow(title: 'Your Location'),
// //                     icon: BitmapDescriptor.defaultMarkerWithHue(
// //                       BitmapDescriptor.hueAzure,
// //                     ),
// //                   ),
// //                 );
// //
// //                 Navigator.of(context).pop(); // close loader
// //
// //                 if (distance <= 100) {
// //                   await _submitAttendance();
// //                 } else {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                       content: Text('You are not at the office location!'),
// //                     ),
// //                   );
// //                 }
// //               } catch (e) {
// //                 Navigator.of(context).pop();
// //                 ScaffoldMessenger.of(
// //                   context,
// //                 ).showSnackBar(SnackBar(content: Text(e.toString())));
// //               } finally {
// //                 setState(() => _isSubmitting = false);
// //               }
// //             }
// //           },
// //           child: Text("Save", style: TextStyle(color: Colors.green)),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildGoogleMap() {
// //     return GoogleMap(
// //       initialCameraPosition: _kGoogleplex,
// //       markers: Set<Marker>.of(_markers),
// //       onMapCreated: (GoogleMapController controller) {
// //         _controller.complete(controller);
// //       },
// //     );
// //   }
// //
// //   Widget _buildFetchCurrentLocation() {
// //     return FloatingActionButton(
// //       onPressed: () async {
// //         showDialog(
// //           context: context,
// //           barrierDismissible: false,
// //           builder: (_) => Center(child: CircularProgressIndicator()),
// //         );
// //         try {
// //           Position position = await Geolocator.getCurrentPosition(
// //             desiredAccuracy: LocationAccuracy.high,
// //           );
// //
// //           LatLng userLatLng = LatLng(position.latitude, position.longitude);
// //
// //           _markers.removeWhere((marker) => marker.markerId.value == 'current');
// //           _markers.add(
// //             Marker(
// //               markerId: MarkerId('current'),
// //               position: userLatLng,
// //               infoWindow: InfoWindow(title: 'My Location'),
// //               icon: BitmapDescriptor.defaultMarkerWithHue(
// //                 BitmapDescriptor.hueAzure,
// //               ),
// //             ),
// //           );
// //
// //           final GoogleMapController controller = await _controller.future;
// //           await controller.animateCamera(
// //             CameraUpdate.newCameraPosition(
// //               CameraPosition(target: userLatLng, zoom: 16),
// //             ),
// //           );
// //
// //           setState(() {
// //             _currentPosition = position;
// //           });
// //         } catch (_) {
// //           ScaffoldMessenger.of(
// //             context,
// //           ).showSnackBar(SnackBar(content: Text('Failed to fetch location')));
// //         } finally {
// //           Navigator.of(context).pop();
// //         }
// //       },
// //       child: Icon(Icons.my_location),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.blue.shade700,
// //         centerTitle: true,
// //         iconTheme: IconThemeData(color: Colors.white),
// //         title: Text('Attendance Form', style: TextStyle(color: Colors.white)),
// //       ),
// //       body: SafeArea(
// //         child: Form(
// //           key: _formKey,
// //           child: Padding(
// //             padding: const EdgeInsets.all(12.0),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Image.asset('assets/profile.png', width: 50, height: 50),
// //                       SizedBox(width: 20),
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Arbaj Shaikh',
// //                             style: TextStyle(
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                           Text(
// //                             'MERN STACK DEVELOPER',
// //                             style: TextStyle(fontSize: 15),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                   Divider(),
// //                   const Text("DATE"),
// //                   TextFormField(
// //                     controller: _dateController,
// //                     readOnly: true,
// //                     onTap: _selectDate,
// //                     decoration: InputDecoration(
// //                       hintText: 'Select Date',
// //                       suffixIcon: Icon(Icons.calendar_today),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                     validator:
// //                         (value) =>
// //                     value == null || value.isEmpty
// //                         ? 'Please select a date'
// //                         : null,
// //                   ),
// //                   SizedBox(height: 16),
// //                   const Text("PUNCH IN"),
// //                   TextFormField(
// //                     controller: _inTimeController,
// //                     enabled: true,
// //                     onTap:
// //                         () =>
// //                         _selectTime(
// //                           context: context,
// //                           controller: _inTimeController,
// //                         ),
// //                     decoration: InputDecoration(
// //                       hintText: 'IN Time',
// //                       suffixIcon: Icon(Icons.lock_clock),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 16),
// //                   const Text("PUNCH OUT"),
// //                   TextFormField(
// //                     controller: _outTimeController,
// //                     readOnly: true,
// //                     onTap:
// //                         () =>
// //                         _selectTime(
// //                           context: context,
// //                           controller: _outTimeController,
// //                         ),
// //                     decoration: InputDecoration(
// //                       hintText: 'Select Time',
// //                       suffixIcon: Icon(Icons.access_time),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 16),
// //                   const Text("LUNCH IN"),
// //                   TextFormField(
// //                     controller: _lunchInTimeController,
// //                     readOnly: true,
// //                     onTap:
// //                         () =>
// //                         _selectTime(
// //                           context: context,
// //                           controller: _lunchInTimeController,
// //                         ),
// //                     decoration: InputDecoration(
// //                       hintText: 'Select Time',
// //                       suffixIcon: Icon(Icons.access_time),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 16),
// //                   const Text("LUNCH OUT"),
// //                   TextFormField(
// //                     controller: _lunchOutTimeController,
// //                     readOnly: true,
// //                     onTap:
// //                         () =>
// //                         _selectTime(
// //                           context: context,
// //                           controller: _lunchOutTimeController,
// //                         ),
// //                     decoration: InputDecoration(
// //                       hintText: 'Select Time',
// //                       suffixIcon: Icon(Icons.access_time),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 16),
// //                   const Text("YOU ARE AWAY FROM OFFICE"),
// //                   TextFormField(
// //                     initialValue: awayFromOffice,
// //                     readOnly: true,
// //                     decoration: InputDecoration(
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   const Text("LOCATION (IN) *"),
// //                   _currentPosition == null
// //                       ? Text("Location not available")
// //                       : Text(
// //                     '${_currentPosition!.latitude}, ${_currentPosition!
// //                         .longitude}',
// //                   ),
// //                   Container(
// //                     height: 200,
// //                     decoration: BoxDecoration(border: Border.all()),
// //                     child: _buildGoogleMap(),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                     children: [_buildButtons(), _buildFetchCurrentLocation()],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LeaveRecordsTable extends StatefulWidget {
//   final int empId;
//   final String name;
//
//   const LeaveRecordsTable({super.key, required this.empId, required this.name});
//
//   @override
//   State<LeaveRecordsTable> createState() => _LeaveRecordsTableState();
// }
//
// class _LeaveRecordsTableState extends State<LeaveRecordsTable> {
//   List<Map<String, dynamic>> leaveData = [];
//   bool isLoading = true;
//   bool hasError = false;
//   bool hasShownPopup = false;
//
//   int? selectedMonth;
//   int? selectedYear;
//
//   bool showStatusPopup = false;
//   String? statusMessage;
//   Color? statusColor;
//
//   Set<String> seenLeaveIds = {};
//
//   @override
//   void initState() {
//     super.initState();
//     fetchLeaveData();
//   }
//
//   Future<void> fetchLeaveData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       seenLeaveIds = prefs.getStringList('seenLeaveIds')?.toSet() ?? {};
//
//       final response = await http.get(
//         Uri.parse('https://api.managifyhr.com/api/leaveform/${widget.empId}/${widget.name}'),
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         List<Map<String, dynamic>> allLeaves = List<Map<String, dynamic>>.from(jsonData);
//
//         if (allLeaves.isNotEmpty) {
//           allLeaves.sort((a, b) {
//             final dateA = DateFormat('yyyy-MM-dd').parse(a['fromDate']);
//             final dateB = DateFormat('yyyy-MM-dd').parse(b['fromDate']);
//             return dateB.compareTo(dateA);
//           });
//
//           DateTime latest = DateFormat('yyyy-MM-dd').parse(allLeaves.first['fromDate']);
//           selectedMonth = latest.month;
//           selectedYear = latest.year;
//         }
//
//         // Show popup for new approved/rejected leave (not previously shown)
//         for (var leave in allLeaves) {
//           final status = leave['status'];
//           final leaveId = leave['id'].toString(); // assumes each leave has unique 'id'
//
//           if ((status == 'Approved' || status == 'Rejected') && !seenLeaveIds.contains(leaveId)) {
//             showStatusPopup = true;
//             statusMessage = status;
//             statusColor = status == 'Approved' ? Colors.green : Colors.red;
//
//             seenLeaveIds.add(leaveId);
//             await prefs.setStringList('seenLeaveIds', seenLeaveIds.toList());
//             break;
//           }
//         }
//
//         setState(() {
//           leaveData = allLeaves;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           hasError = true;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//     }
//   }
//
//   List<Map<String, dynamic>> get filteredLeaveData {
//     if (selectedMonth == null || selectedYear == null) {
//       return leaveData;
//     }
//     return leaveData.where((leave) {
//       try {
//         final fromDate = DateFormat('yyyy-MM-dd').parse(leave['fromDate']);
//         return fromDate.month == selectedMonth && fromDate.year == selectedYear;
//       } catch (_) {
//         return false;
//       }
//     }).toList();
//   }
//
//   Future<void> _selectMonth(BuildContext context) async {
//     final monthNames = List.generate(12, (i) => DateFormat.MMMM().format(DateTime(0, i + 1)));
//     int? pickedMonth = selectedMonth ?? DateTime.now().month;
//     int? pickedYear = selectedYear ?? DateTime.now().year;
//
//     await showDialog(
//       context: context,
//       builder: (context) {
//         int tempMonth = pickedMonth!;
//         int tempYear = pickedYear!;
//
//         return AlertDialog(
//           title: const Text('Select Month'),
//           content: SizedBox(
//             height: 150,
//             child: Column(
//               children: [
//                 DropdownButton<int>(
//                   value: tempMonth,
//                   items: List.generate(12, (index) {
//                     return DropdownMenuItem(
//                       value: index + 1,
//                       child: Text(monthNames[index]),
//                     );
//                   }),
//                   onChanged: (val) {
//                     if (val != null) {
//                       setState(() => tempMonth = val);
//                     }
//                   },
//                 ),
//                 Row(
//                   children: [
//                     const Text('Year: '),
//                     Expanded(
//                       child: TextFormField(
//                         initialValue: tempYear.toString(),
//                         keyboardType: TextInputType.number,
//                         onChanged: (val) {
//                           final y = int.tryParse(val);
//                           if (y != null) {
//                             tempYear = y;
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 pickedMonth = tempMonth;
//                 pickedYear = tempYear;
//                 Navigator.pop(context);
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (pickedMonth != null && pickedYear != null) {
//       setState(() {
//         selectedMonth = pickedMonth;
//         selectedYear = pickedYear;
//       });
//     }
//   }
//
//   String getFilterLabel() {
//     if (selectedMonth == null || selectedYear == null) return 'All';
//     return '${DateFormat.MMMM().format(DateTime(0, selectedMonth!))} $selectedYear';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (showStatusPopup && statusMessage != null && !hasShownPopup) {
//       hasShownPopup = true; // Mark as shown
//       Future.microtask(() {
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: Text(
//               'Leave Status',
//               style: TextStyle(color: statusColor),
//             ),
//             content: Text('Your leave has been $statusMessage.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   setState(() {
//                     showStatusPopup = false;
//                   });
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       });
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leave Records', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue.shade700,
//         centerTitle: true,
//         actions: [
//           TextButton.icon(
//             style: TextButton.styleFrom(foregroundColor: Colors.white),
//             onPressed: () => _selectMonth(context),
//             icon: const Icon(Icons.filter_list),
//             label: Text(getFilterLabel()),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : hasError
//           ? const Center(child: Text('Error loading leave records'))
//           : filteredLeaveData.isEmpty
//           ? Center(child: Text('No leave records for ${getFilterLabel()}'))
//           : SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           child: DataTable(
//             columns: const [
//               DataColumn(label: Text('From Date')),
//               DataColumn(label: Text('To Date')),
//               DataColumn(label: Text('Reason')),
//               DataColumn(label: Text('Status')),
//             ],
//             rows: filteredLeaveData.map((leave) {
//               final status = leave['status'] ?? '';
//               final statusColor = status == 'Approved'
//                   ? Colors.green
//                   : status == 'Rejected'
//                   ? Colors.red
//                   : Colors.black;
//
//               return DataRow(
//                 cells: [
//                   DataCell(Text(leave['fromDate'] ?? '')),
//                   DataCell(Text(leave['toDate'] ?? '')),
//                   DataCell(Text(leave['reason'] ?? '')),
//                   DataCell(
//                     Text(
//                       status,
//                       style: TextStyle(color: statusColor),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }



// problem in code

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:hrm_dump_flutter/screens/dashbord/dashboard_screen.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
//
// class LeaveRecordsTable extends StatefulWidget {
//   final bool showPopup; // Flag to control popup display
//
//   const LeaveRecordsTable({
//     super.key,
//     this.showPopup = true,
//   });
//
//   @override
//   State<LeaveRecordsTable> createState() => _LeaveRecordsTableState();
// }
//
// class _LeaveRecordsTableState extends State<LeaveRecordsTable> {
//   List<Map<String, dynamic>> leaveData = [];
//   bool isLoading = true;
//   bool hasError = false;
//   bool hasShownPopup = false;
//
//   int? selectedMonth;
//   int? selectedYear;
//
//   bool showStatusPopup = false;
//   String? statusMessage;
//   Color? statusColor;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Set popup state based on incoming flag
//     hasShownPopup = !widget.showPopup;
//     showStatusPopup = false;
//     statusMessage = null;
//     statusColor = null;
//
//     fetchLeaveData();
//   }
//
//   Future<void> fetchLeaveData() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://api.managifyhr.com/api/leaveform/$subadminId/$employeeFullName'),
//       );
//
//
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = json.decode(response.body);
//         List<Map<String, dynamic>> allLeaves = List<Map<String, dynamic>>.from(jsonData);
//
//         if (allLeaves.isNotEmpty) {
//           allLeaves.sort((a, b) {
//             final dateA = DateFormat('yyyy-MM-dd').parse(a['fromDate']);
//             final dateB = DateFormat('yyyy-MM-dd').parse(b['fromDate']);
//             return dateB.compareTo(dateA);
//           });
//
//           DateTime latest = DateFormat('yyyy-MM-dd').parse(allLeaves.first['fromDate']);
//           selectedMonth = latest.month;
//           selectedYear = latest.year;
//         }
//
//         final latestNonPendingLeave = allLeaves.firstWhere(
//               (leave) => leave['status'] != null && leave['status'] != 'Pending',
//           orElse: () => {},
//         );
//
//         if (latestNonPendingLeave.isNotEmpty) {
//           final status = latestNonPendingLeave['status'];
//           if (status == 'Approved' || status == 'Rejected') {
//             showStatusPopup = true;
//             statusMessage = status;
//             statusColor = status == 'Approved' ? Colors.green : Colors.red;
//           }
//         }
//
//         setState(() {
//           leaveData = allLeaves;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           hasError = true;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//     }
//   }
//
//   List<Map<String, dynamic>> get filteredLeaveData {
//     if (selectedMonth == null || selectedYear == null) {
//       return leaveData;
//     }
//     return leaveData.where((leave) {
//       try {
//         final fromDate = DateFormat('yyyy-MM-dd').parse(leave['fromDate']);
//         return (fromDate.month == selectedMonth && fromDate.year == selectedYear);
//       } catch (_) {
//         return false;
//       }
//     }).toList();
//   }
//
//   Future<void> _selectMonth(BuildContext context) async {
//     final monthNames = List.generate(12, (i) => DateFormat.MMMM().format(DateTime(0, i + 1)));
//     int? pickedMonth = selectedMonth ?? DateTime.now().month;
//     int? pickedYear = selectedYear ?? DateTime.now().year;
//
//     await showDialog(
//       context: context,
//       builder: (context) {
//         int tempMonth = pickedMonth!;
//         int tempYear = pickedYear!;
//
//         return AlertDialog(
//           title: const Text('Select Month'),
//           content: SizedBox(
//             height: 150,
//             child: Column(
//               children: [
//                 DropdownButton<int>(
//                   value: tempMonth,
//                   items: List.generate(12, (index) {
//                     return DropdownMenuItem(
//                       value: index + 1,
//                       child: Text(monthNames[index]),
//                     );
//                   }),
//                   onChanged: (val) {
//                     if (val != null) {
//                       setState(() => tempMonth = val);
//                     }
//                   },
//                 ),
//                 Row(
//                   children: [
//                     const Text('Year: '),
//                     Expanded(
//                       child: TextFormField(
//                         initialValue: tempYear.toString(),
//                         keyboardType: TextInputType.number,
//                         onChanged: (val) {
//                           final y = int.tryParse(val);
//                           if (y != null) {
//                             tempYear = y;
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 pickedMonth = tempMonth;
//                 pickedYear = tempYear;
//                 Navigator.pop(context);
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (pickedMonth != null && pickedYear != null) {
//       setState(() {
//         selectedMonth = pickedMonth;
//         selectedYear = pickedYear;
//       });
//     }
//   }
//
//   String getFilterLabel() {
//     if (selectedMonth == null || selectedYear == null) return 'All';
//     return '${DateFormat.MMMM().format(DateTime(0, selectedMonth!))} $selectedYear';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (showStatusPopup && statusMessage != null && !hasShownPopup) {
//       hasShownPopup = true;
//       Future.microtask(() {
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: Text('Leave Status', style: TextStyle(color: statusColor)),
//             content: Text('Your leave has been $statusMessage.'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   setState(() {
//                     showStatusPopup = false;
//                   });
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       });
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Leave Records', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue.shade700,
//         centerTitle: true,
//         actions: [
//           TextButton.icon(
//             style: TextButton.styleFrom(foregroundColor: Colors.white),
//             onPressed: () => _selectMonth(context),
//             icon: const Icon(Icons.filter_list),
//             label: Text(getFilterLabel()),
//           ),
//         ],
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>DashboardScreen(email: '')));
//           },
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : hasError
//           ? const Center(child: Text('Error loading leave records'))
//           : filteredLeaveData.isEmpty
//           ? Center(child: Text('No leave records for ${getFilterLabel()}'))
//           : SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           child: DataTable(
//             columns: const [
//               DataColumn(label: Text('From Date')),
//               DataColumn(label: Text('To Date')),
//               DataColumn(label: Text('Reason')),
//               DataColumn(label: Text('Status')),
//             ],
//             rows: filteredLeaveData.map((leave) {
//               final status = leave['status'] ?? '';
//               final statusColor = status == 'Approved'
//                   ? Colors.green
//                   : status == 'Rejected'
//                   ? Colors.red
//                   : Colors.black;
//
//               return DataRow(
//                 cells: [
//                   DataCell(Text(leave['fromDate'] ?? '')),
//                   DataCell(Text(leave['toDate'] ?? '')),
//                   DataCell(Text(leave['reason'] ?? '')),
//                   DataCell(Text(status, style: TextStyle(color: statusColor))),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class WorkFieldAttendance extends StatefulWidget {
//   const WorkFieldAttendance({super.key});
//
//   @override
//   State<WorkFieldAttendance> createState() => _WorkFieldAttendanceState();
// }
//
// class _WorkFieldAttendanceState extends State<WorkFieldAttendance> {
//   final _formKey = GlobalKey<FormState>();
//   final Completer<GoogleMapController> _controller = Completer();
//
//   int subadminId = 0;
//   String employeeFullName = '';
//   String jobRole = '';
//   String empimg = '';
//   bool _isSubmitting = false;
//   final Set<Polyline> _polylines = {};
//
//   final TextEditingController _workLocationController = TextEditingController();
//   final TextEditingController _distanceController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   final TextEditingController _inTimeController = TextEditingController();
//   final TextEditingController _outTimeController = TextEditingController();
//   final TextEditingController _lunchInTimeController = TextEditingController();
//   final TextEditingController _lunchOutTimeController = TextEditingController();
//
//   DateTime? selectedDate;
//   String workLocation = '';
//   String awayFromOffice = '';
//   Position? _currentPosition;
//
//   static const LatLng companyLocation = LatLng(
//     18.561310,
//     73.944481,
//   ); //18.561310, 73.944481
//   static const CameraPosition _kGoogleplex = CameraPosition(
//     target: companyLocation,
//     zoom: 14,
//   );
//
//   final List<Marker> _markers = <Marker>[
//     Marker(
//       markerId: MarkerId('1'),
//       position: companyLocation,
//       infoWindow: InfoWindow(title: 'WTL Tourism'),
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final now = TimeOfDay.now();
//     _inTimeController.text = _formatTimeOfDay24(now);
//   }
//
//   String _formatTimeOfDay24(TimeOfDay time) {
//     final String hour = time.hour.toString().padLeft(2, '0');
//     final String minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }
//
//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       subadminId = prefs.getInt('subadminId') ?? 0;
//       employeeFullName = prefs.getString('fullName') ?? '';
//       jobRole = prefs.getString('jobRole') ?? '';
//       empimg = prefs.getString('empimg') ?? '';
//     });
//   }
//
//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//         _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }
//
//   Future<void> _selectTime({
//     required BuildContext context,
//     required TextEditingController controller,
//   }) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (BuildContext context, Widget? child) {
//         // Force 24-hour format in UI
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       // Manually format to 24-hour string (no AM/PM)
//       final String formattedTime =
//           '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
//       controller.text = formattedTime;
//     }
//   }
//
//   Future<void> _submitAttendance() async {
//     if (_currentPosition == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Current location not available')));
//       return;
//     }
//
//     final String postUrl =
//         'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/add/bulk';
//     final String putUrl =
//         'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/update/bulk';
//
//     // Clean attendance payload
//     final attendancePayload = {
//       "date": _dateController.text.trim(),
//       "status": "Present in Work Field",
//       "reason": "",
//       "punchInTime":
//       _inTimeController.text.trim().isEmpty
//           ? null
//           : _inTimeController.text.trim(),
//       "punchOutTime":
//       _outTimeController.text.trim().isEmpty
//           ? null
//           : _outTimeController.text.trim(),
//       "lunchInTime":
//       _lunchInTimeController.text.trim().isEmpty
//           ? null
//           : _lunchInTimeController.text.trim(),
//       "lunchOutTime":
//       _lunchOutTimeController.text.trim().isEmpty
//           ? null
//           : _lunchOutTimeController.text.trim(),
//       // "workingLocation":
//       //     _distanceController.text.trim().isEmpty
//       //         ? null
//       //         : _distanceController.text.trim(),
//     };
//
//     try {
//       // 1. Submit ADD (POST)
//       final postResponse = await http.post(
//         Uri.parse(postUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode([attendancePayload]),
//       );
//
//       if (postResponse.statusCode == 200) {
//         print("POST success: ${postResponse.body}");
//
//         // 2. Only send PUT if OutTime is provided (simulate a manual update)
//         if (_outTimeController.text.trim().isNotEmpty) {
//           final updatePayload = {
//             ...attendancePayload,
//             "date": _dateController.text.trim(),
//             "status": "Present in Work Field",
//             "reason": "",
//             "punchInTime":
//             _inTimeController.text.trim().isEmpty
//                 ? null
//                 : _inTimeController.text.trim(),
//             "punchOutTime":
//             _outTimeController.text.trim().isEmpty
//                 ? null
//                 : _outTimeController.text.trim(),
//             "lunchInTime":
//             _lunchInTimeController.text.trim().isEmpty
//                 ? null
//                 : _lunchInTimeController.text.trim(),
//             "lunchOutTime":
//             _lunchOutTimeController.text.trim().isEmpty
//                 ? null
//                 : _lunchOutTimeController.text.trim(),
//             // "workingLocation":
//             //     _distanceController.text.trim().isEmpty
//             //         ? null
//             //         : _distanceController.text.trim(),
//           };
//
//           final putResponse = await http.put(
//             Uri.parse(putUrl),
//             headers: {"Content-Type": "application/json"},
//             body: jsonEncode([updatePayload]),
//           );
//
//           if (putResponse.statusCode == 200) {
//             print("PUT success: ${putResponse.body}");
//           } else {
//             print("PUT error: ${putResponse.body}");
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Update failed: ${putResponse.statusCode}'),
//               ),
//             );
//           }
//         }
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Attendance submitted successfully')),
//         );
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(builder: (_) => AttendancesRecordsScreen()),
//         // );
//       } else {
//         print("POST error: ${postResponse.body}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Add Failed: ${postResponse.statusCode}')),
//         );
//       }
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }
//
//   Widget _buildButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         MaterialButton(
//           minWidth: 140,
//           height: 45,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: BorderSide(color: Colors.black),
//           ),
//           onPressed: () => Navigator.pop(context),
//           child: Text("Cancel", style: TextStyle(color: Colors.red)),
//         ),
//         SizedBox(width: 30),
//         MaterialButton(
//           minWidth: 140,
//           height: 45,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: BorderSide(color: Colors.black),
//           ),
//           onPressed: () async {
//             if (_isSubmitting) return;
//
//             if (_formKey.currentState!.validate()) {
//               setState(() => _isSubmitting = true);
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (_) => Center(child: CircularProgressIndicator()),
//               );
//
//               try {
//                 // Location permissions
//                 bool serviceEnabled =
//                 await Geolocator.isLocationServiceEnabled();
//                 if (!serviceEnabled) throw 'Location services are disabled';
//
//                 LocationPermission permission =
//                 await Geolocator.checkPermission();
//                 if (permission == LocationPermission.denied) {
//                   permission = await Geolocator.requestPermission();
//                   if (permission == LocationPermission.denied) {
//                     throw 'Permission denied';
//                   }
//                 }
//                 if (permission == LocationPermission.deniedForever) {
//                   throw 'Permission permanently denied';
//                 }
//
//                 // Get current location
//                 Position position = await Geolocator.getCurrentPosition(
//                   desiredAccuracy: LocationAccuracy.high,
//                 );
//
//                 LatLng userLatLng = LatLng(
//                   position.latitude,
//                   position.longitude,
//                 );
//
//                 // 🔁 Reverse geocoding
//                 List<Placemark> placemarks = await placemarkFromCoordinates(
//                   position.latitude,
//                   position.longitude,
//                 );
//
//                 String locationName =
//                 placemarks.isNotEmpty
//                     ? '${placemarks.first.name}, ${placemarks.first.locality}'
//                     : 'Unknown Location';
//
//                 // Update UI
//                 setState(() {
//                   _currentPosition = position;
//                   workLocation = locationName;
//                   _workLocationController.text = workLocation!;
//                 });
//
//                 // Animate camera
//                 final GoogleMapController controller = await _controller.future;
//                 await controller.animateCamera(
//                   CameraUpdate.newCameraPosition(
//                     CameraPosition(target: userLatLng, zoom: 16),
//                   ),
//                 );
//
//                 // Add marker
//                 _markers.removeWhere(
//                       (marker) => marker.markerId.value == 'current',
//                 );
//                 _markers.add(
//                   Marker(
//                     markerId: MarkerId('current'),
//                     position: userLatLng,
//                     infoWindow: InfoWindow(title: locationName),
//                     icon: BitmapDescriptor.defaultMarkerWithHue(
//                       BitmapDescriptor.hueAzure,
//                     ),
//                   ),
//                 );
//
//                 // Add polyline to office
//                 _polylines.clear();
//                 _polylines.add(
//                   Polyline(
//                     polylineId: PolylineId("route"),
//                     points: [userLatLng, companyLocation],
//                     color: Colors.blue,
//                     width: 5,
//                   ),
//                 );
//
//                 Navigator.of(context).pop(); // Close loader
//
//                 // ✅ Submit attendance (no distance check)
//                 await _submitAttendance();
//               } catch (e) {
//                 Navigator.of(context).pop(); // Close loader
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(SnackBar(content: Text(e.toString())));
//               } finally {
//                 setState(() => _isSubmitting = false);
//               }
//             }
//           },
//           child: Text("Save", style: TextStyle(color: Colors.green)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildGoogleMap() {
//     return GoogleMap(
//       initialCameraPosition: _kGoogleplex,
//       markers: Set<Marker>.of(_markers),
//       polylines: _polylines,
//       onMapCreated: (GoogleMapController controller) {
//         _controller.complete(controller);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Work Field')),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.grey.shade200,
//                         backgroundImage:
//                         (empimg != null && empimg.startsWith('https'))
//                             ? NetworkImage(empimg)
//                             : null,
//                         child:
//                         (empimg == null || !empimg.startsWith('https'))
//                             ? const Icon(
//                           Icons.person,
//                           size: 40,
//                           color: Colors.black,
//                         )
//                             : null,
//                       ),
//                       SizedBox(width: 20),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             employeeFullName,
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           Text(jobRole, style: TextStyle(fontSize: 15)),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Divider(),
//                   const Text("DATE"),
//                   TextFormField(
//                     controller: _dateController,
//                     readOnly: true,
//                     onTap: _selectDate,
//                     decoration: InputDecoration(
//                       hintText: 'Select Date',
//                       suffixIcon: Icon(Icons.calendar_today),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     validator:
//                         (value) =>
//                     value == null || value.isEmpty
//                         ? 'Please select a date'
//                         : null,
//                   ),
//                   SizedBox(height: 16),
//                   const Text("PUNCH IN"),
//                   TextFormField(
//                     controller: _inTimeController,
//                     enabled: true,
//                     onTap:
//                         () => _selectTime(
//                       context: context,
//                       controller: _inTimeController,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'IN Time',
//                       suffixIcon: Icon(Icons.lock_clock),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   const Text("LUNCH OUT"),
//                   TextFormField(
//                     controller: _lunchOutTimeController,
//                     readOnly: true,
//                     onTap:
//                         () => _selectTime(
//                       context: context,
//                       controller: _lunchOutTimeController,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Select Time',
//                       suffixIcon: Icon(Icons.access_time),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   const Text("LUNCH IN"),
//                   TextFormField(
//                     controller: _lunchInTimeController,
//                     readOnly: true,
//                     onTap:
//                         () => _selectTime(
//                       context: context,
//                       controller: _lunchInTimeController,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Select Time',
//                       suffixIcon: Icon(Icons.access_time),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   const Text("PUNCH OUT"),
//                   TextFormField(
//                     controller: _outTimeController,
//                     readOnly: true,
//                     onTap:
//                         () => _selectTime(
//                       context: context,
//                       controller: _outTimeController,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Select Time',
//                       suffixIcon: Icon(Icons.access_time),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   const Text("Away From Office"),
//                   TextFormField(
//                     controller: _distanceController,
//                     readOnly: true,
//                     decoration: InputDecoration(
//                         border: OutlineInputBorder()
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   const Text("Working Location"),
//                   TextFormField(
//                     controller: _workLocationController,
//                     readOnly: true,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text("LOCATION (IN) *"),
//                   _currentPosition == null
//                       ? Text("Location not available")
//                       : Text(
//                     '${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
//                   ),
//                   Container(
//                     height: 200,
//                     decoration: BoxDecoration(border: Border.all()),
//                     child: _buildGoogleMap(),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [_buildButtons()],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }















/*
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkFieldAttendance extends StatefulWidget {
  const WorkFieldAttendance({super.key});

  @override
  State<WorkFieldAttendance> createState() => _WorkFieldAttendanceState();
}

class _WorkFieldAttendanceState extends State<WorkFieldAttendance> {
  final _formKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _controller = Completer();

  int subadminId = 0;
  String employeeFullName = '';
  String jobRole = '';
  String empimg = '';
  bool _isSubmitting = false;
  final Set<Polyline> _polylines = {};

  final TextEditingController _workLocationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _inTimeController = TextEditingController();
  final TextEditingController _outTimeController = TextEditingController();
  final TextEditingController _lunchInTimeController = TextEditingController();
  final TextEditingController _lunchOutTimeController = TextEditingController();

  DateTime? selectedDate;
  String workLocation = '';
  String awayFromOffice = '';
  Position? _currentPosition;

  static const LatLng companyLocation = LatLng(
    18.561310,
    73.944481,
  ); //18.561310, 73.944481
  static const CameraPosition _kGoogleplex = CameraPosition(
    target: companyLocation,
    zoom: 14,
  );

  final List<Marker> _markers = <Marker>[
    Marker(
      markerId: MarkerId('1'),
      position: companyLocation,
      infoWindow: InfoWindow(title: 'WTL Tourism'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final now = TimeOfDay.now();
    _inTimeController.text = _formatTimeOfDay24(now);
  }

  String _formatTimeOfDay24(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subadminId = prefs.getInt('subadminId') ?? 0;
      employeeFullName = prefs.getString('fullName') ?? '';
      jobRole = prefs.getString('jobRole') ?? '';
      empimg = prefs.getString('empimg') ?? '';
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        // Force 24-hour format in UI
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Manually format to 24-hour string (no AM/PM)
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Current location not available')));
      return;
    }

    final String postUrl =
        'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/add/bulk';
    final String putUrl =
        'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/update/bulk';

    // Clean attendance payload
    final attendancePayload = {
      "date": _dateController.text.trim(),
      "status": "Present in Work Field",
      "reason": "",
      "punchInTime":
          _inTimeController.text.trim().isEmpty
              ? null
              : _inTimeController.text.trim(),
      "punchOutTime":
          _outTimeController.text.trim().isEmpty
              ? null
              : _outTimeController.text.trim(),
      "lunchInTime":
          _lunchInTimeController.text.trim().isEmpty
              ? null
              : _lunchInTimeController.text.trim(),
      "lunchOutTime":
          _lunchOutTimeController.text.trim().isEmpty
              ? null
              : _lunchOutTimeController.text.trim(),
      // "workingLocation":
      //     _distanceController.text.trim().isEmpty
      //         ? null
      //         : _distanceController.text.trim(),
    };

    try {
      // 1. Submit ADD (POST)
      final postResponse = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode([attendancePayload]),
      );

      if (postResponse.statusCode == 200) {
        print("POST success: ${postResponse.body}");

        // 2. Only send PUT if OutTime is provided (simulate a manual update)
        if (_outTimeController.text.trim().isNotEmpty) {
          final updatePayload = {
            ...attendancePayload,
            "date": _dateController.text.trim(),
            "status": "Present in Work Field",
            "reason": "",
            "punchInTime":
                _inTimeController.text.trim().isEmpty
                    ? null
                    : _inTimeController.text.trim(),
            "punchOutTime":
                _outTimeController.text.trim().isEmpty
                    ? null
                    : _outTimeController.text.trim(),
            "lunchInTime":
                _lunchInTimeController.text.trim().isEmpty
                    ? null
                    : _lunchInTimeController.text.trim(),
            "lunchOutTime":
                _lunchOutTimeController.text.trim().isEmpty
                    ? null
                    : _lunchOutTimeController.text.trim(),
            // "workingLocation":
            //     _distanceController.text.trim().isEmpty
            //         ? null
            //         : _distanceController.text.trim(),
          };

          final putResponse = await http.put(
            Uri.parse(putUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode([updatePayload]),
          );

          if (putResponse.statusCode == 200) {
            print("PUT success: ${putResponse.body}");
          } else {
            print("PUT error: ${putResponse.body}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Update failed: ${putResponse.statusCode}'),
              ),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance submitted successfully')),
        );
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => AttendancesRecordsScreen()),
        // );
      } else {
        print("POST error: ${postResponse.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add Failed: ${postResponse.statusCode}')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
          minWidth: 140,
          height: 45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        SizedBox(width: 30),
        MaterialButton(
          minWidth: 140,
          height: 45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.black),
          ),
          onPressed: () async {
            if (_isSubmitting) return;

            if (_formKey.currentState!.validate()) {
              setState(() => _isSubmitting = true);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(child: CircularProgressIndicator()),
              );

              try {
                // Location permissions
                bool serviceEnabled =
                    await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) throw 'Location services are disabled';

                LocationPermission permission =
                    await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) {
                    throw 'Permission denied';
                  }
                }
                if (permission == LocationPermission.deniedForever) {
                  throw 'Permission permanently denied';
                }

                // Get current location
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );

                LatLng userLatLng = LatLng(
                  position.latitude,
                  position.longitude,
                );

                // 🔁 Reverse geocoding
                List<Placemark> placemarks = await placemarkFromCoordinates(
                  position.latitude,
                  position.longitude,
                );

                String locationName =
                    placemarks.isNotEmpty
                        ? '${placemarks.first.name}, ${placemarks.first.locality}'
                        : 'Unknown Location';

                LatLng userLatLag = LatLng(
                  position.latitude,
                  position.longitude,
                );
                double distance = Geolocator.distanceBetween(
                  userLatLag.latitude,
                  userLatLag.longitude,
                  companyLocation.latitude,
                  companyLocation.longitude,
                );
                // Update UI
                setState(() {
                  _currentPosition = position;
                  workLocation = locationName;
                  _workLocationController.text = workLocation!;
                  awayFromOffice = '${distance.toStringAsFixed(2)}M';
                  _distanceController.text = awayFromOffice!;
                });

                // Animate camera
                final GoogleMapController controller = await _controller.future;
                await controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: userLatLng, zoom: 16),
                  ),
                );

                // Add marker
                _markers.removeWhere(
                  (marker) => marker.markerId.value == 'current',
                );
                _markers.add(
                  Marker(
                    markerId: MarkerId('current'),
                    position: userLatLng,
                    infoWindow: InfoWindow(title: locationName),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                  ),
                );

                // Add polyline to office
                _polylines.clear();
                _polylines.add(
                  Polyline(
                    polylineId: PolylineId("route"),
                    points: [userLatLng, companyLocation],
                    color: Colors.blue,
                    width: 5,
                  ),
                );

                Navigator.of(context).pop(); // Close loader

                // ✅ Submit attendance (no distance check)
                await _submitAttendance();
              } catch (e) {
                Navigator.of(context).pop(); // Close loader
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              } finally {
                setState(() => _isSubmitting = false);
              }
            }
          },
          child: Text("Save", style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _kGoogleplex,
      markers: Set<Marker>.of(_markers),
      polylines: _polylines,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Work Field')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            (empimg != null && empimg.startsWith('https'))
                                ? NetworkImage(empimg)
                                : null,
                        child:
                            (empimg == null || !empimg.startsWith('https'))
                                ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.black,
                                )
                                : null,
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employeeFullName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(jobRole, style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  const Text("DATE"),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      hintText: 'Select Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please select a date'
                                : null,
                  ),
                  SizedBox(height: 16),
                  const Text("PUNCH IN"),
                  TextFormField(
                    controller: _inTimeController,
                    enabled: true,
                    onTap:
                        () => _selectTime(
                          context: context,
                          controller: _inTimeController,
                        ),
                    decoration: InputDecoration(
                      hintText: 'IN Time',
                      suffixIcon: Icon(Icons.lock_clock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("LUNCH OUT"),
                  TextFormField(
                    controller: _lunchOutTimeController,
                    readOnly: true,
                    onTap:
                        () => _selectTime(
                          context: context,
                          controller: _lunchOutTimeController,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("LUNCH IN"),
                  TextFormField(
                    controller: _lunchInTimeController,
                    readOnly: true,
                    onTap:
                        () => _selectTime(
                          context: context,
                          controller: _lunchInTimeController,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("PUNCH OUT"),
                  TextFormField(
                    controller: _outTimeController,
                    readOnly: true,
                    onTap:
                        () => _selectTime(
                          context: context,
                          controller: _outTimeController,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("Away From Office"),
                  TextFormField(
                    controller: _distanceController,
                    readOnly: true,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  const Text("Working Location"),
                  TextFormField(
                    controller: _workLocationController,
                    readOnly: true,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text("LOCATION (IN) *"),
                  _currentPosition == null
                      ? Text("Location not available")
                      : Text(
                        '${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                      ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(border: Border.all()),
                    child: _buildGoogleMap(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [_buildButtons()],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

 */




// latest attendance form

/*
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
import 'package:hrm_dump_flutter/services/location_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkFieldAttendance extends StatefulWidget {
  const WorkFieldAttendance({super.key});
  static const LatLng companyLocation = LatLng(18.561092, 73.944486);

  @override
  State<WorkFieldAttendance> createState() => _WorkFieldAttendanceState();
}

class _WorkFieldAttendanceState extends State<WorkFieldAttendance> {
  final _formKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _controller = Completer();

  int subadminId = 0;
  int empId = 0;
  String employeeFullName = '';
  String jobRole = '';
  String empimg = '';
  bool _isSubmitting = false;
  bool _isLocationTrackingActive = false;
  final Set<Polyline> _polylines = {};

  final TextEditingController _workLocationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _inTimeController = TextEditingController();
  final TextEditingController _outTimeController = TextEditingController();
  final TextEditingController _lunchInTimeController = TextEditingController();
  final TextEditingController _lunchOutTimeController = TextEditingController();

  DateTime? selectedDate;
  String workLocation = '';
  String awayFromOffice = '';
  Position? _currentPosition;
  late StreamSubscription<Position> _positionSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeLocationTracking();

    // Subscribe to location stream
    _positionSubscription =
        LocationService.instance.positionStream.listen((position) {
          setState(() {
            _currentPosition = position;
            _updateLocationFields(position);
          });
        });
  }

  Future<void> _initializeLocationTracking() async {
    try {
      // Ensure location tracking is active when this screen is opened
      if (!LocationService.instance.isTracking) {
        await LocationService.instance.startLocationTracking();
      }

      setState(() {
        _isLocationTrackingActive = LocationService.instance.isTracking;
      });

      print('Location tracking status: $_isLocationTrackingActive');
    } catch (e) {
      print('Error initializing location tracking: $e');
    }
  }

  Future<void> _updateLocationFields(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String locationName = placemarks.isNotEmpty
          ? '${placemarks.first.name}, ${placemarks.first.locality}'
          : 'Unknown Location';

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        WorkFieldAttendance.companyLocation.latitude,
        WorkFieldAttendance.companyLocation.longitude,
      );

      setState(() {
        _workLocationController.text = locationName;
        _distanceController.text = '${distance.toStringAsFixed(2)} M';
        _animateCameraToPosition(position);
        _updateMarkers(position, locationName);
      });
    } catch (e) {
      print("Reverse geocode failed: $e");
    }
  }

  Future<void> _animateCameraToPosition(Position position) async {
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        16,
      ),
    );
  }

  void _updateMarkers(Position position, String locationName) {
    _markers.removeWhere((marker) => marker.markerId.value == 'current');
    _markers.add(
      Marker(
        markerId: MarkerId('current'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: locationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: PolylineId("route"),
        points: [
          LatLng(position.latitude, position.longitude),
          WorkFieldAttendance.companyLocation,
        ],
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _workLocationController.dispose();
    _distanceController.dispose();
    _dateController.dispose();
    _inTimeController.dispose();
    _outTimeController.dispose();
    _lunchInTimeController.dispose();
    _lunchOutTimeController.dispose();
    super.dispose();
  }

  static const LatLng companyLocation = LatLng(18.561310, 73.944481);
  static const CameraPosition _kGoogleplex = CameraPosition(
    target: companyLocation,
    zoom: 14,
  );

  final List<Marker> _markers = <Marker>[
    Marker(
      markerId: MarkerId('1'),
      position: companyLocation,
      infoWindow: InfoWindow(title: 'WTL Tourism'),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final now = TimeOfDay.now();
    _inTimeController.text = _formatTimeOfDay24(now);
  }

  String _formatTimeOfDay24(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      subadminId = prefs.getInt('subadminId') ?? 0;
      empId = prefs.getInt('empId') ?? 0;
      employeeFullName = prefs.getString('fullName') ?? '';
      jobRole = prefs.getString('jobRole') ?? '';
      empimg = prefs.getString('empimg') ?? '';
    });

    // Update location service with user credentials
    if (subadminId > 0 && empId > 0) {
      LocationService.instance.updateUserCredentials(subadminId, empId);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime({
    required BuildContext context,
    required TextEditingController controller,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString()
          .padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location not available')),
      );
      return;
    }

    final String postUrl = 'http://192.168.1.36:8282/api/location/$subadminId/employee/$empId';
    final String putUrl = 'http://192.168.1.36:8282/api/location/$subadminId/employee/$empId';

    final attendancePayload = {
      "date": _dateController.text.trim(),
      "status": "Present in Work Field",
      "reason": "",
      "punchInTime": _inTimeController.text
          .trim()
          .isEmpty ? null : _inTimeController.text.trim(),
      "punchOutTime": _outTimeController.text
          .trim()
          .isEmpty ? null : _outTimeController.text.trim(),
      "lunchInTime": _lunchInTimeController.text
          .trim()
          .isEmpty ? null : _lunchInTimeController.text.trim(),
      "lunchOutTime": _lunchOutTimeController.text
          .trim()
          .isEmpty ? null : _lunchOutTimeController.text.trim(),
    };

    try {
      final postResponse = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode([attendancePayload]),
      );

      if (postResponse.statusCode == 200) {
        print("POST success: ${postResponse.body}");

        if (_outTimeController.text
            .trim()
            .isNotEmpty) {
          final updatePayload = {
            ...attendancePayload,
            "date": _dateController.text.trim(),
            "status": "Present in Work Field",
            "reason": "",
            "punchInTime": _inTimeController.text
                .trim()
                .isEmpty ? null : _inTimeController.text.trim(),
            "punchOutTime": _outTimeController.text
                .trim()
                .isEmpty ? null : _outTimeController.text.trim(),
            "lunchInTime": _lunchInTimeController.text
                .trim()
                .isEmpty ? null : _lunchInTimeController.text.trim(),
            "lunchOutTime": _lunchOutTimeController.text
                .trim()
                .isEmpty ? null : _lunchOutTimeController.text.trim(),
          };

          final putResponse = await http.put(
            Uri.parse(putUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode([updatePayload]),
          );

          if (putResponse.statusCode == 200) {
            print("PUT success: ${putResponse.body}");
          } else {
            print("PUT error: ${putResponse.body}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Update failed: ${putResponse.statusCode}')),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance submitted successfully')),
        );
      } else {
        print("POST error: ${postResponse.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add Failed: ${postResponse.statusCode}')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildLocationTrackingStatus() {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _isLocationTrackingActive ? Colors.green.shade100 : Colors.red
            .shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isLocationTrackingActive ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isLocationTrackingActive ? Icons.location_on : Icons.location_off,
            color: _isLocationTrackingActive ? Colors.green : Colors.red,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _isLocationTrackingActive
                  ? 'Location tracking active (updating every 10 seconds)'
                  : 'Location tracking inactive',
              style: TextStyle(
                color: _isLocationTrackingActive
                    ? Colors.green.shade800
                    : Colors.red.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!_isLocationTrackingActive)
            TextButton(
              onPressed: _initializeLocationTracking,
              child: Text('Restart'),
            ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
          minWidth: 140,
          height: 45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        SizedBox(width: 30),
        MaterialButton(
          minWidth: 140,
          height: 45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.black),
          ),
          onPressed: () async {
            if (_isSubmitting) return;

            if (_formKey.currentState!.validate()) {
              setState(() => _isSubmitting = true);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(child: CircularProgressIndicator()),
              );

              try {
                bool serviceEnabled = await Geolocator
                    .isLocationServiceEnabled();
                if (!serviceEnabled) throw 'Location services are disabled';

                LocationPermission permission = await Geolocator
                    .checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) {
                    throw 'Permission denied';
                  }
                }
                if (permission == LocationPermission.deniedForever) {
                  throw 'Permission permanently denied';
                }

                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );

                LatLng userLatLng = LatLng(
                    position.latitude, position.longitude);

                List<Placemark> placemarks = await placemarkFromCoordinates(
                  position.latitude,
                  position.longitude,
                );

                String locationName = placemarks.isNotEmpty
                    ? '${placemarks.first.name}, ${placemarks.first.locality}'
                    : 'Unknown Location';

                LatLng userLatLag = LatLng(
                    position.latitude, position.longitude);
                double distance = Geolocator.distanceBetween(
                  userLatLag.latitude,
                  userLatLag.longitude,
                  companyLocation.latitude,
                  companyLocation.longitude,
                );

                setState(() {
                  _currentPosition = position;
                  workLocation = locationName;
                  _workLocationController.text = workLocation;
                  awayFromOffice = '${distance.toStringAsFixed(2)}M';
                  _distanceController.text = awayFromOffice;
                });

                final GoogleMapController controller = await _controller.future;
                await controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: userLatLng, zoom: 16),
                  ),
                );

                _markers.removeWhere(
                      (marker) => marker.markerId.value == 'current',
                );
                _markers.add(
                  Marker(
                    markerId: MarkerId('current'),
                    position: userLatLng,
                    infoWindow: InfoWindow(title: locationName),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                  ),
                );

                _polylines.clear();
                _polylines.add(
                  Polyline(
                    polylineId: PolylineId("route"),
                    points: [userLatLng, companyLocation],
                    color: Colors.blue,
                    width: 5,
                  ),
                );

                Navigator.of(context).pop();
                await _submitAttendance();
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              } finally {
                setState(() => _isSubmitting = false);
              }
            }
          },
          child: Text("Save", style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _kGoogleplex,
      markers: Set<Marker>.of(_markers),
      polylines: _polylines,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Field'),
        actions: [
          IconButton(
            icon: Icon(_isLocationTrackingActive ? Icons.location_on : Icons
                .location_off),
            onPressed: _initializeLocationTracking,
            tooltip: 'Location Tracking Status',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location tracking status indicator
                  _buildLocationTrackingStatus(),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (empimg != null &&
                            empimg.startsWith('https'))
                            ? NetworkImage(empimg)
                            : null,
                        child: (empimg == null || !empimg.startsWith('https'))
                            ? const Icon(
                            Icons.person, size: 40, color: Colors.black)
                            : null,
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employeeFullName,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          Text(jobRole, style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  const Text("DATE"),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      hintText: 'Select Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Please select a date'
                        : null,
                  ),
                  SizedBox(height: 16),
                  const Text("PUNCH IN"),
                  TextFormField(
                    controller: _inTimeController,
                    enabled: true,
                    onTap: () => _selectTime(
                        context: context, controller: _inTimeController),
                    decoration: InputDecoration(
                      hintText: 'IN Time',
                      suffixIcon: Icon(Icons.lock_clock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("LUNCH OUT"),
                  TextFormField(
                    controller: _lunchOutTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(context: context,
                        controller: _lunchOutTimeController),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("LUNCH IN"),
                  TextFormField(
                    controller: _lunchInTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(context: context,
                        controller: _lunchInTimeController),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("PUNCH OUT"),
                  TextFormField(
                    controller: _outTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(
                        context: context, controller: _outTimeController),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("Away From Office"),
                  TextFormField(
                    controller: _distanceController,
                    readOnly: true,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  const Text("Working Location"),
                  TextFormField(
                    controller: _workLocationController,
                    readOnly: true,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text("LOCATION (IN) *"),
                  _currentPosition == null
                      ? Text("Location not available")
                      : Text('${_currentPosition!.latitude}, ${_currentPosition!
                      .longitude}'),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(border: Border.all()),
                    child: _buildGoogleMap(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [_buildButtons()],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 */