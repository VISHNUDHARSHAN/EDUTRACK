import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CIATMarksPage extends StatefulWidget {
  final String department;
  final String year;
  final String section;
  final String subjectCode;

  const CIATMarksPage({
    Key? key,
    required this.department,
    required this.year,
    required this.section,
    required this.subjectCode,
  }) : super(key: key);

  @override
  _CIATMarksPageState createState() => _CIATMarksPageState();
}

class _CIATMarksPageState extends State<CIATMarksPage> {
  late List<Map<String, dynamic>> _studentMarks = [];

  @override
  void initState() {
    super.initState();
    _fetchCIATMarks();
  }

  // Future<void> _fetchCIATMarks() async {
  //   try {
  //     QuerySnapshot<Map<String, dynamic>> marksSnapshot =
  //     await FirebaseFirestore.instance
  //         .collection('Department')
  //         .doc(widget.department)
  //         .collection(widget.year+widget.section)
  //         .where('year', isEqualTo: widget.year)
  //         .where('section', isEqualTo: widget.section)
  //         .where('subjectCode', isEqualTo: widget.subjectCode)
  //         .get();
  //
  //     List<Map<String, dynamic>> studentMarks = [];
  //     for (var doc in marksSnapshot.docs) {
  //       // Retrieve the register number from the document data
  //       String registerNumber = doc['registerNumber'];
  //
  //       studentMarks.add({
  //         'registerNumber': registerNumber,
  //         'Name': doc['Name'],
  //         'CIAT1': doc['CIAT1'] ?? '',
  //         'CIAT2': doc['CIAT2'] ?? '',
  //       });
  //     }
  //     setState(() {
  //       _studentMarks = studentMarks;
  //     });
  //   } catch (e) {
  //     print('Error fetching CIAT marks: $e');
  //   }
  // }
  Future<void> _fetchCIATMarks() async {
    try {
      QuerySnapshot<Map<String, dynamic>> marksSnapshot =
      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection(widget.year + widget.section)
          .where('year', isEqualTo: widget.year)
          .where('section', isEqualTo: widget.section)
          .where('subjectCode', isEqualTo: widget.subjectCode)
          .get();

      List<Map<String, dynamic>> studentMarks = [];
      for (var doc in marksSnapshot.docs) {
        // Retrieve the register number from the document data
        String registerNumber = doc['registerNumber'];

        studentMarks.add({
          'registerNumber': registerNumber,
          'Name': doc['Name'],
          'CIAT1': doc['CIAT1'] ?? '',
          'CIAT2': doc['CIAT2'] ?? '',
        });
      }

      // Sort the student marks based on register number
      studentMarks.sort((a, b) =>
          a['registerNumber'].compareTo(b['registerNumber']));

      setState(() {
        _studentMarks = studentMarks;
      });
    } catch (e) {
      print('Error fetching CIAT marks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CIAT Marks'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Subject: ${widget.subjectCode}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (_studentMarks.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Register Number')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('CIAT1')),
                    DataColumn(label: Text('CIAT2')),
                  ],
                  rows: _studentMarks.map<DataRow>((student) {
                    return DataRow(cells: [
                      DataCell(Text(student['registerNumber'] ?? '')),
                      DataCell(Text(student['Name'] ?? '')),
                      DataCell(Text(student['CIAT1']?.toString() ?? 'N/A')),
                      DataCell(Text(student['CIAT2']?.toString() ?? 'N/A')),
                    ]);
                  }).toList(),
                ),
              )
            else
              Center(
                child: Text('No CIAT marks found for this subject.'),
              ),
          ],
        ),
      ),
    );
  }

}
