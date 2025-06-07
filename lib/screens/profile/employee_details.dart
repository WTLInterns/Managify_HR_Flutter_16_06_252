import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  @override
  _EmployeeDetailsScreenState createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  final picker = ImagePicker();
  File? empImg;

  Map<String, String> formData = {
    'firstName': '',
    'lastName': '',
    'email': '',
    'phone': '',
    'aadharNo': '',
    'panCard': '',
    'education': '',
    'bloodGroup': '',
    'jobRole': '',
    'gender': '',
    'address': '',
    'birthDate': '',
    'joiningDate': '',
    'status': '',
    'bankName': '',
    'bankAccountNo': '',
    'bankIfscCode': '',
    'branchName': '',
    'salary': '',
    'department': '',
    'password': '',
  };

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      formData.forEach((key, _) {
        formData[key] = prefs.getString(key) ?? '';
      });

      String? empImgPath = prefs.getString('empImg');
      if (empImgPath != null && empImgPath.isNotEmpty) {
        empImg = File(empImgPath);
      }
    });
  }

  Widget buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        tileColor: Colors.grey[200],
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : 'N/A'),
      ),
    );
  }

  Widget buildImageSection(String label, File? file) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          if (file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(file, width: 120, height: 120, fit: BoxFit.cover),
            )
          else
            Text("No image found"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Details")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildImageSection("Employee Image", empImg),
            SizedBox(height: 16),
            buildInfoTile("First Name", formData['firstName'] ?? ''),
            buildInfoTile("Last Name", formData['lastName'] ?? ''),
            buildInfoTile("Email", formData['email'] ?? ''),
            buildInfoTile("Phone", formData['phone'] ?? ''),
            buildInfoTile("Aadhar No", formData['aadharNo'] ?? ''),
            buildInfoTile("PAN Card", formData['panCard'] ?? ''),
            buildInfoTile("Education", formData['education'] ?? ''),
            buildInfoTile("Blood Group", formData['bloodGroup'] ?? ''),
            buildInfoTile("Job Role", formData['jobRole'] ?? ''),
            buildInfoTile("Gender", formData['gender'] ?? ''),
            buildInfoTile("Address", formData['address'] ?? ''),
            buildInfoTile("Birth Date", formData['birthDate'] ?? ''),
            buildInfoTile("Joining Date", formData['joiningDate'] ?? ''),
            buildInfoTile("Status", formData['status'] ?? ''),
            buildInfoTile("Bank Name", formData['bankName'] ?? ''),
            buildInfoTile("Account No", formData['bankAccountNo'] ?? ''),
            buildInfoTile("IFSC Code", formData['bankIfscCode'] ?? ''),
            buildInfoTile("Branch", formData['branchName'] ?? ''),
            buildInfoTile("Salary", formData['salary'] ?? ''),
            buildInfoTile("Department", formData['department'] ?? ''),
            buildInfoTile("Password", formData['password'] ?? ''),
          ],
        ),
      ),
    );
  }
}
