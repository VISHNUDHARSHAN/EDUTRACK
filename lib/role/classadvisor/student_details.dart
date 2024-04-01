import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewStudentsPage extends StatefulWidget {
  final String department;
  final String userId;
  final String year;
  final String section;

  const ViewStudentsPage({
    Key? key,
    required this.department,
    required this.userId,
    required this.year,
    required this.section,
  }) : super(key: key);

  @override
  _ViewStudentsPageState createState() => _ViewStudentsPageState();
}

class _ViewStudentsPageState extends State<ViewStudentsPage> {
  late List<Map<String, dynamic>> _studentDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    try {
      QuerySnapshot<Map<String, dynamic>> studentSnapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('student')
          .where('academicYear', isEqualTo: widget.year)
          .where('section', isEqualTo: widget.section)
          .get();

      List<Map<String, dynamic>> studentDetails = [];
      for (var doc in studentSnapshot.docs) {
        Map<String, dynamic> studentData = doc.data();
        studentDetails.add(studentData);
      }
      studentDetails.sort((a, b) =>
          a['registerNumber'].compareTo(b['registerNumber']));
      setState(() {
        _studentDetails = studentDetails;
      });
    } catch (e) {
      print('Error fetching student details: $e');
    }
  }

  Future<void> _editStudent(String registerNumber, Map<String, dynamic> student) async {
    showDialog(
      context: context,
      builder: (context) {
        String editedName = student['name'];
        String editedEmail = student['email'];
        String editedDateOfBirth = student['dateOfBirth'];

        return AlertDialog(
          title: Text('Edit Student'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    editedName = value;
                  },
                  controller: TextEditingController(text: student['name']),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                  onChanged: (value) {
                    editedEmail = value;
                  },
                  controller: TextEditingController(text: student['email']),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                  onChanged: (value) {
                    editedDateOfBirth = value;
                  },
                  controller: TextEditingController(text: student['dateOfBirth']),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update the student details in Firestore
                try {
                  await FirebaseFirestore.instance
                      .collection('Department')
                      .doc(widget.department)
                      .collection('student')
                      .doc(student['userId'])
                      .update({
                    'name': editedName,
                    'email': editedEmail,
                    'dateOfBirth': editedDateOfBirth,
                  });

                  // Fetch updated student details
                  await _fetchStudentDetails();

                  Navigator.pop(context); // Close the dialog
                } catch (e) {
                  print('Error updating student: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating student. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStudent(String userId) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this student?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancel is pressed
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when delete is pressed
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    // Proceed with deletion if confirmed
    if (confirmDelete == true) {
      try {
        // Delete the student document from Firestore
        await FirebaseFirestore.instance
            .collection('Department')
            .doc(widget.department)
            .collection('student')
            .doc(userId)
            .delete();

        // Fetch updated student details
        await _fetchStudentDetails();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error deleting student: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting student. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students Details'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Class : ${widget.year}${widget.section}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (_studentDetails.isNotEmpty)
                DataTable(
                  columns: [
                    DataColumn(label: Text('Register Number')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Date of Birth')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _studentDetails.map<DataRow>((student) {
                    return DataRow(cells: [
                      DataCell(Text(student['registerNumber'] ?? '')),
                      DataCell(Text(student['name'] ?? '')),
                      DataCell(Text(student['email'] ?? '')),
                      DataCell(Text(student['dateOfBirth'] ?? '')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editStudent(student['userId'], student);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteStudent(student['userId']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                )
              else
                Center(
                  child: Text('No students found.'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
