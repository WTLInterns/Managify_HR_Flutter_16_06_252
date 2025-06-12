import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  const EmployeeDetailsScreen({super.key});

  @override
  _EmployeeDetailsScreenState createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _empImg;

  // Consistent color scheme
  static const Color primaryColor = Color(0xFF0077B6);
  static const Color accentColor = Color(0xFF00B4D8);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color textColor = Color(0xFF2D3436);
  static const Color subtitleColor = Color(0xFF636E72);

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

  final List<String> editableFields = [
    'firstName',
    'lastName',
    'phone',
    'education',
    'address'
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      formData.forEach((key, _) {
        formData[key] = prefs.getString(key) ?? '';
      });

      final empImgPath = prefs.getString('empImg');
      if (empImgPath != null && empImgPath.isNotEmpty) {
        final file = File(empImgPath);
        if (file.existsSync()) {
          _empImg = file;
        }
      }
    });
  }

  Future<void> _saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }


  void _showEditDialog(String key, String currentValue, String label) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $label',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: textColor)),
        content: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: subtitleColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: accentColor, width: 2),
            ),
          ),
          cursorColor: accentColor,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                formData[key] = controller.text;
                _saveData(key, controller.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String key, String value, bool isEditable) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        trailing: isEditable
            ? IconButton(
          icon: const Icon(Icons.edit, color: primaryColor),
          onPressed: () => _showEditDialog(key, value, label),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
          children: [
            _buildInfoTile(
                'First Name', 'firstName', formData['firstName']!, false),
            _buildInfoTile(
                'Last Name', 'lastName', formData['lastName']!, false),
            _buildInfoTile('Email', 'email', formData['email']!, false),
            _buildInfoTile('Phone', 'phone', formData['phone']!, false),
            _buildInfoTile(
                'Aadhar No', 'aadharNo', formData['aadharNo']!, false),
            _buildInfoTile(
                'PAN Card', 'panCard', formData['panCard']!, false),
            _buildInfoTile(
                'Education', 'education', formData['education']!, false),
            _buildInfoTile('Blood Group', 'bloodGroup',
                formData['bloodGroup']!, false),
            _buildInfoTile(
                'Job Role', 'jobRole', formData['jobRole']!, false),
            _buildInfoTile('Gender', 'gender', formData['gender']!, false),
            _buildInfoTile(
                'Address', 'address', formData['address']!, false),
            _buildInfoTile('Birth Date', 'birthDate',
                formData['birthDate']!, false),
            _buildInfoTile('Joining Date', 'joiningDate',
                formData['joiningDate']!, false),
            _buildInfoTile('Branch', 'branchName',
                formData['branchName']!, false),
            _buildInfoTile('Department', 'department',
                formData['department']!, false),
            _buildInfoTile(
                'Password', 'password', formData['password']!, false),
          ],
        ),
      ),
    );
  }
}