import 'package:flutter/material.dart';
import 'package:pickmytask/views/widgets/histroy_list.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../viewmodels/location_viewmodel.dart';
import '../services/permission_service.dart';
import '../models/location_model.dart';
import 'widgets/location_card.dart';
import 'widgets/permission_button.dart';

/// Main Location Screen
///
/// Displays:
/// - Current location information
/// - Location history
/// - Permission status
/// - Navigation to map view
class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add observer to handle app lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handle app lifecycle changes
  /// When app comes back to foreground, refresh location
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - refresh location
      final viewModel = context.read<LocationViewModel>();
      viewModel.fetchCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        elevation: 0,
        actions: [
          // Menu button with additional options
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Clear History'),
                onTap: () {
                  context.read<LocationViewModel>().clearHistory();
                },
              ),
              PopupMenuItem(
                child: const Text('Refresh'),
                onTap: () {
                  context.read<LocationViewModel>().fetchCurrentLocation();
                },
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LocationViewModel>(
        builder: (context, viewModel, _) {
          // Show loading indicator while fetching
          if (viewModel.isLoading && viewModel.currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if any
          if (viewModel.errorMessage != null) {
            return _buildErrorWidget(context, viewModel);
          }

          // Show permission request if not granted
          if (viewModel.permissionStatus != LocationPermissionStatus.granted) {
            return _buildPermissionWidget(context, viewModel);
          }

          // Main content - location display and history
          return RefreshIndicator(
            onRefresh: () =>
                context.read<LocationViewModel>().fetchCurrentLocation(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Current location card
                    if (viewModel.currentLocation != null)
                      LocationCard(
                        location: viewModel.currentLocation!,
                        isLoading: viewModel.isLoading,
                      ),

                    const SizedBox(height: 24),

                    // Start/Stop tracking button
                    _buildTrackingButton(context, viewModel),

                    const SizedBox(height: 24),

                    // Map view button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to map view
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapViewScreen(
                                currentLocation: viewModel.currentLocation,
                                locationHistory: viewModel.locationHistory,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View on Map'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location history section
                    if (viewModel.locationHistory.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Location History (${viewModel.locationHistory.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      HistoryList(locations: viewModel.locationHistory),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No location history yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<LocationViewModel>(
        builder: (context, viewModel, _) {
          return FloatingActionButton(
            onPressed: () =>
                context.read<LocationViewModel>().fetchCurrentLocation(),
            tooltip: 'Refresh Location',
            child: const Icon(Icons.refresh),
          );
        },
      ),
    );
  }

  /// Build permission request widget
  Widget _buildPermissionWidget(
    BuildContext context,
    LocationViewModel viewModel,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Location Permission Required',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Enable location permission to track your location',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PermissionButton(
            onPressed: () => viewModel.requestPermission(),
            label: 'Grant Permission',
          ),
          const SizedBox(height: 12),
          if (viewModel.permissionStatus ==
              LocationPermissionStatus.deniedForever)
            TextButton(
              onPressed: () => viewModel.openAppSettings(),
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(BuildContext context, LocationViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
          const SizedBox(height: 24),
          Text('Error', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            viewModel.errorMessage ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (viewModel.errorMessage?.contains(
                    'Location service is disabled',
                  ) ??
                  false) {
                viewModel.openLocationSettings();
              } else {
                viewModel.requestPermission();
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build start/stop tracking button
  Widget _buildTrackingButton(
    BuildContext context,
    LocationViewModel viewModel,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            viewModel.permissionStatus == LocationPermissionStatus.granted
            ? () {
                if (viewModel.isTracking) {
                  viewModel.stopLocationTracking();
                } else {
                  viewModel.startLocationTracking();
                }
              }
            : null,
        icon: Icon(viewModel.isTracking ? Icons.stop : Icons.play_arrow),
        label: Text(viewModel.isTracking ? 'Stop Tracking' : 'Start Tracking'),
        style: ElevatedButton.styleFrom(
          backgroundColor: viewModel.isTracking
              ? Colors.orangeAccent
              : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

/// Map View Screen - Display locations on Google Map
///
/// Shows:
/// - Current location as a blue marker
/// - Location history as green markers
/// - Optional: path connecting all locations
class MapViewScreen extends StatefulWidget {
  final LocationModel? currentLocation;
  final List<LocationModel> locationHistory;

  const MapViewScreen({
    Key? key,
    this.currentLocation,
    required this.locationHistory,
  }) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  late GoogleMapController mapController;
  late Set<Marker> markers;
  late Set<Polyline> polylines;

  @override
  void initState() {
    super.initState();
    _initializeMapMarkers();
  }

  void _initializeMapMarkers() {
    markers = {};
    polylines = {};

    // Add history markers (green)
    for (int i = 0; i < widget.locationHistory.length; i++) {
      final location = widget.locationHistory[i];
      markers.add(
        Marker(
          markerId: MarkerId('history_$i'),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.city ?? 'Location',
            snippet: '${location.latitude}, ${location.longitude}',
          ),
        ),
      );
    }

    // Add current location marker (blue)
    if (widget.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            widget.currentLocation!.latitude,
            widget.currentLocation!.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet:
                '${widget.currentLocation!.city}, ${widget.currentLocation!.state}',
          ),
        ),
      );
    }

    // Add polyline connecting all locations
    if (widget.locationHistory.length > 1) {
      final points = widget.locationHistory
          .map((l) => LatLng(l.latitude, l.longitude))
          .toList();
      polylines.add(
        Polyline(
          polylineId: const PolylineId('path'),
          points: points,
          color: Colors.blue.withOpacity(0.7),
          width: 3,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialLocation =
        widget.currentLocation ??
        (widget.locationHistory.isNotEmpty
            ? widget.locationHistory.first
            : null);

    if (initialLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map View')),
        body: const Center(child: Text('No location data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(initialLocation.latitude, initialLocation.longitude),
          zoom: 14,
        ),
        markers: markers,
        polylines: polylines,
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
