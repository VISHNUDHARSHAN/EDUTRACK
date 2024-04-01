// signup_options_page.dart

import 'package:flutter/material.dart';
import 'staff_signup_page.dart';
import 'student_signup_page.dart';

class SignUpOptionsPage extends StatelessWidget {
  const SignUpOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StaffSignUpPage(),
                  ),
                );
              },
              child: const Text('Staff Sign Up'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentSignUpPage(),
                  ),
                );
              },
              child: const Text('Student Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
