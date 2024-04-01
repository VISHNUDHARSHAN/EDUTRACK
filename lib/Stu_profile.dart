import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfilePage extends StatelessWidget {
  final String userId;
  final String? department;

  const StudentProfilePage({Key? key, required this.userId, required this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Department')
          .doc(department)
          .collection('student')
          .doc(userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Extract student information from the document snapshot
        var data = snapshot.data!.data() as Map<String, dynamic>;
        String name = data['name'];
        String registerNumber = data['registerNumber'];
        String email = data['email'];
        String dateOfBirth = data['dateOfBirth'];
        String academicYear = data['academicYear'];
        String section = data['section'];

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                _buildProfileRow('Name', name),
                _buildProfileRow('Register Number', registerNumber),
                _buildProfileRow('Email', email),
                _buildProfileRow('Date of Birth', dateOfBirth),
                _buildProfileRow('Academic Year', academicYear),
                _buildProfileRow('Section', section),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            resetPassword(context, email);
          },
          child: Text('Reset Password'),
        ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120, // Adjust this width as needed for the labels
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }


  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $email'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending password reset email: $e'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}
