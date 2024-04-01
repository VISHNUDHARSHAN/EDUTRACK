import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RaiseQueryPage extends StatelessWidget {
  final String userId;
  final String? department;

  RaiseQueryPage({required this.userId, this.department});

  final TextEditingController _queryController = TextEditingController();

  Future<void> _submitQuery(BuildContext context) async {
    final String queryText = _queryController.text.trim();
    if (queryText.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('Queries')
            .add({
          'userId': userId,
          'department': department,
          'query': queryText,
          'timestamp': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Query submitted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        _queryController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting query. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error submitting query: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a query.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raise Query'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'Enter your query',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitQuery(context),
              child: Text('Submit Query'),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackToHODPage extends StatelessWidget {
  final String userId;
  final String? department;

  FeedbackToHODPage({required this.userId, this.department});

  final TextEditingController _feedbackController = TextEditingController();

  Future<void> _submitFeedback(BuildContext context) async {
    final String feedbackText = _feedbackController.text.trim();
    if (feedbackText.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('Feedback')
            .add({
          'userId': userId,
          'department': department,
          'feedback': feedbackText,
          'timestamp': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback submitted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        _feedbackController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error submitting feedback: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter feedback.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback to HOD'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(
                labelText: 'Enter your feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitFeedback(context),
              child: Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
