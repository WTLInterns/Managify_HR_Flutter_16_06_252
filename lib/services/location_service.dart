import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService _instance = LocationService._privateConstructor();
  static LocationService get instance => _instance;

  final StreamController<Position> _positionController = StreamController.broadcast();
  Stream<Position> get positionStream => _positionController.stream;

  Position? _lastKnownPosition;
  Position? get lastKnownPosition => _lastKnownPosition;

  Timer? _locationTimer;
  bool _isTracking = false;
  int? subadminId;
  int? empId;

  static const int _trackingIntervalSeconds = 10;
  static const String _baseUrl = 'https://api.managifyhr.com';

  Future<void> initialize() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    await _loadUserCredentials();

    _lastKnownPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _positionController.add(_lastKnownPosition!);
    print('Initial location: ${_lastKnownPosition!.latitude}, ${_lastKnownPosition!.longitude}');

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _lastKnownPosition = position;
      _positionController.add(position);
      print('Updated position from stream: ${position.latitude}, ${position.longitude}');
    });
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    subadminId = prefs.getInt('subadminId');
    empId = prefs.getInt('empId');
    print('Loaded credentials: subadminId=$subadminId, empId=$empId');
  }

  Future<void> startLocationTracking() async {
    if (_isTracking) return;

    if (subadminId == null || empId == null) {
      await _loadUserCredentials();
      if (subadminId == null || empId == null) {
        throw 'User credentials not found. Please login again.';
      }
    }

    _isTracking = true;
    print('Starting location tracking every $_trackingIntervalSeconds seconds');

    await _sendLocationToBackend();

    _locationTimer = Timer.periodic(
      Duration(seconds: _trackingIntervalSeconds),
          (timer) async {
        if (_isTracking) {
          await _sendLocationToBackend();
        }
      },
    );
  }

  void stopLocationTracking() {
    if (!_isTracking) return;

    _isTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    print('Location tracking stopped');
  }

  Future<void> _sendLocationToBackend() async {
    try {
      // Get fresh position if needed
      Position? currentPosition = _lastKnownPosition;

      if (currentPosition == null) {
        print('Getting fresh location...');
        currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10), // Add timeout for position request
        );
        _lastKnownPosition = currentPosition;
        _positionController.add(currentPosition);
      }

      // Validate credentials before making API calls
      if (subadminId == null || empId == null) {
        print('Error: Missing credentials - subadminId: $subadminId, empId: $empId');
        return;
      }

      final locationPayload = {
        "latitude": currentPosition.latitude,
        "longitude": currentPosition.longitude,
        "lastLatitude": currentPosition.latitude,
        "lastLongitude": currentPosition.longitude,
      };

      final postUrl = '$_baseUrl/api/location/$subadminId/employee/$empId';
      final putUrl = '$_baseUrl/api/location/$subadminId/employee/$empId';

      print('Current Position - Lat: ${currentPosition.latitude}, Long: ${currentPosition.longitude}');
      print('Credentials - SubadminId: $subadminId, EmpId: $empId');

      // Try POST request
      try {
        print('Attempting POST to: $postUrl');
        final postResponse = await http.post(
          Uri.parse(postUrl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(locationPayload),
        ).timeout(Duration(seconds: 10)); // Increased timeout

        print('POST Response Status: ${postResponse.statusCode}');
        if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
          print('POST location success: ${postResponse.body}');
        } else {
          print('POST location failed: ${postResponse.statusCode} - ${postResponse.body}');
        }
      } catch (postError) {
        print('POST request error: $postError');
      }

      // Try PUT request
      try {
        print('Attempting PUT to: $putUrl');
        final putResponse = await http.put(
          Uri.parse(putUrl),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode(locationPayload),
        ).timeout(Duration(seconds: 10)); // Increased timeout

        print('PUT Response Status: ${putResponse.statusCode}');
        if (putResponse.statusCode == 200 || putResponse.statusCode == 201) {
          print('PUT location success: ${putResponse.body}');
        } else {
          print('PUT location failed: ${putResponse.statusCode} - ${putResponse.body}');
        }
      } catch (putError) {
        print('PUT request error: $putError');
      }

      print('Location sending completed successfully');

    } catch (e) {
      print('Critical error in _sendLocationToBackend: $e');
      print('Stack trace: ${StackTrace.current}');

      // Try to reload credentials if there's an auth error
      if (e.toString().contains('credentials') || e.toString().contains('auth')) {
        print('Attempting to reload credentials...');
        try {
          await _loadUserCredentials();
        } catch (credError) {
          print('Failed to reload credentials: $credError');
        }
      }
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10), // Add timeout
      );
      _lastKnownPosition = position;
      _positionController.add(position);
      print('Manually fetched current position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return _lastKnownPosition;
    }
  }

  bool get isTracking => _isTracking;

  void updateUserCredentials(int newSubadminId, int newEmpId) {
    // Fixed variable naming conflict
    this.subadminId = newSubadminId;
    this.empId = newEmpId;
    print('Credentials updated: subadminId=$subadminId, empId=$empId');
  }

  void dispose() {
    stopLocationTracking();
    _positionController.close();
    print('LocationService disposed');
  }
}