import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:empowereed2/role/profilepage.dart';
import '../../login_page.dart';
import 'assign_class_advisor.dart';
import 'package:empowereed2/role/view_staff_details.dart';
import 'classes.dart';
import 'package:empowereed2/role/hod/viewfeedback.dart';


class HODDashboard extends StatefulWidget {
  final String userId;
  final String? selectedDepartment; // Include selectedDepartment parameter

  const HODDashboard({Key? key, required this.userId, this.selectedDepartment}) : super(key: key);

  @override
  _HODDashboardState createState() => _HODDashboardState();
}



class _HODDashboardState extends State<HODDashboard> {
  String? _selectedDepartment; // Initialize _selectedDepartment

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.selectedDepartment;
  }
  @override
  Widget build(BuildContext context) {

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('HOD Dashboard'),
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
                'Welcome HOD!',
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
              title: Text('Assign Class Advisors'),
              onTap: () {
                if (_selectedDepartment != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignClassAdvisorsPage(department: _selectedDepartment!),
                    ),
                  );
                }
              },
            ),ListTile(
              title: Text('Feedbacks'),
              onTap: () {
                if (_selectedDepartment != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HodFeedbackPage(department: _selectedDepartment!),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, HOD!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedDepartment != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignClassAdvisorsPage(department: _selectedDepartment!),
                    ),
                  );
                } else {
                  // Handle the case where department information is not available
                }
              },
              child: const Text('Assign Class Advisors'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedDepartment != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewStaffDetails(userId: widget.userId,department: _selectedDepartment!),
                    ),
                  );
                } else {
                  // Handle the case where department information is not available
                }
              },
              child: const Text('View Staff Data'),
            ),
            const SizedBox(height: 20),ElevatedButton(
              onPressed: () {
                if (_selectedDepartment != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetails(userId: widget.userId,department: _selectedDepartment!),
                    ),
                  );
                } else {
                  // Handle the case where department information is not available
                }
              },
              child: const Text('View Student Data'),
            ),
          ],
        ),
      ),
    );
  }
}
