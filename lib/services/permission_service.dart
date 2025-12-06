import 'package:geolocator/geolocator.dart';

/// Service responsible for managing location permissions
///
/// Handles:
/// - Requesting location permissions (fine and coarse)
/// - Checking current permission status
/// - Opening device permission settings
class PermissionService {
  /// Request location permissions from user
  ///
  /// Requests both [LocationPermission.fineLocation] (precise) and
  /// [LocationPermission.coarseLocation] (city-level) permissions
  ///
  /// Returns [LocationPermissionStatus] enum indicating the result
  Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // If already granted, return success
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return LocationPermissionStatus.granted;
      }

      // If permanently denied, user must open settings
      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }

      // Request permission from user
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return LocationPermissionStatus.granted;
      } else if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      } else {
        return LocationPermissionStatus.denied;
      }
    } catch (e) {
      return LocationPermissionStatus.unknown;
    }
  }

  /// Check current location permission status
  ///
  /// Returns [LocationPermissionStatus] without requesting
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return LocationPermissionStatus.granted;
      } else if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      } else if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }

      return LocationPermissionStatus.unknown;
    } catch (e) {
      return LocationPermissionStatus.unknown;
    }
  }

  /// Check if location service is enabled on device
  /// Returns true if location service is turned on
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open app settings so user can manually grant permissions
  /// Returns true if settings opened successfully
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open device location settings
  /// Returns true if settings opened successfully
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}

/// Enum representing different permission states
enum LocationPermissionStatus {
  /// User has granted location permission
  granted,

  /// User has denied permission and can be asked again
  denied,

  /// User has permanently denied permission (must open settings)
  deniedForever,

  /// Permission status is unknown
  unknown,
}
