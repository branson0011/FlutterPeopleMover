import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../models/recommendation.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
      ),
      body: Consumer<RecommendationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: provider.recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = provider.recommendations[index];
              return RecommendationCard(
                recommendation: recommendation,
                onRatingChanged: (rating) {
                  provider.rateRecommendation(
                    recommendation.id,
                    rating,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final Function(double) onRatingChanged;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recommendation.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(recommendation.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rating: ${recommendation.rating.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < recommendation.rating
                            ? Icons.star
                            : Icons.star_border,
                      ),
                      onPressed: () => onRatingChanged(index + 1.0),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
