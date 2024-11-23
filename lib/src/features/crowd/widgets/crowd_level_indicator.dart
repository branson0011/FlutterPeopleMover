import 'package:flutter/material.dart';
import '../models/crowd_level.dart';

class CrowdLevelIndicator extends StatelessWidget {
  final CrowdLevel crowdLevel;
  final bool showLabel;
  final bool showDescription;

  const CrowdLevelIndicator({
    Key? key,
    required this.crowdLevel,
    this.showLabel = true,
    this.showDescription = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          crowdLevel.getIcon(),
          color: crowdLevel.getColor(),
          size: 20,
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            crowdLevel.label,
            style: TextStyle(
              color: crowdLevel.getColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        if (showDescription) ...[
          const SizedBox(width: 8),
          Text(
            crowdLevel.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
