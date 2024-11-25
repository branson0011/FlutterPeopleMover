import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crowd_level.dart';
import '../models/crowd_level_data.dart';
import 'dart:math';

enum IndicatorSize { small, medium, large }

class CrowdLevelIndicator extends StatefulWidget {
  final CrowdLevel crowdLevel;
  final double confidence;
  final DateTime? lastUpdated;
  final IndicatorSize size;
  final bool showConfidence;
  final bool expandable;
  final bool showHistoricalData;
  final List<CrowdLevelData>? historicalData;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  const CrowdLevelIndicator({
    Key? key,
    required this.crowdLevel,
    this.confidence = 1.0,
    this.lastUpdated,
    this.size = IndicatorSize.medium,
    this.showConfidence = false,
    this.expandable = false,
    this.showHistoricalData = false,
    this.historicalData,
    this.onTap,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<CrowdLevelIndicator> createState() => _CrowdLevelIndicatorState();
}

class _CrowdLevelIndicatorState extends State<CrowdLevelIndicator> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isExpanded = false;
  bool _isLoading = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _setupAnimations();
    _setupInteractions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _indicatorSize {
    switch (widget.size) {
      case IndicatorSize.small:
        return 16.0;
      case IndicatorSize.medium:
        return 24.0;
      case IndicatorSize.large:
        return 32.0;
    }
  }

  void _handleTap() {
    if (widget.expandable) {
      setState(() => _isExpanded = !_isExpanded);
      if (widget.enableHaptics) HapticFeedback.selectionClick();
      _controller.forward();
    }
    widget.onTap?.call();
  }

  void _handleLongPress() {
    HapticFeedback.heavyImpact();
    // Show detailed tooltip
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Crowd Level: ${widget.crowdLevel.label}\n'
          'Confidence: ${(widget.confidence * 100).toStringAsFixed(0)}%\n'
          'Last Updated: ${widget.lastUpdated?.toString() ?? 'Unknown'}',
        ),
      ),
    );
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Data'),
            onTap: () {
              Navigator.pop(context);
              widget.onRefresh?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              _handleTap();
            },
          ),
        ],
      ),
    );
  }

  void _setupAccessibility() {
    final semanticsData = {
      'label': 'Crowd level indicator',
      'value': widget.crowdLevel.description,
      'hint': widget.expandable ? 'Double tap to expand' : null,
      'customActions': [
        if (widget.onRefresh != null) 
          {'name': 'refresh', 'action': widget.onRefresh},
      ],
    };
    SemanticsService.announce(
      '${semanticsData['label']}: ${semanticsData['value']}',
      TextDirection.ltr,
    );
  }

  void _setupKeyboardControls() {
    FocusNode(
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            _handleTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );
  }

  void _setupAnimations() {
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.crowdLevel.color.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _setupInteractions() {
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    
    if (widget.expandable) {
      _controller.forward();
    }
  }

  Widget _buildConfidenceIndicator() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => Opacity(
        opacity: _fadeAnimation.value,
        child: _ConfidenceIndicator(
          confidence: widget.confidence,
          size: _indicatorSize * 0.8,
          highContrast: widget.highContrastMode,
          useGradient: widget.useGradient,
        ),
      ),
    );
  }

  Widget _buildHistoricalChart() {
    if (widget.historicalData == null || widget.historicalData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: CustomPaint(
        painter: _HistoricalChartPainter(
          data: widget.historicalData!,
          color: widget.crowdLevel.color,
        ),
      ),
    );
  }

  Widget _buildPullToRefresh() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        try {
          await widget.onRefresh?.call();
        } finally {
          setState(() => _isLoading = false);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return GestureDetector(
      onLongPress: _showActionMenu,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.crowdLevel.icon,
                size: _indicatorSize,
                color: widget.crowdLevel.color,
              ),
              const SizedBox(width: 8),
              Text(
                widget.crowdLevel.label,
                style: TextStyle(
                  color: widget.crowdLevel.color,
                  fontSize: _indicatorSize * 0.75,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.showConfidence) ...[
                const SizedBox(width: 8),
                _buildConfidenceIndicator(),
              ],
              if (widget.showHistoricalData && _isExpanded) ...[
                const SizedBox(height: 16),
                _buildHistoricalChart(),
              ],
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            _DetailedView(
              crowdLevel: widget.crowdLevel,
              confidence: widget.confidence,
              lastUpdated: widget.lastUpdated,
              onRefresh: widget.onRefresh,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedView() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isExpanded ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHistoricalChart(),
              const SizedBox(height: 16),
              _buildConfidenceDetails(),
              if (widget.lastUpdated != null)
                _buildLastUpdated(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Crowd level indicator showing ${widget.crowdLevel.label}',
      value: widget.crowdLevel.description,
      button: widget.expandable,
      child: MouseRegion(
        onEnter: (_) => _controller.forward(),
        onExit: (_) => _controller.reverse(),
        child: GestureDetector(
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _colorAnimation.value,
                  boxShadow: [
                    if (_isPressed)
                      BoxShadow(
                        color: widget.crowdLevel.color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }
}

class _ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final double size;
  final bool highContrast;
  final bool useGradient;

  const _ConfidenceIndicator({
    required this.confidence,
    required this.size,
    this.highContrast = false,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            if (useGradient)
              ShaderMask(
                shaderCallback: (rect) {
                  return SweepGradient(
                    startAngle: 0.0,
                    endAngle: 2 * pi,
                    stops: [confidence, confidence],
                    colors: [
                      _getConfidenceColor(confidence, highContrast),
                      Colors.grey.withOpacity(0.2),
                    ],
                  ).createShader(rect);
                },
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                ),
              )
            else
              CircularProgressIndicator(
                value: confidence,
                strokeWidth: 2,
                backgroundColor: highContrast ? Colors.grey[600] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getConfidenceColor(confidence, highContrast),
                ),
              ),
            if (confidence < 0.5)
              Positioned.fill(
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: size * 0.6,
                  color: highContrast ? Colors.yellow[700] : Colors.orange,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence, bool highContrast) {
    if (highContrast) {
      return confidence > 0.7 ? Colors.lightGreenAccent : Colors.orangeAccent;
    }
    return confidence > 0.7 ? Colors.green : Colors.orange;
  }
}

class _DetailedView extends StatelessWidget {
  final CrowdLevel crowdLevel;
  final double confidence;
  final DateTime? lastUpdated;
  final VoidCallback? onRefresh;

  const _DetailedView({
    required this.crowdLevel,
    required this.confidence,
    this.lastUpdated,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          crowdLevel.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (onRefresh != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
                tooltip: 'Refresh crowd level',
              ),
          ],
        ),
        if (lastUpdated != null)
          Text(
            'Last updated: ${_formatTimestamp(lastUpdated!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _HistoricalChartPainter extends CustomPainter {
  final List<CrowdLevelData> data;
  final Color color;
  final double strokeWidth;
  final bool smoothCurve;

  _HistoricalChartPainter({
    required this.data,
    required this.color,
    this.strokeWidth = 2.0,
    this.smoothCurve = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final xStep = width / (data.length - 1);

    // Calculate points
    final points = List<Offset>.generate(data.length, (i) {
      final x = i * xStep;
      final y = height - (height * (data[i].level.level / 5.0));
      return Offset(x, y);
    });

    // Draw smooth curve or straight lines
    if (smoothCurve) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final controlPoint1 = Offset(
          current.dx + (next.dx - current.dx) / 2,
          current.dy,
        );
        final controlPoint2 = Offset(
          current.dx + (next.dx - current.dx) / 2,
          next.dy,
        );
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          next.dx, next.dy,
        );
      }
    } else {
      path.moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
    }

    // Draw path
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, strokeWidth, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
