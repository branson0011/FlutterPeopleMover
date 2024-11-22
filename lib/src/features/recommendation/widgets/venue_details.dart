import 'package:flutter/material.dart';
import '../models/venue_model.dart';

class VenueDetails extends StatelessWidget {
  final Venue venue;
  final VoidCallback? onClose;
  final VoidCallback? onDirections;
  final VoidCallback? onShare;

  const VenueDetails({
    Key? key,
    required this.venue,
    this.onClose,
    this.onDirections,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildMainInfo(context),
                    const SizedBox(height: 16),
                    _buildCrowdInfo(context),
                    const SizedBox(height: 16),
                    _buildAmenities(context),
                    const SizedBox(height: 16),
                    _buildAccessibility(context),
                    const SizedBox(height: 16),
                    _buildReviews(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        if (venue.photoUrl != null)
          Image.network(
            venue.photoUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              if (onDirections != null)
                IconButton(
                  icon: const Icon(Icons.directions),
                  onPressed: onDirections,
                  color: Colors.white,
                ),
              if (onShare != null)
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: onShare,
                  color: Colors.white,
                ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          venue.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber[600], size: 20),
            const SizedBox(width: 4),
            Text(
              venue.rating.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 16),
            Text(
              '${List.filled(venue.priceLevel, "₹").join()} • ${venue.type}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          venue.address,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCrowdInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Crowd Level',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildCrowdIndicator(context, venue.crowdData['current']),
          ],
        ),
      ),
    );
  }

  Widget _buildCrowdIndicator(BuildContext context, String? crowdLevel) {
    Color color;
    String text;

    switch (crowdLevel?.toLowerCase()) {
      case 'low':
        color = Colors.green;
        text = 'Not Crowded';
        break;
      case 'medium':
        color = Colors.orange;
        text = 'Moderately Crowded';
        break;
      case 'high':
        color = Colors.red;
        text = 'Very Crowded';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildAmenities(BuildContext context) {
    if (venue.amenities == null || venue.amenities!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amenities',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: venue.amenities!.entries.map((entry) {
                return Chip(
                  label: Text(entry.key),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibility(BuildContext context) {
    if (venue.accessibility == null || venue.accessibility!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...venue.accessibility!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      entry.value ? Icons.check_circle : Icons.cancel,
                      color: entry.value ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(entry.key),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews(BuildContext context) {
    if (venue.reviews == null || venue.reviews!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...venue.reviews!.entries.map((entry) {
              final review = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review['author'],
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber[600], size: 16),
                        Text(review['rating'].toString()),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(review['text']),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
