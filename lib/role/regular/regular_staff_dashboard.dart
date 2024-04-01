import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empowereed2/role/profilepage.dart';
import 'package:empowereed2/role/internalmarks.dart';

import '../../login_page.dart';

class RegularStaffDashboard extends StatefulWidget {
  final String userId;
  final String? selectedDepartment;

  const RegularStaffDashboard({
    Key? key,
    required this.userId,
    this.selectedDepartment,
  }) : super(key: key);

  @override
  _RegularStaffDashboardState createState() => _RegularStaffDashboardState();
}

class _RegularStaffDashboardState extends State<RegularStaffDashboard> {
  String? _selectedDepartment; // Initialize _selectedDepartment

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.selectedDepartment;

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
        title: const Text('Regular Staff Dashboard'),
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
              title: Text('Sign Out'),
              onTap: _signOut,
            ),

          ],
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Regular Staff!',
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

  Future<List<Map<String, dynamic>>> fetchSubjectsHandled(String userId, String department) async {
    List<Map<String, dynamic>> subjectsHandled = [];
    try {
      // Fetch staff's name from Firestore
      DocumentSnapshot<Map<String, dynamic>> staffSnapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(department)
          .collection('staff')
          .doc(userId)
          .get();

      if (staffSnapshot.exists) {
        String staffName = staffSnapshot['name'];

        // Fetch subjects handled by the staff
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('Department')
            .doc(department)
            .collection('class')
            .where('staffName', isEqualTo: staffName)
            .get();

        subjectsHandled = snapshot.docs.map((doc) => doc.data()).toList();
        print('$department');
      } else {
        print('Staff document not found for user ID: $userId');
      }
    } catch (e) {
      print('Error fetching subjects handled: $e');
    }
    return subjectsHandled;
  }
}



