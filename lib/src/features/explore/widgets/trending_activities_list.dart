import 'package:flutter/material.dart';
import '../../crowd/models/crowd_level_standard.dart';
import '../../crowd/widgets/crowd_level_badge.dart';

class TrendingActivitiesList extends StatelessWidget {
  const TrendingActivitiesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ActivityCard(
            title: 'Activity ${index + 1}',
            description: 'Description for activity ${index + 1}',
            imageUrl: 'https://placeholder.com/300x200',
            crowdLevel: CrowdDensity.values[index % CrowdDensity.values.length],
          ),
        );
      },
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final CrowdDensity crowdLevel;

  const ActivityCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.crowdLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to activity details
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    CrowdLevelBadge(
                      density: crowdLevel,
                      size: 20,
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
