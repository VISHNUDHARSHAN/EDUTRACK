import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class StaffSignUpPage extends StatefulWidget {
  const StaffSignUpPage({Key? key}) : super(key: key);

  @override
  _StaffSignUpPageState createState() => _StaffSignUpPageState();
}

class _StaffSignUpPageState extends State<StaffSignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  String? _selectedDepartment;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Sign Up'),
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
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  // keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                 // keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: InputDecoration(labelText: 'Department'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDepartment = newValue;
                    });
                  },
                  items: <String>[
                    'ECE',
                    'CSE',
                    'MECH',
                    'EEE',
                    'CIVIL'
                  ].map<DropdownMenuItem<String>>((String value) {
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
                  controller: passwordController,
                  decoration:
                  const InputDecoration(labelText: 'New Password'),
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
                  decoration:
                  const InputDecoration(labelText: 'Confirm Password'),
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
                            'role': 'Regular Staff',
                          });

                          await FirebaseFirestore.instance.collection('Department')
                              .doc(_selectedDepartment)
                              .collection('staff')
                              .doc(userCredential.user!.uid)
                              .set({
                            'name': nameController.text,
                            'email': emailController.text,
                            'role' : 'Regular Staff'
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
