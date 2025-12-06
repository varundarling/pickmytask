import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../utils/date_formatter.dart';

/// HistoryList Widget
///
/// Displays all previous locations in a scrollable list
/// Each item shows:
/// - Location index/number
/// - City and coordinates
/// - Timestamp (relative and absolute)
/// - Distance traveled from previous location (if applicable)
class HistoryList extends StatelessWidget {
  final List<LocationModel> locations;

  const HistoryList({Key? key, required this.locations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final location =
            locations[locations.length - 1 - index]; // Reverse order
        final isLatest = index == 0;

        return _buildHistoryItem(context, location, isLatest);
      },
    );
  }

  /// Build individual history list item
  Widget _buildHistoryItem(
    BuildContext context,
    LocationModel location,
    bool isLatest,
  ) {
    return Card(
      elevation: isLatest ? 2 : 0,
      color: isLatest
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLatest
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.3),
          child: Icon(
            Icons.location_on,
            color: isLatest ? Colors.white : Colors.grey,
          ),
        ),
        title: Text(
          '${location.city ?? 'Unknown'}, ${location.state ?? 'Unknown'}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              location.getFormattedCoordinates(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatRelative(location.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: isLatest
            ? Chip(
                label: const Text('Latest'),
                backgroundColor: Theme.of(context).primaryColor,
                labelStyle: const TextStyle(color: Colors.white),
              )
            : null,
        onTap: () {
          // Show detailed location info in dialog
          _showLocationDetails(context, location);
        },
      ),
    );
  }

  /// Show detailed location information in a dialog
  void _showLocationDetails(BuildContext context, LocationModel location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('City', location.city ?? 'Unknown'),
              _buildDetailRow('State', location.state ?? 'Unknown'),
              _buildDetailRow('Postal Code', location.postalCode ?? 'N/A'),
              _buildDetailRow('Country', location.country ?? 'Unknown'),
              _buildDetailRow('Latitude', location.latitude.toStringAsFixed(6)),
              _buildDetailRow(
                'Longitude',
                location.longitude.toStringAsFixed(6),
              ),
              if (location.accuracy != null)
                _buildDetailRow(
                  'Accuracy',
                  '±${location.accuracy!.toStringAsFixed(1)} meters',
                ),
              _buildDetailRow(
                'Date & Time',
                DateFormatter.formatDateTime(location.timestamp),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build detail row for dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
