import 'package:flutter/material.dart';
import 'package:hrm_dump_flutter/screens/dashbord/job_openings.dart';
import 'package:hrm_dump_flutter/screens/dashbord/leave_records.dart';
import 'package:hrm_dump_flutter/screens/dashbord/attendances_form.dart';
import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
import 'package:hrm_dump_flutter/screens/dashbord/leave_screen.dart';
import 'package:hrm_dump_flutter/screens/dashbord/upload_resume.dart';
import 'package:hrm_dump_flutter/screens/login/login.dart';
import 'package:hrm_dump_flutter/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String employeeFullName = '';
  String profileImage = '';
  String email = '';
  int subadminId = 0;
  String role = '';
  String jobRole = '';
  String empimg = '';
  String registercompanyname = '';
  bool _isJobsExpanded = false;

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
      subadminId = prefs.getInt('subadminId') ?? 0;
      role = prefs.getString('role') ?? '';
      jobRole = prefs.getString('jobRole') ?? '';
      empimg = prefs.getString('empimg') ?? '';
      registercompanyname = prefs.getString('registercompanyname') ?? '';
      profileImage = prefs.getString('profileImage') ?? '';
    });
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath && (uri.isScheme('http') || uri.isScheme('https'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(child: Text('Dashboard', style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
      body: _buildDashboardContent(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade700),
            accountName: Text(employeeFullName),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _isValidUrl(empimg) ? NetworkImage(empimg) : null,
              child: !_isValidUrl(empimg) ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blueGrey),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Profile'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.event_available, color: Colors.blue),
            title: const Text('Attendance'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceFormPage())),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.blue),
            title: const Text('Attendance Records'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendancesRecordsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.event_busy, color: Colors.blue),
            title: const Text('Leave'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeaveScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.blue),
            title: const Text('Leave Records'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaveRecordsTable(subadminId: subadminId, name: employeeFullName),
                ),
              );
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.work_outline, color: Colors.blue),
            title: const Text('Jobs'),
            trailing: Icon(
              _isJobsExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
            initiallyExpanded: _isJobsExpanded,
            onExpansionChanged: (bool expanded) {
              setState(() {
                _isJobsExpanded = expanded;
              });
            },
            children: [
              ListTile(
                title: const Text('Job Openings'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobOpeningGridScreen())),
              ),
              ListTile(
                title: const Text('Upload Resume'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UploadResumeScreen())),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (shouldLogout ?? false) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 800),
                    pageBuilder: (_, __, ___) => const LoginScreen(),
                    transitionsBuilder: (_, animation, __, child) {
                      final slideTween = Tween<Offset>(
                        begin: const Offset(0.0, -1.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeInOut));

                      final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

                      return SlideTransition(
                        position: animation.drive(slideTween),
                        child: FadeTransition(
                          opacity: animation.drive(fadeTween),
                          child: child,
                        ),
                      );
                    },
                  ),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _isValidUrl(empimg) ? NetworkImage(empimg) : null,
                child: !_isValidUrl(empimg)
                    ? const Icon(Icons.person, size: 80, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                employeeFullName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                role,
                style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            Center(child: Text(jobRole, style: const TextStyle(fontSize: 13))),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.business),
                title: Text('Company: $registercompanyname', style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
