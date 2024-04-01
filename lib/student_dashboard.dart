import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empowereed2/Stu_profile.dart';
import 'login_page.dart';
import 'query.dart';

class StudentDashboardPage extends StatefulWidget {
  final String userId;
  final String? selectedDepartment;

  StudentDashboardPage({
    Key? key,
    required this.userId,
    this.selectedDepartment,
  }) : super(key: key);

  @override
  _StudentDashboardPageState createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  List<Map<String, dynamic>> _subjectsList = [];
  Map<String, Map<String, int?>> _ciatMarks = {}; // Corrected declaration
  String? _selectedDepartment;
  String? _studentName;
  String? _registerNumber;

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
    _selectedDepartment = widget.selectedDepartment;

  }

  Future<void> fetchStudentDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> studentSnapshot =
      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.selectedDepartment)
          .collection('student')
          .doc(widget.userId)
          .get();

      if (studentSnapshot.exists) {
        Map<String, dynamic> studentData = studentSnapshot.data()!;
        String year = studentData['academicYear'];
        String section = studentData['section'];
        _studentName = studentData['name'];
        _registerNumber = studentData['registerNumber'];

        fetchSubjectsList(year, section);
        fetchCIATMarks(_studentName!, year, section);
      } else {
        print('Student document does not exist');
      }
    } catch (e) {
      print('Error fetching student details: $e');
    }
  }

  Future<void> fetchSubjectsList(String year, String section) async {
    try {
      QuerySnapshot<Map<String, dynamic>> subjectsSnapshot =
      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.selectedDepartment)
          .collection('class')
          .where('year', isEqualTo: year)
          .get();

      setState(() {
        _subjectsList = subjectsSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error fetching subjects list: $e');
    }
  }

  Future<void> fetchCIATMarks(
      String studentName, String year, String section) async {
    try {
      QuerySnapshot<Map<String, dynamic>> marksSnapshot =
      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.selectedDepartment)
          .collection(year + section)
          .where('Name', isEqualTo: studentName)
          .where('year', isEqualTo: year)
          .where('section', isEqualTo: section)
          .get();
      //print('$year' + '$section');
      if (marksSnapshot.docs.isNotEmpty) {
        marksSnapshot.docs.forEach((doc) {

          _ciatMarks[doc['subjectName']] = {
            'CIAT1': (doc['CIAT1'] ?? 0) as int?, // Default to 0 if CIAT1 is null
            'CIAT2': (doc['CIAT2'] ?? 0) as int?, // Default to 0 if CIAT2 is null
          };


        });
        processCIATMarks();
        // setState(() {});
      }
    } catch (e) {
      print('Error fetching CIAT marks: $e');
    }
  }

  void processCIATMarks() {
    for (var subject in _subjectsList) {
      String subjectName = subject['subjectName'];
      if (_ciatMarks.containsKey(subjectName)) {
        Map<String, int?> marks = Map<String, int?>.from(_ciatMarks[subjectName]!);
        String subjectType = subject['subjectType'];

        // Convert CIAT1
        if (marks['CIAT1'] != null) {
          switch (subjectType) {
            case 'TC':
              marks['CIAT1'] = (marks['CIAT1']! * 0.4).round(); // Convert to 40%
              break;
            case 'TLC':
              marks['CIAT1'] = (marks['CIAT1']! * 0.5).round(); // Convert to 50%
              break;
            case 'LC':
              marks['CIAT1'] = (marks['CIAT1']! * 0.6).round(); // Convert to 60%
              break;
            default:
              break;
          }


        } else {
          marks['CIAT1'] = 0;
        }

        // Convert CIAT2
        if (marks['CIAT2'] != null) {
          switch (subjectType) {
            case 'TC':
              marks['CIAT2'] = (marks['CIAT2']! * 0.4).round(); // Convert to 40%
              break;
            case 'TLC':
              marks['CIAT2'] = (marks['CIAT2']! * 0.5).round(); // Convert to 50%
              break;
            case 'LC':
              marks['CIAT2'] = (marks['CIAT2']! * 0.6).round(); // Convert to 60%
              break;
            default:
              break;
          }
        } else {
          marks['CIAT2'] = 0; // Assign null if CIAT2 is null
        }
        _ciatMarks[subjectName] = marks;
      } else {
        // Handle missing marks for the subject
        _ciatMarks[subjectName] = {'CIAT1': null, 'CIAT2': null};
      }
    }

    setState(() {});
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }


  Future<void> _refreshPage() async {
    setState(() {
      _subjectsList = [];
      _ciatMarks = {};
      fetchStudentDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPage,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Student Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('View Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentProfilePage(
                      userId: widget.userId,
                      department: _selectedDepartment,
                    ),
                  ),
                );
              },
            ),
            // ListTile(
            //   title: Text('Raise Query'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => RaiseQueryPage(
            //           userId: widget.userId,
            //           department: _selectedDepartment,
            //         ),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              title: Text('Feedback to HOD'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackToHODPage(
                      userId: widget.userId,
                      department: _selectedDepartment,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  _studentName ?? '', // Display student's name
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _registerNumber ?? '', // Display student's register number
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            _buildDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Subject Code')),
          DataColumn(label: Text('Subject Name')),
          DataColumn(label: Text('Subject Type')),
          DataColumn(label: Text('CIAT1')),
          DataColumn(label: Text('CIAT2')),
        ],
        rows: _subjectsList.map((subject) {
          String subjectName = subject['subjectName'];
          int? ciat1Marks = _ciatMarks[subjectName]?['CIAT1'];
          int? ciat2Marks = _ciatMarks[subjectName]?['CIAT2'];

          // Check if marks are null or not available
          bool marksAvailable = ciat1Marks != null && ciat2Marks != null;
          return DataRow(cells: [
            DataCell(
              Text(
                subject['subjectCode'] ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Text(
                subject['subjectName'] ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Text(
                subject['subjectType'] ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              marksAvailable ? Text(ciat1Marks.toString()) : Text('N/A'),
            ),
            DataCell(
              marksAvailable ? Text(ciat2Marks.toString()) : Text('N/A'),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}
