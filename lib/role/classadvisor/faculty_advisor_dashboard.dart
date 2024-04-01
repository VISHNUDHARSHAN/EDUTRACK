import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../login_page.dart';
import 'subject_staff_assignment.dart';
import 'student_details.dart';
import 'package:empowereed2/role/profilepage.dart';
import 'package:empowereed2/role/internalmarks.dart';
import 'package:empowereed2/role/view_staff_details.dart';
import 'viewsubjects.dart';



class ClassAdvisorDashboard extends StatefulWidget {
  final String userId;
  final String? selectedDepartment;

  const ClassAdvisorDashboard({
    Key? key,
    required this.userId,
    this.selectedDepartment,
  }) : super(key: key);

  @override
  _ClassAdvisorDashboardState createState() => _ClassAdvisorDashboardState();
}

class _ClassAdvisorDashboardState extends State<ClassAdvisorDashboard> {
  String? _selectedDepartment;
  String? _selectedYear;
  String? _selectedSection;

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.selectedDepartment;
    fetchClassAdvisorDetails();
  }

  Future<void> fetchClassAdvisorDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('Department')
          .doc(_selectedDepartment)
          .collection('staff')
          .doc(widget.userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          _selectedYear = snapshot['year'];
          _selectedSection = snapshot['section'];
        });
      } else {
        print('Class advisor document does not exist');
      }
    } catch (e) {
      print('Error fetching class advisor details: $e');
    }
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Advisor Dashboard'),
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
                'Welcome !',
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
                    builder: (context) => ProfilePage(userId: widget.userId,department:_selectedDepartment!,),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Assign Subject staffs'),
              onTap: () {
                if (_selectedDepartment != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubjectStaffAssignmentPage( userId: widget.userId,
                        selectedYear: _selectedYear,
                        selectedSection: _selectedSection,
                        department: _selectedDepartment,),
                    ),
                  );
                } else {
                  // Handle the case where department information is not available
                }
              },
            ),
            ListTile(
              title: Text('View Staff details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewStaffDetails(userId: widget.userId,department:_selectedDepartment!,),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Students details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewStudentsPage(userId: widget.userId,
                      department:_selectedDepartment!,
                    year: _selectedYear!,
                    section: _selectedSection!),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Subjects details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewSubjectsPage(
                      department:_selectedDepartment!,
                    year: _selectedYear!,
                    section: _selectedSection!),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: _signOut,
            ),
            // Add more options as needed
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Class Advisor!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              'Subjects Handled:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SubjectsHandledList(userId: widget.userId, department: _selectedDepartment),
            ),
          ],
        ),
      ),
    );
  }
}


class SubjectsHandledList extends StatelessWidget {
  final String userId;
  final String? department;

  const SubjectsHandledList({
    Key? key,
    required this.userId,
    this.department,
  }) : super(key: key);

  @override

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchSubjectsHandled(userId, department!),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No subjects handled.'));
        } else {
          List<Map<String, dynamic>> subjectsHandled = snapshot.data!;
          return ListView.builder(
            itemCount: subjectsHandled.length,
            itemBuilder: (context, index) {
              final subject = subjectsHandled[index];
              return ListTile(
                title: Text(subject['subjectName'] ?? ''),
                subtitle: Text('Year: ${subject['year'] ?? ''}, Section: ${subject['section'] ?? ''}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InternalMarksPage(
                          userId: userId,
                          department: department!,
                          year: '${subject['year']}',
                          section: '${subject['section']}',
                          subjectCode: '${subject['subjectCode']}',
                          subjectName: '${subject['subjectName']}',
                          subjectType: '${subject['subjectType']}'
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchSubjectsHandled(String userId,
      String department) async {
    List<Map<String, dynamic>> subjectsHandled = [];
    try {
      // Fetch staff's name from Firestore
      DocumentSnapshot<
          Map<String, dynamic>> staffSnapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(department)
          .collection('staff')
          .doc(userId)
          .get();

      if (staffSnapshot.exists) {
        String staffName = staffSnapshot['name'];

        // Fetch subjects handled by the staff
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('Department')
            .doc(department)
            .collection('class')
            .where('staffName', isEqualTo: staffName)
            .get();

        subjectsHandled = snapshot.docs.map((doc) => doc.data()).toList();
      } else {
        print('Staff document not found for user ID: $userId');
      }
    } catch (e) {
      print('Error fetching subjects handled: $e');
    }
    return subjectsHandled;
  }

}