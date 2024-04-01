import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HodFeedbackPage extends StatefulWidget {
  final String? department;

  HodFeedbackPage({this.department});

  @override
  _HodFeedbackPageState createState() => _HodFeedbackPageState();
}

class _HodFeedbackPageState extends State<HodFeedbackPage> {
  late Stream<QuerySnapshot> _feedbackStream;

  @override
  void initState() {
    super.initState();
    _feedbackStream = FirebaseFirestore.instance
        .collection('Feedback')
        .where('department', isEqualTo: widget.department)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>?> fetchStudentDetails(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> studentSnapshot =
      await FirebaseFirestore.instance
      .collection('Department')
      .doc(widget.department)
          .collection('student').doc(userId).get();

      if (studentSnapshot.exists) {
        return studentSnapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching student details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedbacks'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _feedbackStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final feedbacks = snapshot.data!.docs;

          if (feedbacks.isEmpty) {
            return Center(child: Text('No feedbacks available'));
          }

          return ListView.builder(
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];
              final userId = feedback['userId'];
              final feedbackText = feedback['feedback'];
              final timestamp = feedback['timestamp'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: fetchStudentDetails(userId),
                builder: (context, studentSnapshot) {
                  if (studentSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (studentSnapshot.hasError || studentSnapshot.data == null) {
                    return ListTile(
                      title: Text('Error fetching student details'),
                    );
                  }

                  final studentData = studentSnapshot.data!;
                  final studentName = studentData['name'];
                  final registerNumber = studentData['registerNumber'];
                  final year = studentData['academicYear'];
                  final section = studentData['section'] ?? '';

                  String formattedTime = '${timestamp.toDate().day.toString().padLeft(2, '0')}/'
                      '${timestamp.toDate().month.toString().padLeft(2, '0')}/'
                      '${timestamp.toDate().year.toString()} '
                      '${timestamp.toDate().hour.toString().padLeft(2, '0')}:'
                      '${timestamp.toDate().minute.toString().padLeft(2, '0')}';

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feedback:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          Text(feedbackText),
                          Divider(),
                          SizedBox(height: 8.0),
                          Text('Student Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.0),
                          Text('$studentName($registerNumber)'),
                          Text('Class: $year $section'),
                          Text('Timestamp: $formattedTime'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
