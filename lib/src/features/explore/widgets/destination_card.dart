import 'package:flutter/material.dart';
import '../../../crowd/widgets/crowd_level_indicator.dart';
import '../../../crowd/models/crowd_level_standard.dart';

class DestinationCard extends StatelessWidget {
  final String title;
  final String description;
  final CrowdDensity crowdLevel;

  const DestinationCard({
    Key? key,
    required this.title,
    required this.description,
    required this.crowdLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Stack(
        children: [
          // Background image or other content can go here
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CrowdLevelIndicator(
                        crowdLevel: crowdLevel,
                        showLabel: true,
                        size: 16,
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
