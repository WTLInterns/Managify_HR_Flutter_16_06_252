import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionService {
  static final LocationPermissionService _instance = LocationPermissionService._internal();
  factory LocationPermissionService() => _instance;
  LocationPermissionService._internal();

  /// Request all necessary location permissions
  static Future<bool> requestLocationPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return false;
      }

      // Request background location permission (Android 10+)
      var backgroundStatus = await Permission.locationAlways.status;
      if (!backgroundStatus.isGranted) {
        backgroundStatus = await Permission.locationAlways.request();
        if (!backgroundStatus.isGranted) {
          print('Background location permission not granted');
          // App can still work but won't track in background
        }
      }

      // Request to ignore battery optimizations
      var ignoreBattery = await Permission.ignoreBatteryOptimizations.status;
      if (!ignoreBattery.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }

      print('Location permissions granted');
      return true;

    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Show permission dialog to user
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This app needs location permission to track your attendance.'),
                SizedBox(height: 16),
                Text('Please allow:'),
                Text('• Location access (Always)'),
                Text('• Background app refresh'),
                Text('• Disable battery optimization'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
            TextButton(
              child: Text('Allow'),
              onPressed: () async {
                Navigator.of(context).pop();
                await requestLocationPermissions();
              },
            ),
          ],
        );
      },
    );
  }

  /// Check if all required permissions are granted
  static Future<bool> hasAllPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    return serviceEnabled &&
        (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always);
  }
}