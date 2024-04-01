import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgot_password_page.dart';
import 'role/hod/hod_dashboard.dart';
import 'role/classadvisor/faculty_advisor_dashboard.dart';
import 'role/regular/regular_staff_dashboard.dart';
import 'student_dashboard.dart';

class LoginPage extends StatefulWidget {
  final String? selectedDepartment; // Include selectedDepartment parameter

  const LoginPage({Key? key, this.selectedDepartment}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  String? _selectedDepartment;
  String? _errorText;

  Future<void> _signIn(
      BuildContext context,
      String email,
      String password,
      String? department,
      ) async {
    String errorMessage = ''; // Variable to hold the error message

    try {
      if (department == null) {
        setState(() {
          _errorText = 'Please select your department';
        });
        return;
      }

      _selectedDepartment = department;

      // Perform sign-in with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user exists in the 'students' collection
      DocumentSnapshot<Map<String, dynamic>> studentData = await FirebaseFirestore.instance
          .collection('Department')
          .doc(department)
          .collection('student')
          .doc(userCredential.user!.uid)
          .get();

      // Check if the user exists in the 'staff' collection
      DocumentSnapshot<Map<String, dynamic>> staffData = await FirebaseFirestore.instance
          .collection('Department')
          .doc(department)
          .collection('staff')
          .doc(userCredential.user!.uid)
          .get();

      if (studentData.exists) {
        // Redirect to student dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentDashboardPage(userId: userCredential.user!.uid,selectedDepartment: _selectedDepartment

          )),
        );
      } else if (staffData.exists) {
        // Redirect to staff dashboard based on user's role
        String userRole = staffData['role'];
        if (userRole == 'HOD') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HODDashboard(userId: userCredential.user!.uid, selectedDepartment: _selectedDepartment),),);

        } else if (userRole == 'Class Advisor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ClassAdvisorDashboard(userId: userCredential.user!.uid, selectedDepartment: _selectedDepartment),),);
        } else if (userRole == 'Regular Staff') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RegularStaffDashboard(userId: userCredential.user!.uid, selectedDepartment: _selectedDepartment)),
          );
        } else {
          errorMessage = 'Unknown or unsupported role: $userRole';
        }
      } else {
        errorMessage = 'User not found in either students or staff collection';
      }
    } catch (e) {
      errorMessage = 'Error signing in: $e';
      print(errorMessage);
    }

    // Show error message on the screen
    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: InputDecoration(labelText: 'Department'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDepartment = newValue;
                    _errorText = null; // Clear any previous error message when department changes
                  });
                },
                items: <String>['ECE', 'CSE', 'MECH', 'EEE', 'CIVIL']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _signIn(
                    context,
                    emailController.text,
                    passwordController.text,
                    _selectedDepartment,
                  ); // Pass the selected department
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  _errorText!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
