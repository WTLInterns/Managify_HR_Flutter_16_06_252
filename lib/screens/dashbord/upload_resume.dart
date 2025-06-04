import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:hrm_dump_flutter/theme/colors.dart';
import 'package:hrm_dump_flutter/widget/custom_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadResumeScreen extends StatefulWidget {
  const UploadResumeScreen({super.key});

  @override
  State<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _resumeFile;
  int empId = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    empId = prefs.getInt('empId') ?? 0;
  }

  Future<void> _pickResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_nameController.text.isEmpty || _resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Job Title and upload resume'),
        ),
      );
      return;
    }
    print(
      "Uploading file: ${_resumeFile!.path}, jobRole: ${_nameController.text}",
    );

    try {
      // Use appropriate URL
      final uri = Uri.parse(
        'https://api.managifyhr.com/api/resume/upload/$empId',
      );

      print(
        "Uploading fileeee: ${_resumeFile!.path}, jobRole: ${_nameController.text}",
      );

      final request =
          http.MultipartRequest('POST', uri)
            ..fields['jobRole'] = _nameController.text
            ..files.add(
              await http.MultipartFile.fromPath('file', _resumeFile!.path),
            );

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      print("Status: ${response.statusCode}, Body: $responseBody");

      print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');

      if (response.statusCode == 200) {
        print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');

        // Reset fields after success
        _nameController.clear();
        setState(() {
          _resumeFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resume submitted successfully'),
            backgroundColor: AppColor.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColor.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Upload Resume',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 400,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade100, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 70,
                      right: 20,
                      left: 20,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [
                        UiHelper.customTextField(
                          controller: _nameController,
                          labelText: "Enter Job Title",
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickResume,
                          icon: const Icon(Icons.upload_file),
                          label: const Text("Pick Resume"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _resumeFile != null
                              ? "Selected: ${_resumeFile!.path.split('/').last}"
                              : "No file selected",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 50),
                        UiHelper.customButton(
                          callback: _submitApplication,
                          buttonName: "Submit Application",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
