// app/lib/core/services/location_service.dart

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class UserLocation {
  final double latitude;
  final double longitude;

  const UserLocation({required this.latitude, required this.longitude});
}

class LocationService {
  // Default fallback locations
  static const UserLocation bingenLocation = UserLocation(
    latitude: 49.9650,
    longitude: 7.9000,
  );
  static const UserLocation oberweselLocation = UserLocation(
    latitude: 50.1080,
    longitude: 7.7280,
  );
  static const UserLocation fallbackLocation = UserLocation(
    latitude: 49.9650, // Default to Bingen am Rhein (Pilot Region RLP)
    longitude: 7.9000,
  );

  /// Requests foreground location only when the user explicitly triggers
  /// store search or route optimization (Strict DSGVO compliance).
  static Future<UserLocation> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled, using fallback location.');
        return fallbackLocation;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied, using fallback.');
          return fallbackLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied, using fallback.');
        return fallbackLocation;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e. Falling back to default.');
      return fallbackLocation;
    }
  }
}
