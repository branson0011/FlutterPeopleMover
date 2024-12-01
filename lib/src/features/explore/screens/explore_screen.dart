import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../crowd/widgets/crowd_filter_bar.dart';
import '../../crowd/widgets/crowd_level_badge.dart';
import '../widgets/trending_activities_list.dart';
import '../widgets/seasonal_offers_list.dart';
import '../../crowd/models/crowd_level_standard.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Set<CrowdDensity> _selectedDensities = {};

  void _handleCrowdFilterChanged(Set<CrowdDensity> newSelection) {
    setState(() => _selectedDensities = newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Explore'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CrowdFilterBar(
              selectedDensities: _selectedDensities,
              onSelectionChanged: _handleCrowdFilterChanged,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Destinations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const PopularDestinationsGrid(),
                  const SizedBox(height: 24),
                  const TrendingActivitiesList(),
                  const SeasonalOffersList(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trending Activities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const TrendingActivitiesList(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seasonal Offers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const SeasonalOffersList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PopularDestinationsGrid extends StatelessWidget {
  const PopularDestinationsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return DestinationCard(
          title: 'Destination $index',
          imageUrl: 'https://placeholder.com/300x200',
          crowdLevel: CrowdDensity.values[index % CrowdDensity.values.length],
        );
      },
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final CrowdDensity crowdLevel;

  const DestinationCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.crowdLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
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
                  Row(
                    children: [
                      CrowdLevelBadge(
                        crowdLevel: crowdLevel,
                        showLabel: true,
                        size: 20,
                        animate: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add TrendingActivitiesList and SeasonalOffersList widgets...
