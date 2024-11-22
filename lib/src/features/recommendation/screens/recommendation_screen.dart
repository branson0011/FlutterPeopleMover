import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../models/venue_model.dart';

class RecommendationScreen extends StatefulWidget {
  final String userId;

  const RecommendationScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().fetchRecommendations(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<RecommendationProvider>()
                  .refreshRecommendations(widget.userId);
            },
          ),
        ],
      ),
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
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchRecommendations(widget.userId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.recommendations.isEmpty) {
            return const Center(
              child: Text('No recommendations available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                provider.refreshRecommendations(widget.userId),
            child: ListView.builder(
              itemCount: provider.recommendations.length,
              itemBuilder: (context, index) {
                final venue = provider.recommendations[index];
                return VenueCard(venue: venue);
              },
            ),
          );
        },
      ),
    );
  }
}

class VenueCard extends StatelessWidget {
  final VenueModel venue;

  const VenueCard({
    Key? key,
    required this.venue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        title: Text(venue.name),
        subtitle: Text(venue.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${venue.rating}'),
            const Icon(Icons.star, size: 16),
          ],
        ),
        onTap: () {
          // Navigate to venue details
        },
      ),
    );
  }
}
