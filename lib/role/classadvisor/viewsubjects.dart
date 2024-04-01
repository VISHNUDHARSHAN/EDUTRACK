import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'internals.dart';

class ViewSubjectsPage extends StatefulWidget {
  final String department;
  final String year;
  final String section;

  const ViewSubjectsPage({
    Key? key,
    required this.department,
    required this.year,
    required this.section,
  }) : super(key: key);

  @override
  _ViewSubjectsPageState createState() => _ViewSubjectsPageState();
}

class _ViewSubjectsPageState extends State<ViewSubjectsPage> {
  late List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      QuerySnapshot<Map<String, dynamic>> subjectsSnapshot =
      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('class')
          .where('year', isEqualTo: widget.year)
          .where('section', isEqualTo: widget.section)
          .get();

      List<Map<String, dynamic>> subjects = [];
      for (var doc in subjectsSnapshot.docs) {
        subjects.add({
          'subjectCode': doc['subjectCode'],
          'subjectName': doc['subjectName'],
          'subjectType': doc['subjectType'],
          'staffName': doc['staffName'],
        });
      }
      setState(() {
        _subjects = subjects;
      });
    } catch (e) {
      print('Error fetching subjects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Class: ${widget.year}${widget.section}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (_subjects.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_subjects[index]['subjectName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_subjects[index]['subjectCode']),
                        Text('Staff: ${_subjects[index]['staffName']}'),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the page displaying CIAT marks for the selected subject
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CIATMarksPage(
                            department: widget.department,
                            year: widget.year,
                            section: widget.section,
                            subjectCode: _subjects[index]['subjectCode'],
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            else
              Center(
                child: Text('No subjects found.'),
              ),
          ],
        ),
      ),
    );
  }
}
