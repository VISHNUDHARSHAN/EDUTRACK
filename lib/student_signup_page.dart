import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class StudentSignUpPage extends StatefulWidget {
  StudentSignUpPage({Key? key}) : super(key: key);

  @override
  _StudentSignUpPageState createState() => _StudentSignUpPageState();
}

class _StudentSignUpPageState extends State<StudentSignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController registerNumberController =
  TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController academicYearController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  String? _errorText;
  String? _selectedDepartment;
  String? _selectedSection;
  String? _selectedYear;


  List<String> eceMechSections = ['A', 'B']; // Sections for 'ECE' and 'MECH'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: registerNumberController,
                  decoration: const InputDecoration(labelText: 'Register Number *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your register number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
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
                TextFormField(
                  controller: dateOfBirthController,
                  decoration: const InputDecoration(labelText: 'Date of Birth (dd/mm/yyyy) *'),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    if (!RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(value)) {
                      return 'Please enter date in format dd/mm/yyyy';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: InputDecoration(labelText: 'Year'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedYear = newValue;
                    });
                  },
                  items: <String>[
                    '1',
                    '2',
                    '3',
                    '4',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: InputDecoration(labelText: 'Department'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDepartment = newValue;
                      // Clear section value when department changes
                      sectionController.text = '';
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

                if (_selectedDepartment == 'ECE' || _selectedDepartment == 'MECH')
                  Column(
                    children: [
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: _selectedSection, // Set initial value to _selectedSection
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSection = newValue; // Update selected section
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Section'),
                        items: eceMechSections.map((section) {
                          return DropdownMenuItem<String>(
                            value: section,
                            child: Text(section),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your section';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'New Password *'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm Password *'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Sign up the user with Firebase Authentication
                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        // If signup is successful, insert user data into Firestore
                        if (userCredential.user != null) {

                          await FirebaseFirestore.instance.collection('users')
                              .doc(userCredential.user!.uid)
                              .set({
                            'name': nameController.text,
                            'department': _selectedDepartment,
                            'role': 'student',
                          });

                          await FirebaseFirestore.instance.collection('Department')
                              .doc(_selectedDepartment)
                              .collection('student')
                              .doc(userCredential.user!.uid)
                             .set({
                            'registerNumber': registerNumberController.text,
                            'name': nameController.text,
                            'email': emailController.text,
                            'dateOfBirth': dateOfBirthController.text,
                            'academicYear': _selectedYear,
                            'department': _selectedDepartment,
                            'section': _selectedSection,
                            'userId': userCredential.user!.uid,
                          });

                          // Navigate to the login page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>  LoginPage()),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'email-already-in-use') {
                          setState(() {
                            _errorText = 'The email address is already in use. Please use a different email address.';
                          });
                        } else {
                          setState(() {
                            _errorText = e.message;
                          });
                        }
                      } catch (e) {
                        // Handle other errors
                        setState(() {
                          _errorText = e.toString();
                        });
                      }
                    }
                  },
                  child: const Text('Sign Up'),
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
      ),
    );
  }
}
