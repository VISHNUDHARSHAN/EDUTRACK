import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectStaffAssignmentPage extends StatefulWidget {
  final String userId;
  final String? selectedYear;
  final String? selectedSection;
  final String? department;



   SubjectStaffAssignmentPage({
    Key? key,
    required this.userId,
    this.selectedYear,
    this.selectedSection,
    this.department,
  }) : super(key: key);

  @override
  _SubjectStaffAssignmentPageState createState() =>
      _SubjectStaffAssignmentPageState();
}

class _SubjectStaffAssignmentPageState extends State<SubjectStaffAssignmentPage> {
  String? _selectedYear;
  String? _selectedSection;
  List<Map<String, dynamic>> _staffList = [];
  String? _selectedStaffName;
  String? _subjectCode;
  String? _subjectName;
  String? _selectedType; // Added subject type
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedYear;
    _selectedSection = widget.selectedSection;
    fetchStaffList();
  }

  Future<void> fetchStaffList() async {
    try {
      if (widget.department != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('Department')
            .doc(widget.department!)
            .collection('staff')
            .where('role', isNotEqualTo: 'HOD')
            .get();
        setState(() {
          _staffList = querySnapshot.docs.map((doc) => doc.data()).toList();
        });
      } else {
        print('Error: selectedDepartment is null.');
      }
    } catch (e) {
      print('Error fetching staff list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subject Staff Assignment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Year: $_selectedYear',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
               Text(
                 'Section: $_selectedSection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedStaffName,
                decoration: InputDecoration(labelText: 'Select Staff'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStaffName = newValue;
                  });
                },
                items: _staffList.map<DropdownMenuItem<String>>((staff) {
                  return DropdownMenuItem<String>(
                    value: staff['name'],
                    child: Text(staff['name']),
                  );
                }).toList(),
                onTap: () {
                  // Check for duplicate names in _staffList
                  final names = _staffList.map((staff) => staff['name']).toSet();
                  assert(names.length == _staffList.length, 'Duplicate names found in _staffList');
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Subject Code'),
                onChanged: (value) {
                  setState(() {
                    _subjectCode = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Subject Name'),
                onChanged: (value) {
                  setState(() {
                    _subjectName = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(labelText: 'Type'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                    _errorText = null; // Clear any previous error message when department changes
                  });
                },
                items: <String>['TC', 'LC', 'TLC'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  assignSubjectStaff();
                },
                child: Text('Assign Subject Staff'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Future<void> assignSubjectStaff() async {
    try {
      // Check if the staff is already assigned to a subject in the same class
      bool isStaffAssigned = await checkStaffAssignment();

      // If staff is already assigned, prompt the user to continue or cancel
      if (isStaffAssigned) {
        bool continueAssignment = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Warning'),
              content: Text('This staff is already assigned to a subject in this class. Do you want to continue?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false to indicate cancellation
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true to indicate continuation
                  },
                  child: Text('Continue'),
                ),
              ],
            );
          },
        );

        // If user chooses to cancel, exit the function
        if (!continueAssignment) return;
      }

      // // Proceed with subject staff assignment
      // await FirebaseFirestore.instance.collection('Department').doc(widget.department).collection('subject').add({
      //   'code': _subjectCode,
      //   'name': _subjectName,
      //   'type': _selectedType,
      //   'staff': _selectedStaffName,
      //   'year': _selectedYear,
      //   'section': _selectedSection
      // });

      await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('class')
          .add({
        'year': _selectedYear,
        'section': _selectedSection,
        'subjectCode': _subjectCode,
        'subjectName': _subjectName,
        'subjectType': _selectedType,
        'staffName': _selectedStaffName,
        'classAdvisorId': widget.userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Subject staff assigned successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset values only after successful assignment
      setState(() {
        _subjectCode = '';
        _subjectName = '';
      });

    } catch (e) {
      print('Error assigning subject staff: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning subject staff. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> checkStaffAssignment() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Department')
          .doc(widget.department)
          .collection('class')
          .where('year', isEqualTo: _selectedYear)
          .where('section', isEqualTo: _selectedSection)
          .where('staffName', isEqualTo: _selectedStaffName)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking staff assignment: $e');
      return false; // Return false in case of error
    }
  }
}


