import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empowereed2/role/classadvisor/faculty_advisor_dashboard.dart';
import 'package:empowereed2/role/hod/hod_dashboard.dart';
import 'package:empowereed2/role/regular/regular_staff_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'welcome_page.dart';
import 'student_dashboard.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTrack',
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 24, color: Colors.blue),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (userSnapshot.hasError) {
            return Scaffold(body: Center(child: Text('Error: ${userSnapshot.error}')));
          } else if (userSnapshot.data == null) {

            return WelcomePage();
          } else {
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userSnapshot.data!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(body: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
                } else {
                  final userRole = snapshot.data?.get('role');
                  final department = snapshot.data?.get('department');
                  if (userRole == null) {
                    // User role not found, redirect to WelcomePage
                    return const WelcomePage();
                  } else {
                    switch (userRole) {
                      case 'student':
                        return StudentDashboardPage(userId: userSnapshot.data!.uid, selectedDepartment: department);
                      case 'HOD':
                        return HODDashboard(userId: userSnapshot.data!.uid, selectedDepartment: department);
                      case 'Class Advisor':
                        return ClassAdvisorDashboard(userId: userSnapshot.data!.uid, selectedDepartment: department);
                      case 'Regular Staff':
                        return RegularStaffDashboard(userId: userSnapshot.data!.uid, selectedDepartment: department);
                      default:
                      // Unknown role, redirect to WelcomePage
                        return const WelcomePage();
                    }
                  }
                }
              },
            );
          }
        },
      ),
    );
  }
}


