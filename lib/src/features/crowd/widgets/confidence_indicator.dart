enum IndicatorSize { small, medium, large }

class CrowdLevelIndicator extends StatefulWidget {
  final CrowdLevel crowdLevel;
  final double confidence;
  final DateTime? lastUpdated;
  final IndicatorSize size;
  final bool showConfidence;
  final bool expandable;
  final bool enableHaptics;
  final bool highContrastMode;
  final bool useGradient;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  const CrowdLevelIndicator({
    Key? key,
    required this.crowdLevel,
    required this.confidence,
    this.lastUpdated,
    this.size = IndicatorSize.medium,
    this.showConfidence = false,
    this.expandable = false,
    this.enableHaptics = true,
    this.highContrastMode = false,
    this.useGradient = true,
    this.onTap,
    this.onRefresh,
  }) : super(key: key);

  @override
  _CrowdLevelIndicatorState createState() => _CrowdLevelIndicatorState();
}

class _CrowdLevelIndicatorState extends State<CrowdLevelIndicator> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isExpanded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2.0 * 3.141592653589793).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _setupAccessibility();
    _setupKeyboardControls();
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

  // ...rest of the code...

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
    return Semantics(
      label: 'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
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
                    endAngle: 2 * 3.141592653589793,
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

  // ...rest of the code...
}
