import 'package:flutter/material.dart';
import 'package:hrm_dump_flutter/models/job_opening_model.dart';
import 'package:hrm_dump_flutter/screens/dashbord/upload_resume.dart';
import 'package:hrm_dump_flutter/widget/custom_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JobOpeningGridScreen extends StatefulWidget {
  const JobOpeningGridScreen({super.key});

  @override
  State<JobOpeningGridScreen> createState() => _JobOpeningGridScreenState();
}

class _JobOpeningGridScreenState extends State<JobOpeningGridScreen> {
  List<JobOpening> _jobOpenings = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _companyLogo;
  int empId = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _companyLogo = prefs.getString("company_logo");
    empId = prefs.getInt('empId') ?? 0;

    try {
      final response = await http.get(
        Uri.parse('https://api.managifyhr.com/api/openings/$empId'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          setState(() {
            _jobOpenings = decoded.map((e) => JobOpening.fromJson(e)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Unexpected JSON format";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed with status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching job openings: $e";
        _isLoading = false;
      });
    }
  }

  Widget _buildJobCard(BuildContext context, JobOpening job) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, 5),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            job.role ?? "N/A",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          _buildJobField("Location", job.location ?? "-", Icons.location_on),
          _buildJobField(
            "Positions",
            job.positions?.toStringAsFixed(0) ?? "-",
            Icons.people,
          ),
          _buildJobField("Experience", job.exprience ?? "-", Icons.school),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
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
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_companyLogo != null)
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _companyLogo!,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                job.role ?? "Job Details",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildDialogRow(
                                "Company",
                                job.subadmin?.registercompanyname ?? "-",
                              ),
                              _buildDialogRow('Role', job.role ?? "-"),
                              _buildDialogRow(
                                "Experience",
                                job.exprience ?? "-",
                              ),
                              _buildDialogRow("Location", job.location ?? "-"),
                              _buildDialogRow("Work Type", job.workType ?? "-"),
                              _buildDialogRow(
                                "Positions",
                                job.positions?.toStringAsFixed(0) ?? "-",
                              ),
                              _buildDialogRow("Site Mode", job.siteMode ?? "-"),
                              _buildDialogRow(
                                "Description",
                                job.description ?? "-",
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  UiHelper.customButton(
                                    callback: () => Navigator.of(context).pop(),
                                    buttonName: "Cancel",
                                  ),
                                  const SizedBox(width: 8),
                                  UiHelper.customButton(
                                    callback:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const UploadResumeScreen(),
                                          ),
                                        ),
                                    buttonName: "Upload Resume",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text("Apply Now"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size.fromHeight(36),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobField(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$title: $value",
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, softWrap: true)),
        ],
      ),
    );
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
          'Job Openings',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : _jobOpenings.isEmpty
              ? const Center(
                child: Text(
                  'Job Openings are not Available',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.76,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _jobOpenings.length,
                itemBuilder: (context, index) {
                  return _buildJobCard(context, _jobOpenings[index]);
                },
              ),
    );
  }
}
