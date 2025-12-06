import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../utils/date_formatter.dart';

/// LocationCard Widget
///
/// Displays current location details in a beautiful card format
/// Shows:
/// - Latitude and Longitude
/// - City, State, Pincode
/// - Last updated timestamp
/// - Accuracy information
class LocationCard extends StatelessWidget {
  final LocationModel location;
  final bool isLoading;

  const LocationCard({Key? key, required this.location, this.isLoading = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and refresh indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Location',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Coordinates section
            _buildInfoRow(
              context,
              icon: Icons.location_on,
              label: 'Coordinates',
              value: location.getFormattedCoordinates(),
            ),

            const SizedBox(height: 12),

            // City section
            _buildInfoRow(
              context,
              icon: Icons.location_city,
              label: 'City',
              value: location.city ?? 'Unknown',
            ),

            const SizedBox(height: 12),

            // State section
            _buildInfoRow(
              context,
              icon: Icons.map,
              label: 'State',
              value: location.state ?? 'Unknown',
            ),

            const SizedBox(height: 12),

            // Postal code section
            _buildInfoRow(
              context,
              icon: Icons.mail,
              label: 'Postal Code',
              value: location.postalCode ?? 'N/A',
            ),

            const SizedBox(height: 12),

            // Accuracy section
            if (location.accuracy != null)
              _buildInfoRow(
                context,
                icon: Icons.info,
                label: 'Accuracy',
                value: '±${location.accuracy!.toStringAsFixed(1)} meters',
              ),

            const SizedBox(height: 16),

            // Divider
            const Divider(),

            const SizedBox(height: 8),

            // Last updated timestamp
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  'Updated: ${DateFormatter.formatRelative(location.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Text(
              DateFormatter.formatDateTime(location.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build consistent info rows
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
