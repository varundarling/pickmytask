import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../core/constants.dart';
import '../models/location_model.dart';

/// Service responsible for all location-related operations
///
/// This service handles:
/// - Getting current location
/// - Listening to location stream updates
/// - Converting coordinates to addresses using Geocoding API
/// - Managing location permissions
class LocationService {
  // Private constructor for singleton pattern (optional)
  LocationService();

  /// Get current device location
  /// Returns [LocationModel] with current coordinates and address info
  /// Throws [Exception] if location service is disabled or permission denied
  Future<LocationModel> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(AppConstants.errorLocationDisabled);
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Convert coordinates to address
      LocationModel locationModel = await _convertPositionToLocation(position);
      return locationModel;
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to location updates stream
  ///
  /// Returns a stream of [LocationModel] that emits whenever location changes
  /// The stream will only emit if location changes by [distanceFilter] meters
  ///
  /// Usage:
  /// ```dart
  /// locationService.getLocationStream().listen((location) {
  ///   print('New location: ${location.city}');
  /// });
  /// ```
  Stream<LocationModel> getLocationStream({
    double distanceFilter = AppConstants.locationUpdateThreshold,
  }) {
    try {
      // Convert double distanceFilter to int for LocationSettings
      final int distanceFilterInt = distanceFilter.toInt();

      // Get position stream with specified distance filter
      final positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilterInt,
        ),
      );

      // Convert position stream to location model stream
      return positionStream.asyncMap((position) async {
        return _convertPositionToLocation(position);
      });
    } catch (e) {
      // Return error as stream
      return Stream.error(e);
    }
  }

  /// Convert Position (from Geolocator) to LocationModel (our domain model)
  ///
  /// This method also performs reverse geocoding to get address information
  /// from coordinates
  Future<LocationModel> _convertPositionToLocation(Position position) async {
    try {
      // Get address from coordinates using Google Geocoding API
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Extract first result (most accurate)
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        city: placemark?.locality ?? 'Unknown',
        state: placemark?.administrativeArea ?? 'Unknown',
        postalCode: placemark?.postalCode ?? 'N/A',
        country: placemark?.country ?? 'Unknown',
        timestamp: DateTime.now(),
        accuracy: position.accuracy,
      );
    } catch (e) {
      // If geocoding fails, return location with just coordinates
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        accuracy: position.accuracy,
      );
    }
  }

  /// Get distance between two locations in meters
  /// Useful for checking if user has moved significantly
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open device location settings
  /// User can manually enable location service from settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open device app settings for this specific app
  /// User can manually grant/revoke permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
