import 'package:flutter/material.dart';
import '../models/venue_model.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;
  final bool showDistance;
  final double? distance;

  const VenueCard({
    Key? key,
    required this.venue,
    required this.onTap,
    this.showDistance = false,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (venue.photoUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  venue.photoUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        venue.rating.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${List.filled(venue.priceLevel, "₹").join()} • ${venue.type}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: _getCrowdColor(venue.crowdData['current']),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getCrowdText(venue.crowdData['current']),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      if (venue.isOpenNow())
                        const Text(
                          'Open Now',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const Text(
                          'Closed',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  if (showDistance && distance != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        Text(
                          '${(distance! / 1000).toStringAsFixed(1)} km',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCrowdColor(String? crowdLevel) {
    switch (crowdLevel?.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCrowdText(String? crowdLevel) {
    switch (crowdLevel?.toLowerCase()) {
      case 'low':
        return 'Not Crowded';
      case 'medium':
        return 'Moderately Crowded';
      case 'high':
        return 'Very Crowded';
      default:
        return 'Unknown';
    }
  }
}
