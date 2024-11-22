import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/recommendation_card.dart';

class RecommendationScreen extends StatefulWidget {
  final String userId;

  const RecommendationScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<RecommendationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refreshRecommendations(widget.userId),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.recommendations.length,
                    itemBuilder: (context, index) {
                      final venue = provider.recommendations[index];
                      return RecommendationCard(
                        venue: venue,
                        onTap: () => _showVenueDetails(venue),
                        onLike: () => _handleLike(venue),
                        onShare: () => _handleShare(venue),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search places...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (value) {
          // Implement search functionality
        },
      ),
    );
  }

  void _showFilterOptions() {
    // Implement filter options
  }

  void _showVenueDetails(venue) {
    // Implement venue details navigation
  }

  void _handleLike(venue) {
    // Implement like functionality
  }

  void _handleShare(venue) {
    // Implement share functionality
  }
}
