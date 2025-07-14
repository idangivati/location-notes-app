import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LocationHelper {
  static Future<GeoPoint?> getCurrentLocation() async {
    try {
      debugPrint('📍 Checking location permissions...');
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('📍 Location permissions denied');
          throw LocationException('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('📍 Location permissions permanently denied');
        throw LocationException('Location permissions are permanently denied.');
      }

      debugPrint('📍 Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('📍 Location acquired: ${position.latitude}, ${position.longitude}');
      return GeoPoint(position.latitude, position.longitude);
      
    } catch (e) {
      debugPrint('📍 Error getting location: $e');
      rethrow;
    }
  }

  static String formatLocation(GeoPoint location) {
    return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lon: ${location.longitude.toStringAsFixed(4)}';
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}