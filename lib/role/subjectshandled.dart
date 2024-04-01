import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectsHandledPage extends StatefulWidget {
  final String department;
  final String userId;
  final Map<String, dynamic> staffDetails;

  const SubjectsHandledPage({
    Key? key,
    required this.department,
    required this.userId,
    required this.staffDetails,
  }) : super(key: key);

  @override
  _SubjectsHandledPageState createState() => _SubjectsHandledPageState();
}

class _SubjectsHandledPageState extends State<SubjectsHandledPage> {
  late List<Map<String, dynamic>> _subjectDetails = [];
  bool _isClassAdvisor = false;


  @override
  void initState() {
    super.initState();
    _fetchSubjectDetails();
    _checkUserRole();
  }

  Future<void> _fetchSubjectDetails() async {
    try {
      QuerySnapshot<Map<String, dynamic>> subjectSnapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('class')
          .where('staffName', isEqualTo: widget.staffDetails['name'])
          .get();

      List<Map<String, dynamic>> subjectDetails = [];
      for (var doc in subjectSnapshot.docs) {
        subjectDetails.add({
          'documentId': doc.id,
          'yearSection': '${doc['year']} ${doc['section']}',
          'subjectCode': doc['subjectCode'],
          'subjectName': doc['subjectName'],
          'subjectType': doc['subjectType'],
        });
      }
      setState(() {
        _subjectDetails = subjectDetails;
      });
    } catch (e) {
      print('Error fetching subject details: $e');
    }
  }

  Future<void> _checkUserRole() async {
    try {
      // Fetch user role from Firestore based on userId
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('staff')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        // Check if the user is a class advisor
        String userRole = userSnapshot.data()?['role'];
        if (userRole == 'Class Advisor') {
          setState(() {
            _isClassAdvisor = true;
          });
        }
      } else {
        // Handle case where user document does not exist
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects Handled'),
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
                  'Staff Name: ${widget.staffDetails['name']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.staffDetails['role'] == 'Class Advisor')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Role: ${widget.staffDetails['role']}',
                  ),
                ),
              if (widget.staffDetails['role'] == 'Class Advisor')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Class: ${widget.staffDetails['staffYear']} ${widget.staffDetails['staffSection']}',
                  ),
                ),
              _subjectDetails != null
                  ? DataTable(
                columns: [
                  DataColumn(label: Text('Class')),
                  DataColumn(label: Text('Subject Code')),
                  DataColumn(label: Text('Subject Name')),
                  DataColumn(label: Text('Subject Type')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _subjectDetails.map<DataRow>((subject) {
                  return DataRow(cells: [
                    DataCell(Text(subject['yearSection'] ?? '')),
                    DataCell(Text(subject['subjectCode'] ?? '')),
                    DataCell(Text(subject['subjectName'] ?? '')),
                    DataCell(Text(subject['subjectType'] ?? '')),
                    DataCell(
                      _isClassAdvisor
                          ? Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editSubject(subject);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteSubject(subject['documentId']);
                            },
                          ),
                        ],
                      )
                          : Container(), // Empty container for HOD
                    ),
                  ]);
                }).toList(),
              )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editSubject(Map<String, dynamic> subject) async {
    try {
      // Fetch the subject details to verify if the class advisor is responsible for it
      DocumentSnapshot<Map<String, dynamic>> subjectSnapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('class')
          .doc(subject['documentId'])
          .get();

      if (subjectSnapshot.exists) {
        String classAdvisorId = subjectSnapshot['classAdvisorId']; // Assuming this field contains the class advisor's user ID
        if (classAdvisorId == widget.userId) {
          // Show a dialog for editing the subject
          showDialog(
            context: context,
            builder: (context) {
              String editedSubjectCode = subjectSnapshot['subjectCode'];
              String editedSubjectName = subjectSnapshot['subjectName'];
              String editedSubjectType = subjectSnapshot['subjectType'];

              return AlertDialog(
                title: Text('Edit Subject'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: 'Subject Code'),
                        onChanged: (value) {
                          editedSubjectCode = value;
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Subject Name'),
                        onChanged: (value) {
                          editedSubjectName = value;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: editedSubjectType,
                        decoration: InputDecoration(labelText: 'Type'),
                        onChanged: (String? newValue) {
                          setState(() {
                            editedSubjectType = newValue!;
                          });
                        },
                        items: <String>['TC', 'LC', 'TLC'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
                      // Update the subject details in Firestore
                      try {
                        await FirebaseFirestore.instance
                            .collection('Department')
                            .doc(widget.department)
                            .collection('class')
                            .doc(subject['documentId'])
                            .update({
                          'subjectCode': editedSubjectCode,
                          'subjectName': editedSubjectName,
                          'subjectType': editedSubjectType,
                        });
                        // Refresh the subject details after editing
                        _fetchSubjectDetails();
                        Navigator.pop(context); // Close the dialog
                      } catch (e) {
                        print('Error updating subject: $e');
                        // Show an error message if updating fails
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to update subject. Please try again.'),
                        ));
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              );
            },
          );
        } else {
          // Show a message indicating that the class advisor cannot edit this subject
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Permission Denied'),
                content: Text('You are not responsible for editing this subject.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Subject document not found.');
      }
    } catch (e) {
      print('Error editing subject: $e');
    }
  }



  Future<void> _deleteSubject(String documentId) async {
    try {
      // Fetch the subject details to verify if the class advisor is responsible for it
      DocumentSnapshot<Map<String, dynamic>> subjectSnapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('class')
          .doc(documentId)
          .get();

      if (subjectSnapshot.exists) {
        String classAdvisorId = subjectSnapshot['classAdvisorId']; // Assuming this field contains the class advisor's user ID
        if (classAdvisorId == widget.userId) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: Text('Are you sure you want to delete this subject?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('Department')
                          .doc(widget.department)
                          .collection('class')
                          .doc(documentId)
                          .delete();
                      _fetchSubjectDetails(); // Refresh subject details after deletion
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Delete'),
                  ),
                ],
              );
            },
          );
        } else {
          // Show a message indicating that the class advisor cannot delete this subject
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Permission Denied'),
                content: Text(
                    'You are not responsible for deleting this subject.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error deleting subject: $e');
    }
  }
}
