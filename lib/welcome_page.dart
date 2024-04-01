// welcome_page.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_options_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/logo.jpg',
                width: 100.0,
                height: 100.0,
              ),
            ),

            Text(
              'Welcome to EduTrack!',
              style: Theme.of(context).textTheme.displayLarge,
            ),

            const SizedBox(height: 40.0),

            // Sign In button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  LoginPage(),
                  ),
                );
              },
              child: const Text('Sign In'),
            ),

            const SizedBox(height: 16.0),

            // Create Account button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpOptionsPage(),
                  ),
                );
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}