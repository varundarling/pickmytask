import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../core/constants.dart';

/// LocationViewModel - Business Logic & State Management
///
/// This is the heart of the MVVM pattern. It contains:
/// - All business logic for location tracking
/// - State management using Provider pattern
/// - Communication between services and UI
///
/// The ViewModel is independent of the UI framework (Flutter)
/// and can be tested separately
class LocationViewModel extends ChangeNotifier {
  // Services
  final LocationService _locationService;
  final PermissionService _permissionService;

  // State variables
  LocationModel? _currentLocation;
  List<LocationModel> _locationHistory = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isLocationEnabled = false;
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.unknown;
  bool _isTracking = false;

  // Getters - expose state to UI layer
  LocationModel? get currentLocation => _currentLocation;
  List<LocationModel> get locationHistory => _locationHistory;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLocationEnabled => _isLocationEnabled;
  LocationPermissionStatus get permissionStatus => _permissionStatus;
  bool get isTracking => _isTracking;

  /// Constructor - Initialize ViewModel with required services
  LocationViewModel({
    required LocationService locationService,
    required PermissionService permissionService,
  }) : _locationService = locationService,
       _permissionService = permissionService {
    // Initialize app state on creation
    _initialize();
  }

  /// Initialize app - check permissions and location service status
  /// This is called once when app starts
  Future<void> _initialize() async {
    _clearError();
    _setLoading(true);

    try {
      // Check if location service is enabled
      _isLocationEnabled = await _permissionService.isLocationServiceEnabled();

      // Check current permission status
      _permissionStatus = await _permissionService.checkPermissionStatus();

      // If permission granted, fetch initial location
      if (_permissionStatus == LocationPermissionStatus.granted &&
          _isLocationEnabled) {
        await fetchCurrentLocation();
      }

      notifyListeners();
    } catch (e) {
      _setError('Initialization failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Request location permission from user
  ///
  /// Updates permission status and notifies UI
  Future<void> requestPermission() async {
    _clearError();
    _setLoading(true);

    try {
      // Check if location service is enabled
      _isLocationEnabled = await _permissionService.isLocationServiceEnabled();

      if (!_isLocationEnabled) {
        _setError(AppConstants.errorLocationDisabled);
        _setLoading(false);
        return;
      }

      // Request permission
      _permissionStatus = await _permissionService.requestLocationPermission();

      if (_permissionStatus == LocationPermissionStatus.granted) {
        // Permission granted, fetch initial location
        await fetchCurrentLocation();
        // Start tracking
        await startLocationTracking();
      } else if (_permissionStatus == LocationPermissionStatus.deniedForever) {
        _setError(
          'Location permission is permanently denied. Please enable it in app settings.',
        );
      } else {
        _setError(AppConstants.errorPermissionDenied);
      }

      notifyListeners();
    } catch (e) {
      _setError('Permission request failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch current location once
  ///
  /// Gets user's current position and converts to address
  /// Adds to history if successful
  Future<void> fetchCurrentLocation() async {
    _clearError();
    _setLoading(true);

    try {
      LocationModel location = await _locationService.getCurrentLocation();
      _currentLocation = location;

      // Add to history if not already there (check if coordinates differ)
      if (_locationHistory.isEmpty ||
          _isLocationDifferent(
            location,
            _locationHistory.last,
            threshold: 10,
          )) {
        _addToHistory(location);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to get location: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Start listening to location updates
  ///
  /// This will continuously track location changes
  /// and update the history automatically
  ///
  /// Only works if permission is granted
  Future<void> startLocationTracking() async {
    if (_permissionStatus != LocationPermissionStatus.granted) {
      _setError('Permission required to track location');
      return;
    }

    if (_isTracking) {
      return; // Already tracking
    }

    _isTracking = true;
    _clearError();
    notifyListeners();

    try {
      // Listen to location stream
      _locationService
          .getLocationStream(
            distanceFilter: AppConstants.locationUpdateThreshold,
          )
          .listen(
            (LocationModel newLocation) {
              // Update current location
              _currentLocation = newLocation;

              // Add to history if it's significantly different from last location
              if (_isLocationDifferent(
                newLocation,
                _locationHistory.lastOrNull,
                threshold: AppConstants.locationUpdateThreshold,
              )) {
                _addToHistory(newLocation);
              }

              // Notify UI of changes
              notifyListeners();
            },
            onError: (error) {
              _setError('Tracking error: ${error.toString()}');
              _isTracking = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _setError('Failed to start tracking: ${e.toString()}');
      _isTracking = false;
      notifyListeners();
    }
  }

  /// Stop tracking location updates
  void stopLocationTracking() {
    _isTracking = false;
    notifyListeners();
  }

  /// Clear location history
  void clearHistory() {
    _locationHistory.clear();
    notifyListeners();
  }

  /// Check if two locations are significantly different
  ///
  /// Used to avoid adding duplicate nearby locations to history
  /// Returns true if distance between locations is > threshold
  bool _isLocationDifferent(
    LocationModel? newLocation,
    LocationModel? lastLocation, {
    required double threshold,
  }) {
    if (newLocation == null || lastLocation == null) {
      return true;
    }

    double distance = _locationService.getDistanceBetween(
      lastLocation.latitude,
      lastLocation.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );

    return distance > threshold;
  }

  /// Add location to history list
  /// Maintains max history size to prevent memory issues
  void _addToHistory(LocationModel location) {
    _locationHistory.add(location);

    // Limit history to max items to prevent memory bloat
    if (_locationHistory.length > AppConstants.maxHistoryItems) {
      _locationHistory.removeAt(0); // Remove oldest entry
    }
  }

  // State management helper methods

  /// Set loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// Set error message and notify listeners
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Open app settings for manual permission grant
  Future<void> openAppSettings() async {
    await _permissionService.openAppSettings();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await _permissionService.openLocationSettings();
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
