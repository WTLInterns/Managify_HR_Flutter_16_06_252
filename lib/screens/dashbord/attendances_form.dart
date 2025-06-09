import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
import 'package:hrm_dump_flutter/services/location_service.dart';
import 'package:hrm_dump_flutter/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceFormPage extends StatefulWidget {
  @override
  _AttendanceFormPageState createState() => _AttendanceFormPageState();
}

class _AttendanceFormPageState extends State<AttendanceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _controller = Completer();

  int count = 0;
  int leaves = 0;
  int subadminId = 0;
  String employeeFullName = '';
  String jobRole = '';
  String empimg = '';
  bool _isSubmitting = false;
  bool _isTimeSaved = false;
  final Set<Polyline> _polylines = {};

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _inTimeController = TextEditingController();
  final TextEditingController _outTimeController = TextEditingController();
  final TextEditingController _lunchInTimeController = TextEditingController();
  final TextEditingController _lunchOutTimeController = TextEditingController();
  final TextEditingController _workTypeController = TextEditingController();

  DateTime? selectedDate;
  String awayFromOffice = '';
  Position? _currentPosition;
  late StreamSubscription<Position> _positionSubscription;
  String workhome = 'Work From Home';
  String workField = 'Work From Field';

  // New variables for managing attendance state
  Map<String, dynamic> _savedAttendanceData = {};
  bool _hasInitialPunchIn = false;
  bool _hasLunchOut = false;
  bool _hasLunchIn = false;
  bool _hasPunchOut = false;
  String _currentAttendanceDate = '';

  // Work type options
  final List<String> _workTypeOptions = [
    'Work From Office',
    'Work From Home',
    'Work From Field',
  ];
  String? _selectedWorkType;

  static const LatLng companyLocation = LatLng(18.561092, 73.944486);

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
    _loadSavedAttendanceData();

    // Subscribe to location stream
    _positionSubscription = LocationService.instance.positionStream.listen((
      position,
    ) {
      setState(() {
        _currentPosition = position;
        _updateLocationFields(position);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Don't auto-fill if we have saved attendance data for today
    if (!_hasInitialPunchIn) {
      final now = TimeOfDay.now();
      _inTimeController.text = _formatTimeOfDay24(now);
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      selectedDate = DateTime.now();
    }
  }

  String _formatTimeOfDay24(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasAbsolutePath &&
        (uri.isScheme('http') || uri.isScheme('https'));
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

  Future<void> _loadSavedAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedDataJson = prefs.getString(
      'attendance_data_$subadminId',
    );
    final String? savedTimestamp = prefs.getString(
      'attendance_timestamp_$subadminId',
    );

    if (savedDataJson != null && savedTimestamp != null) {
      final DateTime savedTime = DateTime.parse(savedTimestamp);
      final DateTime now = DateTime.now();

      // Check if saved data is within 24 hours
      if (now.difference(savedTime).inHours < 24) {
        final Map<String, dynamic> savedData = jsonDecode(savedDataJson);
        final String savedDate = savedData['date'] ?? '';
        final String todayDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now());

        // Check if saved data is for today
        if (savedDate == todayDate) {
          setState(() {
            _savedAttendanceData = savedData;
            _currentAttendanceDate = savedDate;

            // Fill the form with saved data
            _dateController.text = savedData['date'] ?? '';
            _inTimeController.text = savedData['punchInTime'] ?? '';
            _lunchOutTimeController.text = savedData['lunchOutTime'] ?? '';
            _lunchInTimeController.text = savedData['lunchInTime'] ?? '';
            _outTimeController.text = savedData['punchOutTime'] ?? '';
            _workTypeController.text = savedData['workType'] ?? '';
            _selectedWorkType = savedData['workType'];

            // Set attendance state flags
            _hasInitialPunchIn =
                savedData['punchInTime'] != null &&
                savedData['punchInTime'].isNotEmpty;
            _hasLunchOut =
                savedData['lunchOutTime'] != null &&
                savedData['lunchOutTime'].isNotEmpty;
            _hasLunchIn =
                savedData['lunchInTime'] != null &&
                savedData['lunchInTime'].isNotEmpty;
            _hasPunchOut =
                savedData['punchOutTime'] != null &&
                savedData['punchOutTime'].isNotEmpty;

            // Parse the saved date
            if (savedData['date'] != null) {
              selectedDate = DateTime.parse(savedData['date']);
            }
          });
        } else {
          // Clear old data if it's not for today
          await _clearSavedAttendanceData();
        }
      } else {
        // Clear expired data
        await _clearSavedAttendanceData();
      }
    }
  }

  Future<void> _saveAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();

    final attendanceData = {
      'date': _dateController.text,
      'punchInTime': _inTimeController.text,
      'lunchOutTime': _lunchOutTimeController.text,
      'lunchInTime': _lunchInTimeController.text,
      'punchOutTime': _outTimeController.text,
      'workType': _workTypeController.text,
    };

    await prefs.setString(
      'attendance_data_$subadminId',
      jsonEncode(attendanceData),
    );
    await prefs.setString(
      'attendance_timestamp_$subadminId',
      DateTime.now().toIso8601String(),
    );

    setState(() {
      _savedAttendanceData = attendanceData;
      _currentAttendanceDate = _dateController.text;
    });
  }

  Future<void> _clearSavedAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('attendance_data_$subadminId');
    await prefs.remove('attendance_timestamp_$subadminId');

    setState(() {
      _savedAttendanceData = {};
      _currentAttendanceDate = '';
      _hasInitialPunchIn = false;
      _hasLunchOut = false;
      _hasLunchIn = false;
      _hasPunchOut = false;
    });
  }

  bool _canEditField(String field) {
    // If no saved data, allow editing
    if (_savedAttendanceData.isEmpty) return true;

    // Check if date matches current saved date
    if (_dateController.text != _currentAttendanceDate) return true;

    switch (field) {
      case 'date':
      case 'punchIn':
        return !_hasInitialPunchIn;
      case 'lunchOut':
        return _hasInitialPunchIn && !_hasLunchOut;
      case 'lunchIn':
        return _hasLunchOut && !_hasLunchIn;
      case 'punchOut':
        return _hasInitialPunchIn && !_hasPunchOut;
      case 'workType':
        return !_hasInitialPunchIn;
      default:
        return true;
    }
  }

  String _getNextEditableField() {
    if (!_hasInitialPunchIn) return 'Initial Punch In';
    if (!_hasLunchOut) return 'Lunch Out';
    if (!_hasLunchIn) return 'Lunch In';
    if (!_hasPunchOut) return 'Punch Out';
    return 'All fields completed';
  }

  Future<void> _updateLocationFields(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String locationName =
          placemarks.isNotEmpty
              ? '${placemarks.first.name}, ${placemarks.first.locality}'
              : 'Unknown Location';

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        companyLocation.latitude,
        companyLocation.longitude,
      );

      setState(() {
        _distanceController.text = '${distance.toStringAsFixed(2)} M';
        awayFromOffice = '${distance.toStringAsFixed(2)} M';
      });

      _updateMarkers(position, locationName);
    } catch (e) {
      print("Reverse geocode failed: $e");
    }
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
          companyLocation,
        ],
        color: Colors.blue,
        width: 5,
      ),
    );
  }

  Future<void> _selectDate() async {
    if (!_canEditField('date')) return;

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
    required String fieldType,
  }) async {
    if (!_canEditField(fieldType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This field cannot be edited at this time')),
      );
      return;
    }

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
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      setState(() {
        controller.text = formattedTime;
        _isTimeSaved = true;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Current location not available'),
          backgroundColor: AppColor.red,
        ),
      );
      return;
    }

    // Save attendance data to SharedPreferences first
    await _saveAttendanceData();

    // Update attendance state flags based on filled fields
    setState(() {
      _hasInitialPunchIn = _inTimeController.text.isNotEmpty;
      _hasLunchOut = _lunchOutTimeController.text.isNotEmpty;
      _hasLunchIn = _lunchInTimeController.text.isNotEmpty;
      _hasPunchOut = _outTimeController.text.isNotEmpty;
    });

    final String postUrl =
        'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/add/bulk';
    final String putUrl =
        'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/update/bulk';

    final attendancePayload = {
      "date": _dateController.text.trim(),
      "status": "Present",
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
      "workType":
          _workTypeController.text.trim().isEmpty
              ? null
              : _workTypeController.text.trim(),
    };

    try {
      final postResponse = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode([attendancePayload]),
      );

      if (postResponse.statusCode == 200) {
        print("POST success: ${postResponse.body}");

        if (_outTimeController.text.trim().isNotEmpty) {
          final updatePayload = {
            ...attendancePayload,
            "date": _dateController.text.trim(),
            "status": "Present",
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
            "workType":
                _workTypeController.text.trim().isEmpty
                    ? null
                    : _workTypeController.text.trim(),
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
            print('Update failed: ${putResponse.statusCode}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please try again"),
                backgroundColor: AppColor.red,
              ),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance saved successfully'),
            backgroundColor: AppColor.green,
          ),
        );

        // If _hasPunchOut and _hasInitialPunchIn fields are not completed, increase leaves
        if (!_hasPunchOut && !_hasInitialPunchIn) {
          leaves++;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('leaves', leaves); // save updated leave count
        }

        // If all fields are completed, navigate to records screen and increase count
        if (_hasPunchOut) {
          count++;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('count', count); // save updated count

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AttendancesRecordsScreen()),
          );
        }
      } else {
        print("POST error: ${postResponse.body}");
        print('Save Failed: ${postResponse.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please try again"),
            backgroundColor: AppColor.red,
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      print('Error : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please try again"),
          backgroundColor: AppColor.red,
        ),
      );
    }
  }

  void _calculateAndUpdateDistance(Position position) {
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      companyLocation.latitude,
      companyLocation.longitude,
    );

    setState(() {
      _distanceController.text = '${distance.toStringAsFixed(2)} M';
      awayFromOffice = '${distance.toStringAsFixed(2)} M';
    });
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
                bool serviceEnabled =
                    await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) throw 'Location services are disabled';

                LocationPermission permission =
                    await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied)
                    throw 'Permission denied';
                }
                if (permission == LocationPermission.deniedForever) {
                  throw 'Permission permanently denied';
                }

                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );

                LatLng userLatLng = LatLng(
                  position.latitude,
                  position.longitude,
                );

                List<Placemark> placemarks = await placemarkFromCoordinates(
                  position.latitude,
                  position.longitude,
                );

                String locationName =
                    placemarks.isNotEmpty
                        ? '${placemarks.first.name}, ${placemarks.first.locality}'
                        : 'Unknown Location';

                _calculateAndUpdateDistance(position);

                setState(() {
                  _currentPosition = position;
                });

                final GoogleMapController controller = await _controller.future;
                await controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: userLatLng, zoom: 16),
                  ),
                );

                _updateMarkers(position, locationName);

                Navigator.of(context).pop(); // close loader

                double distance = Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  companyLocation.latitude,
                  companyLocation.longitude,
                );

                if (_workTypeController.text == workhome ||
                    _workTypeController.text == workField) {
                  await _submitAttendance();
                } else {
                  if (distance <= 25) {
                    await _submitAttendance();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You are not at the office location!'),
                      ),
                    );
                  }
                }
              } catch (e) {
                Navigator.of(context).pop();
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
    return GestureDetector(
      onPanUpdate: (details){},
      child: GoogleMap(
        initialCameraPosition: _kGoogleplex,
        markers: Set<Marker>.of(_markers),
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  Widget _buildWorkTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedWorkType,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: 'Select Work Type',
        enabled: _canEditField('workType'),
      ),
      items:
          _workTypeOptions.map((String workType) {
            return DropdownMenuItem<String>(
              value: workType,
              child: Text(workType),
            );
          }).toList(),
      onChanged:
          _canEditField('workType')
              ? (String? newValue) {
                setState(() {
                  _selectedWorkType = newValue;
                  _workTypeController.text = newValue ?? '';
                });
              }
              : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a work type';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Attendance Form', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  if (_savedAttendanceData.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text('Next: ${_getNextEditableField()}'),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.purpleAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.black,
                          child: ClipOval(
                            child:
                                _isValidUrl(empimg)
                                    ? Image.network(
                                      empimg,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                'assets/Webutsav__3.png',
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                    : Image.asset(
                                      'assets/Webutsav__3.png',
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employeeFullName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              jobRole,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  const Text("DATE"),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _canEditField('date') ? _selectDate : null,
                    decoration: InputDecoration(
                      hintText: 'Select Date',
                      suffixIcon: Icon(
                        _canEditField('date')
                            ? Icons.calendar_today
                            : Icons.lock_clock,
                        color: _canEditField('date') ? null : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabled: _canEditField('date'),
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
                    enabled: _canEditField('punchIn'),
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'IN Time',
                      suffixIcon: Icon(
                        Icons.lock_clock,
                        color: _canEditField('punchIn') ? null : Colors.grey,
                      ),
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
                          fieldType: 'lunchOut',
                        ),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(
                        _canEditField('lunchOut')
                            ? Icons.access_time
                            : Icons.lock_clock,
                        color: _canEditField('lunchOut') ? null : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabled: _canEditField('lunchOut'),
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
                          fieldType: 'lunchIn',
                        ),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(
                        _canEditField('lunchIn')
                            ? Icons.access_time
                            : Icons.lock_clock,
                        color: _canEditField('lunchIn') ? null : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabled: _canEditField('lunchIn'),
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
                          fieldType: 'punchOut',
                        ),
                    decoration: InputDecoration(
                      hintText: 'Select Time',
                      suffixIcon: Icon(
                        _canEditField('punchOut')
                            ? Icons.access_time
                            : Icons.lock_clock,
                        color: _canEditField('punchOut') ? null : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabled: _canEditField('punchOut'),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("Away From Office"),
                  TextFormField(
                    controller: _distanceController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          'Distance will be calculated when you click Save',
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("WORK TYPE *"),
                  _buildWorkTypeDropdown(),
                  const SizedBox(height: 16),
                  const Text("LOCATION (IN) *"),
                  _currentPosition == null
                      ? Text("Location not available")
                      : Text(
                        '${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                      ),
                  AbsorbPointer(
                    absorbing: false,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(border: Border.all()),
                      child: _buildGoogleMap(),
                    ),
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

  @override
  void dispose() {
    _positionSubscription.cancel();
    super.dispose();
  }
}
