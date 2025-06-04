import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrm_dump_flutter/services/location_service.dart';

class BackgroundLocationService {
  static const String _isolateName = 'location_isolate';
  static const MethodChannel _channel = MethodChannel('background_location');

  static bool _isInitialized = false;
  static SendPort? _isolatePort;

  /// Initialize background service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Register the isolate
      final isolatePort = IsolateNameServer.lookupPortByName(_isolateName);
      if (isolatePort != null) {
        _isolatePort = isolatePort;
      }

      // Setup method channel for native background handling
      _channel.setMethodCallHandler(_handleMethodCall);

      _isInitialized = true;
      print('Background location service initialized');
    } catch (e) {
      print('Background service initialization error: $e');
    }
  }

  /// Handle method calls from native side
  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAppBackground':
        await _handleAppBackground();
        break;
      case 'onAppForeground':
        await _handleAppForeground();
        break;
      case 'onAppTerminated':
        await _handleAppTerminated();
        break;
    }
  }

  /// Handle app going to background
  static Future<void> _handleAppBackground() async {
    print('App went to background - continuing location tracking');
    // Location service should continue running
    if (!LocationService.instance.isTracking) {
      await LocationService.instance.startLocationTracking();
    }
  }

  /// Handle app coming to foreground
  static Future<void> _handleAppForeground() async {
    print('App came to foreground - location tracking active');
    // Ensure location service is still running
    if (!LocationService.instance.isTracking) {
      await LocationService.instance.startLocationTracking();
    }
  }

  /// Handle app termination
  static Future<void> _handleAppTerminated() async {
    print('App terminated - stopping location tracking');
    LocationService.instance.stopLocationTracking();
  }

  /// Start background location tracking
  static Future<void> startBackgroundTracking() async {
    try {
      await _channel.invokeMethod('startBackgroundTracking');
      print('Background tracking started');
    } catch (e) {
      print('Error starting background tracking: $e');
    }
  }

  /// Stop background location tracking
  static Future<void> stopBackgroundTracking() async {
    try {
      await _channel.invokeMethod('stopBackgroundTracking');
      print('Background tracking stopped');
    } catch (e) {
      print('Error stopping background tracking: $e');
    }
  }
}

/// App lifecycle observer to handle state changes
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('App resumed');
        _handleAppForeground();
        break;
      case AppLifecycleState.paused:
        print('App paused');
        _handleAppBackground();
        break;
      case AppLifecycleState.detached:
        print('App detached');
        _handleAppTerminated();
        break;
      case AppLifecycleState.inactive:
        print('App inactive');
        break;
      case AppLifecycleState.hidden:
        print('App hidden');
        break;
    }
  }

  void _handleAppForeground() {
    // Ensure location tracking continues
    if (!LocationService.instance.isTracking) {
      LocationService.instance.startLocationTracking();
    }
  }

  void _handleAppBackground() {
    // Keep location tracking active in background
    if (!LocationService.instance.isTracking) {
      LocationService.instance.startLocationTracking();
    }
  }

  void _handleAppTerminated() {
    // Clean up resources
    LocationService.instance.stopLocationTracking();
  }
}