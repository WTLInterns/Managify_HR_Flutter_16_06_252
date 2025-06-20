import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:managify_hr/screens/login/login.dart';
import 'package:managify_hr/screens/profile/employee_details.dart';
import 'package:managify_hr/screens/profile/privacy/leave_policy.dart';
import 'package:managify_hr/screens/profile/privacy/privacy_policy.dart';
import 'package:managify_hr/screens/profile/privacy/term_&_condition.dart';
import 'package:managify_hr/theme/colors.dart';
import 'package:managify_hr/widget/custom_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NonStoringCacheManager extends CacheManager {
  static const key = 'nonStoringCache';
  static final NonStoringCacheManager _instance = NonStoringCacheManager._();
  factory NonStoringCacheManager() => _instance;

  NonStoringCacheManager._()
      : super(Config(
    key,
    fileService: HttpFileService(),
  ));
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;
  bool _darkModeEnabled = false;
  bool _locationEnabled = false;

  // User data variables
  String employeeFullName = '';
  String companyurl = '';
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
  String education = '';
  String gender = '';
  String profileImage = '';
  int totalDays = 0;
  int absentDays = 0;
  int presentDays = 0;
  double attendancePercentage = 0.0;

  // Current month for attendance data
  DateTime _selectedMonth = DateTime.now();

  // Base URL for images
  final String _imageBaseUrl = 'https://api.managifyhr.com/images/profile/';

  // Image handling
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    _loadUserData();
    _checkLocationServiceStatus(); // Check initial location service status

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
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _animationController.dispose();
    super.dispose();
  }

  // Detect when app resumes to re-check location status
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationServiceStatus(); // Re-check status when app resumes
    }
  }

  // Check if location services are enabled and update the switch state
  Future<void> _checkLocationServiceStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      serviceEnabled = permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    }
    if (mounted) {
      setState(() {
        _locationEnabled = serviceEnabled;
      });
    }
  }

  // Handle switch toggle
  Future<void> _handleLocationToggle(bool value) async {
    if (value) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return; // Status will be checked when app resumes
      }
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permission denied.')),
          );
          setState(() {
            _locationEnabled = false;
          });
        }
        return;
      }
    } else {
      await Geolocator.openLocationSettings();
      return; // Status will be checked when app resumes
    }
    if (mounted) {
      setState(() {
        _locationEnabled = value;
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String monthKey = DateFormat('yyyy_MM').format(_selectedMonth);
    setState(() {
      employeeFullName = prefs.getString('fullName') ?? '';
      email = prefs.getString('email') ?? '';
      subadminId = prefs.getInt('subadminId') ?? 0;
      phone = prefs.getInt('phone') ?? 0;
      empId = prefs.getInt('empId') ?? 0;
      jobRole = prefs.getString('jobRole') ?? '';
      empimg = prefs.getString('empimg') ?? '';
      birthDate = prefs.getString('birthDate') ?? '';
      companyurl = prefs.getString('companyurl') ?? '';
      address = prefs.getString('address') ?? '';
      gender = prefs.getString('gender') ?? '';
      profileImage = prefs.getString('profileImage') ?? '';
      presentDays = prefs.getInt('presentDays_$monthKey') ?? 0;
      absentDays = prefs.getInt('absentDays_$monthKey') ?? 0;
      totalDays = prefs.getInt('totalDays_$monthKey') ?? 0;
      attendancePercentage =
          prefs.getDouble('attendancePercentage_$monthKey') ?? 0.0;
    });
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (_isValidUrl(imagePath)) return imagePath;
    return '$_imageBaseUrl$imagePath';
  }

  Future<CacheManager> _getCacheManager() async {
    if (kIsWeb) {
      return NonStoringCacheManager();
    }
    return DefaultCacheManager();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        if (!kIsWeb) {
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = path.basename(pickedFile.path);
          final savedImage = await File(pickedFile.path).copy(
              '${appDir.path}/$fileName');

          // Verify file existence
          if (await savedImage.exists()) {
            setState(() {
              _imageFile = savedImage;
              profileImage = savedImage.path;
              empimg = ''; // Clear network image to prioritize local image
            });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('profileImage', savedImage.path);
            await prefs.setString('empimg', '');
          } else {
            throw Exception('Failed to save image to ${savedImage.path}');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image picking is not supported on web')),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<bool> _hasValidLocalImage() async {
    if (profileImage.isEmpty || kIsWeb) return false;
    return await File(profileImage).exists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: FutureBuilder<bool>(
                future: _hasValidLocalImage(),
                builder: (context, snapshot) {
                  final hasLocalImage = snapshot.data ?? false;
                  final hasValidNetworkImage = _isValidUrl(
                      _getImageUrl(empimg));
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildSliverAppBar(
                          hasValidNetworkImage && !hasLocalImage,
                          hasLocalImage),
                    ),
                  );
                },
              ),
            ),
          ),
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
    );
  }

  Widget _buildSliverAppBar(bool hasValidNetworkImage, bool hasLocalImage) {
    return Container(
      height: 320,
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
                            backgroundImage: hasLocalImage
                                ? FileImage(File(profileImage))
                                : (hasValidNetworkImage
                                ? CachedNetworkImageProvider(
                                _getImageUrl(empimg))
                                : null),
                            child: !hasLocalImage && !hasValidNetworkImage
                                ? Icon(
                                Icons.person, size: 55, color: Colors.grey)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () async {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) =>
                                    SafeArea(
                                      child: Wrap(
                                        children: [
                                          ListTile(
                                            leading: Icon(Icons.photo_library),
                                            title: Text('Choose from Gallery'),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _pickImage(ImageSource.gallery);
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.camera_alt),
                                            title: Text('Take a Photo'),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _pickImage(ImageSource.camera);
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
                                    color: Colors.white, width: 2),
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
    );
  }

  Widget _buildProfileStats() {
    final stats = [
      {'label': 'EmpId', 'value': empId.toString(), 'icon': Icons.badge},
      {
        'label': 'Attendance',
        'value': presentDays.toString(),
        'icon': Icons.event_available
      },
      {
        'label': 'Leaves',
        'value': absentDays.toString(),
        'icon': Icons.event_busy
      },
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
        children: stats.map((stat) {
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
                        size: 23,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      stat['value'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      stat['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
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
                gradient: isSelected
                    ? LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
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
                buttonName: 'Details',
                width: 320,
                height: 50,
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                callback: () =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmployeeDetailsScreen()),
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
              _handleLocationToggle,
            ),
            _buildActionRow(
              Icons.star_rate,
              'Rate Us',
              'Give us app rating & Feedback',
            ),
            _buildActionRow(
              Icons.phone_iphone,
              'Follow Us On Social Media',
              'Join our community',
              urlToLaunch: 'https://www.instagram.com/webutsav?igsh=dHRtb24wYjNsY2ly',
            ),
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
      builder: (context) =>
          AlertDialog(
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
                      horizontal: 20, vertical: 12),
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
                      horizontal: 20, vertical: 12),
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
      builder: (context) =>
      const Center(
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
          pageBuilder: (context, animation,
              secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, -1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final slideTween = Tween(begin: begin, end: end);
            final curveTween = CurveTween(curve: curve);
            final slideAnimation = animation.drive(
                slideTween.chain(curveTween));

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
            _buildActionRow(
              Icons.article,
              'Term & Condition',
              'What you need to know',
              destinationScreen: TermsAndConditionsScreen(),
            ),
            _buildActionRow(
              Icons.lock,
              'Privacy Policy',
              'Review privacy information',
              destinationScreen: PrivacyPolicyScreen(),
            ),
            _buildActionRow(
                Icons.fact_check,
                'Leave Policy',
                "Company Leave Guidelines",
                destinationScreen: LeavePolicyScreen()
            ),
            _buildActionRow(
              Icons.language,
              'Visit Our Website',
              'View your activity',
              urlToLaunch: companyurl,
            ),
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

  Widget _buildActionRow(IconData icon,
      String title,
      String subtitle, {
        bool isDestructive = false,
        String? urlToLaunch,
        Widget? destinationScreen,
      }) {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();

        if (destinationScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        } else if (urlToLaunch != null) {
          final Uri url = Uri.parse(urlToLaunch);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
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

  // Your original _buildSwitchRow widget
  Widget _buildSwitchRow(IconData icon,
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,) {
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
    final paint = Paint()
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