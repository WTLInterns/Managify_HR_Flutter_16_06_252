import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
import 'package:hrm_dump_flutter/screens/dashbord/dashboard_screen.dart';
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

  int subadminId = 0;
  String employeeFullName = '';
  String companyname = '';
  String companylogo = '';
  String jobRole = '';
  String empimg = '';
  double latitude = 0.0;
  double longitude = 0.0;
  bool _isSubmitting = false;
  bool _isWorkTypeSaved = false;
  // final Set<Polyline> _polylines = {};

  // Base URL for images
  final String _imageBaseUrl = 'https://api.managifyhr.com/images/profile/';


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

  final List<String> _workTypeOptions = [
    'Work From Office',
    'Work From Home',
    'Work From Field',
  ];
  String? _selectedWorkType;

  LatLng? companyLocation;
  CameraPosition? _kGoogleplex;

  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    // Set current date in _dateController
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    selectedDate = DateTime.now();

    // Set default work type to "Work From Office"
    _selectedWorkType = 'Work From Office';
    _workTypeController.text = 'Work From Office';

    // Load user data and initialize location-related variables
    _loadUserData().then((_) {
      _initializeLocation();
      // Load saved attendance data after user data is loaded
      _loadSavedAttendanceData().then((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _autoFillNextField();
        });
      });
    });

    _positionSubscription = LocationService.instance.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
        _updateLocationFields(position);
      });
    });
  }

  Future<void> _initializeLocation() async {
    setState(() {
      // Initialize companyLocation and _kGoogleplex after latitude and longitude are loaded
      companyLocation = LatLng(latitude, longitude);
      _kGoogleplex = CameraPosition(
        target: companyLocation!,
        zoom: 14,
      );
      // Initialize markers
      _markers = [
        Marker(
          markerId: MarkerId('1'),
          position: companyLocation!,
          infoWindow: InfoWindow(title: companyname),
        ),
      ];
    });

    // Move the camera to the company location if the map is already created
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(_kGoogleplex!),
      );
    }
  }

  String _getCurrentStage() {
    print('Checking stage: inTime=${_inTimeController.text}, lunchOut=${_lunchOutTimeController.text}');
    if (_inTimeController.text.isEmpty) return 'punchIn';
    if (_lunchOutTimeController.text.isEmpty) return 'lunchOut';
    if (_lunchInTimeController.text.isEmpty) return 'lunchIn';
    if (_outTimeController.text.isEmpty) return 'punchOut';
    return 'complete';
  }

  void _autoFillNextField() {
    final stage = _getCurrentStage();
    final now = TimeOfDay.now();
    final formattedTime = _formatTimeOfDay24(now);

    print('Current stage: $stage');
    print('Punch In: ${_inTimeController.text}');
    print('Lunch Out: ${_lunchOutTimeController.text}');

    setState(() {
      switch (stage) {
        case 'punchIn':
          _inTimeController.text = formattedTime;
          print('Setting Punch In to: $formattedTime');
          break;
        case 'lunchOut':
          if (_inTimeController.text.isNotEmpty) {
            _lunchOutTimeController.text = formattedTime;
            print('Setting Lunch Out to: $formattedTime');
          }
          break;
        case 'lunchIn':
          if (_lunchOutTimeController.text.isNotEmpty) {
            _lunchInTimeController.text = formattedTime;
            print('Setting Lunch In to: $formattedTime');
          }
          break;
        case 'punchOut':
          if (_lunchInTimeController.text.isNotEmpty) {
            _outTimeController.text = formattedTime;
            print('Setting Punch Out to: $formattedTime');
          }
          break;
      }
    });
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
      companyname = prefs.getString('registercompanyname') ?? '';
      companylogo = prefs.getString('companylogo') ?? '';
      jobRole = prefs.getString('jobRole') ?? '';
      empimg = prefs.getString('empimg') ?? '';
      latitude = prefs.getDouble('latitude') ?? 0.0;
      longitude = prefs.getDouble('longitude') ?? 0.0;
      print('mmmmmmmmmmmmmmmmmmmmmmmmmmmm');
      print(latitude);
      print(longitude);
      print('mmmmmmmmmmmmmmmmmmmmmmmmmmmm');
    });
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (_isValidUrl(imagePath)) return imagePath;
    return '$_imageBaseUrl$imagePath';
  }

  Future<CacheManager> _getCacheManager() async {
    if (kIsWeb) {
      return NonStoringCacheManager();
    }
    return DefaultCacheManager();
  }

  Future<void> _loadSavedAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedDataJson = prefs.getString('attendance_data_$subadminId');
    final String? savedTimestamp = prefs.getString('attendance_timestamp_$subadminId');

    if (savedDataJson != null && savedTimestamp != null) {
      final DateTime savedTime = DateTime.parse(savedTimestamp);
      final DateTime now = DateTime.now();

      if (now.difference(savedTime).inHours < 24) {
        final Map<String, dynamic> savedData = jsonDecode(savedDataJson);
        final String savedDate = savedData['date'] ?? '';
        final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        if (savedDate == todayDate) {
          setState(() {
            _dateController.text = savedData['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
            _inTimeController.text = savedData['punchInTime'] ?? '';
            _lunchOutTimeController.text = savedData['lunchOutTime'] ?? '';
            _lunchInTimeController.text = savedData['lunchInTime'] ?? '';
            _outTimeController.text = savedData['punchOutTime'] ?? '';
            _workTypeController.text = savedData['workType'] ?? 'Work From Office';
            _selectedWorkType = savedData['workType']?.isNotEmpty ?? false ? savedData['workType'] : 'Work From Office';
            _isWorkTypeSaved = savedData['workType']?.isNotEmpty ?? false;

            if (savedData['date'] != null) {
              selectedDate = DateTime.parse(savedData['date']);
            }
            print('Loaded saved data: $savedData');
          });
        } else {
          await _clearSavedAttendanceData();
        }
      } else {
        await _clearSavedAttendanceData();
      }
    } else {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
        selectedDate = DateTime.now();
        _selectedWorkType = 'Work From Office';
        _workTypeController.text = 'Work From Office';
        _isWorkTypeSaved = false;
      });
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
    print('Saved attendance data: $attendanceData');
    _autoFillNextField();
  }

  Future<void> _clearSavedAttendanceData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('attendance_data_$subadminId');
    await prefs.remove('attendance_timestamp_$subadminId');
    setState(() {
      _inTimeController.clear();
      _lunchOutTimeController.clear();
      _lunchInTimeController.clear();
      _outTimeController.clear();
      _workTypeController.text = 'Work From Office';
      _selectedWorkType = 'Work From Office';
      _isWorkTypeSaved = false;
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      selectedDate = DateTime.now();
    });
    _autoFillNextField();
  }

  Future<void> _updateLocationFields(Position position) async {
    if (companyLocation == null) return; // Guard against null companyLocation

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
        companyLocation!.latitude,
        companyLocation!.longitude,
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
    if (companyLocation == null) return; // Guard against null companyLocation

    _markers.removeWhere((marker) => marker.markerId.value == 'current');
    _markers.add(
      Marker(
        markerId: MarkerId('current'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: locationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // _polylines.clear();
    // _polylines.add(
    //   Polyline(
    //     polylineId: PolylineId("route"),
    //     points: [
    //       LatLng(position.latitude, position.longitude),
    //       companyLocation!,
    //     ],
    //     color: Colors.blue,
    //     width: 5,
    //   ),
    // );
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

    await _saveAttendanceData();

    final String postUrl =
        'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/add/bulk';
    final String putUrl =
        'https://api.managifyhr.com/api/employee/$subadminId/$employeeFullName/attendance/update/bulk';

    final attendancePayload = {
      "date": _dateController.text.trim(),
      "status": "",
      "reason": "",
      "punchInTime": _inTimeController.text.trim().isEmpty ? null : _inTimeController.text.trim(),
      "punchOutTime": _outTimeController.text.trim().isEmpty ? null : _outTimeController.text.trim(),
      "lunchInTime": _lunchInTimeController.text.trim().isEmpty ? null : _lunchInTimeController.text.trim(),
      "lunchOutTime": _lunchOutTimeController.text.trim().isEmpty ? null : _lunchOutTimeController.text.trim(),
      "workType": _workTypeController.text.trim().isEmpty ? null : _workTypeController.text.trim(),
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
            "punchInTime": _inTimeController.text.trim().isEmpty ? null : _inTimeController.text.trim(),
            "punchOutTime": _outTimeController.text.trim().isEmpty ? null : _outTimeController.text.trim(),
            "lunchInTime": _lunchInTimeController.text.trim().isEmpty ? null : _lunchInTimeController.text.trim(),
            "lunchOutTime": _lunchOutTimeController.text.trim().isEmpty ? null : _lunchOutTimeController.text.trim(),
            "workType": _workTypeController.text.trim().isEmpty ? null : _workTypeController.text.trim(),
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
          }
        }

        setState(() {
          _isWorkTypeSaved = _outTimeController.text.trim().isNotEmpty ? true : _isWorkTypeSaved;
        });

        final stage = _getCurrentStage();
        if (stage == 'punchOut' && _outTimeController.text.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AttendancesRecordsScreen()),
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        print("POST error: ${postResponse.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please try again"),
            backgroundColor: AppColor.red,
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please try again"),
          backgroundColor: AppColor.red,
        ),
      );
    }
  }

  void _calculateAndUpdateDistance(Position position) {
    if (companyLocation == null) return; // Guard against null companyLocation

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      companyLocation!.latitude,
      companyLocation!.longitude,
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
            borderRadius: BorderRadius.circular(8),
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
            borderRadius: BorderRadius.circular(8),
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
                bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) throw 'Location services are disabled';

                LocationPermission permission = await Geolocator.checkPermission();
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

                String locationName = placemarks.isNotEmpty
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

                Navigator.of(context).pop();

                if (companyLocation == null) {
                  throw 'Company location not initialized';
                }

                double distance = Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  companyLocation!.latitude,
                  companyLocation!.longitude,
                );

                if (_workTypeController.text == workhome ||
                    _workTypeController.text == workField) {
                  await _submitAttendance();
                } else {
                  if (distance <= 20) {
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
                // ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text(e.toString())));
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
    // Show a placeholder if _kGoogleplex is not initialized
    if (_kGoogleplex == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(border: Border.all()),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onPanUpdate: (details) {},
      child: GoogleMap(
        initialCameraPosition: _kGoogleplex!,
        markers: Set<Marker>.of(_markers),
        // polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          // Ensure the camera is set to the correct position
          controller.animateCamera(CameraUpdate.newCameraPosition(_kGoogleplex!));
        },
      ),
    );
  }

  Widget _buildWorkTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedWorkType,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        hintText: 'Select Work Type',
        filled: _isWorkTypeSaved,
        fillColor: _isWorkTypeSaved ? Colors.transparent : null,
      ),
      items: _workTypeOptions.map((String workType) {
        return DropdownMenuItem<String>(
          value: workType,
          child: Text(workType),
        );
      }).toList(),
      onChanged: _isWorkTypeSaved
          ? null
          : (String? newValue) {
        setState(() {
          _selectedWorkType = newValue;
          _workTypeController.text = newValue ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a work type';
        }
        return null;
      },
      disabledHint: _isWorkTypeSaved
          ? Text(_selectedWorkType ?? 'Work Type Selected')
          : null,
    );
  }

  Widget _buildProgressIndicator() {
    final stage = _getCurrentStage();
    return Column(
      children: [
        LinearProgressIndicator(
          value: stage == 'punchIn'
              ? 0.25
              : stage == 'lunchOut'
              ? 0.5
              : stage == 'lunchIn'
              ? 0.75
              : 1.0,
          backgroundColor: Colors.grey[200],
          color: Colors.blue,
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Punch In',
              style: TextStyle(
                fontWeight: stage == 'punchIn' ? FontWeight.bold : FontWeight.normal,
                color: stage == 'punchIn' ? Colors.blue : Colors.grey,
              ),
            ),
            Text(
              'Lunch Out',
              style: TextStyle(
                fontWeight: stage == 'lunchOut' ? FontWeight.bold : FontWeight.normal,
                color: stage == 'lunchOut' ? Colors.blue : Colors.grey,
              ),
            ),
            Text(
              'Lunch In',
              style: TextStyle(
                fontWeight: stage == 'lunchIn' ? FontWeight.bold : FontWeight.normal,
                color: stage == 'lunchIn' ? Colors.blue : Colors.grey,
              ),
            ),
            Text(
              'Punch Out',
              style: TextStyle(
                fontWeight: stage == 'punchOut' ? FontWeight.bold : FontWeight.normal,
                color: stage == 'punchOut' ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Attendance',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressIndicator(),
                  SizedBox(height: 16),
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
                          backgroundColor: AppColor.black,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColor.black,
                            child: FutureBuilder<CacheManager>(
                              future: _getCacheManager(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && _getImageUrl(companylogo).isNotEmpty) {
                                  return CachedNetworkImage(
                                    imageUrl: _getImageUrl(companylogo),
                                    cacheManager: snapshot.data,
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                      ),
                                    ),
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.person_rounded, size: 30, color: Colors.white),
                                  );
                                }
                                return const Icon(Icons.person_rounded, size: 30, color: Colors.white);
                              },
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
                    decoration: InputDecoration(
                      hintText: 'Select Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("PUNCH IN"),
                  TextFormField(
                    controller: _inTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'IN Time',
                      suffixIcon: Icon(Icons.lock_clock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("LUNCH OUT"),
                  TextFormField(
                    controller: _lunchOutTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Lunch Out Time',
                      suffixIcon: Icon(Icons.lock_clock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("LUNCH IN"),
                  TextFormField(
                    controller: _lunchInTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Lunch In Time',
                      suffixIcon: Icon(Icons.lock_clock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("PUNCH OUT"),
                  TextFormField(
                    controller: _outTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'OUT Time',
                      suffixIcon: Icon(Icons.lock_clock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("Away From Office"),
                  TextFormField(
                    controller: _distanceController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Distance will be calculated when you click Save',
                    ),
                  ),
                  SizedBox(height: 16),
                  const Text("WORK TYPE *"),
                  _buildWorkTypeDropdown(),
                  const SizedBox(height: 16),
                  const Text("LOCATION (IN) *"),
                  Text('User',style: TextStyle(fontWeight: FontWeight.w500),),
                  _currentPosition == null
                      ? Text("Location not available")
                      : Text(
                    '${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                  ),
                  Text('Company',style: TextStyle(fontWeight: FontWeight.w500),),
                  Text('$latitude,$longitude'),
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