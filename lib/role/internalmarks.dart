import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class InternalMarksPage extends StatefulWidget {
  final String userId;
  final String department;
  final String year;
  final String section;
  final String subjectCode;
  final String subjectName;
  final String subjectType;

  const InternalMarksPage({
    Key? key,
    required this.userId,
    required this.department,
    required this.year,
    required this.section,
    required this.subjectCode,
    required this.subjectName,
    required this.subjectType,
  }) : super(key: key);

  @override
  _InternalMarksPageState createState() => _InternalMarksPageState();
}

class _InternalMarksPageState extends State<InternalMarksPage> {
  List<Map<String, dynamic>> _studentsList = [];
  List<int?> _marksList = [];
  String _selectedCIAT = 'CIAT1';
  String? department;

  @override
  void initState() {
    super.initState();
    fetchStudentsList();
  }

  Future<void> fetchStudentsList() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('student')
          .where('academicYear', isEqualTo: widget.year)
          .where('section', isEqualTo: widget.section)
          .orderBy('registerNumber') // Sort by register number
          .get();

      setState(() {
        _studentsList =
            querySnapshot.docs.map((doc) => doc.data()).toList();
        _marksList = List.generate(_studentsList.length, (index) => null);
        // Fetch existing marks for each student
        fetchExistingMarks();
      });
    } catch (e) {
      print('Error fetching students list: $e');
    }
  }

  Future<void> fetchExistingMarks() async {
    try {
      for (int i = 0; i < _studentsList.length; i++) {
        Map<String, dynamic> student = _studentsList[i];
        // Retrieve existing marks for each student
        QuerySnapshot<Map<String, dynamic>> existingMarksSnapshot =
        await FirebaseFirestore.instance
            .collection('Department')
            .doc(widget.department)
            .collection(widget.year+widget.section)
            // .doc(widget.subjectCode)
            // .collection('Internals')
            .where('Name', isEqualTo: student['name'])
            .where('subjectCode', isEqualTo: widget.subjectCode)
            .where('subjectName', isEqualTo: widget.subjectName)
            .where('year', isEqualTo: widget.year)
            .where('section', isEqualTo: widget.section)
            .get();
        if (existingMarksSnapshot.docs.isNotEmpty) {
          // If existing marks exist, set them in the marks list
          Map<String, dynamic> existingMarks =
          existingMarksSnapshot.docs.first.data();
          _marksList[i] = existingMarks[_selectedCIAT];
        }
      }
    } catch (e) {
      print('Error fetching existing marks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internal Marks - ${widget.subjectName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject Name: ${widget.subjectName}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Subject Code: ${widget.subjectCode}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButton<String>(
                          value: _selectedCIAT,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCIAT = newValue!;
                              // Fetch existing marks for the newly selected CIAT
                              fetchExistingMarks();
                            });
                          },
                          items: <String>['CIAT1', 'CIAT2']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Show Year, Section, and Subject Type here
                Row(
                  children: [
                    Text(
                      'Class: ${widget.year}${widget.section}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 18),
                    Text(
                      '${widget.subjectType}',
                      style: const TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _studentsList.length,
                itemBuilder: (context, index) {
                  final student = _studentsList[index];
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  student['registerNumber'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  student['name'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Marks'),
                          onChanged: (value) {
                            // Update marks list when the text field value changes
                            _marksList[index] = int.tryParse(value);
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3), // Limit to 3 characters (100)
                          ],
                          controller: TextEditingController(text: _marksList[index]?.toString() ?? ''),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Upload marks to the database
                  uploadMarks();
                },
                child: Text('Upload Marks'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadMarks() async {
    try {
      for (int i = 0; i < _studentsList.length; i++) {
        Map<String, dynamic> student = _studentsList[i];
        int? marks = _marksList[i];

        // Check if a document for the student and subject already exists
        QuerySnapshot<Map<String, dynamic>> existingDocs =
        await FirebaseFirestore.instance
            .collection('Department')
            .doc(widget.department)
            .collection(widget.year+widget.section) //Internals
            // .doc(widget.subjectCode)
            // .collection('Internals')
            .where('Name', isEqualTo: student['name'])
            .where('subjectCode', isEqualTo: widget.subjectCode)
            .where('subjectName', isEqualTo: widget.subjectName)
            .where('year', isEqualTo: widget.year)
            .where('section', isEqualTo: widget.section)
            .get();

        if (existingDocs.docs.isNotEmpty) {
          // Document already exists, update the existing document with CIAT marks
          existingDocs.docs.first.reference.update({
            _selectedCIAT: marks, // Store the CIAT marks based on the selected CIAT
          });
        } else {
          // Document does not exist, create a new document and store CIAT marks
          await FirebaseFirestore.instance
              .collection('Department')
              .doc(widget.department)
              .collection(widget.year+widget.section)
              // .doc(widget.subjectCode)
              // .collection('Internals')
              .add({
            'registerNumber': student['registerNumber'],
            'Name': student['name'],
            _selectedCIAT: marks, // Store the CIAT marks based on the selected CIAT
            'year': widget.year,
            'section': widget.section,
            'subjectCode': widget.subjectCode,
            'subjectName': widget.subjectName,
            'subjectType': widget.subjectType,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marks uploaded successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
     // print('Error uploading marks: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading marks. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
