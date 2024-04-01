import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final String? department;
  final String userId;

  const ProfilePage({Key? key, required this.userId, this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Department').doc(department).collection('staff').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while fetching data
        }
        if (snapshot.hasError)
        {
          return Text('Error: ${snapshot.error}');
        }

        // Extract user information from the document snapshot
        var data = snapshot.data!.data() as Map<String, dynamic>;
        String name = data['name'];
        String email = data['email'];

        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(' $name'),
                Text(' $email'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    resetPassword(context, email);
                  },
                  child: const Text('Reset Password'),
                ),
              ],
            ),
          ),
        );
      },
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
