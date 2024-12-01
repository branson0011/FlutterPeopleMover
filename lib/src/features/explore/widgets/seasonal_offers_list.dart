import 'package:flutter/material.dart';
import '../../crowd/models/crowd_level_standard.dart';
import '../../crowd/widgets/crowd_level_badge.dart';

class SeasonalOffersList extends StatelessWidget {
  const SeasonalOffersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OfferCard(
              title: 'Seasonal Offer ${index + 1}',
              discount: '${(index + 1) * 10}% OFF',
              imageUrl: 'https://placeholder.com/200x300',
              crowdLevel: CrowdDensity.values[index % CrowdDensity.values.length],
            ),
          );
        },
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final String title;
  final String discount;
  final String imageUrl;
  final CrowdDensity crowdLevel;

  const OfferCard({
    Key? key,
    required this.title,
    required this.discount,
    required this.imageUrl,
    required this.crowdLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 200,
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  discount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CrowdLevelBadge(
                      density: crowdLevel,
                      size: 16,
                      showLabel: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
