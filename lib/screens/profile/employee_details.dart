import 'package:flutter/material.dart';
import 'package:managify_hr/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  const EmployeeDetailsScreen({super.key});

  @override
  _EmployeeDetailsScreenState createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  // Consistent color scheme
  static const Color textColor = Color(0xFF2D3436);
  static const Color subtitleColor = Color(0xFF636E72);

  // User data variables
  String employeeFullName = '';
  String email = '';
  int phone = 0;
  String role = '';
  String jobRole = '';
  String empimg = '';
  String registercompanyname = '';
  String address = '';
  String birthDate = '';
  String joiningDate = '';
  String education = '';
  String gender = '';
  String aadharNo = '';
  String bloodGroup = '';
  String panCard = '';
  String department = '';
  String bankName = '';
  String bankAccountNo = '';
  String bankIfscCode = '';
  String branchName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeFullName = prefs.getString('fullName') ?? '';
      email = prefs.getString('email') ?? '';
      phone = prefs.getInt('phone') ?? 0;
      jobRole = prefs.getString('jobRole') ?? '';
      empimg = prefs.getString('empimg') ?? '';
      birthDate = prefs.getString('birthDate') ?? '';
      joiningDate = prefs.getString('joiningDate') ?? '';
      address = prefs.getString('address') ?? '';
      gender = prefs.getString('gender') ?? '';
      aadharNo = prefs.getString('aadharNo') ?? '';
      bloodGroup = prefs.getString('bloodGroup') ?? '';
      panCard = prefs.getString('panCard') ?? '';
      branchName = prefs.getString('branchName') ?? '';
      bankIfscCode = prefs.getString('bankIfscCode') ?? '';
      bankAccountNo = prefs.getString('bankAccountNo') ?? '';
      bankName = prefs.getString('bankName') ?? '';
      department = prefs.getString('department') ?? '';
      education = prefs.getString('education') ?? '';
    });
  }

  Widget _buildInfoTile(String label, String key, String value, bool isEditable) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : 'Not Provided',
          style: const TextStyle(color: subtitleColor, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Employee Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile('Full Name', 'fullName', employeeFullName, false),
            _buildInfoTile('Email', 'email', email, false),
            _buildInfoTile('Phone No', 'phone', phone.toString(), false),
            _buildInfoTile('Department', 'department', department, false),
            _buildInfoTile('Education', 'education', education, false),
            _buildInfoTile('Job Role', 'jobRole', jobRole, false),
            _buildInfoTile('Joining Date', 'joiningDate', joiningDate, false),
            _buildInfoTile('Address', 'address', address, false),
            _buildInfoTile('Birth Date', 'birthDate', birthDate, false),
            _buildInfoTile('Gender', 'gender', gender, false),
            _buildInfoTile('Blood Group', 'bloodGroup', bloodGroup, false),
            _buildInfoTile('Bank Name', 'bankName', bankName, false),
            _buildInfoTile('Branch Name', 'branchName', branchName, false),
            _buildInfoTile('Bank Account No', 'bankAccountNo', bankAccountNo, false),
            _buildInfoTile('Bank IFSC Code', 'bankIfscCode', bankIfscCode, false),
            _buildInfoTile('Aadhar No', 'aadharNo', aadharNo, false),
            _buildInfoTile('Pan Card', 'panCard', panCard, false),
            _buildInfoTile('Password', 'password', '**********', false),
          ],
        ),
      ),
    );
  }
}