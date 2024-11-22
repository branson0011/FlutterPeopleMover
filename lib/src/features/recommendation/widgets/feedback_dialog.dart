import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class FeedbackDialog extends StatefulWidget {
  final String userId;
  final String venueId;
  final String venueName;

  const FeedbackDialog({
    Key? key,
    required this.userId,
    required this.venueId,
    required this.venueName,
  }) : super(key: key);

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final FeedbackService feedbackService = FeedbackService();
  final TextEditingController feedbackController = TextEditingController();
  double rating = 3.0;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate ${widget.venueName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    setState(() => rating = index + 1.0);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : submitFeedback,
          child: isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> submitFeedback() async {
    setState(() => isSubmitting = true);
    
    try {
      await feedbackService.submitFeedback(
        userId: widget.userId,
        venueId: widget.venueId,
        rating: rating,
        feedback: feedbackController.text,
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'platform': Theme.of(context).platform.toString(),
        },
      );
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $e')),
        );
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }
}
