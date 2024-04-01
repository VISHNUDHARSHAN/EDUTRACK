import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empowereed2/role/classadvisor/viewsubjects.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassInfo {
  final String className;
  final String advisorName;
  final int numberOfStudents;

  ClassInfo({
    required this.className,
    required this.advisorName,
    required this.numberOfStudents,
  });
}

class ClassDetails extends StatefulWidget {
  final String userId;
  final String? department;

  const ClassDetails({Key? key, required this.userId, this.department}) : super(key: key);

  @override
  _ClassDetailsState createState() => _ClassDetailsState();
}

class _ClassDetailsState extends State<ClassDetails> {
  late List<ClassInfo> _classInfoList = [];

  @override
  void initState() {
    super.initState();
    _fetchClassInfo();
  }

  Future<void> _fetchClassInfo() async {
    try {
      QuerySnapshot<Map<String, dynamic>> classAdvisorsSnapshot =
      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('classAdvisors')
          .get();

      List<ClassInfo> classInfoList = [];
      for (var doc in classAdvisorsSnapshot.docs) {
        String advisorName = doc['name'];
        String year = doc['year'];
        String section = doc['section'];
        QuerySnapshot<Map<String, dynamic>> studentSnapshot = await FirebaseFirestore.instance
            .collection('Department')
            .doc(widget.department)
            .collection('student')
            .where('academicYear', isEqualTo: year)
            .where('section', isEqualTo: section)
            .get();
        int numberOfStudents = studentSnapshot.size;
        classInfoList.add(
          ClassInfo(
            className: '$year $section',
            advisorName: advisorName,
            numberOfStudents: numberOfStudents,
          ),
        );
      }
      setState(() {
        _classInfoList = classInfoList;
      });
    } catch (e) {
      print('Error fetching class info: $e');
    }
  }

  Future<void> _incrementYear(ClassInfo classInfo) async {
    if (classInfo.className.startsWith('4')) {
      _promptAuthenticationAndDeleteYear(classInfo);
    } else {
      bool nextYearExists = await _checkNextYearClassExists(classInfo);
      if (!nextYearExists) {
        _promptAuthenticationAndIncrementYear(classInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The class for the next academic year already exists.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _promptAuthenticationAndDeleteYear(ClassInfo classInfo) async {
    showDialog(
      context: context,
      builder: (context) {
        String enteredEmail = '';
        String enteredPassword = '';

        return AlertDialog(
          title: Text('Authentication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  enteredEmail = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  enteredPassword = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFinalYearClass(enteredEmail, enteredPassword);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFinalYearClass(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('classAdvisors')
          .where('year', isEqualTo: '4')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('student')
          .where('academicYear', isEqualTo: '4')
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      await _fetchClassInfo();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Final year class deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting final year class: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting final year class. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _promptAuthenticationAndIncrementYear(ClassInfo classInfo) async {
    showDialog(
      context: context,
      builder: (context) {
        String enteredEmail = '';
        String enteredPassword = '';

        return AlertDialog(
          title: Text('Authentication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  enteredEmail = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {
                  enteredPassword = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _authenticateAndIncrementYear(enteredEmail, enteredPassword, classInfo);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkNextYearClassExists(ClassInfo classInfo) async {
    String nextYear = (int.parse(classInfo.className.split(' ')[0]) + 1).toString();
    QuerySnapshot<Map<String, dynamic>> nextYearSnapshot = await FirebaseFirestore.instance
        .collection('Department')
        .doc(widget.department)
        .collection('classAdvisors')
        .where('year', isEqualTo: nextYear)
        .get();
    return nextYearSnapshot.docs.isNotEmpty;
  }

  Future<void> _authenticateAndIncrementYear(String email, String password, ClassInfo classInfo) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _incrementYearAfterAuthentication(classInfo);
    } catch (e) {
      print('Authentication Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _incrementYearAfterAuthentication(ClassInfo classInfo) async {
    try {
      QuerySnapshot<Map<String, dynamic>> advisorSnapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('classAdvisors')
          .where('name', isEqualTo: classInfo.advisorName)
          .where('year', isEqualTo: classInfo.className.split(' ')[0])
          .get();
      for (var doc in advisorSnapshot.docs) {
        await doc.reference.update({'year': (int.parse(classInfo.className.split(' ')[0]) + 1).toString()});
      }

      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('student')
          .where('academicYear', isEqualTo: classInfo.className.split(' ')[0])
          .where('section', isEqualTo: classInfo.className.split(' ')[1])
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({'academicYear': (int.parse(classInfo.className.split(' ')[0]) + 1).toString()});
        });
      });

      await _fetchClassInfo();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class promoted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error promoting class: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error promoting class. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOD Dashboard'),
      ),
      body: ListView.builder(
        itemCount: _classInfoList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_classInfoList[index].className),
            subtitle: Text(
              'Advisor: ${_classInfoList[index].advisorName}\nStudents: ${_classInfoList[index].numberOfStudents}',
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _incrementYear(_classInfoList[index]);
              },
              child: Text('Promote'),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewSubjectsPage(
                    department: widget.department!,
                    year: _classInfoList[index].className.split(' ')[0],
                    section: _classInfoList[index].className.split(' ')[1],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
