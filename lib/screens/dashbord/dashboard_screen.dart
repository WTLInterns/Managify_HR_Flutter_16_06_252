import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrm_dump_flutter/screens/dailyGoals/daily_goals.dart';
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
  int _selectedIndex = 0;

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
    return uri != null &&
        uri.hasAbsolutePath &&
        (uri.isScheme('http') || uri.isScheme('https'));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home - Stay on Dashboard
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DailyGoalsScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _onItemTapped(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSelected ? 8 : 6), // Reduced padding
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 8.0, // Reduced blur
                  offset: Offset(0, 2), // Reduced offset
                  spreadRadius: 0,
                ),
              ] : null,
            ),
            child: AnimatedScale(
              duration: Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              scale: isSelected ? 1.1 : 1.0,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: isSelected ? 24 : 22, // Reduced icon size
              ),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 300),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: isSelected ? 11 : 10, // Reduced font size
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Instead of left padding, use this for centering
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),

      body: _buildDashboardContent(),
      bottomNavigationBar: Container(
        height: 63,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 25,
              offset: Offset(0, -10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          child: Stack(
            children: [
              // Navigation items
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                // Reduced vertical padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_filled, 'Home'),
                    _buildNavItem(1, Icons.track_changes, 'Goals'),
                    _buildNavItem(2, Icons.person, 'Profile'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final bool hasValidNetworkImage = _isValidUrl(empimg);
    final bool hasLocalImage = profileImage.isNotEmpty && File(profileImage).existsSync();

    // Get screen dimensions and safe area insets
    final mediaQuery = MediaQuery.of(context);
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = mediaQuery.padding.top;
    final bottomNavHeight = 63.0;
    final bottomSafeArea = mediaQuery.padding.bottom;

    // Calculate available height for the drawer
    final availableHeight = mediaQuery.size.height -
        appBarHeight -
        statusBarHeight -
        bottomNavHeight -
        bottomSafeArea;

    return Drawer(
      child: Container(
        height: availableHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildUserHeader(hasValidNetworkImage, hasLocalImage),
            const SizedBox(height: 8),
            _buildAnimatedTile(
              icon: Icons.home_rounded,
              title: 'Home',
              color: Colors.indigo,
              onTap: () => Navigator.pop(context),
            ),
            _buildAnimatedTile(
              icon: Icons.event_available_rounded,
              title: 'Attendance Form',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                _createSlidePageRoute(AttendanceFormPage()),
              ),
            ),
            _buildAnimatedTile(
              icon: Icons.list_alt_rounded,
              title: 'Attendance Records',
              color: Colors.cyan,
              onTap: () => Navigator.push(
                context,
                _createSlidePageRoute(AttendancesRecordsScreen()),
              ),
            ),
            _buildAnimatedTile(
              icon: Icons.event_busy_rounded,
              title: 'Leave',
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                _createSlidePageRoute(LeaveScreen()),
              ),
            ),
            _buildAnimatedTile(
              icon: Icons.assignment_turned_in_rounded,
              title: 'Leave Records',
              color: Colors.amber,
              onTap: () => Navigator.push(
                context,
                _createSlidePageRoute(
                  LeaveRecordsTable(
                    subadminId: subadminId,
                    name: employeeFullName,
                  ),
                ),
              ),
            ),
            _buildJobsExpansionTile(),
            const Divider(height: 32, thickness: 1, color: Colors.grey),
            _buildAnimatedTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              color: Colors.red,
              isDestructive: true,
              onTap: _handleLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(bool hasValidNetworkImage, bool hasLocalImage) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade800,
            Colors.indigo.shade800,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: UserAccountsDrawerHeader(
        decoration: const BoxDecoration(color: Colors.transparent),
        accountName: Text(
          employeeFullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        accountEmail: Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        currentAccountPicture: Hero(
          tag: 'profile_avatar',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: hasValidNetworkImage
                  ? NetworkImage(empimg)
                  : (hasLocalImage ? FileImage(File(profileImage)) : null),
              child: (!hasValidNetworkImage && !hasLocalImage)
                  ? const Icon(Icons.person_rounded, size: 50, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          onTap: () {
            // Add haptic feedback
            HapticFeedback.lightImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red.shade700 : Colors.grey.shade800,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobsExpansionTile() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _isJobsExpanded ? Colors.purple.withOpacity(0.05) : Colors.transparent,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: Colors.purple,
              size: 22,
            ),
          ),
          title: Text(
            'Jobs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _isJobsExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.expand_more_rounded,
              color: Colors.grey.shade400,
            ),
          ),
          initiallyExpanded: _isJobsExpanded,
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isJobsExpanded = expanded;
            });
            HapticFeedback.selectionClick();
          },
          children: [
            _buildSubTile(
              'Job Openings',
              Icons.work_rounded,
              Colors.purple.shade300,
                  () => Navigator.push(
                context,
                _createSlidePageRoute(JobOpeningGridScreen()),
              ),
            ),
            _buildSubTile(
              'Upload Resume',
              Icons.upload_file_rounded,
              Colors.purple.shade400,
                  () => Navigator.push(
                context,
                _createSlidePageRoute(UploadResumeScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 8, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade300,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _createSlidePageRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final offsetAnimation = animation.drive(tween);
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();

    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text("Logout", style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
  }

  Widget _buildDashboardContent() {
    final bool hasValidNetworkImage = _isValidUrl(empimg);
    final bool hasLocalImage =
        profileImage.isNotEmpty && File(profileImage).existsSync();
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
                backgroundImage:
                    hasValidNetworkImage
                        ? NetworkImage(empimg)
                        : (hasLocalImage
                            ? FileImage(File(profileImage))
                            : null),
                child:
                    (!hasValidNetworkImage && !hasLocalImage)
                        ? const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                employeeFullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                role,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(child: Text(jobRole, style: const TextStyle(fontSize: 13))),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.business),
                title: Text(
                  'Company: $registercompanyname',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
