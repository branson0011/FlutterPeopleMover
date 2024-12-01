import 'package:flutter/material.dart';
import '../models/crowd_level_standard.dart';
import '../services/crowd_analytics_service.dart';

class CrowdFeedbackWidget extends StatefulWidget {
  final String locationId;
  final CrowdDensity currentDensity;
  final Function(CrowdDensity, double, String?) onFeedbackSubmitted;

  const CrowdFeedbackWidget({
    Key? key,
    required this.locationId,
    required this.currentDensity,
    required this.onFeedbackSubmitted,
  }) : super(key: key);

  @override
  State<CrowdFeedbackWidget> createState() => _CrowdFeedbackWidgetState();
}

class _CrowdFeedbackWidgetState extends State<CrowdFeedbackWidget> {
  late CrowdDensity _selectedDensity;
  double _confidence = 0.5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDensity = widget.currentDensity;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How crowded is it really?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDensitySelector(),
            const SizedBox(height: 16),
            _buildConfidenceSlider(),
            const SizedBox(height: 16),
            _buildCommentField(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDensitySelector() {
    return SegmentedButton<CrowdDensity>(
      segments: CrowdDensity.values.map((density) {
        return ButtonSegment<CrowdDensity>(
          value: density,
          label: Text(density.toString().split('.').last),
        );
      }).toList(),
      selected: {_selectedDensity},
      onSelectionChanged: (Set<CrowdDensity> selection) {
        setState(() => _selectedDensity = selection.first);
      },
    );
  }

  Widget _buildConfidenceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How confident are you?',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: _confidence,
          onChanged: (value) => setState(() => _confidence = value),
          divisions: 4,
          label: '${(_confidence * 100).round()}%',
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      decoration: const InputDecoration(
        labelText: 'Additional comments (optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          widget.onFeedbackSubmitted(
            _selectedDensity,
            _confidence,
            _commentController.text.isEmpty ? null : _commentController.text,
          );
          Navigator.of(context).pop();
        },
        child: const Text('Submit Feedback'),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
