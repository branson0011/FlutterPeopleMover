import 'package:flutter/material.dart';
import '../models/crowd_level.dart';

class AnimatedCrowdIndicator extends StatelessWidget {
  final CrowdLevel crowdLevel;
  final double size;
  final bool animate;
  final Duration duration;
  final Curve curve;

  const AnimatedCrowdIndicator({
    Key? key,
    required this.crowdLevel,
    this.size = 24.0,
    this.animate = true,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: animate ? value : 1.0,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: crowdLevel.color.withOpacity(value * 0.2),
              border: Border.all(
                color: crowdLevel.color.withOpacity(value),
                width: 2,
              ),
            ),
            child: Icon(
              crowdLevel.icon,
              size: size * 0.6,
              color: crowdLevel.color.withOpacity(value),
            ),
          ),
        );
      },
    );
  }
}
