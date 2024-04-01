import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empowereed2/role/subjectshandled.dart';

class ViewStaffDetails extends StatefulWidget {
  final String department;
  final String? userId;

  const ViewStaffDetails({Key? key, required this.department, this.userId}) : super(key: key);

  @override
  _ViewStaffDetailsState createState() => _ViewStaffDetailsState();
}

class _ViewStaffDetailsState extends State<ViewStaffDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> staffList = [];

  @override
  void initState() {
    super.initState();
    fetchStaffMembers();
  }

  Future<void> fetchStaffMembers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> staffSnapshot = await _firestore
          .collection('Department')
          .doc(widget.department)
          .collection('staff')
          .where('role', isNotEqualTo: 'HOD') // Exclude HOD
          .get();

      List<Map<String, dynamic>> staffDetails = [];
      for (var staffDoc in staffSnapshot.docs) {
        String staffName = staffDoc['name'];
        String staffRole = staffDoc['role'];
        String? staffYear;
        String? staffSection;
        if (staffRole == 'Class Advisor') {
          staffYear = staffDoc['year'];
          staffSection = staffDoc['section'];
        }

        staffDetails.add({
          'name': staffName,
          'role': staffRole,
          'staffYear': staffYear,
          'staffSection': staffSection,
        });
      }

      setState(() {
        staffList = staffDetails;
      });
    } catch (e) {
      print('Error fetching staff members: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Details'),
      ),
      body: ListView.builder(
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${staffList[index]['name']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubjectsHandledPage(
                    userId: widget.userId!,
                    department: widget.department,
                    staffDetails: staffList[index],
                  ),
                ),
              );
            },
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (staffList[index]['role'] == 'Class Advisor')
                  Text('${staffList[index]['role']}'),
                if (staffList[index]['role'] == 'Class Advisor')
                  Text('Class: ${staffList[index]['staffYear']} ${staffList[index]['staffSection']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}


