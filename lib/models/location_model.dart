import 'package:equatable/equatable.dart';

/// Model representing a single location point
///
/// This is a pure data class following MVVM pattern
/// It holds all information about a location snapshot
class LocationModel extends Equatable {
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final DateTime timestamp;
  final double? accuracy;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    required this.timestamp,
    this.accuracy,
  });

  /// Create a LocationModel from another instance with some fields changed
  /// Useful for immutable updates
  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    DateTime? timestamp,
    double? accuracy,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      timestamp: timestamp ?? this.timestamp,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  /// Format location for display purposes
  String getFormattedCoordinates() {
    return '$latitude, $longitude';
  }

  /// Get full address string
  String getFullAddress() {
    List<String> addressParts = [];
    if (city != null) addressParts.add(city!);
    if (state != null) addressParts.add(state!);
    if (postalCode != null) addressParts.add(postalCode!);
    if (country != null) addressParts.add(country!);
    return addressParts.join(', ');
  }

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    city,
    state,
    postalCode,
    country,
    timestamp,
    accuracy,
  ];
}
