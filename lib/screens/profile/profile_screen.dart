import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrm_dump_flutter/screens/login/login.dart';
import 'package:hrm_dump_flutter/screens/profile/employee_details.dart';
import 'package:hrm_dump_flutter/theme/colors.dart';
import 'package:hrm_dump_flutter/widget/custom_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;

  // User data variables
  int count = 0;
  int leaves = 0;
  String employeeFullName = '';
  String email = '';
  int subadminId = 0;
  int phone = 0;
  int empId = 0;
  String role = '';
  String jobRole = '';
  String empimg = '';
  String registercompanyname = '';
  String address = '';
  String birthDate = '';
  String joiningDate = '';
  String education = '';
  String gender = '';

  // Image handling
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
    resetMonthlyStatsIfNeeded().then((_) {
      setState(() {});      // Refresh UI after loading/resetting
    });

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeFullName = prefs.getString('fullName') ?? '';
      email = prefs.getString('email') ?? '';
      subadminId = prefs.getInt('subadminId') ?? 0;
      count = prefs.getInt('count') ?? 0;
      leaves = prefs.getInt('leaves') ?? 0;
      phone = prefs.getInt('phone') ?? 0;
      empId = prefs.getInt('empId') ?? 0;
      jobRole = prefs.getString('jobRole') ?? '';
      empimg = prefs.getString('empimg') ?? '';
      birthDate = prefs.getString('birthDate') ?? '';
      address = prefs.getString('address') ?? '';
      gender = prefs.getString('gender') ?? '';
      birthDate = prefs.getString('birthDate') ?? '';
    });
  }

  Future<void> _loadProfileImage() async {
    final imagePath = await _getImageFromSharedPreferences();
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        setState(() {
          empimg = imagePath;
        });
      } else {
        setState(() {
          _imageFile = File(imagePath);
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _saveImageToSharedPreferences(pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveImageToSharedPreferences(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (imagePath.startsWith('http')) {
        await prefs.setString('profileImage', imagePath);
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imagePath);
      final savedImage = await File(imagePath).copy('${appDir.path}/$fileName');

      await prefs.setString('profileImage', savedImage.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: ${e.toString()}')),
      );
    }
  }

  Future<String?> _getImageFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileStats(),
                    SizedBox(height: 20),
                    _buildTabBar(),
                    SizedBox(height: 20),
                    _buildTabContent(),
                    _buildLogoutCard(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: BackgroundPatternPainter()),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundImage:
                                    _imageFile != null
                                        ? FileImage(_imageFile!)
                                            as ImageProvider
                                        : (empimg.isNotEmpty
                                            ? NetworkImage(empimg)
                                            : AssetImage(
                                                  'assets/default_profile.png',
                                                )
                                                as ImageProvider),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () async {
                                  showModalBottomSheet(
                                    context: context,
                                    builder:
                                        (_) => SafeArea(
                                          child: Wrap(
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  Icons.photo_library,
                                                ),
                                                title: Text(
                                                  'Choose from Gallery',
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  _pickImage(
                                                    ImageSource.gallery,
                                                  );
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.camera_alt),
                                                title: Text('Take a Photo'),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  _pickImage(
                                                    ImageSource.camera,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF00D4AA),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      TweenAnimationBuilder(
                        duration: Duration(milliseconds: 1000),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Column(
                                children: [
                                  Text(
                                    employeeFullName,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10,
                                          color: Colors.black26,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      jobRole,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resetMonthlyStatsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the stored month, or null if not stored yet
    final storedMonth = prefs.getInt('month') ?? -1;

    // Get current month (1 to 12)
    final currentMonth = DateTime.now().month;

    if (storedMonth != currentMonth) {
      // New month started - reset the attendance and leaves counts
      await prefs.setInt('count', 0);
      await prefs.setInt('leaves', 0);

      // Update the stored month to current month
      await prefs.setInt('month', currentMonth);

      // Also update your in-memory variables if you have them
      count = 0;
      leaves = 0;
    } else {
      // Same month - load existing values
      count = prefs.getInt('count') ?? 0;
      leaves = prefs.getInt('leaves') ?? 0;
    }

    // Similarly load empId if needed
    // empId = prefs.getInt('empId') ?? 0;
  }


  Widget _buildProfileStats() {
    final stats = [
      {'label': 'EmpId', 'value': empId.toString(), 'icon': Icons.badge},
      {'label': 'Attendance', 'value': count.toString(), 'icon': Icons.event_available},
      {'label': 'Leaves', 'value': leaves.toString(), 'icon': Icons.event_busy},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            stats.map((stat) {
              Color valueColor;
              if (stat['label'] == 'Attendance') {
                valueColor = AppColor.green;
              } else if (stat['label'] == 'Leaves') {
                valueColor = AppColor.red;
              } else {
                valueColor = Color(0xFF2D3748);
              }

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF667eea).withOpacity(0.1),
                                Color(0xFFf093fb).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            stat['icon'] as IconData,
                            color: Color(0xFF667eea),
                            size: 24,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          stat['value'] as String,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: valueColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          stat['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: valueColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {'icon': Icons.person, 'label': 'Profile'},
      {'icon': Icons.settings, 'label': 'Settings'},
      {'icon': Icons.security, 'label': 'Privacy'},
      {'icon': Icons.info, 'label': 'About'},
    ];

    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 12),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        )
                        : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color:
                        isSelected
                            ? Color(0xFF667eea).withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 15 : 10,
                    offset: Offset(0, isSelected ? 8 : 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[index]['icon'] as IconData,
                    color: isSelected ? Colors.white : Color(0xFF718096),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    tabs[index]['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Color(0xFF718096),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildProfileContent();
      case 1:
        return _buildSettingsContent();
      case 2:
        return _buildPrivacyContent();
      case 3:
        return _buildAboutContent();
      default:
        return _buildProfileContent();
    }
  }

  Widget _buildProfileContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoCard('Personal Information', [
            _buildInfoRow(Icons.email, 'Email', email),
            _buildInfoRow(Icons.phone, 'Phone', phone.toString()),
            _buildInfoRow(Icons.location_on, 'Address', address),
            _buildInfoRow(Icons.cake, 'Birthday', birthDate),
            Center(
              child: UiHelper.customButton(
                buttonName: 'Edit',
                width: 200,
                height: 50,
                callback:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployeeDetailsScreen(),
                      ),
                    ),
              ),
            ),
            SizedBox(height: 10),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoCard('App Settings', [
            _buildSwitchRow(
              Icons.dark_mode,
              'Dark Mode',
              'Enable dark theme',
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            _buildSwitchRow(
              Icons.location_on,
              'Location Services',
              'Allow location access',
              _locationEnabled,
              (value) => setState(() => _locationEnabled = value),
            ),
            _buildActionRow(Icons.star_rate, 'Rate Us', 'Give us app rating & Feedback'),
            _buildActionRow(Icons.storage, 'Storage', '2.4 GB used'),
          ]),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showLogoutDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign out of your account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: const Text(
              "Are you sure you want to logout? You'll need to sign in again to access your account.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    if (shouldLogout ?? false) {
      await _performLogout(context);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      Navigator.pop(context);

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder:
              (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, -1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final slideTween = Tween(begin: begin, end: end);
            final curveTween = CurveTween(curve: curve);
            final slideAnimation = animation.drive(
              slideTween.chain(curveTween),
            );

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);
            final fadeAnimation = animation.drive(fadeTween.chain(curveTween));

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        ),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPrivacyContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoCard('Privacy Controls', [
            _buildActionRow(Icons.article, 'Term & Condition', 'Review our policies'),
            _buildActionRow(Icons.lock, 'Privacy Policy', 'Review privacy information'),
            _buildActionRow(Icons.language, 'Visit Our Website', 'View your activity',
            ),
            _buildActionRow(Icons.phone_iphone, 'Follow Us On Social Media', 'Join our community'),
          ]),
        ],
      ),
    );
  }

  Widget _buildAboutContent() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInfoCard('App Information', [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFFf093fb)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/HRM_logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ManagifyHR',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Streamline your workforce management with our intuitive HRM app — effortless attendance, tracking, secure employee data, and smarter HR decisions, all in one place',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF667eea), size: 20),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Color(0xFF667eea),
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDestructive ? Colors.red : Color(0xFF2D3748),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Color(0xFF718096)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF718096)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF667eea), size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF667eea),
          ),
        ],
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        canvas.drawCircle(Offset(i * 40.0, j * 40.0), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
