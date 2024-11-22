import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/venue_card.dart';
import '../widgets/recommendation_filter.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  late GoogleMapController _mapController;
  LatLng _currentLocation = const LatLng(0, 0);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Implement location retrieval
    // For now using dummy location
    setState(() {
      _currentLocation = const LatLng(37.7749, -122.4194);
    });
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    final provider = Provider.of<RecommendationProvider>(context, listen: false);
    await provider.fetchRecommendations(
      userLocation: _currentLocation,
      radius: 5000,
    );
    _updateMarkers();
  }

  void _updateMarkers() {
    final provider = Provider.of<RecommendationProvider>(context, listen: false);
    setState(() {
      _markers = provider.recommendedVenues.map((venue) {
        return Marker(
          markerId: MarkerId(venue.id),
          position: venue.location,
          infoWindow: InfoWindow(
            title: venue.name,
            snippet: '${venue.rating} ★ • ${venue.type}',
          ),
          onTap: () => _showVenueDetails(venue),
        );
      }).toSet();
    });
  }

  void _showVenueDetails(Venue venue) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VenueDetailsSheet(venue: venue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecommendationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  ElevatedButton(
                    onPressed: _fetchRecommendations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 14,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.3,
                minChildSize: 0.1,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: provider.recommendedVenues.length,
                            itemBuilder: (context, index) {
                              final venue = provider.recommendedVenues[index];
                              return VenueCard(
                                venue: venue,
                                onTap: () => _showVenueDetails(venue),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: RecommendationFilter(
                  onFilterChanged: (filters) {
                    provider.updatePreferences(filters);
                    _fetchRecommendations();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class VenueDetailsSheet extends StatelessWidget {
  final Venue venue;

  const VenueDetailsSheet({
    Key? key,
    required this.venue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (venue.photoUrl != null)
            Image.network(
              venue.photoUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                const SizedBox(height: 16),
                Text(
                  'Current Crowd Level',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildCrowdIndicator(venue.crowdData['current']),
                const SizedBox(height: 16),
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: venue.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdIndicator(String? crowdLevel) {
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
}
