import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignClassAdvisorsPage extends StatefulWidget {
  final String department;
  final String? loggedInUserRole;
  //final String userId;

  const AssignClassAdvisorsPage({Key? key, required this.department, this.loggedInUserRole}) : super(key: key);

  @override
  _AssignClassAdvisorsPageState createState() => _AssignClassAdvisorsPageState();
}

class _AssignClassAdvisorsPageState extends State<AssignClassAdvisorsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> staffList = [];

  String? _selectedYear;
  String? _selectedSection;

  @override
  void initState() {
    super.initState();
    fetchStaffMembers();
  }

  Future<void> fetchStaffMembers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Department')
          .doc(widget.department)
          .collection('staff')
          .where('role', isNotEqualTo: 'HOD') // Filter by department
          .get();
      setState(() {
        staffList = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print('Error fetching staff members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Class Advisors'),
      ),
      body: ListView.builder(
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(staffList[index]['name']),
            subtitle: Text(staffList[index]['role']),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Assign Class Advisor'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.department == 'ECE' || widget.department ==
                            'MECH') ...[
                          DropdownButtonFormField<String>(
                            value: _selectedSection,
                            decoration: InputDecoration(labelText: 'Section'),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSection = newValue;
                              });
                            },
                            items: <String>['A', 'B']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                        DropdownButtonFormField<String>(
                          value: _selectedYear,
                          decoration: InputDecoration(labelText: 'Year'),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedYear = newValue;
                            });
                          },
                          items: <String>['1', '2', '3', '4']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          saveClassAdvisorAssignment(
                            staffList[index]['name'],
                            widget.department,
                            _selectedYear!,
                            _selectedSection ??
                                '', // If section is null, pass an empty string
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text('Assign'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> saveClassAdvisorAssignment(
      String classAdvisorName,
      String department,
      String year,
      String section,
      ) async {
    try {
      QuerySnapshot<Map<String, dynamic>> existingAssignment = await _firestore
          .collection('Department')
          .doc(department)
          .collection('classAdvisors')
          .where('name', isEqualTo: classAdvisorName)
          .limit(1)
          .get();


      if (existingAssignment.docs.isNotEmpty) {
        String existingDocumentId = existingAssignment.docs.first.id;
        String existingClassAdvisor = existingAssignment.docs.first.get('name');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Class Advisor Already Assigned'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'The class advisor $existingClassAdvisor is already assigned to a class. Do you want to replace the existing assignment?'),
                  const SizedBox(height: 16),
                  Text('Note: Replacing the assignment will update the class details with the new assignment.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _firestore.collection('Department').doc(department)
                        .collection('classAdvisors').doc(existingDocumentId).update({
                      'year': year,
                      'section': section,
                      'name': classAdvisorName,
                    });


                    await _firestore
                        .collection('Department')
                        .doc(department)
                        .collection('staff')
                        .where('name', isEqualTo: classAdvisorName)
                        .get()
                        .then((querySnapshot) {
                      querySnapshot.docs.forEach((doc) {
                        doc.reference.update({'role': 'Class Advisor',  'year': year,
                          'section': section});
                      });
                    });


                    Navigator.of(context).pop();
                  },
                  child: Text('Replace'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
        return;
      }
      QuerySnapshot<Map<String, dynamic>> existingClassAdvisorAssignment = await _firestore
          .collection('Department')
          .doc(department)
          .collection('classAdvisors')
          .where('year', isEqualTo: year)
          .where('section', isEqualTo: section)
          .where('name', isNotEqualTo: classAdvisorName) // Exclude the current class advisor
          .get();


      if (existingClassAdvisorAssignment.docs.isNotEmpty) {
        String existingClassAdvisorName = existingClassAdvisorAssignment.docs.first.get('name');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('A Class Advisor Already Assigned'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A class advisor is already assigned to this class with the name: $existingClassAdvisorName.'),
                  Text('Do you want to replace the existing assignment with $classAdvisorName?'),
                  const SizedBox(height: 16),
                  Text('Note: Replacing the assignment will update the class details with the new assignment.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Update the existing class advisor assignment with the new class advisor name
                    await existingClassAdvisorAssignment.docs.first.reference.update({
                      'name': classAdvisorName,
                    });

                    // Update the role of the existing class advisor to 'Regular'
                    await _firestore
                        .collection('Department')
                        .doc(department)
                        .collection('staff')
                        .where('name', isEqualTo: existingClassAdvisorName)
                        .get()
                        .then((querySnapshot) {
                      querySnapshot.docs.forEach((doc) {
                        doc.reference.update({
                          'role': 'Regular Staff',
                          'year': FieldValue.delete(),
                          'section': FieldValue.delete(),
                        });
                      });
                    });

                    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('name', isEqualTo: existingClassAdvisorName)
                        .get();

                    for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot in querySnapshot.docs) {
                      DocumentReference docRef = docSnapshot.reference;


                      await docRef.update({'role': 'Regular Staff'});
                    }


                       await _firestore
                        .collection('Department')
                        .doc(department)
                        .collection('staff')
                        .where('name', isEqualTo: classAdvisorName)
                        .get()
                        .then((querySnapshot) {
                      querySnapshot.docs.forEach((doc) {
                        doc.reference.update({'role': 'Class Advisor',  'year': year,
                          'section': section});
                      });
                    });

                    QuerySnapshot<Map<String, dynamic>> querySnapshot2 = await FirebaseFirestore.instance
                        .collection('users')
                        .where('name', isEqualTo: classAdvisorName)
                        .get();

                    for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot in querySnapshot2.docs) {
                      DocumentReference docRef = docSnapshot.reference;


                      await docRef.update({'role': 'Class Advisor'});
                    }

                    Navigator.of(context).pop();
                  },
                  child: Text('Replace'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
        return;
      }


      await _firestore.collection('Department')
          .doc(department)
          .collection('classAdvisors')
          .add({
        'name': classAdvisorName,
        'year': year,
        'section': section,
      });
      await _firestore.collection('Department').doc(department)
          .collection('staff')
          .where('name', isEqualTo: classAdvisorName)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'role': 'Class Advisor',  'year': year,
            'section': section});
        });
      });

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: classAdvisorName)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot in querySnapshot.docs) {
        DocumentReference docRef = docSnapshot.reference;


        await docRef.update({'role': 'Class Advisor'});
      }

    } catch (e) {
      print('Error assigning class advisor: $e');
    }
  }
}